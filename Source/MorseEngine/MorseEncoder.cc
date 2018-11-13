//
//  MorseEncoder.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "MorseEncoder.h"

MorseEncoder::MorseEncoder(std::function<void (bool)> callback) {
  light_source_switch_callback_ = callback;
  thread_ = std::thread([this]() {
    do {
//      std::unique_lock<std::mutex> lock(queue_lock_);
      if(dispatch_queue_.size() && !quit_) {
        auto task = std::move(dispatch_queue_.front());
        dispatch_queue_.pop();
        task();
      }
    } while (!quit_);
  });
}

void MorseEncoder::clear() {
  std::queue<std::function<void(void)>> empty;
  std::swap(dispatch_queue_, empty);
}

void MorseEncoder::terminate() {
  quit_ = true;
}

MorseEncoder::~MorseEncoder() {
  if (thread_.joinable()) {
    thread_.join();
  }
}

void MorseEncoder::pushToEncoderQueue(std::function<void()> callback) {
  dispatch_queue_.push(callback);
}

void MorseEncoder::enqueueCharacter(const std::string& character) {
  MorseGlyph glyph = MorseMapper::getGlyph(character);
  for(bool morse_symbol : glyph) {
    pushToEncoderQueue([this, morse_symbol]() {
      light_source_switch_callback_(true);
      if (morse_symbol == kDitSymbol) {
        waitSeconds(kDitDuration);
      } else {
        waitSeconds(kDahDuration);
      }
      light_source_switch_callback_(false);
      waitSeconds(kIntervalDuration);
    });
  }
  pushToEncoderQueue([this]() {
    waitSeconds(kCharSeparationDuration - kIntervalDuration);
  });
}

void MorseEncoder::enqueueWord(const std::string& word) {
  for(const char& c_character : word) {
    std::string character(1, (&c_character)[0]);
    enqueueCharacter(character);
  }
  pushToEncoderQueue([this]() {
    waitSeconds(kWordSeparationDuration - kCharSeparationDuration);
  });
}

void MorseEncoder::enqueueMessage(std::string message) {
  size_t pos = 0;
  std::string word;
  while ((pos = message.find(' ')) != std::string::npos) {
    word = message.substr(0, pos);
    enqueueWord(word);
    message.erase(0, pos + 1);
  }
  enqueueWord(message);
  
  pushToEncoderQueue([this]() {
    waitSeconds(kWordSeparationDuration * 2);
  });
}

void MorseEncoder::enqueueWordSeparator() {
  pushToEncoderQueue([this]() {
    waitSeconds(kWordSeparationDuration);
  });
}

void MorseEncoder::waitSeconds(float duration) {
  std::chrono::microseconds sec(long(duration * 1000000));
  std::this_thread::sleep_for(sec);
}
