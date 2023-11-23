//
//  MatchView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 22.11.23.
//

import UIKit
import Firebase

class MatchView: UIView {
    
    var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            guard let url = URL(string: user.imageUrl1 ?? "") else { return }
            self.currentUserImageView.alpha = 1
            self.currentUserImageView.sd_setImage(with: url)
        }
    }
    
    var cardUID: String? {
        didSet {
            guard let cardUID = cardUID else { return }
            
            Firestore.firestore().collection("users").document(cardUID).getDocument { snapshot, err in
                if let err = err {
                    print("Failed to fetch user:", err)
                    return
                }
                
                guard let dictionary = snapshot?.data() else { return }
                
                let user = User(dictionary: dictionary)
                
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                self.cardUserImageView.alpha = 1
                self.cardUserImageView.sd_setImage(with: url)
                self.setupAnimations()
            }
        }
    }
    
    private let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var currentUserImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "jane1"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 140 / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var cardUserImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "jane3"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 140 / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var itsAMatchImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "itsamatch"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var descLabel: UILabel = {
       let label = UILabel()
        label.text = "Es inch kextot batedzda...."
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var sendMessageButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.backgroundColor = .yellow
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var keepSwipingButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("KEEP SWIPING", for: .normal)
        button.backgroundColor = .yellow
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //backgroundColor = .red
        
        setupBlurView()
        setupLayout()
        //setupAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupAnimations() {
            // starting positions
            let angle = 30 * CGFloat.pi / 180
            
            currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
            
            cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
            
            sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
            keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
            
            // keyframe animations for segmented animation
            
            UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
                
                // animation 1 - translation back to original position
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                    self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                    self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
                })
                
                // animation 2 - rotation
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                    self.currentUserImageView.transform = .identity
                    self.cardUserImageView.transform = .identity
                })
                
                
            }) { (_) in
                
            }
            
            UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.sendMessageButton.transform = .identity
                self.keepSwipingButton.transform = .identity
            })
        }
    
    fileprivate func setupLayout() {
        
        addSubview(keepSwipingButton)
        
        addSubview(sendMessageButton)
        
        addSubview(itsAMatchImageView)
        
        addSubview(descLabel)
        
        addSubview(currentUserImageView)
        
        addSubview(cardUserImageView)
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        descLabel.anchor(top: nil, leading: leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
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
