//
//  MatchesNavBar.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 23.11.23.
//

import LBTATools

class MatchesNavBar: UIView {
    
    let backButton = UIButton(image: UIImage(named: "app_icon")!, tintColor: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "top_messages_icon")!.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        imageView.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        let messageLabel = UILabel(text: "Message", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        
        self.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        self.stack(imageView.withHeight(44), self.hstack(messageLabel, feedLabel, distribution: .fillEqually)).padTop(10)
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
