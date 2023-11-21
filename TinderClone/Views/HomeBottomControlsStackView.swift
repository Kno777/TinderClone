//
//  HomeBottomControlsStackView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
    
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let refreshButton = createButton(image: UIImage(named: "refresh_circle") ?? UIImage())
    let dislikeButton = createButton(image: UIImage(named: "dismiss_circle") ?? UIImage())
    let superLikeButton = createButton(image: UIImage(named: "super_like_circle") ?? UIImage())
    let likeButton = createButton(image: UIImage(named: "like_circle") ?? UIImage())
    let specialButton = createButton(image: UIImage(named: "boost_circle") ?? UIImage())

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually

        heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        _ = [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].map { button in
            self.addArrangedSubview(button)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
