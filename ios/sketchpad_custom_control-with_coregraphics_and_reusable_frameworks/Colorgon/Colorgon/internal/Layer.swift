//
//  Layer.swift
//  Colorgon
//
//  Created by Oluwatobi Omotayo on 31/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import QuartzCore
import CoreImage

final class Layer: CALayer {
    
    var value: Float = 1 {
        didSet {
            value = min(max(0, value), 1)
            setNeedsDisplay()
        }
    }
    
    //MARK: fileprivate
    fileprivate let ciContext = CIContext()
    
    fileprivate let kernel = CIColorKernel(source:
    "kernel vec4 makeColorgon(float width, float height, float value) {" +
      "vec2 position = destCoord() / vec2(width, height);" +
      "position.y = 1. - position.y;" +
      "position = 2. * position - 1.;" +
      
      "vec2 cyanVertexPosition = vec2(.8660254038, .5);" +
      "float rightVertexXInverse = 1. / cyanVertexPosition.x;" +
      "vec2 maskSteps;" +
      "float mask;" +

      "vec2 redFaceOrigin = -cyanVertexPosition;" +
      "vec2 redToWhitePosition = mat2(" +
        "vec2(rightVertexXInverse, cyanVertexPosition.y * rightVertexXInverse)," +
        "vec2(0, 1)" +
      ") * (position - redFaceOrigin);" +
      "maskSteps = step(0., 1. - redToWhitePosition);" +
      "mask = min(maskSteps.x, maskSteps.y);" +
      "vec3 redFaceColor = vec3(mask, redToWhitePosition.yx * mask);" +
      
      "vec2 greenFaceOrigin = vec2(0, 1);" +
      "float xContribution = rightVertexXInverse * cyanVertexPosition.y;" +
      "vec2 greenToWhitePosition = mat2(" +
        "vec2(-xContribution, xContribution)," +
        "vec2(-1, -1)" +
      ") * (position - greenFaceOrigin);" +
      "maskSteps = step(0., 1. - greenToWhitePosition);" +
      "mask = min(maskSteps.x, maskSteps.y);" +
      "vec3 greenFaceColor = vec3(greenToWhitePosition.x, mask, greenToWhitePosition.y);" +
      "greenFaceColor.rb *= mask;" +
      
      "vec2 blueFaceOrigin = vec2(cyanVertexPosition.x, -cyanVertexPosition.y);" +
      "vec2 blueToWhitePosition = mat2(" +
        "vec2(-rightVertexXInverse, cyanVertexPosition.y * -rightVertexXInverse)," +
        "vec2(0, 1)" +
      ") * (position - blueFaceOrigin);" +
      "maskSteps = step(0., 1. - blueToWhitePosition);" +
      "mask = min(maskSteps.x, maskSteps.y);" +
      "vec3 blueFaceColor = vec3(blueToWhitePosition * mask, mask);" +
      
      "vec3 fullValueColor = redFaceColor + greenFaceColor + blueFaceColor;" +
      "return vec4(fullValueColor * value, 1);" +
    "}"
  )!
  

    //MARK: init
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
  
    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }
}

extension Layer {
    override func draw(in ctx: CGContext) {
        // the default implementation of this method doesn't do anything,
        // so you don't need to bother to call super.
        guard let ciImage = kernel.apply(
                extent: CGRect(origin: .zero, size: bounds.size),
                arguments: [bounds.width, bounds.height, value]
            ),
            let cgImage = ciContext.createCGImage(
                ciImage,
                from: bounds
            )
            else { return }
        
        mask = {
            let mask = CAShapeLayer()
            let path = CGMutablePath()
            path.addLines(
                between: stride(
                    from: CGFloat.pi/6,
                    to: 2 * .pi,
                    by: .pi/3
                ).map { angle in
                    CGPoint(x: cos(angle), y: sin(angle))
                },
                transform: CGAffineTransform(
                    scaleX: bounds.width/2,
                    y: bounds.height/2
                ).translatedBy(
                    x: 1,
                    y: 1
                )
            )
            path.closeSubpath()
            mask.path = path
            return mask
        }()
        
        ctx.draw(cgImage, in: bounds)
    }
}
