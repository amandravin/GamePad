/*
 * Copyright (c) 2013, Alexander Mandravin(alexander.mandravin@gmail.com)
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies, 
 * either expressed or implied, of the FreeBSD Project.
 */

#import "HIDDevice.h"
#import "ThreadUtil.h"


static void
hid_device_report_callback(void* context, IOReturn inResult, void* inSender, IOHIDReportType inType, uint32_t inReportID, uint8_t* inReport, CFIndex inReportLength);

static void
hid_device_input_value_callback(void* context, IOReturn result, void* sender, IOHIDValueRef value);


@interface HIDDevice()

- (void) deviceReport:(IOHIDReportType)reportType reportID:(uint32_t)reportID reportBytes:(uint8_t*)reportBytes reportLength:(CFIndex)reportLength;
- (void) deviceValue:(IOHIDValueRef)valueRef;

@end


@implementation HIDDevice

- (id) initWithDeviceRef:(IOHIDDeviceRef)deviceRef runLoop:(CFRunLoopRef)runLoop
{
    if (self = [super init])
    {
        m_reportData = NULL;
        m_deviceRef = (IOHIDDeviceRef)CFRetain(deviceRef);
        m_deviceRunLoop = runLoop;
        m_elementDictionary = [[NSMutableDictionary alloc] init];

        CFArrayRef array = IOHIDDeviceCopyMatchingElements(deviceRef, nil, kIOHIDOptionsTypeNone);
        if (array)
        {
            NSArray* elements = (NSArray*)array;
            for (id object in elements)
            {
                IOHIDElementRef element = (IOHIDElementRef)object;
                NSString* key = [HIDElement convertElementRefToString:element];
                HIDElement* hidElement = [m_elementDictionary objectForKey:key];
                if (!hidElement)
                {
                    hidElement = [[[HIDElement alloc] initWithElementRef:element] autorelease];
                    [m_elementDictionary setObject:hidElement forKey:key];
                }
            }

            CFRelease(array);
        }

        {
            id name = (id)IOHIDDeviceGetProperty(m_deviceRef, CFSTR(kIOHIDProductKey));
            if (name && [name isKindOfClass:[NSString class]])
            {
                m_deviceName = [[NSString stringWithString:(NSString*)name] retain];
            }
        }
    }

    return self;
}

- (void) dealloc
{
    [self stopListening];

    if (m_reportData)
    {
        free(m_reportData);
    }

    if (m_deviceRef)
    {
        CFRelease(m_deviceRef);
    }

    [m_elementDictionary release];
    [m_deviceName release];

    [super dealloc];
}

- (BOOL) startListening
{
    __block BOOL result = NO;

    [CustomThread syncRunBlock: ^
    {
        if (m_reportData)
        {
            result = YES;
            return;
        }

        if (!m_deviceRef)
        {
            return;
        }

        IOHIDDeviceScheduleWithRunLoop(m_deviceRef, m_deviceRunLoop, kCFRunLoopDefaultMode);

        uint32_t length = [(NSNumber*)IOHIDDeviceGetProperty(m_deviceRef, CFSTR(kIOHIDMaxInputReportSizeKey)) unsignedIntValue];
        m_reportData = (uint8_t*)malloc(length);
        if (!m_reportData)
        {
            IOHIDDeviceRegisterInputReportCallback(m_deviceRef, NULL, 0, NULL, NULL);
            IOHIDDeviceRegisterInputValueCallback(m_deviceRef, NULL, NULL);
            IOHIDDeviceUnscheduleFromRunLoop(m_deviceRef, m_deviceRunLoop, kCFRunLoopDefaultMode);
            return;
        }

        //IOHIDDeviceRegisterInputReportCallback(m_deviceRef, m_reportData, length, hid_device_report_callback, self);
        IOHIDDeviceRegisterInputValueCallback(m_deviceRef, hid_device_input_value_callback, self);

        result = YES;
    }
    inRunLoop:m_deviceRunLoop];

    return result;
}

- (void) stopListening
{
    [CustomThread syncRunBlock: ^
    {
        if (!m_reportData)
        {
            return;
        }

        if (m_deviceRef)
        {
            IOHIDDeviceRegisterInputReportCallback(m_deviceRef, NULL, 0, NULL, NULL);
            IOHIDDeviceRegisterInputValueCallback(m_deviceRef, NULL, NULL);
            IOHIDDeviceUnscheduleFromRunLoop(m_deviceRef, m_deviceRunLoop, kCFRunLoopDefaultMode);
        }

        free(m_reportData);
        m_reportData = NULL;
    }
    inRunLoop:m_deviceRunLoop];
}

- (void) invalidate
{
    [CustomThread syncRunBlock: ^
    {
        [self stopListening];

        if (m_deviceRef)
        {
            CFRelease(m_deviceRef);
            m_deviceRef = nil;
        }
    }
    inRunLoop:m_deviceRunLoop];
}

- (void) deviceReport:(IOHIDReportType)reportType reportID:(uint32_t)reportID reportBytes:(uint8_t*)reportBytes reportLength:(CFIndex)reportLength
{
    // Not needed for now
}

- (void) deviceValue:(IOHIDValueRef)valueRef
{
    if (!valueRef)
    {
        return;
    }

    IOHIDElementRef elementRef = IOHIDValueGetElement(valueRef);
    if (!elementRef)
    {
        return;
    }

    NSString* key = [HIDElement convertElementRefToString:elementRef];
    HIDElement* hidElement = [m_elementDictionary objectForKey:key];
    if (!hidElement)
    {
        hidElement = [[[HIDElement alloc] initWithElementRef:elementRef] autorelease];
        [m_elementDictionary setObject:hidElement forKey:key];
    }

	uint32_t length = (uint32_t)IOHIDValueGetLength(valueRef);
	const uint8_t* data = IOHIDValueGetBytePtr(valueRef);
    if (length && data)
    {
        int32_t value = 0;
        for (int i = 0; i < length; i++)
        {
            value |= data[i] << i;
        }

        if (hidElement.m_latestValue != value)
        {
            hidElement.m_latestValue = value;
            //NSLog(@"deviceValue [%d] el[%@]", hidElement.m_latestValue, hidElement);
            [self elementValueChanged:hidElement];
        }
    }
}

- (NSString*) getDeviceName
{
    return m_deviceName;
}

- (void) elementValueChanged:(HIDElement*)element
{
    // Dummy
}

static void
hid_device_report_callback(void* context, IOReturn inResult, void* inSender, IOHIDReportType inType, uint32_t inReportID, uint8_t* inReport, CFIndex inReportLength)
{
    [(HIDDevice*)context deviceReport:inType reportID:inReportID reportBytes:inReport reportLength:inReportLength];
}

static void
hid_device_input_value_callback(void* context, IOReturn result, void* sender, IOHIDValueRef value)
{
    [(HIDDevice*)context deviceValue:value];
}

@end
