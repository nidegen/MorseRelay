//
//  FrameProcessor.mm
//  MorseRelay
//
//  Created by Nicolas Degen on 12.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import "FrameProcessor.h"

#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>

#include "FlashTracker.h"

@interface FrameProcessor()
@property MorseDecoder morseDecoder;
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
  
  /* Set Region of Interest */
  
  int offset_x = width - 80/2;
  int offset_y = height - 80/2;
  
  cv::Rect roi;
  roi.x = offset_x;
  roi.y = offset_y;
  roi.width = frame_image_bgra.size().width - (offset_x * 2);
  roi.height = frame_image_bgra.size().height - (offset_y * 2);
  
  /* Crop the original image to the defined ROI */
  
  cv::Mat crop = frame_image_bgra(roi);
  
  cv::Mat frame_image_rgb;
  cv::cvtColor(crop, frame_image_rgb, CV_BGR2GRAY); // this makes a COPY of the data!
  bool flashDetected = FlashTracker::processFrame(frame_image_rgb);
  if (!_previousFrameHadFlash && flashDetected) {
    _morseDecoder.signalStartDetected();
  } else if (_previousFrameHadFlash && !flashDetected) {
    _morseDecoder.signalEndDetected();
  }
  
  UIImage* image_rgb = MatToUIImage(frame_image_rgb);
  
}
@end
