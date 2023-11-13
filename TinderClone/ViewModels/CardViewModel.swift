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

struct CardViewModel: ProducesCardViewModel {
    
    func toCardViewModel() -> CardViewModel {
        return self
    }
    
    let imageName: String
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
}
