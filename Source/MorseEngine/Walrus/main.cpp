//
//  main.cpp
//  Walrus
//
//  Created by Nicolas Degen on 17.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include <iostream>
#include "chrono"

#include "MorseDecoder.h"
#include "MorseEncoder.h"
#include "MorseMapper.h"

int main(int argc, const char * argv[]) {
  MorseEncoder morse_encoder_cli([](bool signal_on) {
    if (signal_on) {
      std::cout << "*";
    } else {
      std::cout << "\b";
    }
  });
  
  MorseDecoder morse_decoder;
  
  MorseEncoder morse_encoder_to_decoder([&morse_decoder](bool signal_on) {
    if (signal_on) {
      morse_decoder.signalStartDetected();
    } else {
      morse_decoder.signalEndDetected();
    }
  });
  
  std::cout << "Here's to you from the walrus: \n";
  morse_encoder_cli.morseCharacter("S");
  morse_encoder_cli.morseCharacter("M");
  morse_encoder_cli.morseCharacter("S");
  
  morse_decoder.setSymbolDecodedCallback([](const std::string& symbol) {
    std::cout << std::endl << "We have seen symbol: " << symbol << std::endl;
  });
  
  morse_decoder.setWordDecodedCallback([](const std::string& symbol) {
    std::cout << std::endl << "We have seen a word: " << symbol << std::endl;
  });
  
  morse_encoder_to_decoder.morseCharacter("S");
  morse_encoder_to_decoder.morseCharacter("O");
  morse_encoder_to_decoder.morseCharacter("S");
  morse_encoder_to_decoder.callOnEncoderThread([&morse_decoder]() {
    morse_decoder.finishReading();
  });
  morse_encoder_cli.terminate();
  morse_encoder_to_decoder.terminate();
  return 0;
}