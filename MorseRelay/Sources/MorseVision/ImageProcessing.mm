#include <AVKit/AVKit.h>
#import "ImageProcessing.h"

#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>

float getAverageLuminance(const cv::Mat& frame) {
  cv::Scalar average = cv::mean(frame);
  return float(average(0));
}

float getLuminanceOfBrightestSpot(const cv::Mat& frame) {
  cv::Point min_loc, max_loc;
  double min, max;
  cv::Mat blurred_frame;

  cv::GaussianBlur(frame, blurred_frame, cv::Size(3,3), 0);
  cv::minMaxLoc(frame, &min, &max, &min_loc, &max_loc);

  cv::Rect roi;
  roi.x = max_loc.x - 3;
  roi.y = max_loc.y - 3;
  roi.width = 6;
  roi.height = 6;

  /* Crop the original image to the defined ROI */

  cv::Mat flash_area = frame(roi);
  cv::Mat output;
  double max_value = 0.9;
  int adaptive_mode = cv::AdaptiveThresholdTypes::ADAPTIVE_THRESH_MEAN_C;
  int threshold_type = cv::THRESH_BINARY;
  int block_size = 5;
  double constant = 12.3;
  cv::adaptiveThreshold(flash_area, output, max_value, adaptive_mode, threshold_type, block_size, constant);
  // Hacked heuristic: is max lightness above 0.9?
  return (max > 0.9);
}

@implementation ImageProcessing

+ (float)readBuffer:(CMSampleBufferRef)sampleBuffer {
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

  float luminanceDelta =  getAverageLuminance(frame_image_rgb);
  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
  return luminanceDelta;
}

@end
