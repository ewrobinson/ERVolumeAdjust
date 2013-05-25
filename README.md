ERVolumeAdjust
==============

This fills a gap in AVFoundation (OSX), allowing an app to control the input volume of an audio device.

### ERVolumeAdjust gives you what Apple mysteriously left out of AVFoundation.
These classes work closely with AVFoundation but should play nicely with other audio frameworks. Once you get the localized name or the DeviceUID (or whatever the QTKit equivalent is - I don't feel like looking it up at the moment), you are basically done. All you have to do is:

```
ERInputVolumeControl *inputVolumeController = [[ERInputVolumeControl alloc] init];
[volumeController selectInputDevice:myLocalizedOrUIDString];
```
That's all it takes to load the device. Now to change the volume, you do something like this:

```
[volumeController setInputDeviceVolume:newVolume];//newVolume is a float between 0 and 1
```
That's it! It's like magic, but without the risk of getting sorted into Hufflepuff. If you want to get the current input volume of the selected device, you do this:

```
float volume = [volumeController getInputDeviceVolume];//will be between 0 and 1.
```

Included is some sample code which should give you a good intro to how it all works. To use it in your project, simply copy over the ERInputVolumeControl.h/.m and ERAudioDevice.h/.m classes, and you are ready to go.

opyright (c) <2013>, <E. Walter Robinson>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.