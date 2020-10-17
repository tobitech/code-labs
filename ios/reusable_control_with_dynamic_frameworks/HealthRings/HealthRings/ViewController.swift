//
//  ViewController.swift
//  HealthRings
//
//  Created by Oluwatobi Omotayo on 31/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import ThreeRingControl

final class ViewController: UIViewController {
  @IBOutlet
  fileprivate weak var threeRingView: ThreeRingView!

  @IBOutlet
  fileprivate weak var animationEnabledSwitch: UISwitch!
  
  @IBOutlet
  fileprivate weak var durationSlider: UISlider!
  
  @IBOutlet
  fileprivate var valueSliders: [UISlider]!
}

//MARK: internal
extension ViewController {
  @IBAction
  func handleUpdateButtonTapped() {
    let values = valueSliders.map{CGFloat($0.value)}
    
    if animationEnabledSwitch.isOn {
      threeRingView.animationDuration = TimeInterval(durationSlider.value)
      
      for (ring, value) in zip(rings, values) {
        threeRingView.animate(
          ring: ring,
          value: value
        )
      }
    } else {
      threeRingView.innerRingValue = values[0]
      threeRingView.middleRingValue = values[1]
      threeRingView.outerRingValue = values[2]
    }
  }
}

//MARK: UIViewController
extension ViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    handleUpdateButtonTapped()
    
    let colors = [threeRingView.innerRingColor, threeRingView.middleRingColor, threeRingView.outerRingColor]
    for (slider, color) in zip(valueSliders, colors) {
      slider.thumbTintColor = color
      slider.minimumTrackTintColor = color.darkened
    }
  }
}

