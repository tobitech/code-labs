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


import UIKit

//MARK: UIGestureRecognizer
final class PanGestureRecognizer: UIPanGestureRecognizer, GestureRecognizer {
    fileprivate var lastYPositionInView: CGFloat?
    
    var selection: Selection = .color(UnitCube.whiteColor)
    
    var selectionTouchRadiusCrossover = CGFloat()
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
    }
}

extension PanGestureRecognizer {
    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent
        ) {
        setSelection(touches: touches)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        lastYPositionInView = nil
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        lastYPositionInView = nil
        super.touchesCancelled(touches, with: event)
    }
}

extension PanGestureRecognizer {
    
    func handleLargeRadiusTouch(yPositionInView: CGFloat) {
        defer {
            lastYPositionInView = yPositionInView
        }
        
        guard let lastYPositionInView = lastYPositionInView else { return }
        selection = .valueDelta(
            Float(yPositionInView - lastYPositionInView)
        )
    }
}
