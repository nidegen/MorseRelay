//
//  NSEncoderViewController.swift
//  MorseRelayDebugger
//
//  Created by Nicolas Degen on 11.10.18.
//  Copyright © 2018 nide. All rights reserved.
//

import Cocoa

class NSEncoderViewController: NSViewController {
  var textEntry = NSTextField(frame: .zero)
  var morseButton = NSButton(frame: .zero)
  var resetButton = NSButton(frame: .zero)
  var flashView = NSImageView(frame: .zero)
  
  let flashlightEncoder = FlashlightEncoder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    flashlightEncoder.terminationCallback = {
      self.cancelMorsing(self.morseButton)
    }
    #if DEBUG
    // flashlightEncoder?.emitMorseMessage("SMS and you")
    #endif
    
    flashlightEncoder.signalAction = {
      signalOn in
      DispatchQueue.main.async {
        if signalOn {
          self.flashView.image = NSImage(named: "Background")
        } else {
          self.flashView.image = nil
        }
      }
    }
    flashlightEncoder.terminationCallback = {
      DispatchQueue.main.async {
        self.cancelMorsing(self.morseButton)
      }
    }
  }
  
  @objc func morseTextField(_ sender: NSButton?) {
    flashlightEncoder.emitMorseMessage(textEntry.stringValue)
    sender?.contentTintColor = .red
    morseButton.title = "Cancel"
    sender?.action = #selector(cancelMorsing)
  }
  
  @objc func cancelMorsing(_ sender: NSButton?) {
    flashlightEncoder.cancelMorseEmission()
    sender?.contentTintColor = .green
    morseButton.title = "Morse"
    sender?.action =  #selector(morseTextField)
  }
  
  @objc func resetTextField() {
    textEntry.stringValue = ""
  }
  
  override func loadView() {
    super.loadView()
    
    morseButton.bezelStyle = .rounded
    view.addSubview(morseButton)
    morseButton.contentTintColor = .green
    morseButton.layer?.cornerRadius = 5
    morseButton.title = "Morse"
    morseButton.action = #selector(morseTextField)
    morseButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([morseButton.heightAnchor.constraint(equalToConstant: 30),
                                 morseButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
                                 morseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
                                 morseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)])
    
    resetButton.bezelStyle = .rounded
    view.addSubview(resetButton)
    resetButton.contentTintColor = .blue
    resetButton.layer?.cornerRadius = 5
    resetButton.title = "Reset"
    resetButton.action = #selector(resetTextField)
    resetButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([resetButton.heightAnchor.constraint(equalToConstant: 30),
                                 resetButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
                                 resetButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
                                 resetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)])
    
    view.addSubview(flashView)
    flashView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([flashView.heightAnchor.constraint(equalToConstant: 100),
                                 flashView.widthAnchor.constraint(equalTo: flashView.widthAnchor),
                                 flashView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 flashView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)])
    
    textEntry.backgroundColor = NSColor.white.withAlphaComponent(0.2)
    textEntry.textColor = .black
    textEntry.layer?.cornerRadius = 5
    textEntry.alignment = .natural
    textEntry.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    
    view.addSubview(textEntry)
    textEntry.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([textEntry.heightAnchor.constraint(equalToConstant: 100),
                                 textEntry.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
                                 textEntry.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 textEntry.topAnchor.constraint(equalTo: flashView.bottomAnchor, constant: 10)])
  }
}
