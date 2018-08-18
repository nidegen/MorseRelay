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
      //Wait until we have data or a quit signal
      //      cv_.wait([this] {
      //        return (dispatch_queue_.size() || quit_);
      //      });
      
      //after wait, we own the lock
      if(dispatch_queue_.size() && !quit_) {
        auto task = std::move(dispatch_queue_.front());
        dispatch_queue_.pop();
        task();
      }
    } while (!quit_);
  });
}

void MorseEncoder::clear() {
  
}

void MorseEncoder::terminate() {
  callOnEncoderThread([this]() {
    quit_ = true;
  });
}

MorseEncoder::~MorseEncoder() {
  if (thread_.joinable()) {
    thread_.join();
  }
}

void MorseEncoder::callOnEncoderThread(std::function<void()> callback) {
  dispatch_queue_.push(callback);
}

void MorseEncoder::morseCharacter(const std::string& character) {
  callOnEncoderThread([this, character]() {
    morseCharacterSynchronous(character);
  });
}

void MorseEncoder::morseWord(const std::string& word) {
  callOnEncoderThread([this, word]() {
    morseWordSynchronous(word);
  });
}

void MorseEncoder::morseMessage(const std::string& message) {
  callOnEncoderThread([this, message]() {
    morseMessageSynchronous(message);
  });
}

void MorseEncoder::morseWordSeparator() {
  callOnEncoderThread([this]() {
    waitSeconds(kWordSeparationDuration);
  });
}

void MorseEncoder::waitSeconds(float duration) {
  std::chrono::microseconds sec(long(duration * 1000000));
  std::this_thread::sleep_for(sec);
}

void MorseEncoder::morseCharacterSynchronous(const std::string& character) {
  MorseGlyph glyph = MorseMapper::getGlyph(character);
  for(bool morse_symbol : glyph) {
    light_source_switch_callback_(true);
    if (morse_symbol == kDitSymbol) {
      waitSeconds(kDitDuration);
    } else {
      waitSeconds(kDahDuration);
    }
    light_source_switch_callback_(false);
    waitSeconds(kIntervalDuration);
  }
  waitSeconds(kCharSeparationDuration - kIntervalDuration);
}

void MorseEncoder::morseWordSynchronous(const std::string& word) {
  std::cout << std::endl << "Morsing word: " << word << std::endl;
  for(const char& c_character : word) {
    std::string character(1, (&c_character)[0]);
    morseCharacterSynchronous(character);
  }
  waitSeconds(kWordSeparationDuration - kCharSeparationDuration);
}

void MorseEncoder::morseMessageSynchronous(std::string message) {
  size_t pos = 0;
  std::string word;
  while ((pos = message.find(' ')) != std::string::npos) {
    word = message.substr(0, pos);
    morseWordSynchronous(word);
    message.erase(0, pos + 1);
  }
  morseWordSynchronous(message);
  waitSeconds(kWordSeparationDuration *2);
}
