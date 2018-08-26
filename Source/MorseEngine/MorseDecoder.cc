//
//  MorseDecoder.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "MorseDecoder.h"

MorseDecoder::MorseDecoder() {
  this->reset();
}

void MorseDecoder::setSymbolDecodedCallback(std::function<void (const std::string&)> callback) {
  did_decode_symbol_callback_ = callback;
}

void MorseDecoder::setWordDecodedCallback(std::function<void (const std::string&)> callback) {
  did_decode_word_callback_ = callback;
}

void MorseDecoder::finishReading() {
  time_of_last_signal_start_ = std::chrono::high_resolution_clock::now();
  last_pause_duration_ = time_of_last_signal_start_ - time_of_last_signal_end_;
  if (last_pause_duration_.count() < kCharSeparationDuration * 1.2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    if (did_decode_symbol_callback_)
      did_decode_symbol_callback_(symbol);
    signal_history_.clear();
  } else if (last_pause_duration_.count() < kWordSeparationDuration * 1.2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    
    if (did_decode_word_callback_)
      did_decode_word_callback_(symbol_history);
    signal_history_.clear();
    symbol_history.clear();
  }
}

void MorseDecoder::reset() {
  time_of_last_signal_end_ = std::chrono::high_resolution_clock::now();
  last_signal_duration_ = std::chrono::seconds(20);
  signal_history_.clear();
}

void MorseDecoder::signalEndDetected() {
  time_of_last_signal_end_ = std::chrono::high_resolution_clock::now();
  last_signal_duration_ = time_of_last_signal_end_ - time_of_last_signal_start_;
  if (last_signal_duration_.count() > kDahDuration * 0.9) {
    signal_history_.push_back(kDahSymbol);
  } else {
    signal_history_.push_back(kDitSymbol);
  }
}

void MorseDecoder::signalStartDetected() {
  time_of_last_signal_start_ = std::chrono::high_resolution_clock::now();
  last_pause_duration_ = time_of_last_signal_start_ - time_of_last_signal_end_;
  if (last_pause_duration_.count() < kIntervalDuration * 1.2) {
    //continue, still parsing glyph
  } else if (last_pause_duration_.count() < kCharSeparationDuration * 1.2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    signal_history_.clear();
    if (did_decode_symbol_callback_)
      did_decode_symbol_callback_(symbol);
  } else if (last_pause_duration_.count() < kWordSeparationDuration * 1.2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    signal_history_.clear();
    if (did_decode_word_callback_)
      did_decode_word_callback_(symbol_history);
    symbol_history.clear();
  }
}
