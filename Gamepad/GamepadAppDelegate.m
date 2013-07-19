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

#import "GamepadAppDelegate.h"


@implementation ControlView

@synthesize m_x;
@synthesize m_y;

- (id) init
{
    if (self = [super init])
    {
        [self setEditable:NO];
        [self setBackgroundColor:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0]];

        m_center = [[NSTextField alloc] init];
        [m_center setEditable:NO];
        [m_center setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
        m_center.frame = CGRectMake(0, 0, 10, 10);
        [self addSubview:m_center];

        [self setCenterX:0.0 y:0.0];
    }

    return self;
}

- (void) dealloc
{
    [m_center release];
    [super dealloc];
}

- (void) setCenterX:(float)x y:(float)y
{
    float xPos = (1.0 + x) * self.bounds.size.width / 2.0;
    float yPos = (1.0 + y) * self.bounds.size.height / 2.0;

    m_x = x;
    m_y = y;

    xPos = MIN(self.bounds.size.width - m_center.frame.size.width / 2.0, MAX(m_center.frame.size.width / 2.0, xPos));
    yPos = MIN(self.bounds.size.height - m_center.frame.size.height / 2.0, MAX(m_center.frame.size.height / 2.0, yPos));
    m_center.frame = CGRectMake(xPos - m_center.frame.size.width / 2.0,
                                yPos - m_center.frame.size.height / 2.0,
                                m_center.frame.size.width,
                                m_center.frame.size.height);
}

@end


@interface GamepadAppDelegate()

- (void) setActive:(NSTextField*)field active:(BOOL)active;
- (void) setUIToInitialState;
- (void) hideAllControls;
- (BOOL) attachToGamePad:(GamePad*)gamePad;
- (void) detachFromGamePad:(GamePad*)gamePad;

@end


@implementation GamepadAppDelegate

