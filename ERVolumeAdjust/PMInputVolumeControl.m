//
//  PMInputVolumeControl.m
//  audioVolumeTest
//
//  Created by Eric Robinson on 5/8/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import "PMInputVolumeControl.h"


@implementation PMInputVolumeControl

@synthesize selectedDevice, deviceList;


- (id)init
{
    self = [super init];
    if (self) {
        self.deviceList = [self listAllAudioDevices];
        self.selectedDevice = nil;
    }
    return self;
}


-(BOOL) selectInputDevice:(NSString *)deviceName{
   // NSLog(@"called");
    for(int i = 0; i < [self.deviceList count]; i++){
        
        if([deviceName isEqualToString:[[self.deviceList objectAtIndex:i] deviceName]]){
            self.selectedDevice = [self.deviceList objectAtIndex:i];
            return YES;
        }
        
    }
    
    return NO;
    
}


-(Float32)getInputDeviceVolume{
    AudioObjectPropertyAddress      address;
    AudioDeviceID                   deviceID;
    OSStatus                        err;
    UInt32                          size;
   // UInt32                          channels[ 2 ];
    Float32                         volume = 0;
    
    
    
    // get the default input device id
    address.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMaster;
    
    //  size = sizeof(deviceID);
    //  err = AudioObjectGetPropertyData( kAudioObjectSystemObject, &address, 0, nil, &size, &deviceID );
    
    
    deviceID = self.selectedDevice.deviceID;
    
    for(int i = 0; i < [self numberOfInputChannels]; i++){
        
        if([self isVolumeGettableOnChannel:i]){
        
             
                AudioObjectPropertyAddress theVolumeAddressChannel = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, i };
              
                AudioObjectGetPropertyDataSize(self.selectedDevice.deviceID, &theVolumeAddressChannel, 0, NULL, &size); //shoulnd't return an error as this was just checked
                err = AudioObjectGetPropertyData(self.selectedDevice.deviceID, &theVolumeAddressChannel, 0, NULL, &size, &volume);
                if(err == noErr){
                    return volume;
                    
                }
        
            
        }
    }
    /*
     // try to get the input volume
     if ( ! err ) {
     address.mSelector = kAudioDevicePropertyVolumeScalar;
     address.mScope = kAudioDevicePropertyScopeInput;
     
     size = sizeof(volume);
     address.mElement = kAudioObjectPropertyElementMaster;
     // returns an error which we expect since it reported not having the property
     err = AudioObjectGetPropertyData( deviceID, &address, 0, nil, &size, &volume );
     
     size = sizeof(volume);
     address.mElement = channels[ 0 ];
     
     AudioObjectPropertyAddress theVolumeAddressChannelZero = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 0 };
     
     // returns noErr, but says the volume is always zero (weird)
     err = AudioObjectGetPropertyData( deviceID, &theVolumeAddressChannelZero, 0, nil, &size, &volume );
     NSLog(@"volume of channel 0 - %f",volume);
     size = sizeof(volume);
     address.mElement = channels[ 1 ];
     
     AudioObjectPropertyAddress theVolumeAddressChannelOne = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 1 };
     
     
     // returns noErr, but returns the correct volume!
     err = AudioObjectGetPropertyData( deviceID, &theVolumeAddressChannelOne, 0, nil, &size, &volume );
     NSLog(@"volume of channel 1 - %f",volume);
     }
     */
}


-(void) setInputDeviceVolume:(Float32) toVolume {
    AudioObjectPropertyAddress      address;
    AudioDeviceID                   deviceID;
    OSStatus                        err;
    UInt32                          size;
    UInt32                          channels[ 2 ];
    Float32                         volume;
    
    
    
    // get the default input device id
    address.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMaster;
    
  //  size = sizeof(deviceID);
  //  err = AudioObjectGetPropertyData( kAudioObjectSystemObject, &address, 0, nil, &size, &deviceID );
    
    
    deviceID = self.selectedDevice.deviceID;
    
    
    //---- get device name
    CFStringRef deviceName = NULL;
    size = sizeof(deviceName);
    address.mSelector = kAudioDevicePropertyDeviceNameCFString;
    err = AudioObjectGetPropertyData(deviceID, &address, 0, NULL, &size, &deviceName);
    if(kAudioHardwareNoError != err) {
        fprintf(stderr, "AudioObjectGetPropertyData (kAudioDevicePropertyDeviceNameCFString) failed: %i\n", err);
        
    }
    
    NSLog(@"device name - %@",(__bridge NSString *)(deviceName));
    //-----  /get device name
    
    // get the input device stereo channels
    if ( ! err ) {
        address.mSelector = kAudioDevicePropertyPreferredChannelsForStereo;
        address.mScope = kAudioDevicePropertyScopeInput;
        address.mElement = kAudioObjectPropertyElementWildcard;
        size = sizeof(channels);
        err = AudioObjectGetPropertyData( deviceID, &address, 0, nil, &size, &channels );
    }
    
    // run some tests to see what channels might respond to volume changes
    if ( ! err ) {
        Boolean                     hasProperty;
        
        address.mSelector = kAudioDevicePropertyVolumeScalar;
        address.mScope = kAudioDevicePropertyScopeInput;
        
        // On my MacBook Pro using the default microphone input:
        
        address.mElement = kAudioObjectPropertyElementMaster;
        // returns false, no VolumeScalar property for the master channel
        hasProperty = AudioObjectHasProperty( deviceID, &address );
        
        address.mElement = channels[ 0 ];
        // returns true, channel 0 has a VolumeScalar property
        hasProperty = AudioObjectHasProperty( deviceID, &address );
        
        address.mElement = channels[ 1 ];
        // returns true, channel 1 has a VolumeScalar property
        hasProperty = AudioObjectHasProperty( deviceID, &address );
    }

    // try to set the input volume
    
    if ( ! err ) {
        
        address.mSelector = kAudioDevicePropertyVolumeScalar;
        address.mScope = kAudioDevicePropertyScopeInput;
        
        size = sizeof(volume);
        
        if ( toVolume < 0.0 ) volume = 0.0;
        else if ( toVolume > 1.0 ) volume = 1.0;
        else volume = toVolume;
        
        address.mElement = kAudioObjectPropertyElementMaster;
        // returns an error which we expect since it reported not having the property
        err = AudioObjectSetPropertyData( deviceID, &address, 0, nil, size, &volume );
        
        address.mElement = channels[ 0 ];
      //  NSLog(@"volume to new input - %f", volume);
        
        for(int i = 0; i < [self numberOfInputChannels]; i++){
            
            if([self isVolumeSettableOnChannel:i]){
                AudioObjectPropertyAddress theVolumeAddressChannelTwo = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, i };
                
                // address.mElement = channels[ 2 ];
                // success! correctly sets the input device volume.
                err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelTwo, 0, nil, size, &volume );
            }    
            
        }
        

  /*
        AudioObjectPropertyAddress theVolumeAddressChannelZero = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 0 };
        // returns noErr, but doesn't affect my input gain
        err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelZero, 0, nil, size, &volume );
        
        
     
        AudioObjectPropertyAddress theVolumeAddressChannelOne = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 1 };
        
        address.mElement = channels[ 1 ];
        // success! correctly sets the input device volume.
        err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelOne, 0, nil, size, &volume );
      
        AudioObjectPropertyAddress theVolumeAddressChannelTwo = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 2 };
        
       // address.mElement = channels[ 2 ];
        // success! correctly sets the input device volume.
        err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelTwo, 0, nil, size, &volume );
 
        
        AudioObjectPropertyAddress theVolumeAddressChannelThree = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, 3 };
        
        // address.mElement = channels[ 2 ];
        // success! correctly sets the input device volume.
        err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelThree, 0, nil, size, &volume );
        
        */

    }
    
    //return err;
}



