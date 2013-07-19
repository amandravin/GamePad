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

#import <Cocoa/Cocoa.h>
#import <GamePad/GamePad.h>


@interface ControlView : NSTextField
{
    NSTextField*      m_center;
    float             m_x;
    float             m_y;
}

@property (nonatomic, assign, readonly) float m_x;
@property (nonatomic, assign, readonly) float m_y;

- (void) setCenterX:(float)x y:(float)y;

@end

#define BUTTONS_COUNT 12


@interface GamepadAppDelegate : NSObject <NSApplicationDelegate, GamePadManagerDelegate, GamePadDelegate>
{
// Gamepad staff
    GamePadManager*                    m_gpManager;       // Gamepad manager for observing gamepads plug/unplug
    GamePad*                           m_gamePad;         // Current attached gamepad

// UI staff
    IBOutlet NSTextField*              m_labelConnected;
    IBOutlet NSTextField*              m_labelName;

    IBOutlet NSTextField*              m_label1;
    IBOutlet NSTextField*              m_label2;
    IBOutlet NSTextField*              m_label3;
    IBOutlet NSTextField*              m_label4;
    IBOutlet NSTextField*              m_label5;
    IBOutlet NSTextField*              m_label6;
    IBOutlet NSTextField*              m_label7;
    IBOutlet NSTextField*              m_label8;
    IBOutlet NSTextField*              m_label9;
    IBOutlet NSTextField*              m_label10;
    IBOutlet NSTextField*              m_label11;
    IBOutlet NSTextField*              m_label12;

    NSTextField*                       m_buttons[BUTTONS_COUNT];

    ControlView*                       m_control1;
    ControlView*                       m_control2;
    ControlView*                       m_control3;
    ControlView*                       m_control4;
    ControlView*                       m_control5;
}

@property (assign) IBOutlet NSWindow* window;

@end
