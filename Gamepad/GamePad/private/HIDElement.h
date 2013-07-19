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
#import <IOKit/hid/IOHIDManager.h>


// Usage pages from HID Usage Tables spec 1.0
enum
{
    kUsage_PageGenericDesktop			= 0x01,
    kUsage_PageSimulationControls		= 0x02,
    kUsage_PageVRControls				= 0x03,
    kUsage_PageSportControls			= 0x04,
    kUsage_PageGameControls				= 0x05,
    kUsage_PageKeyboard					= 0x07,
    kUsage_PageLED						= 0x08,
    kUsage_PageButton					= 0x09,
    kUsage_PageOrdinal					= 0x0A,
    kUsage_PageTelephonyDevice			= 0x0B,
    kUsage_PageConsumer					= 0x0C,
    kUsage_PageDigitizers				= 0x0D,
    kUsage_PagePID						= 0x0F,
    kUsage_PageUnicode					= 0x10,
    kUsage_PageAlphanumericDisplay		= 0x14,
    kUsage_PageMonitor					= 0x80,
    kUsage_PageMonitorEnumeratedValues	= 0x81,
    kUsage_PageMonitorVirtualControl 	= 0x82,
    kUsage_PageMonitorReserved			= 0x83,
    kUsage_PagePowerDevice				= 0x84,
    kUsage_PageBatterySystem			= 0x85,
    kUsage_PowerClassReserved			= 0x86,
    kUsage_PowerClassReserved2			= 0x87,
	kUsage_VendorDefinedStart			= 0xff00
};


// Usage constants for Generic Desktop page (01) from HID Usage Tables spec 1.0
enum
{
    kUsage_01_Pointer		= 0x01,
    kUsage_01_Mouse			= 0x02,
    kUsage_01_Joystick		= 0x04,
    kUsage_01_GamePad		= 0x05,
    kUsage_01_Keyboard		= 0x06,
    kUsage_01_Keypad		= 0x07,

    kUsage_01_X				= 0x30,
    kUsage_01_Y				= 0x31,
    kUsage_01_Z				= 0x32,
    kUsage_01_Rx			= 0x33,
    kUsage_01_Ry			= 0x34,
    kUsage_01_Rz			= 0x35,
    kUsage_01_Slider		= 0x36,
    kUsage_01_Dial			= 0x37,
    kUsage_01_Wheel			= 0x38,
    kUsage_01_HatSwitch		= 0x39,
    kUsage_01_CountedBuffer	= 0x3A,
    kUsage_01_ByteCount		= 0x3B,
    kUsage_01_MotionWakeup	= 0x3C,

    kUsage_01_Vx			= 0x40,
    kUsage_01_Vy			= 0x41,
    kUsage_01_Vz			= 0x42,
    kUsage_01_Vbrx			= 0x43,
    kUsage_01_Vbry			= 0x44,
    kUsage_01_Vbrz			= 0x45,
    kUsage_01_Vno			= 0x46,

    kUsage_01_SystemControl		= 0x80,
    kUsage_01_SystemPowerDown 	= 0x81,
    kUsage_01_SystemSleep 		= 0x82,
    kUsage_01_SystemWakeup		= 0x83,
    kUsage_01_SystemContextMenu = 0x84,
    kUsage_01_SystemMainMenu	= 0x85,
    kUsage_01_SystemAppMenu		= 0x86,
    kUsage_01_SystemMenuHelp	= 0x87,
    kUsage_01_SystemMenuExit	= 0x88,
    kUsage_01_SystemMenuSelect	= 0x89,
    kUsage_01_SystemMenuRight	= 0x8A,
    kUsage_01_SystemMenuLeft	= 0x8B,
    kUsage_01_SystemMenuUp		= 0x8C,
    kUsage_01_SystemMenuDown	= 0x8D
};


@interface HIDElement : NSObject

@property (nonatomic, assign, readonly) IOHIDElementRef    m_elementRef;
@property (nonatomic, assign, readonly) IOHIDElementType   m_type;
@property (nonatomic, assign, readonly) uint32_t           m_usage;
@property (nonatomic, assign, readonly) uint32_t           m_usagePage;
@property (nonatomic, assign, readonly) BOOL               m_virtual;
@property (nonatomic, assign, readonly) BOOL               m_relative;
@property (nonatomic, assign, readonly) BOOL               m_wrapping;
@property (nonatomic, assign, readonly) BOOL               m_nonLinear;
@property (nonatomic, assign, readonly) BOOL               m_array;
@property (nonatomic, assign, readonly) BOOL               m_preferredState;
@property (nonatomic, assign, readonly) BOOL               m_nullState;
@property (nonatomic, assign, readonly) uint32_t           m_reportID;
@property (nonatomic, assign, readonly) uint32_t           m_reportSize;
@property (nonatomic, assign, readonly) uint32_t           m_reportCount;
@property (nonatomic, assign, readonly) uint32_t           m_unit;
@property (nonatomic, assign, readonly) uint32_t           m_unitExponent;
@property (nonatomic, assign, readonly) CFIndex            m_logicalMin;
@property (nonatomic, assign, readonly) CFIndex            m_logicalMax;
@property (nonatomic, assign, readonly) CFIndex            m_physicalMin;
@property (nonatomic, assign, readonly) CFIndex            m_physicalMax;
@property (nonatomic, assign, readwrite) int32_t           m_latestValue;

- (id) initWithElementRef:(IOHIDElementRef)elementRef;

+ (NSString*) convertElementRefToString:(IOHIDElementRef)elementRef;

@end