-(NSArray *)listAllAudioDevices{
    AudioObjectPropertyAddress  propertyAddress;
    AudioObjectID               *deviceIDs;
    UInt32                      propertySize;
    NSInteger                   numDevices;
    
    
    NSMutableArray                  *mutableDeviceArray = [NSMutableArray arrayWithCapacity:0];
    
    propertyAddress.mSelector = kAudioHardwarePropertyDevices;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    if (AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &propertySize) == noErr) {
        numDevices = propertySize / sizeof(AudioDeviceID);
        deviceIDs = (AudioDeviceID *)calloc(numDevices, sizeof(AudioDeviceID));
        
        if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &propertySize, deviceIDs) == noErr) {
            AudioObjectPropertyAddress      deviceAddress;
            char                            deviceName[64];
            char                            manufacturerName[64];
            
            for (NSInteger idx=0; idx<numDevices; idx++) {
                propertySize = sizeof(deviceName);
                deviceAddress.mSelector = kAudioDevicePropertyDeviceName;
                deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, deviceName) == noErr) {
                    
                    propertySize = sizeof(manufacturerName);
                    deviceAddress.mSelector = kAudioDevicePropertyDeviceManufacturer;
                    deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                    deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                    if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, manufacturerName) == noErr) {
                        CFStringRef     uidString;
                        // AudioDeviceID   deviceID;
                        propertySize = sizeof(uidString);
                        deviceAddress.mSelector = kAudioDevicePropertyDeviceUID;
                        deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                        deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                        if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, &uidString) == noErr) {
                            
                            // NSLog(@"device %s by %s id %@", deviceName, manufacturerName, uidString);
                            PMAudioDevice *device = [[PMAudioDevice alloc] init];
                            device.deviceUID = (__bridge NSString *)uidString;
                            device.deviceName = [NSString stringWithCString:deviceName encoding:NSUTF8StringEncoding];
                            device.deviceID = deviceIDs[idx];
                            //  NSLog(@"devicename - %@", device.deviceName);
                            [mutableDeviceArray addObject:device];
                            CFRelease(uidString);
                        }
                    }
                }
            }
        }
        
        free(deviceIDs);
    }
    
    return [NSArray arrayWithArray:mutableDeviceArray];
    
}


-(BOOL) isVolumeSettableOnChannel:(int) channel {
    Boolean is_settable = false;
    AudioObjectPropertyAddress address = {kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, (UInt32)channel};
    OSStatus err = AudioObjectIsPropertySettable(self.selectedDevice.deviceID, &address, &is_settable);
    
    if(err != noErr){
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
      //  NSLog(@"error - %@", [error localizedDescription]);
    }
    
    return is_settable;
}

-(BOOL) isVolumeGettableOnChannel:(int)channel{
    Boolean is_gettable = false;
    AudioObjectPropertyAddress address = {kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, (UInt32)channel};
    is_gettable = AudioObjectHasProperty(self.selectedDevice.deviceID, &address);
    return is_gettable;
    
}

-(int) numberOfInputChannels{
    UInt32 size = 0;
    AudioObjectPropertyAddress address = { kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput};
    OSStatus err = AudioObjectGetPropertyDataSize(self.selectedDevice.deviceID, &address, 0, NULL, &size);
    if (err != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
      //  NSLog(@"error - %@", [error localizedDescription]);
        return -1;
    }
    
    return (int)size;
}

@end
