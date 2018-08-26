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
  var textEntry: UITextView!
  var morseButton: UIButton!
  
  let flashlightEncoder = FlashlightEncoder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    #if DEBUG
//    flashlightEncoder?.emitMorseMessage("SMS and you")
    #endif
  }
  
  @objc func morseTextField() {
    flashlightEncoder?.emitMorseMessage(textEntry.text)
  }
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
    navigationController?.isNavigationBarHidden = true
    
    let margins = view.layoutMarginsGuide
    
    morseButton = UIButton(frame: .zero)
    view.addSubview(morseButton)
    morseButton.backgroundColor = .black
    morseButton.layer.cornerRadius = 5
    morseButton.setTitle("Morse", for: .normal)
    morseButton.addTarget(self, action: #selector(morseTextField), for: .touchDown)
    morseButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([morseButton.heightAnchor.constraint(equalToConstant: 60),
                                 morseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
                                 morseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 morseButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20)])
    
    textEntry = UITextView(frame: .zero)
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
    NSLayoutConstraint.activate([textEntry.bottomAnchor.constraint(equalTo: morseButton.topAnchor, constant: -20),
                                 textEntry.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
                                 textEntry.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                 textEntry.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20)])
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension EncoderViewController: UITextViewDelegate {
//  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
//                replacementText text: String) -> Bool {
//    <#code#>
//  }
//  func textViewShouldReturn(_ textField: UITextField) -> Bool {
//      textField.resignFirstResponder()
//    return true
//  }
}
