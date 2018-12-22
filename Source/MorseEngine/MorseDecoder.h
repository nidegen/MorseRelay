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

#include "MorseMapper.h"

class MorseDecoder {
 public:
  MorseDecoder();
  
  void reset();
  
  void setSymbolDecodedCallback(std::function<void (const std::string&)> callback);
  void setWordDecodedCallback(std::function<void (const std::string&)> callback);
  void setCleanMessageCallback(std::function<void ()> callback);
  
  void finishReading();
  
  void signalEndDetected();
  void signalStartDetected();
  
  void printLog() {
    
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
    
 private:
  std::vector<bool> signal_history_;
  std::string symbol_history;
  
  std::chrono::duration<float> last_signal_duration_;
  std::chrono::duration<float> last_pause_duration_;
  
  std::chrono::time_point<std::chrono::high_resolution_clock> time_of_last_signal_start_;
  std::chrono::time_point<std::chrono::high_resolution_clock> time_of_last_signal_end_;
  
  std::function<void (const std::string&)> did_decode_symbol_callback_;
  std::function<void (const std::string&)> did_decode_word_callback_;
  
  std::vector<std::pair<bool,float>> signal_log_;
};

#endif // MORSE_DECODER_H_
