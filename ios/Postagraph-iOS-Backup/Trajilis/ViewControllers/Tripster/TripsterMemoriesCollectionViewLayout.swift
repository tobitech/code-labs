//
//  TripsterMemories.swift
//  Trajilis
//
//  Created by bibek timalsina on 7/16/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripsterMemoriesCollectionViewLayout: UICollectionViewLayout {
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var cellSpacing: CGFloat = 15
    private var lineSpacing: CGFloat = 15
    private var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    private var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {return 0}
        return collectionView.bounds.width - sectionInset.left - sectionInset.right
    }
    
    private let heightWidthRatios: [CGFloat] = [200/171, 200/149, 200/335, 200/144, 200/176, 200/335]
    private let widthRatios: [CGFloat] = [171/335, 149/335, 1, 144/335, 176/335, 1]
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        
        guard cache.isEmpty == true,
            let collectionView = collectionView else {
                return
        }
        
        var xOffset: CGFloat = sectionInset.left
        var yOffset: CGFloat = sectionInset.top
        let yOffsetChanger = [1,2,4,5]
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let cellCount = item.quotientAndRemainder(dividingBy: 6).remainder
            let widthRatio = widthRatios[cellCount]
            let heightRatio = heightWidthRatios[cellCount]
            
            let viewWidth = widthRatio*contentWidth
            let viewHeight = viewWidth*heightRatio
            
            let frame = CGRect(x: xOffset, y: yOffset, width: viewWidth, height: viewHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            contentHeight = frame.maxY
            if yOffsetChanger.contains(cellCount) {
                yOffset = frame.maxY + cellSpacing
                xOffset = sectionInset.left
            }else {
                xOffset = frame.maxX + cellSpacing
            }
        }
        contentHeight += sectionInset.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.item(at: indexPath.item)
    }
}
