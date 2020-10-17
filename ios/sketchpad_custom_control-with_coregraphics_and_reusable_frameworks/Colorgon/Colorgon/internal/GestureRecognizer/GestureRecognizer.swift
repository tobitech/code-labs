/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit.UIGestureRecognizerSubclass
import simd

protocol GestureRecognizer: class {
    var selection: Selection { get set }
    var selectionTouchRadiusCrossover: CGFloat { get set }
    
    func handleLargeRadiusTouch(yPositionInView: CGFloat)
}

extension GestureRecognizer where Self: UIGestureRecognizer {
    func setSelection(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let positionInView = touch.location(in: view)
        if touch.majorRadius < selectionTouchRadiusCrossover {
            selection = .color(
                UnitCube.getColor(
                    positionInView: positionInView, viewSize: view!.bounds.size
                )
            )
        } else {
            handleLargeRadiusTouch(yPositionInView: positionInView.y)
        }
    }
}

//MARK:
enum Selection {
    case color(SIMD3<Float>)
    case valueDelta(Float)
}
