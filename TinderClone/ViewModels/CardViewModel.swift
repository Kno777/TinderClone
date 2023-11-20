//
//  CardViewModel.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel: ProducesCardViewModel {
    
    func toCardViewModel() -> CardViewModel {
        return self
    }
    
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex: Int = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
            //let image = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    // Reactive Programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousePhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}
