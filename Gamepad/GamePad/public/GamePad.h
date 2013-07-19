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

#import <Foundation/Foundation.h>


// GamePad control type 
enum
{
// BUTTON
    GAMEPAD_BUTTON_BEGIN = 0,
    GAMEPAD_BUTTON_1 = 1,
    GAMEPAD_BUTTON_2 = 2,
    GAMEPAD_BUTTON_3 = 3,
    GAMEPAD_BUTTON_4 = 4,
    GAMEPAD_BUTTON_5 = 5,
    GAMEPAD_BUTTON_6 = 6,
    GAMEPAD_BUTTON_7 = 7,
    GAMEPAD_BUTTON_8 = 8,
    GAMEPAD_BUTTON_9 = 9,
    GAMEPAD_BUTTON_10 = 10,
    GAMEPAD_BUTTON_11 = 11,
    GAMEPAD_BUTTON_12 = 12,
    GAMEPAD_BUTTON_13 = 13,
    GAMEPAD_BUTTON_14 = 14,
    GAMEPAD_BUTTON_15 = 15,
    GAMEPAD_BUTTON_16 = 16,
    GAMEPAD_BUTTON_17 = 17,
    GAMEPAD_BUTTON_18 = 18,
    GAMEPAD_BUTTON_19 = 19,
    GAMEPAD_BUTTON_20 = 20,
    GAMEPAD_BUTTON_21 = 21,
    GAMEPAD_BUTTON_22 = 22,
    GAMEPAD_BUTTON_23 = 23,
    GAMEPAD_BUTTON_24 = 24,
    GAMEPAD_BUTTON_25 = 25,
    GAMEPAD_BUTTON_26 = 26,
    GAMEPAD_BUTTON_27 = 27,
    GAMEPAD_BUTTON_28 = 28,
    GAMEPAD_BUTTON_29 = 29,
    GAMEPAD_BUTTON_30 = 30,
    GAMEPAD_BUTTON_31 = 31,
    GAMEPAD_BUTTON_32 = 32,
    GAMEPAD_BUTTON_END = 1024,

// DPAD
    GAMEPAD_DPAD = 1025,

// AXIS
    GAMEPAD_AXIS_X = 1026,
    GAMEPAD_AXIS_Y = 1027,
    GAMEPAD_AXIS_Z = 1028,
    GAMEPAD_AXIS_RX = 1029,
    GAMEPAD_AXIS_RY = 1030,
    GAMEPAD_AXIS_RZ = 1031,

// SLIDER
    GAMEPAD_SLIDER = 1032
};

typedef NSInteger GAMEPAD_CONTROL_TYPE;


// DPAD values
enum
{
    GAMEPAD_DPAD_UP = 0,
    GAMEPAD_DPAD_RIGHT_UP = 1,
    GAMEPAD_DPAD_RIGHT = 2,
    GAMEPAD_DPAD_RIGHT_DOWN = 3,
    GAMEPAD_DPAD_DOWN = 4,
    GAMEPAD_DPAD_LEFT_DOWN = 5,
    GAMEPAD_DPAD_LEFT = 6,
    GAMEPAD_DPAD_LEFT_UP = 7,
    GAMEPAD_DPAD_FREE = 15
};

typedef NSInteger GAMEPAD_DPAD_VALUE;


// GamePad control interface
@interface GamePadControl : NSObject

// Returns control type
- (GAMEPAD_CONTROL_TYPE) getControlType;

// Returns latest integer control value
- (int32_t) getIntegerValue;

// Returns minimum supported control value
- (int32_t) getMinSupportedValue;

// Returns maximum supported control value
- (int32_t) getMaxSupportedValue;

@end


// GamePad delegate protocol
@protocol GamePadDelegate <NSObject>

@optional

// Invoked every time when gamepad control value is changed
// -sender: gamepad that control value is changed
// -control: control that value is changed
- (void) gamePad:(id)sender didChangeValueForControl:(GamePadControl*)control;

@end


// GamePad interface
@interface GamePad : NSObject

// Start listening for control value updates. See GamePadDelegate.
- (BOOL) startListeningWithDelegate:(id<GamePadDelegate>)delegate;

// Stop listening for control value updates
- (void) stopListening;

// Returns gamepad name 
- (NSString*) getDeviceName;

// Returns NSArray with available GamePadControls for that gamepad
- (NSArray*) getControls;

@end


// GamePadManager delegate protocol
@protocol GamePadManagerDelegate <NSObject>

@optional

// Invoked on attaching gamepad to USB
// -sender: gamepad manager
// -gamePad: attached gamepad
- (void) gamePadManager:(id)sender didAttachGamePad:(GamePad*)gamePad;

// Invoked on detaching gamepad from USB
// -sender: gamepad manager
// -gamePad: detached gamepad
- (void) gamePadManager:(id)sender didDetachGamePad:(GamePad*)gamePad;

@end


// GamePad manager
@interface GamePadManager : NSObject

// Designated initializer
// -delegate: gamepad manager delegate. See GamePadManagerDelegate.
- (id) initWithDelegate:(id<GamePadManagerDelegate>)delegate;

// Start watchig for gamepads
- (BOOL) startWatching;

// Stop watching gamepads. After this call you will not be able to listen gamepad control values update.
// So, consider do not call it if you want continue listening for gamepad control value updates.
- (void) stopWatching;

// Returns all attached USB gamepads in sync way
- (NSArray*) getGamepads;

@end
