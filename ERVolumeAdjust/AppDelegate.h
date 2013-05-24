//
//  AppDelegate.h
//  ERVolumeAdjust
//
//  Created by Eric Robinson on 5/24/13.
//  Copyright (c) 2013 Eric Robinson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "ERInputVolumeControl.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>{
    
    IBOutlet        NSSlider        *volumeSlide;
    IBOutlet        NSComboBox      *deviceListBox;
    IBOutlet        NSTextField     *inputVolumeLevel;
    
    
    ERInputVolumeControl        *volumeController;
    
    AVCaptureDevice              *selectedAudioDevice;
}

@property (assign) IBOutlet NSWindow *window;

@property (copy)       NSArray						*audioDeviceList;
@property (copy)       NSArray                      *audioDeviceListStrings;
@property (copy)       NSString                     *selectedInputAudioDeviceString;

-(IBAction)changeVolumeForSelectedDevice:(id)sender;
-(IBAction)audioDeviceChanged:(id)sender;


@end
