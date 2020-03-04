//
//  MorseDecoder.h
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#ifndef MORSE_DECODER_H_
#define MORSE_DECODER_H_

#include <string>
#include <chrono>
#include <vector>
#include <thread>
#include <condition_variable>

#include "MorseMapper.h"

enum class SignalEvent {
  kMorseSignalStart,
  kMorseSignalEnd,
};

class MorseDecoder {
 public:
  MorseDecoder();
  ~MorseDecoder() {
    if (listening_to_events_) {
      stopListening();
    }
  }
  
  void reset();
  
  void setSymbolDecodedCallback(std::function<void (const std::string&)> callback);
  void setWordDecodedCallback(std::function<void (const std::string&)> callback);
  void setMessageUpdateCallback(std::function<void (const std::string&)> callback);
    
  void parseSignalLog();
  
  void printLog();
  
  void startListening();
  
  void stopListening();
  
  void signalEvent(SignalEvent signal_event);
    
 private:
  void listenToSignalEvents();
  
  std::mutex mutex_;
  std::condition_variable conditional_variable_;
  bool signal_log_updated_ = false;
  SignalEvent new_signal_event_ = SignalEvent::kMorseSignalStart;
  std::thread listener_thread_;
  float idle_time_ = 0;
  bool listening_to_events_ = false;
  
  std::chrono::time_point<std::chrono::high_resolution_clock> time_of_last_signal_start_;
  std::chrono::time_point<std::chrono::high_resolution_clock> time_of_last_signal_end_;
  std::chrono::time_point<std::chrono::high_resolution_clock> time_of_new_signal_event_;
  
  std::function<void (const std::string&)> did_decode_symbol_callback_;
  std::function<void (const std::string&)> did_decode_word_callback_;
  std::function<void (const std::string&)> message_update_callback_;
  
  std::vector<std::pair<bool,float>> signal_log_;
};

#endif // MORSE_DECODER_H_
