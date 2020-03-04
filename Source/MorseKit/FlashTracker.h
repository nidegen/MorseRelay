//
//  FlashTracker.h
//  MorseRelay
//
//  Created by Nicolas Degen on 15.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#ifndef FLASH_DETECTOR_H_
#define FLASH_DETECTOR_H_

#include <functional>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "MorseDecoder.h"

class FlashTracker {
 public:
  static float processFrame(const cv::Mat& frame);
};

#endif // FLASH_DETECTOR_H_
