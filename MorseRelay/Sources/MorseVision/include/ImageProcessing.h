#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageProcessing : NSObject

+ (float)readBuffer:(CMSampleBufferRef)sampleBuffer;
@end


NS_ASSUME_NONNULL_END
