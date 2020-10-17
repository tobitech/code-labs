//
//  ViewController.swift
//  BahamAirLoginScreen
//
//  Created by Oluwatobi Omotayo on 05/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: IB Outlets

  @IBOutlet var loginButton: UIButton!
  @IBOutlet var heading: UILabel!
  @IBOutlet var username: UITextField!
  @IBOutlet var password: UITextField!

  @IBOutlet var cloud1: UIImageView!
  @IBOutlet var cloud2: UIImageView!
  @IBOutlet var cloud3: UIImageView!
  @IBOutlet var cloud4: UIImageView!

  let info = UILabel()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Call animation methods here
    animateForm()
    animateLoginButton()
    animateBalloon()
    
    animateCloud(layer: cloud1.layer)
    animateCloud(layer: cloud2.layer)
    animateCloud(layer: cloud3.layer)
    animateCloud(layer: cloud4.layer)
    
    username.delegate = self
    password.delegate = self
  }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animateInfo()
    }

  // MARK:- Animation Methods
    
    func animateBalloon() {
        // TODO: Add Keyframe Animation
        let balloon = CALayer()
        balloon.contents = UIImage(named: "balloon")!.cgImage
        balloon.frame = CGRect(x: -50.0, y: 0.0, width: 50.0, height: 65.0)
        view.layer.insertSublayer(balloon, above: username.layer)
        
        let flight = CAKeyframeAnimation(keyPath: keyPath.position)
        flight.duration = 12.0
        
        flight.keyTimes = [0.0, 0.5, 1.0] // percentage of progress through the animation's duration. mapped to a number between 0 and 1.
        flight.values = [
            CGPoint(x: -50.0, y: 0),
            CGPoint(x: view.frame.width + 50.0, y: 160.0),
            CGPoint(x: -50.0, y: loginButton.center.y)
        ] // position values to go with each key time.
        
        balloon.add(flight, forKey: nil)
    }
    
    func animateCloud(layer: CALayer) {
        let cloudSpeed = 60.0 / Double(view.layer.frame.size.width)
        let duration: TimeInterval = Double(view.layer.frame.size.width - layer.frame.origin.x) * cloudSpeed
        
        let cloudMove = CABasicAnimation(keyPath: keyPath.positionX)
        cloudMove.duration = duration
        cloudMove.toValue = self.view.bounds.size.width + layer.bounds.width / 2
        cloudMove.delegate = self
        cloudMove.fillMode = .forwards
        
        cloudMove.setValue("cloud", forKey: "name")
        cloudMove.setValue(layer, forKey: "layer")
        
        layer.add(cloudMove, forKey: nil)
    }
    
  func animateForm() {
    // TODO: Add your first layer animation
    // 1 - create the animation object
    // TODO: Change `flyRight` to spring animation
    // let flyRight = CABasicAnimation(keyPath: keyPath.positionX)
    let flyRight = CASpringAnimation(keyPath: keyPath.positionX)
    
    flyRight.damping = 250 // has a default value of 10.0
    flyRight.mass = 50.0 // has a default value of 1.0
    flyRight.stiffness = 800.0 // default is 100.0
    flyRight.initialVelocity = 1.0 // default value is 0.0, negative values allowed.
    
    flyRight.duration = flyRight.settlingDuration // 0.5
    flyRight.fromValue = -view.bounds.size.width / 2
    flyRight.toValue = view.bounds.size.width / 2
    
    // TODO: Experiment with animation timing
    flyRight.timingFunction = CAMediaTimingFunction(
        controlPoints: 0.99, 0, 0, 0.99
    ) // CAMediaTimingFunction(name: .easeOut)
    // flyRight.speed = 0.25
    flyRight.fillMode = .backwards
    
    // TODO: set delegate for animation
    flyRight.delegate = self // any copy of this animation would fire up the delegate method as it should.
    flyRight.setValue("form", forKey: "name")
    
    // 2 - Add the animation to a layer
    flyRight.setValue(heading.layer, forKey: "layer")
    heading.layer.add(flyRight, forKey: nil)
    
    flyRight.setValue(username.layer, forKey: "layer")
    flyRight.beginTime = CACurrentMediaTime() + 0.3
    username.layer.add(flyRight, forKey: nil)
    
    flyRight.setValue(password.layer, forKey: "layer")
    flyRight.beginTime = CACurrentMediaTime() + 0.5
    password.layer.add(flyRight, forKey: nil)
    
    // 3 - update the layer model
    // -- step not needed for this example.
  }
    
    func animateLoginButton() {
        // TODO: Add animation group to scale, rotate, and fade in loginButton
        // 1 - Create a CAAnimationGroup
        let groupAnimation = CAAnimationGroup()
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        groupAnimation.beginTime = CACurrentMediaTime() + 0.5 // remember this is how to set delay.
        groupAnimation.duration = 0.5
        groupAnimation.fillMode = .backwards
        
        // 2 - Create the animations you want to group
        let scaleDown = CABasicAnimation(keyPath: keyPath.transformScale)
        scaleDown.fromValue = 3.5
        scaleDown.toValue = 1.0
        
        let rotate = CABasicAnimation(keyPath: keyPath.transformRotation)
        rotate.fromValue = CGFloat.pi / 4
        rotate.toValue = 0.0
        
        let fade = CABasicAnimation(keyPath: keyPath.opacity)
        fade.fromValue = 0.0
        fade.toValue = 1.0
        
        // 3 - Set the group's animations property and add it to the layer you want to animate
        groupAnimation.animations = [scaleDown, rotate, fade]
        loginButton.layer.add(groupAnimation, forKey: nil)
    }

  func animateInfo() {
    // Add text info
    info.frame = CGRect(x: 0.0, y: loginButton.center.y + 30.0,  width: view.frame.size.width, height: 30)
    info.backgroundColor = UIColor.clear
    info.font = UIFont(name: "HelveticaNeue", size: 12.0)
    info.textAlignment = .center
    info.textColor = UIColor.white
    info.text = "Tap on a field and enter username and password"
    view.insertSubview(info, belowSubview: loginButton)
    
    // perfect candidate for an animation group
    /*
    let flyLeft = CABasicAnimation(keyPath: keyPath.positionX)
    flyLeft.fromValue = info.layer.position.x + view.frame.size.width
    flyLeft.toValue = info.layer.position.x
    flyLeft.duration = 10.0
    info.layer.add(flyLeft, forKey: nil)
    
    let fadeLabelIn = CABasicAnimation(keyPath: keyPath.opacity)
    fadeLabelIn.fromValue = 0.0
    fadeLabelIn.toValue = 1.0
    fadeLabelIn.duration = 5.0
    info.layer.add(fadeLabelIn, forKey: nil)
    */
    
    let infoGroup = CAAnimationGroup()
    infoGroup.beginTime = CACurrentMediaTime() + 0.5
    infoGroup.duration = 10.0
    infoGroup.fillMode = .backwards
    infoGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
    
    let flyLeft = CABasicAnimation(keyPath: keyPath.positionX)
    flyLeft.fromValue = info.layer.position.x + view.frame.size.width
    flyLeft.toValue = info.layer.position.x
    
    let fadeLabelIn = CABasicAnimation(keyPath: keyPath.opacity)
    fadeLabelIn.fromValue = 0.0
    fadeLabelIn.toValue = 1.0
    fadeLabelIn.duration = 5.0
    
    infoGroup.animations = [flyLeft, fadeLabelIn]
    // info.layer.add(infoGroup, forKey: nil)
    info.layer.add(infoGroup, forKey: "infoAppear")
  }
    @IBAction func login() {
        // TODO: Animate the background color of loginButton
        let startColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
        let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
        loginButton.layer.backgroundColor = tintColor.cgColor
        
        let tint = CABasicAnimation(keyPath: keyPath.backgroundColor)
        tint.fromValue = startColor.cgColor
        tint.toValue = tintColor.cgColor
        tint.duration = 1.0
        
        loginButton.layer.add(tint, forKey: nil)
        
        delay(seconds: 4) {
            self.loginButton.layer.backgroundColor = startColor.cgColor
            
            tint.fromValue = tintColor.cgColor
            tint.toValue = startColor.cgColor
            self.loginButton.layer.add(tint, forKey: nil)
        }
        
        // challenge
        let fade = CAKeyframeAnimation(keyPath: keyPath.opacity)
        fade.duration = 0
        fade.keyTimes = [0.0, 0.2, 0.8, 1.0]
        fade.values = [1.0, 0.33, 0.33, 1.0]
        loginButton.layer.add(fade, forKey: nil)
        info.layer.add(fade, forKey: nil)
    }
}