- (void)dealloc
{
    [m_gamePad release];
    [m_gpManager release];

    [m_control1 release];
    [m_control2 release];
    [m_control3 release];
    [m_control4 release];
    [m_control5 release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    m_control1 = [[ControlView alloc] init];
    m_control1.frame = CGRectMake(50, 210, 100, 100);
    [_window.contentView addSubview:m_control1];

    m_control2 = [[ControlView alloc] init];
    m_control2.frame = CGRectMake(40, 60, 100, 100);
    [_window.contentView addSubview:m_control2];

    m_control3 = [[ControlView alloc] init];
    m_control3.frame = CGRectMake(190, 60, 100, 100);
    [_window.contentView addSubview:m_control3];

    m_control4 = [[ControlView alloc] init];
    m_control4.frame = CGRectMake(340, 60, 100, 100);
    [_window.contentView addSubview:m_control4];

    m_control5 = [[ControlView alloc] init];
    m_control5.frame = CGRectMake(40, 25, 400, 14);
    [_window.contentView addSubview:m_control5];

    m_buttons[0] = m_label1;
    m_buttons[1] = m_label2;
    m_buttons[2] = m_label3;
    m_buttons[3] = m_label4;
    m_buttons[4] = m_label5;
    m_buttons[5] = m_label6;
    m_buttons[6] = m_label7;
    m_buttons[7] = m_label8;
    m_buttons[8] = m_label9;
    m_buttons[9] = m_label10;
    m_buttons[10] = m_label11;
    m_buttons[11] = m_label12;

    [self setUIToInitialState];

    // Initialize gamepad manager
    m_gpManager = [[GamePadManager alloc] initWithDelegate:self];

    // Start watching for plug/unplug gamepads. See GamePadManagerDelegate.
    [m_gpManager startWatching];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void) setActive:(NSTextField*)field active:(BOOL)active
{
    if (active)
    {
        field.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    }
    else
    {
        field.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
}

- (void) setUIToInitialState
{
    for (int i = 0; i < BUTTONS_COUNT; i++)
    {
        [self setActive:m_buttons[i] active:NO];
        [m_buttons[i] setHidden:NO];
    }

    [m_control1 setCenterX:0.0 y:0.0];
    [m_control2 setCenterX:0.0 y:0.0];
    [m_control3 setCenterX:0.0 y:0.0];
    [m_control4 setCenterX:0.0 y:0.0];
    [m_control5 setCenterX:0.0 y:0.0];

    [m_control1 setHidden:NO];
    [m_control2 setHidden:NO];
    [m_control3 setHidden:NO];
    [m_control4 setHidden:NO];
    [m_control5 setHidden:NO];

    m_labelConnected.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    [m_labelName setStringValue:@"Gamepad is not connected"];
}

- (void) hideAllControls
{
    for (int i = 0; i < BUTTONS_COUNT; i++)
    {
        [self setActive:m_buttons[i] active:NO];
        [m_buttons[i] setHidden:YES];
    }

    [m_control1 setHidden:YES];
    [m_control2 setHidden:YES];
    [m_control3 setHidden:YES];
    [m_control4 setHidden:YES];
    [m_control5 setHidden:YES];
}

- (BOOL) attachToGamePad:(GamePad*)gamePad
{
    if (m_gamePad || gamePad == nil)
    {
        // Ignore other gamepads since we have attached one already
        return NO;
    }

    m_gamePad = [gamePad retain];

    // Start listening this gamepad. See GamePadDelegate.
    if (![m_gamePad startListeningWithDelegate:self])
    {
        //  Listening failed
        [m_gamePad release];
        m_gamePad = nil;
        return NO;
    }

    m_labelConnected.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0];

    NSString* deviceName = [m_gamePad getDeviceName];
    [m_labelName setStringValue:(deviceName != nil ? deviceName : @"Unknown gamepad")];

    [self hideAllControls];

    for (GamePadControl* control in [m_gamePad getControls])
    {
        if ([control getControlType] > GAMEPAD_BUTTON_BEGIN && [control getControlType] <= BUTTONS_COUNT)
        {
            [m_buttons[[control getControlType] - 1] setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_DPAD)
        {
            [m_control1 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_X)
        {
            [m_control2 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_Y)
        {
            [m_control2 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_RX)
        {
            [m_control4 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_RY)
        {
            [m_control4 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_Z)
        {
            [m_control3 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_AXIS_RZ)
        {
            [m_control3 setHidden:NO];
        }
        else if ([control getControlType] == GAMEPAD_SLIDER)
        {
            [m_control5 setHidden:NO];
        }
    }

    return YES;
}

- (void) detachFromGamePad:(GamePad*)gamePad
{
    if (gamePad == m_gamePad)
    {
        [m_gamePad release];
        m_gamePad = nil;

        [self setUIToInitialState];
    }
}

- (void) gamePadManager:(id)sender didAttachGamePad:(GamePad*)gamePad
{
    // New gamepad is plugged
    [self attachToGamePad:gamePad];
}

- (void) gamePadManager:(id)sender didDetachGamePad:(GamePad*)gamePad
{
    // Known gamepad is unplugged
    [self detachFromGamePad:gamePad];

    if (m_gamePad == nil)
    {
        NSArray* gamepads = [m_gpManager getGamepads];
        for (int i = 0; i < [gamepads count]; i++)
        {
            if ([self attachToGamePad:[gamepads objectAtIndex:i]])
            {
                break;
            }
        }
    }
}

- (void) gamePad:(id)sender didChangeValueForControl:(GamePadControl*)control
{
    // Gamepad control value is changed
    if (sender != m_gamePad)
    {
        // Ignore events from other gamepads
        return;
    }

    if ([control getControlType] > GAMEPAD_BUTTON_BEGIN && [control getControlType] <= BUTTONS_COUNT)
    {
        // BUTTON
        [self setActive:m_buttons[[control getControlType] - 1] active:[control getIntegerValue] != 0];
    }
    else if ([control getControlType] == GAMEPAD_DPAD)
    {
        // DPAD
        switch ((GAMEPAD_DPAD_VALUE)[control getIntegerValue])
        {
            case GAMEPAD_DPAD_UP:
                [m_control1 setCenterX:0.0 y:-1.0];
                break;

            case GAMEPAD_DPAD_RIGHT_UP:
                [m_control1 setCenterX:1.0 y:-1.0];
                break;

            case GAMEPAD_DPAD_RIGHT:
                [m_control1 setCenterX:1.0 y:0.0];
                break;

            case GAMEPAD_DPAD_RIGHT_DOWN:
                [m_control1 setCenterX:1.0 y:1.0];
                break;

            case GAMEPAD_DPAD_DOWN:
                [m_control1 setCenterX:0.0 y:1.0];
                break;

            case GAMEPAD_DPAD_LEFT_DOWN:
                [m_control1 setCenterX:-1.0 y:1.0];
                break;

            case GAMEPAD_DPAD_LEFT:
                [m_control1 setCenterX:-1.0 y:0.0];
                break;

            case GAMEPAD_DPAD_LEFT_UP:
                [m_control1 setCenterX:-1.0 y:-1.0];
                break;

            case GAMEPAD_DPAD_FREE:
                [m_control1 setCenterX:0.0 y:0.0];
                break;

            default:
                break;
        }
    }
    else if ([control getControlType] == GAMEPAD_AXIS_X)
    {
        [m_control2 setCenterX:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue] y:m_control2.m_y];
    }
    else if ([control getControlType] == GAMEPAD_AXIS_Y)
    {
        [m_control2 setCenterX:m_control2.m_x y:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue]];
    }
    else if ([control getControlType] == GAMEPAD_AXIS_RX)
    {
        [m_control4 setCenterX:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue] y:m_control4.m_y];
    }
    else if ([control getControlType] == GAMEPAD_AXIS_RY)
    {
        [m_control4 setCenterX:m_control4.m_x y:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue]];
    }
    else if ([control getControlType] == GAMEPAD_AXIS_Z)
    {
        [m_control3 setCenterX:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue] y:m_control3.m_y];
    }
    else if ([control getControlType] == GAMEPAD_AXIS_RZ)
    {
        [m_control3 setCenterX:m_control3.m_x y:-1.0 + 2.0 * [control getIntegerValue] / [control getMaxSupportedValue]];
    }
    else if ([control getControlType] == GAMEPAD_SLIDER)
    {
        [m_control5 setCenterX:1.0 - 2.0 * [control getIntegerValue] / [control getMaxSupportedValue] y:m_control5.m_y];
    }
}

@end
