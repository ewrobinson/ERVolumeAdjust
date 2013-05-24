//
//  ERInputVolumeControl.m
//  audioVolumeTest
//
//  Created by Eric Robinson on 5/8/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import "ERInputVolumeControl.h"


@implementation ERInputVolumeControl

@synthesize selectedDevice, deviceList;


- (id)init
{
    self = [super init];
    if (self) {
        
        //gets the list of all audio devices. Since AVFoundation will give us the list of input devices, so we dont need to worry sorting them.
        
        self.deviceList = [self listAllAudioDevices];
        self.selectedDevice = nil;
    }
    return self;
}



//Devices are selected based on the localized name (AVFoundation) or the DeviceUID (Core Audio). It's easier this way.
//Iterate though the list of devices, and selects based on the matched screen. If it fails, it returns NO.
-(BOOL) selectInputDevice:(NSString *)deviceName{

    for(int i = 0; i < [self.deviceList count]; i++){
        
        if([deviceName isEqualToString:[[self.deviceList objectAtIndex:i] deviceName]]){
            self.selectedDevice = [self.deviceList objectAtIndex:i];
            return YES;
        }
        
    }
    
    return NO;
    
}


-(Float32)getInputDeviceVolume{
    
    //If an audio device hasn't been selected, we can't get the input volume. Duh.
    if(self.selectedDevice == nil){
        NSLog(@"Error - No Audio Input Device is selected");
        return -1;
        
    }
    
    
    AudioDeviceID                   deviceID;
    OSStatus                        err;
    UInt32                          size;
    Float32                         volume = 0;
    
    deviceID = self.selectedDevice.deviceID;
    
    //gets the input channels for the selected device, and iterates through them to find out which can tell us the volume.
    for(int i = 0; i < [self numberOfInputChannels]; i++){
        
        //determins if the we can get the volume
        if([self isVolumeGettableOnChannel:i]){
        
             
                AudioObjectPropertyAddress theVolumeAddressChannel = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, i };
              
                AudioObjectGetPropertyDataSize(self.selectedDevice.deviceID, &theVolumeAddressChannel, 0, NULL, &size);
                err = AudioObjectGetPropertyData(self.selectedDevice.deviceID, &theVolumeAddressChannel, 0, NULL, &size, &volume);
            
                if(err == noErr){
                    return volume;
                    
                }
            
        }
    }
    NSLog(@"Error - unable to get volume for device");
    return -1; //if we get to this point, something strange happened, likely indicating that the device doesn't have volume control

}


-(void) setInputDeviceVolume:(float) volume {
    AudioDeviceID                   deviceID;
    OSStatus                        err;
    UInt32                          size;

    
    
    deviceID = self.selectedDevice.deviceID;
    
    size = sizeof(volume);
        
        for(int i = 0; i < [self numberOfInputChannels]; i++){
            
            if([self isVolumeSettableOnChannel:i]){
                AudioObjectPropertyAddress theVolumeAddressChannelTwo = { kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, i };
                
                err = AudioObjectSetPropertyData( deviceID, &theVolumeAddressChannelTwo, 0, nil, size, &volume );
            }    
            
        }
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

            
            for (NSInteger idx=0; idx<numDevices; idx++) {
                propertySize = sizeof(deviceName);
                deviceAddress.mSelector = kAudioDevicePropertyDeviceName;
                deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, deviceName) == noErr) {
                    
                        CFStringRef     uidString;

                        propertySize = sizeof(uidString);
                        deviceAddress.mSelector = kAudioDevicePropertyDeviceUID;
                        deviceAddress.mScope = kAudioObjectPropertyScopeGlobal;
                        deviceAddress.mElement = kAudioObjectPropertyElementMaster;
                        if (AudioObjectGetPropertyData(deviceIDs[idx], &deviceAddress, 0, NULL, &propertySize, &uidString) == noErr) {
                            
                            ERAudioDevice *device = [[ERAudioDevice alloc] init];
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
        
        free(deviceIDs);
    }
    
    return [NSArray arrayWithArray:mutableDeviceArray];
    
}


-(BOOL) isVolumeSettableOnChannel:(int) channel {
    Boolean is_settable = false;
    AudioObjectPropertyAddress address = {kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, (UInt32)channel};
    /*OSStatus err = */AudioObjectIsPropertySettable(self.selectedDevice.deviceID, &address, &is_settable);
    
    //GETTING THE ERROR MESSAGE HERE ISN'T HELPFUL, BECAUSE IT WILL RETURN ONE FOR EACH CHANNEL THAT DOESN'T ALLOW SETTING THE VOLUME. IF YOU WANT TO SEE HOW IT ALL WORKS, UNCOMMENT EVERYTHING BELOW AND ABOVE THIS LINE.
    
  /*  if(err != noErr){
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        NSLog(@"error - %@", [error localizedDescription]);
    }
    */
    return is_settable;
}

-(BOOL) isVolumeGettableOnChannel:(int)channel{//SAME AS isVolumeSettableOnChannel. COPY/PASTE THE COMMENTED CODE TO SEE THE ERRORS, INDICATING THAT VOLUME IS NOT GETTABLE.
    Boolean is_gettable = false;
    AudioObjectPropertyAddress address = {kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput, (UInt32)channel};
    is_gettable = AudioObjectHasProperty(self.selectedDevice.deviceID, &address);
    return is_gettable;
    
}

-(int) numberOfInputChannels{
    UInt32 size = 0;
    AudioObjectPropertyAddress address = { kAudioDevicePropertyStreams, kAudioDevicePropertyScopeInput};
    OSStatus err = AudioObjectGetPropertyDataSize(self.selectedDevice.deviceID, &address, 0, NULL, &size);
    
    //AS ABOVE, THE ERROR MESSAGE ISN'T HELPUL, BUT IT MIGHT BE IN CERTAIN SITUATIONS. JUST UNCOMMENT.
    if (err != noErr) {
      //  NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
      //  NSLog(@"error - %@", [error localizedDescription]);
        return -1;
    }
    
    return (int)size;
}

@end
