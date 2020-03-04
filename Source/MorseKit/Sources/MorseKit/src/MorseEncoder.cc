//
//  MorseEncoder.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "MorseKit/MorseEncoder.h"

#include <future>

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
void MorseEncoder::waitForQueueFinished() {
  std::promise<bool> queue_finished_promise;
  std::future<bool> queue_finished_future = queue_finished_promise.get_future();
  dispatch_queue_.push([&queue_finished_promise, this](){
    queue_finished_promise.set_value(true);
  });
  queue_finished_future.wait();
  return;
}

void MorseEncoder::enqueueCharacter(const std::string& character) {
  MorseGlyph glyph = MorseMapper::getGlyph(character);

  if (glyph.empty()) {
    return;
  }
  for (int i = 0; i < glyph.size() - 1; ++i) {
    if (glyph[i] == kDitSymbol) {
      pushToEncoderQueue([this]() {
        light_source_switch_callback_(true);
        waitSeconds(kDitDuration);
        light_source_switch_callback_(false);
        waitSeconds(kIntervalDuration);
      });
    } else {
      pushToEncoderQueue([this]() {
        light_source_switch_callback_(true);
        waitSeconds(kDahDuration);
        light_source_switch_callback_(false);
        waitSeconds(kIntervalDuration);
      });
    }
  }
  
  // For last glyph signal, do not append signal interval waiting time
  if (glyph.back() == kDitSymbol) {
    pushToEncoderQueue([this]() {
      light_source_switch_callback_(true);
      waitSeconds(kDitDuration);
      light_source_switch_callback_(false);
    });
  } else {
    pushToEncoderQueue([this]() {
      light_source_switch_callback_(true);
      waitSeconds(kDahDuration);
      light_source_switch_callback_(false);
    });
  }
}

void MorseEncoder::enqueueWord(const std::string& word) {
  const char &last_c_caharacter = *(--word.end());
  
  for(const char& c_character : word) {
    std::string character(1, (&c_character)[0]);
    enqueueCharacter(character);
    
    // For last character, do not append character separation waiting time
    if (&c_character == &last_c_caharacter) {
      return;
    }
    pushToEncoderQueue([this]() {
      waitSeconds(kCharSeparationDuration);
    });
  }
}

void MorseEncoder::enqueueMessage(std::string message) {
  size_t pos = 0;
  std::string word;
  while ((pos = message.find(' ')) != std::string::npos) {
    word = message.substr(0, pos);
    enqueueWord(word);
    message.erase(0, pos + 1);
    
    pushToEncoderQueue([this]() {
      waitSeconds(kWordSeparationDuration);
    });
  }
  enqueueWord(message);
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
