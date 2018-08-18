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
  var textEntryField: UITextField!
  var morseButton: UIButton!
  
  let flashlightEncoder = FlashlightEncoder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    #if DEBUG
//    flashlightEncoder?.emitMorseMessage("SMS and you")
    #endif
  }
  
  @objc func morseTextField() {
    flashlightEncoder?.emitMorseMessage(textEntryField.text)
  }
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
    textEntryField = UITextField(frame: .zero)
    textEntryField.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
    textEntryField.textColor = .white
    textEntryField.borderStyle = .roundedRect
    textEntryField.textAlignment = .natural
    textEntryField.contentVerticalAlignment = .top
    view.addSubview(textEntryField)
    textEntryField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([textEntryField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120 - self.additionalSafeAreaInsets.bottom),
                                 textEntryField.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
                                 textEntryField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                 textEntryField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40 + self.additionalSafeAreaInsets.top)])
    textEntryField.borderStyle = .roundedRect
    textEntryField.delegate = self
    textEntryField.returnKeyType = .done

    
    
    morseButton = UIButton(frame: .zero)
    view.addSubview(morseButton)
    morseButton.backgroundColor = .darkGray
    morseButton.layer.cornerRadius = 5
    morseButton.setTitle("Morse", for: .normal)
    morseButton.addTarget(self, action: #selector(morseTextField), for: .touchDown)
    morseButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([morseButton.heightAnchor.constraint(equalToConstant: 60),
                                 morseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                                 morseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 morseButton.topAnchor.constraint(equalTo: textEntryField.bottomAnchor, constant: 30)])
  }
}

extension EncoderViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
    return true
  }
}
