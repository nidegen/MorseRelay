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

void MorseDecoder::setMessageUpdateCallback(std::function<void (const std::string&)> callback) {
  message_update_callback_ = callback;
}

void MorseDecoder::parseSignalLog() {
  std::string updated_message = "";
 
  std::vector<MorseUnit> morse_signal;
  MorseGlyph current_morse_glyph;
  
  for (const auto& signal : signal_log_) {
    bool emmitting_signal = signal.first;
    float signal_duration = signal.second;
    
    if (emmitting_signal) {
      if (signal_duration > kDahDuration * 0.8) {
        morse_signal.push_back(MorseUnit::kDah);
      } else if (signal_duration > kDitDuration * 0.5 &&
                 signal_duration < kDahDuration * 0.5) {
        morse_signal.push_back(MorseUnit::kDit);
      } else {
#if DEBUG
       std::cout << "Too short signal parsed." << std::endl;
       std::cout << "  duration: " << signal_duration/kDitDuration << " Dits, " << signal_duration/kDahSymbol << " Dahs" << std::endl;
#endif
      }
    } else {
      if (signal_duration < (kIntervalDuration + kCharSeparationDuration)/2) {
        morse_signal.push_back(MorseUnit::kInterval);
      } else if (signal_duration < (kCharSeparationDuration + kWordSeparationDuration)/2) {
        morse_signal.push_back(MorseUnit::kCharacterSeparator);
      } else if (signal_duration > (kCharSeparationDuration + kWordSeparationDuration)/2) {
        morse_signal.push_back(MorseUnit::kWordSeparator);
      }
    }
  }
  
  bool did_end_with_word = false;
  for (const MorseUnit& unit : morse_signal) {
    did_end_with_word = false;
    switch (unit) {
      case MorseUnit::kDit:
        current_morse_glyph.push_back(kDitSymbol);
        break;
      case MorseUnit::kDah:
        current_morse_glyph.push_back(kDahSymbol);
        break;
      case MorseUnit::kCharacterSeparator:
        if (!current_morse_glyph.empty()) {
          updated_message.append(MorseMapper::getSymbol(current_morse_glyph));
          current_morse_glyph.clear();
        }
        break;
      case MorseUnit::kWordSeparator:
        if (!current_morse_glyph.empty()) {
          updated_message.append(MorseMapper::getSymbol(current_morse_glyph));
          current_morse_glyph.clear();
          did_end_with_word = true;
          updated_message.append(" ");
        }
        break;
      case MorseUnit::kInterval:
        continue;
        break;
    }
  }
  
  if (did_end_with_word) {
    auto index = updated_message.find_last_of(' ');
    std::string last_word = updated_message.substr(0, index);
    index = last_word.find_last_of(' ');
    last_word = last_word.substr(++index);
    
    // todo: use this
    // std::string last_wrd = updated_message.substr(0, updated_message.size()-1).substr(++index);
    
    if (did_decode_symbol_callback_) {
      did_decode_symbol_callback_(&last_word.back());
    }
    
    if (did_decode_word_callback_) {
      did_decode_word_callback_(last_word);
    }
  }
  if (message_update_callback_) {
    message_update_callback_(updated_message);
  }

  if (morse_signal.empty()) {
    return;
  }
  
  if (morse_signal.back() == MorseUnit::kCharacterSeparator) {
    if (did_decode_symbol_callback_) {
      did_decode_symbol_callback_(&updated_message.back());
    }
  }
}

void MorseDecoder::reset() {
  time_of_last_signal_end_ = std::chrono::high_resolution_clock::now();
  time_of_last_signal_start_ = std::chrono::high_resolution_clock::now();
  signal_log_.clear();
}

void MorseDecoder::listenToSignalEvents() {
  idle_time_ = 0;
  while (true) {
    std::unique_lock<std::mutex> lock(mutex_);
    // Let thread sleep until signal_log_updated_ is set to true or after 0.01 seconds:
    conditional_variable_.wait_for(lock, std::chrono::duration<double>(0.01), [this] {
      return signal_log_updated_;
    });
    
    if (signal_log_updated_) {
      idle_time_ = 0;
//      std::cout << "Got an update! " << std::endl;
      
      if (new_signal_event_ == SignalEvent::kMorseSignalStart) {
        time_of_last_signal_start_ = time_of_new_signal_event_;
        if (signal_log_.empty()) {
          continue;
        }
        float pause_duration = std::chrono::duration<float>(time_of_new_signal_event_ - time_of_last_signal_end_).count();
        signal_log_.push_back(std::make_pair(false, pause_duration));
      } else if (new_signal_event_ == SignalEvent::kMorseSignalEnd) {
        time_of_last_signal_end_ = time_of_new_signal_event_;
        float emission_duration = std::chrono::duration<float>(time_of_new_signal_event_ - time_of_last_signal_start_).count();
        if (emission_duration < 0) {
          continue;
        }
        signal_log_.push_back(std::make_pair(true, emission_duration));
      }
      
      parseSignalLog();
      
      signal_log_updated_ = false;
    } else {
      if (!listening_to_events_)
        break;
      idle_time_ += 0.01;
    }
  }
}

void MorseDecoder::startListening() {
  listening_to_events_ = true;
  listener_thread_ = std::thread(&MorseDecoder::listenToSignalEvents, this);
}

void MorseDecoder::stopListening() {
  // Terminate currently recorded signal:
  if (!signal_log_.empty() && signal_log_.back().first)
    signal_log_.push_back(std::make_pair(false, kWordSeparationDuration));
  
  listening_to_events_ = false;
  if (listener_thread_.joinable()) {
    listener_thread_.join();
  }
  parseSignalLog();
}

void MorseDecoder::signalEvent(SignalEvent signal_event) {
  std::unique_lock<std::mutex> lock(mutex_);
  signal_log_updated_ = true;
  new_signal_event_ = signal_event;
  time_of_new_signal_event_ = std::chrono::high_resolution_clock::now();
  
  lock.unlock();
  conditional_variable_.notify_one();
}

void MorseDecoder::printLog() {
  std::cout << "\n\n signals: \n" << std::endl;
  
  for (const auto& signal_piece : signal_log_) {
    float duration = signal_piece.second;
    bool is_signal = signal_piece.first;
    
    if (is_signal) {
      std::cout << duration << std::endl;
    }
  }
  
  std::cout << "\n\n pauses: \n" << std::endl;
  
  for (const auto& signal_piece : signal_log_) {
    float duration = signal_piece.second;
    bool is_signal = signal_piece.first;
    
    if (!is_signal) {
      std::cout << duration << std::endl;
    }
  }
}
