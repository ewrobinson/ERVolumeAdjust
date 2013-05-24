//
//  AppDelegate.m
//  ERVolumeAdjust
//
//  Created by Eric Robinson on 5/24/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    volumeController = [[ERInputVolumeControl alloc] init];
    
//THE FOLLWOING CODE PERTAINS TO AVFOUNDATION. THIS IS DUMMY CODE (MORE OR LESS) TO SIMULATE THE INITIALIZATION OD INPUT DEVICES FOR A CAPTURE SESSION.
    
//****** THE MAIN POINT IS THE PART WHERE WE GET THE DEVICE STRINGS, AS THESE WILL BE USED TO SELECT THE DEVICE FOR THE VOLUME CONTROLLER
    
    
    //GETS THE AUDIO DEVICES.
    self.audioDeviceList = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    //CREATES A PARALLEL ARRAY IN WHICH WE STORE THE LOCALIZED STRINGS (THE ONES WE SEND TO ERInputDeviceVolume)
    NSMutableArray *avdeviceArray = [NSMutableArray array];
    for(AVCaptureDevice *incDevice in self.audioDeviceList){
        [avdeviceArray addObject:[incDevice localizedName]];
    }
    self.audioDeviceListStrings = [NSArray arrayWithArray:avdeviceArray];
    
    
    //FOR FUN, WE'LL JUST START WITH THE FIRST ONE.
    self.selectedInputAudioDeviceString = [self.audioDeviceListStrings objectAtIndex:0];
    selectedAudioDevice = [avdeviceArray objectAtIndex:0];
    
    //HERE IS THE MAGIC - SEND THE STRING TO VOLUMECONTROLLER, AND IT IS READY TO GO.
    if(![volumeController selectInputDevice:self.selectedInputAudioDeviceString]){
        
        NSLog(@"Error - unable to select this audio device. Check what is being sent in debug.");
    }
    else{
        float volume = [volumeController getInputDeviceVolume];
        [inputVolumeLevel setStringValue:[NSString stringWithFormat:@"%i%@", (int)((volume / 1.0) *100), @"%"]];
        [self setVolumeForSlider]; // WE DON'T NEED TO SEND IT ANY VARIABLE, BECAUSE IT CAN GET THEM ITSELF.
    }
    
    
    
}


-(void)setVolumeForSlider{
    
    [volumeSlide setFloatValue:[volumeController getInputDeviceVolume]];
    
}

-(IBAction)changeVolumeForSelectedDevice:(id)sender{
    
    //SENDS THE VALUE BASED ON THE SLIDER, WHICH CHANGES THE INPUT VOLUME. BECAUSE THE SLIDER GOES FROM 0 TO 1, WE DON'T NEED TO CHANGE THE VALUE BEING SENT.
    
    [volumeController setInputDeviceVolume:[(NSSlider*)sender floatValue]];
    [inputVolumeLevel setStringValue:[NSString stringWithFormat:@"%i%@",(int)(([(NSSlider*) sender floatValue] / 1.0) *100), @"%" ]];
}


-(IBAction)audioDeviceChanged:(id)sender{
    //BOUND TO self.inputAudioDeviceString, ALL WE HAVE TO DO IS SEND THAT STRING TO volumeController.
    [volumeController selectInputDevice:self.selectedInputAudioDeviceString];
 
    
    //THIS SHOULD LOOK FAMILIAR
    float volume = [volumeController getInputDeviceVolume];
    [inputVolumeLevel setStringValue:[NSString stringWithFormat:@"%i%@", (int)((volume / 1.0) *100), @"%"]];
    [self setVolumeForSlider]; // WE DON'T NEED TO SEND IT ANY VARIABLE, BECAUSE IT CAN GET THEM ITSELF.
    
    
}


@end
