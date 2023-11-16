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
    var name: String?
    var age: Int?
    var profession: String?
    //let imageNames: [String]
    var imageUrl1: String?
    var uid: String?
    var bio: String?
    
    
    init(dictionary: [String: Any]) {
        // we'll initialize our user here
        
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String ?? ""
        self.name = dictionary["fullName"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
    }
    
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32)])
        
        let ageString = age != nil ? "\(age!)" : ""
        
        attributedText.append(NSAttributedString(string: " \(ageString)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        attributedText.append(NSAttributedString(string: "\n\(profession ?? "")", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        
        return CardViewModel(imageNames: [imageUrl1 ?? ""], attributedString: attributedText, textAlignment: .left)
    }
}