//MARK:- CAAnimationDelegate
extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let name = anim.value(forKey: "name") as? String,
            let layer = anim.value(forKey: "layer") as? CALayer else {
                return
        }
        
        if name == "form" {
            let pulse = CABasicAnimation(keyPath: keyPath.transformScale)
            pulse.fromValue = 1.25
            pulse.toValue = 1.0
            pulse.duration = 0.5
            layer.add(pulse, forKey: nil)
        } else if name == "cloud" {
            layer.position.x = -layer.bounds.width / 2
            delay(seconds: 0.4) {
                self.animateCloud(layer: layer)
            }
        }
    }
}

//MARK:- UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(info.layer.animationKeys() ?? "No animations currently running")
        info.layer.removeAnimation(forKey: "infoAppear")
        
        // challenge
        textField.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        textField.layer.shadowOffset = CGSize(width: 5, height: 7)
        textField.layer.masksToBounds = false
        
        textField.layer.shadowOpacity = 1.0
        
        let fadeIn = CABasicAnimation(keyPath: keyPath.shadowOpacity)
        fadeIn.fromValue = 0
        fadeIn.toValue = 1.0
        fadeIn.duration = 1.0
        textField.layer.add(fadeIn, forKey: nil)
        
        let shadowBounce = CASpringAnimation(keyPath: keyPath.shadowOffset)
        shadowBounce.fromValue = CGSize.zero
        shadowBounce.toValue = CGSize(width: 5, height: 7)
        shadowBounce.damping = 6.0
        shadowBounce.duration = shadowBounce.settlingDuration
        textField.layer.add(shadowBounce, forKey: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.shadowOpacity = 0.0
    }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let nextField = (textField === username) ? password : username
    nextField?.becomeFirstResponder()
    return true
  }
}

//MARK:- A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

//MARK:- Animation keyPaths
enum keyPath {
  static let backgroundColor = "backgroundColor"
  static let opacity = "opacity"
  static let position = "position"
  static let positionX = "position.x"
  static let positionY = "position.y"
  static let shadowOffset = "shadowOffset"
  static let shadowOpacity = "shadowOpacity"
  static let transformRotation = "transform.rotation"
  static let transformScale = "transform.scale"
}

