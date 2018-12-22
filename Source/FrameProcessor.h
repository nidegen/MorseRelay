//
//  FrameProcessor.h
//  MorseRelay
//
//  Created by Nicolas Degen on 12.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <CoreGraphics/CGGeometry.h>

@interface FrameProcessor : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)reset;
- (void)setWordDetectedCallback: (void(^)(NSString* string)) callback;
- (void)setSymbolDetectedCallback: (void(^)(NSString* string)) callback;
- (void)setSignalDetectionEventCallback: (void(^)(bool signalStarted)) callback;
- (CGRect)getROIForFrame: (CGSize) frame;
@end
