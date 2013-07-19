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


static void
gamepad_hid_device_matching_callback(void* context, IOReturn inResult, void* inSender, IOHIDDeviceRef inIOHIDDeviceRef);

static void
gamepad_hid_device_removal_callback(void* context, IOReturn inResult, void* inSender, IOHIDDeviceRef inIOHIDDeviceRef);


@interface GamePadManager()
{
    CustomThread*                m_gamePadThread;
    CFRunLoopRef                 m_clientRunLoop;
    IOHIDManagerRef              m_hidManager;

    NSMutableDictionary*         m_gamePads;

    id<GamePadManagerDelegate>   m_delegate;
}

- (void) deviceMatching:(IOHIDDeviceRef)deviceRef;
- (void) deviceRemoved:(IOHIDDeviceRef)deviceRef;

+ (NSString*) convertDeviceRefToString:(IOHIDDeviceRef)deviceRef;


- (void) asyncPerformBlockInClientThread:(void (^)(void))block;
- (void) syncPerformBlockInClientThread:(void (^)(void))block;
- (void) asyncPerformBlockInGamePadThread:(void (^)(void))block;
- (void) syncPerformBlockInGamePadThread:(void (^)(void))block;

@end


@implementation GamePadManager

- (id) initWithDelegate:(id<GamePadManagerDelegate>)delegate
{
    if (self = [super init])
    {
        m_delegate = delegate;
        m_gamePads = [[NSMutableDictionary alloc] init];
        m_clientRunLoop = CFRunLoopGetCurrent();
        m_gamePadThread = [[CustomThread alloc] init];
    }

    return self;
}

- (void) dealloc
{
    m_delegate = nil;

    [self syncPerformBlockInGamePadThread: ^
    {
        for (GamePad* gamepad in m_gamePads)
        {
            [gamepad invalidate];
        }

        [m_gamePads release];
        m_gamePads = nil;

        [self stopWatching];
    }];

    if (CFRunLoopGetCurrent() != [m_gamePadThread getRunLoop])
    {
        [m_gamePadThread join];
        [m_gamePadThread release];
        m_gamePadThread = nil;
    }
    else
    {
        NSLog(@"Error: GamePadManager: join to gamepad thread from self! Use another thread for gamepad manager release.");
    }

    [super dealloc];
}

- (BOOL) startWatching
{
    [self asyncPerformBlockInGamePadThread: ^
    {
        if (m_hidManager)
        {
            return;
        }

        m_hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        if (!m_hidManager)
        {
            NSLog(@"Error! GamePadManager:startWatching Failed!");
            return;
        }

        IOHIDManagerSetDeviceMatching(m_hidManager, NULL);
        IOHIDManagerRegisterDeviceMatchingCallback(m_hidManager, gamepad_hid_device_matching_callback, self);
        IOHIDManagerRegisterDeviceRemovalCallback(m_hidManager, gamepad_hid_device_removal_callback, self);
        IOHIDManagerScheduleWithRunLoop(m_hidManager, [m_gamePadThread getRunLoop], kCFRunLoopDefaultMode);
        IOHIDManagerOpen(m_hidManager, kIOHIDOptionsTypeNone);
    }];

    return YES;
}

- (void) stopWatching
{
    [self syncPerformBlockInGamePadThread: ^
    {
        if (!m_hidManager)
        {
            return;
        }

        for (GamePad* gamepad in m_gamePads)
        {
            [gamepad invalidate];
        }

        [m_gamePads removeAllObjects];

        IOHIDManagerRegisterDeviceMatchingCallback(m_hidManager, NULL, NULL);
        IOHIDManagerRegisterDeviceRemovalCallback(m_hidManager, NULL, NULL);
        IOHIDManagerUnscheduleFromRunLoop(m_hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerClose(m_hidManager, kIOHIDOptionsTypeNone);
        CFRelease(m_hidManager);
        m_hidManager = NULL;
    }];
}

- (NSArray*) getGamepads
{
    __block NSArray* array = nil;

    [self syncPerformBlockInGamePadThread: ^
    {
        if ([m_gamePads count] > 0)
        {
            array = [[NSArray arrayWithArray:[m_gamePads allValues]] retain];
        }
    }];

    return [array autorelease];
}

- (void) deviceMatching:(IOHIDDeviceRef)deviceRef
{
    if (!deviceRef)
    {
        return;
    }

    NSString* deviceID = [GamePadManager convertDeviceRefToString:deviceRef];
    if (!deviceID)
    {
        return;
    }

    GamePad* gamepad = [m_gamePads objectForKey:deviceID];
    if (gamepad)
    {
        return;
    }

    {
        GamePadPrivate* gamepadPrivate = [[[GamePadPrivate alloc] initWithDeviceRef:deviceRef runLoop:CFRunLoopGetCurrent()] autorelease];
        if (![gamepadPrivate isGamepadValid])
        {
            return;
        }

        gamepad = [[[GamePad alloc] initWithGamePadPrivate:gamepadPrivate] autorelease];
    }

    [m_gamePads setObject:gamepad forKey:deviceID];

    [gamepad retain];
    [self asyncPerformBlockInClientThread: ^
    {
        if ([m_delegate respondsToSelector:@selector(gamePadManager:didAttachGamePad:)])
        {
            [m_delegate gamePadManager:self didAttachGamePad:gamepad];
        }

        [gamepad release];
    }];
}

- (void) deviceRemoved:(IOHIDDeviceRef)deviceRef
{
    if (!deviceRef)
    {
        return;
    }

    NSString* deviceID = [GamePadManager convertDeviceRefToString:deviceRef];
    if (!deviceID)
    {
        return;
    }

    GamePad* gamepad = [m_gamePads objectForKey:deviceID];
    if (!gamepad)
    {
        return;
    }

    [gamepad invalidate];
    [gamepad retain];
    [m_gamePads removeObjectForKey:deviceID];

    [self asyncPerformBlockInClientThread: ^
    {
        if ([m_delegate respondsToSelector:@selector(gamePadManager:didDetachGamePad:)])
        {
            [m_delegate gamePadManager:self didDetachGamePad:gamepad];
        }

        [gamepad release];
    }];
}

+ (NSString*) convertDeviceRefToString:(IOHIDDeviceRef)deviceRef
{
    if (!deviceRef)
    {
        return nil;
    }

    return [NSString stringWithFormat:@"Device=%llx", (long long)deviceRef];
}

- (void) asyncPerformBlockInClientThread:(void (^)(void))block
{
    [CustomThread asyncRunBlock:block inRunLoop:m_clientRunLoop];
}

- (void) syncPerformBlockInClientThread:(void (^)(void))block
{
    [CustomThread syncRunBlock:block inRunLoop:m_clientRunLoop];
}

- (void) asyncPerformBlockInGamePadThread:(void (^)(void))block
{
    [CustomThread asyncRunBlock:block inRunLoop:[m_gamePadThread getRunLoop]];
}

- (void) syncPerformBlockInGamePadThread:(void (^)(void))block
{
    [CustomThread syncRunBlock:block inRunLoop:[m_gamePadThread getRunLoop]];
}

@end


static void
gamepad_hid_device_matching_callback(void* context, IOReturn inResult, void* inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    [(GamePadManager*)context deviceMatching:inIOHIDDeviceRef];
}

static void
gamepad_hid_device_removal_callback(void* context, IOReturn inResult, void* inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
    [(GamePadManager*)context deviceRemoved:inIOHIDDeviceRef];
}
