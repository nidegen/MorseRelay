//
//  MorseMapper.h
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#ifndef MORSE_MAPPER_H_
#define MORSE_MAPPER_H_

#include <vector>
#include <string>
#include <unordered_map>


#include <iostream>

typedef std::vector<bool> MorseGlyph;
typedef std::unordered_map<std::string, MorseGlyph> SymbolToMorseGlyphMap;
typedef std::unordered_map<MorseGlyph, std::string> MorseGlyphToSymbolMap;

static bool kDahSymbol = true;
static bool kDitSymbol = false;

enum class MorseUnit {
  kDah,
  kDit,
  kInterval,
  kCharacterSeparator,
  kWordSeparator
};

static float kDitDuration = 0.2;
static float kDahDuration = 3 * kDitDuration;
static float kIntervalDuration = kDitDuration;
static float kCharSeparationDuration = kDahDuration;
static float kWordSeparationDuration = 7 * kDitDuration;

class MorseMapper {
 public:
  inline static MorseGlyph getGlyph(std::string character) {
    std::transform(character.begin(), character.end(), character.begin(), ::toupper);
    if (kSymbolToGlyph.find(character) == kSymbolToGlyph.end()) {
      std::cout << "Unknown symbol: " << character << ". Ignoring..." << std::endl;
      return MorseGlyph();
    }
    return kSymbolToGlyph.at(character);
  }
  
  inline static std::string getSymbol(const MorseGlyph& glyph) {
    if (kGlyphToSymbol.find(glyph) == kGlyphToSymbol.end()) {
      std::cout << "Unknown glyph: ";
      for (bool glyph_element: glyph) {
        std:: cout << glyph_element;
      }
      std::cout << ". Ignoring..." << std::endl;
      return "";
    }
    return kGlyphToSymbol.at(glyph);
  }
 private:
  static const SymbolToMorseGlyphMap kSymbolToGlyph;
  static const MorseGlyphToSymbolMap kGlyphToSymbol;
};

#endif // MORSE_MAPPER_H_
