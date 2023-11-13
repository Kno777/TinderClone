//
//  TopNavigationStackView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit

class TopNavigationStackView: UIStackView {
    
    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: UIImage(named: "app_icon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .equalCentering
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        fireImageView.contentMode = .scaleAspectFit
        
        settingsButton.setImage(UIImage(named: "top_left_profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        messageButton.setImage(UIImage(named: "top_right_messages")?.withRenderingMode(.alwaysOriginal), for: .normal)

        
        let topView = [settingsButton, UIView(), fireImageView, UIView(), messageButton].map { view in
            return view
        }
        
        topView.forEach { view in
            addArrangedSubview(view)
        }
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
