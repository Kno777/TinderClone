//
//  MatchView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 22.11.23.
//

import UIKit

class MatchView: UIView {
    
    private let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var currentUserImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "jane1"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 140 / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()
    
    private lazy var cardUserImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "jane3"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 140 / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //backgroundColor = .red
        
        setupBlurView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayout() {
        addSubview(currentUserImageView)
        
        addSubview(cardUserImageView)
        
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: 140, height: 140))
        currentUserImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: 140, height: 140))
        cardUserImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func setupBlurView() {
        addSubview(visualEffect)
        
        visualEffect.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDissmisTap)))
        
        visualEffect.fillSuperview()
        visualEffect.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            
            self.visualEffect.alpha = 1
        }
    }
    
    @objc fileprivate func handleDissmisTap() {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
        
        
    }
}


#Preview("MatchView") {
    MatchView()
}
