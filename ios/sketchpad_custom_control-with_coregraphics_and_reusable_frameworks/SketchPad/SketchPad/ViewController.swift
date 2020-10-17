//
//  ViewController.swift
//  SketchPad
//
//  Created by Oluwatobi Omotayo on 30/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import Colorgon
import DeluxeButton
import Scribble
import UIKit

final class ViewController: UIViewController {
  
    @IBOutlet
    fileprivate private(set) weak var colorgonView: Colorgon.View!

    @IBOutlet fileprivate private(set) weak var fillButton: DeluxeButton!
    
    @IBOutlet
    fileprivate private(set) weak var canvas: CanvasView! {
        didSet {
            canvas.drawColor = CanvasView.makeTexturePatternColor(texture: #imageLiteral(resourceName: "DrawingTexture"), color: .black)
        }
    }
}

//MARK: @IBAction
private extension ViewController {
  @IBAction
  func handleFillButtonTapped() {
    canvas.canvasColor = fillButton.unpressedBackgroundColor
  }
}

// MARK: UIViewController
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorgonView.handleColorSelection = { [unowned self] color in
            self.canvas.drawColor =
            CanvasView.makeTexturePatternColor(
                texture: #imageLiteral(resourceName: "DrawingTexture"), color: color
            )
            self.fillButton.unpressedBackgroundColor = color
            self.fillButton.pressedBackgroundColor = color.highlighted
            
            self.fillButton.tintColor = self.colorgonView.value < 0.25
                ? UIColor(white: 0.6, alpha: 1)
                : .black
        }
    }
}

//MARK:-
private extension UIColor {
  var highlighted: UIColor {
    var hue = CGFloat()
    var saturation = CGFloat()
    var brightness = CGFloat()
    var alpha = CGFloat()
    
    getHue(
      &hue,
      saturation: &saturation,
      brightness: &brightness,
      alpha: &alpha
    )
    
    return UIColor(
      hue: hue,
      saturation: saturation * 0.4,
      brightness: brightness * 1.2,
      alpha: alpha
    )
  }
}

