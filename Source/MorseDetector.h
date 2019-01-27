//
//  MorseDetector.h
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#ifndef MORSEDETECTOR_H_
#define MORSEDETECTOR_H_

#include <string>
#include <vector>

#include <opencv2/core/core.hpp>
#import <opencv2/imgproc/imgproc.hpp>

class MorseDetector {
  std::vector<bool> morse_history;
  std::string detected_string;
  
  float time_since_last_change;
  
  float last_frame_spot_luminosity;
  
  float expected_spot_high_luminosity;
  float expected_spot_low_luminosity;
  
  // Expected duration of morse signals in seconds
  static constexpr float kDahDuration = 0.5;
  static constexpr float kDitDuration = 0.25;
  static constexpr float kIntervalDuration = 0.25;
  static constexpr float kCharSeparationDuration = 0.5;
  static constexpr float kWordSeparationDuration = 1;
  
 public:
  void processFrame(const cv::Mat& frame, float time_since_last_frame) {
    cv::Point min_loc, max_loc;
    double min, max;
    cv::Mat blurred_frame;
    void cv::GaussianBlur(frame, blurred_frame, 3, 0)
    cv::minMaxLoc(frame, &min, &max, &min_loc, &max_loc);
  }
};

#endif // MORSEDETECTOR_H_
