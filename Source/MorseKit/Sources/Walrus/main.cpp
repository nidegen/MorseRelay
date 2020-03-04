//
//  main.cpp
//  Walrus
//
//  Created by Nicolas Degen on 17.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include <iostream>
#include "chrono"

#include "MorseKit/MorseDecoder.h"
#include "MorseKit/MorseEncoder.h"
#include "MorseKit/MorseMapper.h"

int main(int argc, const char * argv[]) {
  MorseEncoder morse_encoder_cli([](bool signal_on) {
    if (signal_on) {
      std::cout << "*";
    } else {
      std::cout << "\b";
    }
  });
  
  MorseDecoder morse_decoder;
  
  morse_decoder.startListening();
  
  MorseEncoder morse_encoder_to_decoder([&morse_decoder](bool signal_on) {
    if (signal_on) {
      morse_decoder.signalEvent(SignalEvent::kMorseSignalStart);
    } else {
      morse_decoder.signalEvent(SignalEvent::kMorseSignalEnd);
    }
  });
  
  std::cout << "Here's to you from the walrus: \n";
  morse_encoder_cli.enqueueMessage("hoi sanya");
  
  morse_decoder.setSymbolDecodedCallback([](const std::string& symbol) {
    std::cout << std::endl << "We have seen symbol: " << symbol << std::endl;
  });
  
  morse_decoder.setWordDecodedCallback([](const std::string& symbol) {
    std::cout << std::endl << "We have seen a word: " << symbol << std::endl;
  });
  
//  morse_encoder_to_decoder.enqueueMessage("nya");
  morse_encoder_to_decoder.enqueueMessage("hoi sanya");
  morse_encoder_to_decoder.waitForQueueFinished();

  morse_decoder.stopListening();
//  morse_decoder.printLog();
  
  morse_encoder_cli.terminate();
  morse_encoder_to_decoder.terminate();
  return 0;
}
