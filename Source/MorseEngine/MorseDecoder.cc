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

void MorseDecoder::setCleanMessageCallback(std::function<void ()> callback) {
  
}

void MorseDecoder::finishReading() {
  time_of_last_signal_start_ = std::chrono::high_resolution_clock::now();
  last_pause_duration_ = time_of_last_signal_start_ - time_of_last_signal_end_;
  signal_log_.push_back(std::make_pair(false, last_pause_duration_.count()));
  
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
  signal_log_.clear();
}

void MorseDecoder::signalEndDetected() {
  time_of_last_signal_end_ = std::chrono::high_resolution_clock::now();
  last_signal_duration_ = time_of_last_signal_end_ - time_of_last_signal_start_;
  
  signal_log_.push_back(std::make_pair(true, last_signal_duration_.count()));
  
  if (last_signal_duration_.count() > kDahDuration * 0.8) {
    signal_history_.push_back(kDahSymbol);
  } else if (last_signal_duration_.count() > kDitDuration * 0.5 &&
             last_signal_duration_.count() < kDahDuration * 0.5) {
    signal_history_.push_back(kDitSymbol);
  } else {
    std::cout << "Signal end detected without registering" << std::endl;
    std::cout << "  Duration: " << last_signal_duration_.count()/kDitDuration << " Dits, " << last_signal_duration_.count()/kDahSymbol << " Dahs" << std::endl;
  }
}

void MorseDecoder::signalStartDetected() {
  time_of_last_signal_start_ = std::chrono::high_resolution_clock::now();
  last_pause_duration_ = time_of_last_signal_start_ - time_of_last_signal_end_;
  
  signal_log_.push_back(std::make_pair(false, last_pause_duration_.count()));
  
  if (signal_history_.empty()) {
    return;
  } else if (last_pause_duration_.count() < (kIntervalDuration + kCharSeparationDuration)/2) {
    // continue, still parsing glyph
    return;
  } else if (last_pause_duration_.count() < (kCharSeparationDuration + kWordSeparationDuration)/2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    signal_history_.clear();
    if (did_decode_symbol_callback_)
      did_decode_symbol_callback_(symbol);
  } else if (last_pause_duration_.count() > (kCharSeparationDuration + kWordSeparationDuration)/2) {
    std::string symbol = MorseMapper::getSymbol(signal_history_);
    symbol_history.append(symbol);
    signal_history_.clear();
    if (did_decode_word_callback_)
      did_decode_word_callback_(symbol_history);
    symbol_history.clear();
  }
}
