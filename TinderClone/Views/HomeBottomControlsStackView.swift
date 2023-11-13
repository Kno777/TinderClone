//
//  HomeBottomControlsStackView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually

        heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        
        let subviews = [UIImage(named: "refresh_circle"),UIImage(named: "dismiss_circle"),UIImage(named: "super_like_circle"),UIImage(named: "like_circle"),UIImage(named: "boost_circle")].map { image in
            
            let button = UIButton(type: .system)
            button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            return button
        }
        
        subviews.forEach { view in
            addArrangedSubview(view)
        }
        
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
