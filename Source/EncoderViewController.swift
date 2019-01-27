//
//  EncoderViewController.swift
//  MorseRelay
//
//  Created by Nicolas Degen on 22.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

import UIKit
import AVKit

class EncoderViewController: UIViewController {
  let textEntry = UITextView(frame: .zero)
  let morseButton = UIButton(frame: .zero)
  let resetButton = UIButton(frame: .zero)
  
  let flashView = UIButton(frame: .zero)
  
  let flashlightEncoder = FlashlightEncoder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    flashlightEncoder.terminationCallback = {
      DispatchQueue.main.async {
        self.cancelMorsing(self.morseButton)
      }
    }
    #if DEBUG
    // flashlightEncoder?.emitMorseMessage("SMS and you")
    #endif
    
    if !flashlightEncoder.deviceHasTorch {
      flashlightEncoder.signalAction = { signal in
      DispatchQueue.main.async {
          if signal {
            self.flashView.backgroundColor = .white
          } else  {
            self.flashView.backgroundColor = .black
          }
        }
      }
    }
  }
  
  @objc func morseTextField(_ sender: UIButton?) {
    flashlightEncoder.emitMorseMessage(textEntry.text)
    sender?.backgroundColor = .red
    morseButton.setTitle("Stop", for: .normal)
    sender?.removeTarget(nil, action: nil, for: .allEvents)
    morseButton.addTarget(self, action: #selector(cancelMorsing), for: .touchDown)
  }
  
  @objc func cancelMorsing(_ sender: UIButton?) {
    flashlightEncoder.cancelMorseEmission()
    sender?.backgroundColor = .green
    morseButton.setTitle("Morse", for: .normal)
    sender?.removeTarget(nil, action: nil, for: .allEvents)
    morseButton.addTarget(self, action: #selector(morseTextField), for: .touchDown)
  }
  
  @objc func resetTextField() {
    textEntry.text = ""
  }
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
    navigationController?.isNavigationBarHidden = true
    
    let margins = view.layoutMarginsGuide
    
    var topAnchor = margins.topAnchor
    
    if !flashlightEncoder.deviceHasTorch {
      view.addSubview(flashView)
      flashView.backgroundColor = .black
      flashView.layer.cornerRadius = 5
      flashView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([flashView.heightAnchor.constraint(equalTo: margins.heightAnchor, multiplier: 0.3),
                                   flashView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                                   flashView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -10),
                                   flashView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10)])
      topAnchor = flashView.bottomAnchor
    }
    
    view.addSubview(morseButton)
    morseButton.backgroundColor = .green
    morseButton.layer.cornerRadius = 5
    morseButton.setTitle("Morse", for: .normal)
    morseButton.addTarget(self, action: #selector(morseTextField), for: .touchDown)
    morseButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([morseButton.heightAnchor.constraint(equalToConstant: 60),
                                 morseButton.leftAnchor.constraint(equalTo: margins.leftAnchor),
                                 morseButton.rightAnchor.constraint(equalTo: margins.centerXAnchor, constant: -10),
                                 morseButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10)])
    
    view.addSubview(resetButton)
    resetButton.backgroundColor = .blue
    resetButton.layer.cornerRadius = 5
    resetButton.setTitle("Reset", for: .normal)
    resetButton.addTarget(self, action: #selector(resetTextField), for: .touchDown)
    resetButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([resetButton.heightAnchor.constraint(equalToConstant: 60),
                                 resetButton.rightAnchor.constraint(equalTo: margins.rightAnchor),
                                 resetButton.leftAnchor.constraint(equalTo: margins.centerXAnchor, constant: 10),
                                 resetButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10)])
    
    textEntry.backgroundColor = UIColor.white.withAlphaComponent(0.2)
    textEntry.textColor = .lightText
    textEntry.clipsToBounds = true
    textEntry.layer.cornerRadius = 5
    textEntry.textAlignment = .natural
    textEntry.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
    
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    textEntry.inputAccessoryView = keyboardToolbar
    
    view.addSubview(textEntry)
    textEntry.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([textEntry.bottomAnchor.constraint(equalTo: morseButton.topAnchor, constant: -10),
                                 textEntry.leftAnchor.constraint(equalTo: margins.leftAnchor),
                                 textEntry.rightAnchor.constraint(equalTo: margins.rightAnchor),
                                 textEntry.topAnchor.constraint(equalTo: topAnchor, constant: 10)])
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent //.default for black style
  }
}
