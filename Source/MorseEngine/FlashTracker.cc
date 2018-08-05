//
//  FlashTracker.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 15.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "FlashTracker.h"

/* static */
bool FlashTracker::processFrame(const cv::Mat& frame) {
  cv::Point min_loc, max_loc;
  double min, max;
  cv::Mat blurred_frame;
  
  // acv::GaussianBlur(<#cv::InputArray src#>, <#cv::OutputArray dst#>, <#cv::Size ksize#>, <#double sigmaX#>)
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
  //  cv::adaptiveThreshold(flash_arsignalStartDetectedea, output, <#double maxValue#>, <#int adaptiveMethod#>, <#int thresholdType#>, <#int blockSize#>, <#double C#>)
  cv::adaptiveThreshold(flash_area, output, max_value, adaptive_mode, threshold_type, block_size, constant);
  
  // Hacked heuristic: is max lightness above 0.9?
  return (max > 0.9);
}
