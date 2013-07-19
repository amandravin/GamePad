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

#import "GamePadPrivate.h"
#import "ThreadUtil.h"


@interface GamePadControl()
{
    HIDElement*             m_hidElement;
    GAMEPAD_CONTROL_TYPE    m_type;

    NSLock*                 m_lock;
    int32_t                 m_value;
}

@property (nonatomic, retain) HIDElement*             m_hidElement;
@property (nonatomic, assign) GAMEPAD_CONTROL_TYPE    m_type;

+ (GamePadControl*) createGamePadControlWithHIDElement:(HIDElement*)element;
+ (int32_t) requestValueForElement:(HIDElement*)element;
- (BOOL) updateValue:(int32_t)value;

@end


@implementation GamePadControl

@synthesize m_hidElement;
@synthesize m_type;

- (id) init
{
    if (self = [super init])
    {
        m_lock = [[NSLock alloc] init];
        m_value = 0;
    }

    return self;
}

+ (GamePadControl*) createGamePadControlWithHIDElement:(HIDElement*)element
{
    //NSLog(@"elem = [%@]", element);
    if (element.m_type == kIOHIDElementTypeInput_Button && element.m_usagePage == kUsage_PageButton)
    {
        // Button
        if ((GAMEPAD_CONTROL_TYPE)element.m_usage > GAMEPAD_BUTTON_BEGIN &&
            (GAMEPAD_CONTROL_TYPE)element.m_usage < GAMEPAD_BUTTON_END)
        {
            GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
            control.m_type = (GAMEPAD_CONTROL_TYPE)element.m_usage;
            control.m_hidElement = element;
            [control updateValue:[GamePadControl requestValueForElement:element]];
            return control;
        }
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_HatSwitch)
    {
        // D-Pad
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_DPAD;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    // Axis
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_X)
    {
        // X
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_X;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Y)
    {
        // Y
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_Y;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Z)
    {
        // Z
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_Z;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Rx)
    {
        // RX
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_RX;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Ry)
    {
        // RY
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_RY;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Rz)
    {
        // RZ
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_AXIS_RZ;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    else if (element.m_usagePage == kUsage_PageGenericDesktop && element.m_usage == kUsage_01_Slider)
    {
        // Slider
        GamePadControl* control = [[[GamePadControl alloc] init] autorelease];
        control.m_type = GAMEPAD_SLIDER;
        control.m_hidElement = element;
        [control updateValue:[GamePadControl requestValueForElement:element]];
        return control;
    }
    return nil;
}

- (void) dealloc
{
    [m_hidElement release];
    [m_lock release];
    [super dealloc];
}

+ (int32_t) requestValueForElement:(HIDElement*)element
{
    if (!element || !element.m_elementRef)
    {
        return 0;
    }

    IOHIDDeviceRef deviceRef = IOHIDElementGetDevice(element.m_elementRef);
    if (!deviceRef)
    {
        return 0;
    }

    IOHIDValueRef valueRef = nil;
    IOReturn result = IOHIDDeviceGetValue(deviceRef, element.m_elementRef, &valueRef);
    if (result)
    {
        return 0;
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

        return value;
    }

    return 0;
}

- (BOOL) updateValue:(int32_t)value
{
    CustomLock lock(m_lock);
    if (m_value == value)
    {
        return NO;
    }

    m_value = value;
    return YES;
}

- (GAMEPAD_CONTROL_TYPE) getControlType
{
    return m_type;
}

- (int32_t) getIntegerValue
{
    CustomLock lock(m_lock);
    return m_value;
}

- (int32_t) getMinSupportedValue
{
    return (int32_t)m_hidElement.m_physicalMin;
}

- (int32_t) getMaxSupportedValue
{
    return (int32_t)m_hidElement.m_physicalMax;
}

@end


@interface GamePadPrivate()
{
    id                      m_master;
    id<GamePadDelegate>     m_delegate;
    CFRunLoopRef            m_delegateRunLoop;

    BOOL                    m_parsed;
    BOOL                    m_valid;

    NSDictionary*           m_controls;
}

@property (nonatomic, assign) id  m_master;

- (BOOL) startListeningWithDelegate:(id<GamePadDelegate>)delegate;
- (NSArray*) getControls;

- (BOOL) parse;
- (GamePadControl*) getControlByHIDElement:(HIDElement*)element;

@end


@implementation GamePadPrivate

@synthesize m_master;

- (void) dealloc
{
    m_delegate = nil;
    [m_controls release];
    [super dealloc];
}

- (BOOL) isGamepadValid
{
    if (m_parsed)
    {
        return m_valid;
    }

    m_parsed = YES;
    m_valid = NO;

    // Looking for GamePad
    for (HIDElement* element in [m_elementDictionary allValues])
    {
        if (element.m_type == kIOHIDElementTypeCollection &&
            element.m_usagePage == kUsage_PageGenericDesktop &&
            element.m_usage == kUsage_01_GamePad)
        {
            m_valid = [self parse];
            break;
        }
    }

    return m_valid;
}

- (BOOL) parse
{
    if (m_controls)
    {
        [m_controls release];
        m_controls = nil;
    }

    NSMutableDictionary* controls = [NSMutableDictionary dictionary];

    for (HIDElement* element in [m_elementDictionary allValues])
    {
        GamePadControl* control = [GamePadControl createGamePadControlWithHIDElement:element];
        if (control)
        {
            NSString* key = [HIDElement convertElementRefToString:element.m_elementRef];
            if (key)
            {
                [controls setObject:control forKey:key];
            }
        }
    }

    if ([controls count] > 0)
    {
        m_controls = [[NSDictionary dictionaryWithDictionary:controls] retain];
    }

    return (m_controls != nil);
}

- (GamePadControl*) getControlByHIDElement:(HIDElement*)element
{

    NSString* key = [HIDElement convertElementRefToString:element.m_elementRef];
    if (key)
    {
        GamePadControl* control = [m_controls objectForKey:key];
        return control;
    }

    return nil;
}

- (BOOL) startListeningWithDelegate:(id<GamePadDelegate>)delegate
{
    m_delegate = delegate;
    m_delegateRunLoop = CFRunLoopGetCurrent();
    return [self startListening];
}

- (void) invalidate
{
    m_delegate = nil;
    [super invalidate];
}

- (void) stopListening
{
    m_delegate = nil;
    [super stopListening];
}

- (NSArray*) getControls
{
    return [m_controls allValues];
}

- (void) elementValueChanged:(HIDElement*)element
{
    GamePadControl* control = [self getControlByHIDElement:element];
    if (control && [control updateValue:element.m_latestValue])
    {
        [control retain];
        [CustomThread asyncRunBlock: ^
        {
            if ([m_delegate respondsToSelector:@selector(gamePad:didChangeValueForControl:)])
            {
                [m_delegate gamePad:m_master didChangeValueForControl:control];
            }

            [control release];
        }
        inRunLoop:m_delegateRunLoop];
    }
}

@end


@implementation GamePad

- (id) initWithGamePadPrivate:(GamePadPrivate*)priv
{
    if (self = [super init])
    {
        m_private = [priv retain];
        priv.m_master = self;
    }

    return self;
}

- (void) dealloc
{
    [m_private invalidate];
    [m_private release];
    [super dealloc];
}

- (void) invalidate
{
    [m_private invalidate];
}

- (BOOL) startListeningWithDelegate:(id<GamePadDelegate>)delegate
{
    return [m_private startListeningWithDelegate:delegate];
}

- (void) stopListening
{
    [m_private stopListening];
}

- (NSString*) getDeviceName
{
    return [m_private getDeviceName];
}

- (NSArray*) getControls
{
    return [m_private getControls];
}

@end
