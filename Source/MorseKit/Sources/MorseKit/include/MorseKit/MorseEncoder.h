//
//  MorseEncoder.hpp
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include <chrono>
#include <condition_variable>
#include <functional>
#include <mutex>
#include <queue>
#include <string>
#include <thread>
#include <vector>

#include "MorseMapper.h"

#ifndef MORSE_ENCODER_H_
#define MORSE_ENCODER_H_

class MorseEncoder {
 public:
  MorseEncoder(std::function<void (bool)> callback);
  ~MorseEncoder();
  void terminate();
  void pushToEncoderQueue(std::function<void()> callback);
  void waitForQueueFinished();
  void enqueueWordSeparator();
  void clear();
  
  void enqueueCharacter(const std::string& character);
  void enqueueWord(const std::string& word);
  void enqueueMessage(std::string message);

 private:
  std::thread thread_;
  bool quit_ = false;
  std::queue<std::function<void(void)>> dispatch_queue_;
  std::function<void (bool)> light_source_switch_callback_;
  std::mutex queue_lock_;
  
  void waitSeconds(float duration);
};

#endif // MORSE_ENCODER_H_
