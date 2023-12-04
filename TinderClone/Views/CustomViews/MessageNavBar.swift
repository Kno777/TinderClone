//
//  MessageNavBar.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 04.12.23.
//

import LBTATools

class MessageNavBar: UIView {
    
    private let userProfileImageView = CircularImageView(width: 44, image: UIImage(named: "jane1"))
    private let nameLabel = UILabel(text: "Username", font: .systemFont(ofSize: 16))
    let backButton = UIButton(image: UIImage(named: "back")!, tintColor: .orange)
    let flagButton = UIButton(image: UIImage(named: "flag")!, tintColor: .orange)
    
    private let match: Match
    
    init(match: Match) {
        self.match = match
        
        self.nameLabel.text = match.name
        self.userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        let middleStack = hstack(
            stack(userProfileImageView, nameLabel, spacing: 8, alignment: .center),
            alignment: .center
        )
        
        hstack(
            backButton,
            middleStack,
            flagButton
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
