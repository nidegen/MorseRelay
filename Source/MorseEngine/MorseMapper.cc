//
//  MorseMapper.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 13.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "MorseMapper.h"

/* static */
const SymbolToMorseGlyphMap MorseMapper::kSymbolToGlyph {
  {"A", std::vector<bool> {kDitSymbol, kDahSymbol}},
  {"B", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  {"C", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},
  {"D", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol}},
  {"E", std::vector<bool> {kDitSymbol}},
  {"F", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},
  {"G", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol}},
  {"H", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  {"I", std::vector<bool> {kDitSymbol, kDitSymbol}},
  {"J", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol}},
  {"K", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol}},
  {"L", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"M", std::vector<bool> {kDahSymbol, kDahSymbol}},
  {"N", std::vector<bool> {kDahSymbol, kDitSymbol}},
  {"O", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol}},
  {"P", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},
  {"Q", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  {"R", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol}},
  {"S", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol}},
  {"T", std::vector<bool> {kDahSymbol}},
  {"U", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol}},
  {"V", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},
  {"W", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol}},
  {"X", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},
  {"Y", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},
  {"Z", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"1", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}},
  {"2", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol}},
  {"3", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},
  {"4", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},
  {"5", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  {"6", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  {"7", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  {"8", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"9", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},
  {"0", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}},
  
  {"À", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  {"Å", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  {"Ä", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  {"È", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},
  {"É", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"Ö", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},
  {"OE", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},
  {"Ü", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},
  {"ß", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"SZ", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},
  {"CH", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}},
  {"Ñ", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},
  
  {".", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},           // AAA
  {",", std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},           // MIM
  {":", std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},           // OS
  {";", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},           // NNN
  {"?", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}},           // IMI
  {"!", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}},           // KW
  {"-", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},           // BA
  {"_", std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},           // UK
  {"(", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},                 // KN
  {")", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},           // KK
  {"'", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}},           // JN
  {"=", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},                // BT
  {"+", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},                // AR
  {"/", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},              // DN
  {"@", std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},           // AC
  
  // {"KA (Spruchanfang)", std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  // {"BT (Pause)", std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}},
  // {"AR (Spruchende)", std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},
  // {"VE (verstanden)", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}},
  // {"SK (Verkehrsende)", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}},
  // {"SOS (internationaler (See-)Notruf)", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
  // {"HH (Fehler; Irrung; Wiederholung ab letztem vollständigen Wort)", std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}},
};

/* static */
const MorseGlyphToSymbolMap MorseMapper::kGlyphToSymbol {
  {std::vector<bool> {kDitSymbol, kDahSymbol}, "A"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "B"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "C"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol}, "D"},
  {std::vector<bool> {kDitSymbol}, "E"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "F"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol}, "G"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "H"},
  {std::vector<bool> {kDitSymbol, kDitSymbol}, "I"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol}, "J"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol}, "K"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "L"},
  {std::vector<bool> {kDahSymbol, kDahSymbol}, "M"},
  {std::vector<bool> {kDahSymbol, kDitSymbol}, "N"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol}, "O"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol}, "P"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "Q"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol}, "R"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol}, "S"},
  {std::vector<bool> {kDahSymbol}, "T"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol}, "U"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "V"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol}, "W"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "X"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, "Y"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "Z"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}, "1"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol}, "2"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, "3"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "4"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "5"},
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "6"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "7"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "8"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}, "9"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}, "0"},
  
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "Å"}, // À, Å
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "Ä"},
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "È"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "É"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}, "Ö"}, // OE
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, "Ü"},
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "ß"}, //SZ
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol}, "CH"},
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, "Ñ"},
  
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "."}, // AAA
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, ","}, // MIM
  {std::vector<bool> {kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, ":"}, // OS
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, ";"}, // NNN
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol}, "?"}, // IMI
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol}, "!"}, // KW
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "-"}, // BA
  {std::vector<bool> {kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "_"}, // UK
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol}, "("},             // KN
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, ")"}, // KK
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol}, "'"}, // JN
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "="},             // BT
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "+"},             // AR
  {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "/"},             // DN
  {std::vector<bool> {kDitSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "@"}, // AC
  
  // {std::vector<bool> {kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "KA (Spruchanfang)"},
  // {std::vector<bool> {kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol}, "BT (Pause)"},
  // {std::vector<bool> {kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "AR (Spruchende)"},
  // {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol}, "VE (verstanden)"},
  // {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDitSymbol, kDahSymbol}, "SK (Verkehrsende)"},
  // {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDahSymbol, kDahSymbol, kDahSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "SOS (internationaler (See-)Notruf)"},
  // {std::vector<bool> {kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol, kDitSymbol}, "HH (Fehler; Irrung; Wiederholung ab letztem vollständigen Wort)"},
};
