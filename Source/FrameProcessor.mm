//
//  FrameProcessor.mm
//  MorseRelay
//
//  Created by Nicolas Degen on 12.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import "FrameProcessor.h"

#include <functional>

#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#include "FlashTracker.h"

@interface FrameProcessor() {
  std::function<void(bool)> _signalChangedCallback;
  Morse::Decoder _morseDecoder;
}

@property bool previousFrameHadFlash;

@end

@implementation FrameProcessor
- (void)setWordDetectedCallback: (void(^)(NSString* string)) callback {
  _morseDecoder.setWordDecodedCallback([callback](const std::string& cppWord){
    NSString *word = [NSString stringWithUTF8String:cppWord.c_str()];
    callback(word);
  });
}

- (void)setSymbolDetectedCallback: (void(^)(NSString* string)) callback {
  _morseDecoder.setSymbolDecodedCallback([callback](const std::string& cppSymbol){
    NSString *symbol = [NSString stringWithUTF8String:cppSymbol.c_str()];
    callback(symbol);
  });
}


- (void)setSignalUpdateCallback: (void(^)(NSString* string)) callback {
  _morseDecoder.setMessageUpdateCallback([callback](const std::string& cppSymbol){
    NSString *symbol = [NSString stringWithUTF8String:cppSymbol.c_str()];
    callback(symbol);
  });
}

- (void)setSignalDetectionEventCallback: (void(^)(bool signalStarted)) callback {
  _signalChangedCallback = [callback](bool signalDetected) {
    callback(signalDetected);
  };
}

- (void)reset {
#ifdef DEBUG
  _morseDecoder.printLog();
#endif
  _morseDecoder.reset();
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
  CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  
  CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
  int width = int(CVPixelBufferGetWidth(pixelBuffer));
  int height = int(CVPixelBufferGetHeight(pixelBuffer));
  size_t stride = CVPixelBufferGetBytesPerRow(pixelBuffer);
  unsigned char* data = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
//  FourCharCode format = (FourCharCode)CVPixelBufferGetPixelFormatType(pixelBuffer);
  
  cv::Mat frame_image_bgra = cv::Mat(cv::Size(width, height), CV_8UC4, data, stride);
  
  static constexpr int kSampleSize = 80;
  int offset_x = (width - kSampleSize)/2;
  int offset_y = (height - kSampleSize)/2;
  
  cv::Rect roi;
  roi.x = offset_x;
  roi.y = offset_y;
  roi.width = kSampleSize;
  roi.height = kSampleSize;
  
  cv::Mat crop = frame_image_bgra(roi);
  
  cv::Mat frame_image_rgb;
  cv::cvtColor(crop, frame_image_rgb, cv::COLOR_BGR2GRAY); // this makes a COPY of the data!
  
//  UIImage* image_rgb = MatToUIImage(frame_image_rgb);
  float luminanceDelta = FlashTracker::processFrame(frame_image_rgb);
  if (!_previousFrameHadFlash && luminanceDelta > 1.3) {
    _morseDecoder.signalEvent(Morse::SignalEvent::kStart);
    _previousFrameHadFlash = true;
    if (_signalChangedCallback)
      _signalChangedCallback(true);
  } else if (_previousFrameHadFlash && luminanceDelta < 0.9) {
    _previousFrameHadFlash = false;
    if (_signalChangedCallback)
      _signalChangedCallback(false);
    _morseDecoder.signalEvent(Morse::SignalEvent::kEnd);
  }
  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

- (CGRect)getROIForFrame: (CGSize) frame {
  CGRect roi;
  static constexpr int kSampleSize = 80;
  roi.origin.x = (frame.width - kSampleSize)/2;
  roi.origin.y = (frame.height - kSampleSize)/2;
  roi.size.width = kSampleSize;
  roi.size.height = kSampleSize;
  return roi;
}

- (void)startProcessing {
  _morseDecoder.reset();
  _morseDecoder.startListening();
}

- (void)stopProcessing {
  _morseDecoder.stopListening();
}

@end
