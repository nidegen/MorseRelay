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
  void callOnEncoderThread(std::function<void()> callback);
  void morseCharacter(const std::string& character);
  void morseWord(const std::string& word);
  void morseMessage(const std::string& message);
  void morseWordSeparator();
  void clear();
  
 private:
  
  std::thread thread_;
  bool quit_ = false;
  std::queue<std::function<void(void)>> dispatch_queue_;
  std::function<void (bool)> light_source_switch_callback_;
  
  void waitSeconds(float duration);
  void morseCharacterSynchronous(const std::string& character);
  void morseWordSynchronous(const std::string& word);
  void morseMessageSynchronous(std::string message);
};

#endif // MORSE_ENCODER_H_
