/// Copyright (c) 2017 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class MainViewController: UIViewController {
  
  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var salesCountLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // likeButton.setTitle(NSLocalizedString("You like?", comment: "You like the result?"), for: .normal)
    imageView.image = UIImage(named: NSLocalizedString("imageName", comment: "name of the image file"))
  }
  
  @IBAction func likeButtonPressed() {
    guard salesCountLabel.isHidden else { return }
    
    let period = getMonthCount()
    
    let formatString = NSLocalizedString("You have sold 1000 apps in %d months", comment: "Time to sell 1000 apps")
    // salesCountLabel.text = String.localizedStringWithFormat(formatString, period)
    let quantity = NumberFormatter.localizedString(from: 1000, number: .decimal)
    salesCountLabel.text = String.localizedStringWithFormat(formatString, quantity, period)
    
    salesCountLabel.isHidden = false
    
    imageView.isHidden = false
    
    salesCountLabel.alpha = 0
    imageView.alpha = 0
    
    likeButton.isEnabled = false
    
    UIView.animate(withDuration: 1, animations: {
      self.salesCountLabel.alpha = 1
      self.imageView.alpha = 1
    }) { finished in
      if finished {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.salesCountLabel.isHidden = true
          self.imageView.isHidden = true
          self.likeButton.isEnabled = true
        }
      }
    }
  }
  
  private func getMonthCount() -> Int {
    let choices = [1, 2, 5]
    let index = Int(arc4random_uniform(UInt32(choices.count)))
    return choices[index]
  }
}
