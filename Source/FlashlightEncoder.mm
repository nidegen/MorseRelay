//
//  FlashlightEncoder.mm
//  MorseRelay
//
//  Created by Nicolas Degen on 14.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import "FlashlightEncoder.h"

#import <AVKit/AVKit.h>

#include "MorseEncoder.h"

@interface FlashlightEncoder () {
  MorseEncoder* _morseEncoder;
}
// Cannot use objc property as it has no copy constructor due to std::thread
//@property MorseEncoder morseEncoder;
@end

@implementation FlashlightEncoder
- (id)init  {
  _morseEncoder = new MorseEncoder([self](bool turnOn){
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
      AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      if ([device hasTorch]) {// && [device hasFlash]){
        [device lockForConfiguration:nil];
        if (turnOn) {
          [device setTorchMode:AVCaptureTorchModeOn];
        } else {
          [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
      } else {
        if (turnOn) {
          std::cout << "Flash on" << std::endl;
        } else {
          std::cout << "Flash off" << std::endl;
        }
      }
      if (_signalAction) {
        _signalAction(turnOn);
      }
    }

  });
  return self;
}

- (void)dealloc {
  delete _morseEncoder;
}

- (void)emitMorseWord:(NSString*) word {
  std::string cppWord = std::string([word UTF8String]);
  _morseEncoder->enqueueWord(cppWord);
  _morseEncoder->pushToEncoderQueue(_terminationCallback);
}

- (void)emitMorseMessage:(NSString*) message {
  std::string cppWord = std::string([message UTF8String]);
  _morseEncoder->enqueueMessage(cppWord);
  _morseEncoder->pushToEncoderQueue(_terminationCallback);
}

-(void) cancelMorseEmission {
  _morseEncoder->clear();
}
@end
