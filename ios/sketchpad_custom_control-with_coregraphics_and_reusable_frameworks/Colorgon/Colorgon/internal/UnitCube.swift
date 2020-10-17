//
//  UnitCube.swift
//  Colorgon
//
//  Created by Oluwatobi Omotayo on 31/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import QuartzCore
import simd

enum UnitCube {
    
    static let whiteColor = SIMD3<Float>(repeating: 1)
    
    static func getColor(
        positionInView: CGPoint,
        viewSize: CGSize
        ) -> SIMD3<Float> {
        let
            yFlippedPositionInView = SIMD2<Float>(
            Float(positionInView.x),
            Float(viewSize.height - positionInView.y)
            ),
            normalizedPositionInView =
            yFlippedPositionInView
            / SIMD2<Float>( Float(viewSize.width), Float(viewSize.height) ),
        position = 2 * normalizedPositionInView - SIMD2<Float>(repeating: 1)
        
        if let redFacePosition = faces.red[position] {
            return [1, redFacePosition.y, redFacePosition.x]
        }
        else if let greenFacePosition = faces.green[position] {
            return [greenFacePosition.x, 1, greenFacePosition.y]
        }
        else if let blueFacePosition = faces.blue[position] {
            return [blueFacePosition.x, blueFacePosition.y, 1]
        }
        else {
            // If something unexpected goes wrong…
            return UnitCube.whiteColor
        }
    }

    //MARK: private
  private static let faces: (
    red: Face,
    green: Face,
    blue: Face
  ) = {
    let
      edgeRadians: Float = .pi / 6,
      cyanVertexPosition: SIMD2<Float> = [cos(edgeRadians), sin(edgeRadians)],
      rightVertexXInverse = 1 / cyanVertexPosition.x
    
    return (
      red: Face(
        origin: -cyanVertexPosition,
        basisInverse: float2x2([
          [rightVertexXInverse, cyanVertexPosition.y * rightVertexXInverse],
          [0, 1]
        ])
      ),
      green: Face(
        origin: [0, 1],
        basisInverse: {
          let xContribution = rightVertexXInverse * cyanVertexPosition.y
          return float2x2([
            [-xContribution, xContribution],
            [-1, -1]
          ])
        }()
      ),
      blue: Face(
        origin: [cyanVertexPosition.x, -cyanVertexPosition.y],
        basisInverse: float2x2([
          [-rightVertexXInverse, cyanVertexPosition.y * -rightVertexXInverse],
          [0, 1]
        ])
      )
    )
  }()
}

//MARK:-
private struct Face {
  let origin: SIMD2<Float>
  let basisInverse: float2x2
}

extension Face {
    subscript(position: SIMD2<Float>) -> SIMD2<Float>? {
        let position = basisInverse * (position - origin)
        guard max(position.x, position.y) <= 1  else { return nil }
        
        return position
    }
}
