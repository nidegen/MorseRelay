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
@property AVCaptureDevice *torchDevice;
@end

@implementation FlashlightEncoder
- (id)init  {
  _torchDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  _deviceHasTorch = [_torchDevice hasTorch];
  
  _morseEncoder = new MorseEncoder([self](bool turnOn) {
    if (_deviceHasTorch) {
      [_torchDevice lockForConfiguration:nil];
      if (turnOn) {
        [_torchDevice setTorchMode:AVCaptureTorchModeOn];
      } else {
        [_torchDevice setTorchMode:AVCaptureTorchModeOff];
      }
      [_torchDevice unlockForConfiguration];
    } else {
#if DEBUG
      if (turnOn) {
        std::cout << "Flash on" << std::endl;
      } else {
        std::cout << "Flash off" << std::endl;
      }
#endif
    }
    if (_signalAction) {
      _signalAction(turnOn);
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
