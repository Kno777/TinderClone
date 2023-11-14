//
//  User.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import Foundation
import UIKit

struct User: ProducesCardViewModel {
    
    // defining our properties for our model layer
    let name: String
    let age: Int
    let profession: String
    let imageNames: [String]
    
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32)])
        
        attributedText.append(NSAttributedString(string: " \(age)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        attributedText.append(NSAttributedString(string: "\n\(profession)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        
        return CardViewModel(imageNames: imageNames, attributedString: attributedText, textAlignment: .left)
    }
}


