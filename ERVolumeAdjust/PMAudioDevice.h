//
//  PMAudioDevice.h
//  audioVolumeTest
//
//  Created by Eric Robinson on 5/8/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreAudio/CoreAudio.h>

@interface PMAudioDevice : NSObject


@property   (copy)      NSString        *deviceName;
@property   (copy)      NSString        *deviceUID;
@property               AudioDeviceID   deviceID;

@end
