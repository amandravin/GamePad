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

#import "HIDElement.h"


@interface HIDElement()
{
    IOHIDElementRef    m_elementRef;
    IOHIDElementType   m_type;
    uint32_t           m_usage;
    uint32_t           m_usagePage;
    BOOL               m_virtual;
    BOOL               m_relative;
    BOOL               m_wrapping;
    BOOL               m_nonLinear;
    BOOL               m_array;
    BOOL               m_preferredState;
    BOOL               m_nullState;
    uint32_t           m_reportID;
    uint32_t           m_reportSize;
    uint32_t           m_reportCount;
    uint32_t           m_unit;
    uint32_t           m_unitExponent;
    CFIndex            m_logicalMin;
    CFIndex            m_logicalMax;
    CFIndex            m_physicalMin;
    CFIndex            m_physicalMax;

    int32_t            m_latestValue;
}

+ (NSString*) pageNameFromUsagePage:(NSUInteger)usagePage;

@end


@implementation HIDElement

@synthesize m_elementRef;
@synthesize m_type;
@synthesize m_usage;
@synthesize m_usagePage;
@synthesize m_virtual;
@synthesize m_relative;
@synthesize m_wrapping;
@synthesize m_nonLinear;
@synthesize m_array;
@synthesize m_reportID;
@synthesize m_reportSize;
@synthesize m_reportCount;
@synthesize m_unit;
@synthesize m_unitExponent;
@synthesize m_logicalMin;
@synthesize m_logicalMax;
@synthesize m_physicalMin;
@synthesize m_physicalMax;
@synthesize m_preferredState;
@synthesize m_nullState;
@synthesize m_latestValue;

- (id) initWithElementRef:(IOHIDElementRef)elementRef
{
    if (self = [super init])
    {
        m_elementRef = (IOHIDElementRef)CFRetain(elementRef);
        m_type = IOHIDElementGetType(elementRef);
        m_usagePage = IOHIDElementGetUsagePage(elementRef);
        m_usage = IOHIDElementGetUsage(elementRef);
        m_virtual = IOHIDElementIsVirtual(elementRef);
        m_relative = IOHIDElementIsRelative(elementRef);
        m_wrapping = IOHIDElementIsWrapping(elementRef);
        m_array = IOHIDElementIsArray(elementRef);
        m_nonLinear = IOHIDElementIsNonLinear(elementRef);
        m_preferredState = IOHIDElementHasPreferredState(elementRef);
        m_nullState = IOHIDElementHasNullState(elementRef);
		m_reportID = IOHIDElementGetReportID(elementRef);
		m_reportSize = IOHIDElementGetReportSize(elementRef);
		m_reportCount = IOHIDElementGetReportCount(elementRef);
        m_unit = IOHIDElementGetUnit(elementRef);
        m_unitExponent = IOHIDElementGetUnitExponent(elementRef);
        m_logicalMin = IOHIDElementGetLogicalMin(elementRef);
        m_logicalMax = IOHIDElementGetLogicalMax(elementRef);
        m_physicalMin = IOHIDElementGetPhysicalMin(elementRef);
        m_physicalMax = IOHIDElementGetPhysicalMax(elementRef);
        m_latestValue = 0;
    }

    return self;
}

- (void) dealloc
{
    if (m_elementRef)
    {
        CFRelease(m_elementRef);
    }

    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"id[%ld] pname[%@] t[%d] up[%d] u[%d] v[%d] r[%d] w[%d] a[%d] nl[%d] ps[%d], ns[%d] rid[%d] rs[%d] rc[%d] u[%d] uex[%d] lmin[%d] lmax[%d] pmin[%d] pmax[%d]",
        (long)m_elementRef, [HIDElement pageNameFromUsagePage:m_usagePage], (int)m_type, (int)m_usagePage, (int)m_usage, (int)m_virtual, (int)m_relative, 
        (int)m_wrapping, (int)m_array, (int)m_nonLinear, (int)m_preferredState, (int)m_nullState, (int)m_reportID, (int)m_reportSize, (int)m_reportCount,
        (int)m_unit, (int)m_unitExponent, (int)m_logicalMin, (int)m_logicalMax, (int)m_physicalMin, (int)m_physicalMax];
}

+ (NSString*) pageNameFromUsagePage:(NSUInteger)usagePage
{
    if ((usagePage >= 0x11 && usagePage <= 0x13) ||
        (usagePage >= 0x15 && usagePage <= 0x3F) ||
        (usagePage >= 0x41 && usagePage <= 0x7F) ||
        (usagePage >= 0x88 && usagePage <= 0x8B) ||
        (usagePage >= 0x92 && usagePage <= 0xFEFF))
    {
        return @"Reserved";
    }
    else if (usagePage >= 0x80 && usagePage <= 0x83)
    {
        return @"Monitor Pages";
    }
    else if (usagePage >= 0x84 && usagePage <= 0x87)
    {
        return @"Power Pages";
    }
    else if (usagePage >= 0xFF00 && usagePage <= 0xFFFF)
    {
        return @"Vendor Defined";
    }

    switch (usagePage)
    {
        case 0x00:
            return @"Undefined";

        case 0x01:
            return @"Generic Desktop Controls";

        case 0x02:
            return @"Simulation Controls";

        case 0x03:
            return @"VR Controls";

        case 0x04:
            return @"Sport Controls";

        case 0x05:
            return @"Game Controls";

        case 0x06:
            return @"Generic Device Controls";

        case 0x07:
            return @"Keyboard/Keypad";

        case 0x08:
            return @"LEDs";

        case 0x09:
            return @"Button";

        case 0x0A:
            return @"Ordinal";

        case 0x0B:
            return @"Telephony";

        case 0x0C:
            return @"Consumer";

        case 0x0D:
            return @"Digitizer";

        case 0x0E:
            return @"Reserved";

        case 0x0F:
            return @"PID Page";

        case 0x10:
            return @"Unicode";

        case 0x14:
            return @"Alphanumeric Display";

        case 0x40:
            return @"Medical Instruments";

        case 0x8C:
            return @"Bar Code Scanner Page";

        case 0x8D:
            return @"Scale Page";

        case 0x8E:
            return @"MSR Device";

        case 0x8F:
            return @"Reserved Point of Scale Page";

        case 0x90:
            return @"Camera Control Page";

        case 0x91:
            return @"Arcade Page";

        default:
            return @"Unknown";
    }
}

+ (NSString*) convertElementRefToString:(IOHIDElementRef)elementRef
{
    if (!elementRef)
    {
        return nil;
    }

    return [NSString stringWithFormat:@"ElementRef=%llx", (long long)elementRef];
}

@end
