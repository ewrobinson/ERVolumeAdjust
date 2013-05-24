//
//  ERAudioDevice.h
//  audioVolumeTest
//
//  Created by Eric Robinson on 5/8/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreAudio/CoreAudio.h>


//THIS IS JUST A HELPER CLASS THAT I USED TO HOLD CERTAIN DATA. I COULD USE A STRUCT, BUT IN CASE I NEED MORE FUNCTIONALITY LATER ON, I JSUT MADE A LITTLE CLASS.

@interface ERAudioDevice : NSObject


@property   (copy)      NSString        *deviceName;
@property   (copy)      NSString        *deviceUID;
@property               AudioDeviceID   deviceID;

@end
