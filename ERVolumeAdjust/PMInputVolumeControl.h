//
//  PMInputVolumeControl.h
//  audioVolumeTest
//
//  Created by Eric Robinson on 5/8/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMAudioDevice.h"


@interface PMInputVolumeControl : NSObject


@property   (retain)    PMAudioDevice   *selectedDevice;
@property   (retain)      NSArray         *deviceList;

-(BOOL) selectInputDevice:(NSString*)deviceName;

-(void) setInputDeviceVolume:(Float32) toVolume;

-(Float32) getInputDeviceVolume;


//move these to private
-(NSArray *)listAllAudioDevices;
-(int) numberOfInputChannels;
-(BOOL) isVolumeGettableOnChannel:(int)channel;
-(BOOL) isVolumeSettableOnChannel:(int) channel;
@end
