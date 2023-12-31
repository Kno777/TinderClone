//
//  CardView.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit
import SDWebImage

protocol CardViewDelegate: AnyObject {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    
    weak var delegate: CardViewDelegate?
    
    var nextCardView: CardView?
    
    var cardViewModel: CardViewModel? {
        didSet {
            guard let cardViewModel = cardViewModel else { return }
            
            let imageName = cardViewModel.imageUrls.first ?? ""
            // load our image using some kind of url instead
            
            if let url = URL(string: imageName) {
                imageView.sd_setImage(with: url)
            }
            
            
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageUrls.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
        }
    }
    
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    fileprivate let informationLabel = UILabel()
    fileprivate let barsStackView = UIStackView()
    let barDeselectedColor: UIColor = UIColor(white: 0, alpha: 0.1)
    //var imageIndex: Int = 0
    
    // Configurations
    fileprivate let threshold: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        print("tap to photo")
        
        guard let cardViewModel = self.cardViewModel else { return }
        
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousePhoto()
        }
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ subview in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture: gesture)
        default:
            ()
        }
    }
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel?.imageIndexObserver = { [weak self] idx, imageUrl in
            print("Changing photo from view model")
            
            if let url = URL(string: imageUrl ?? "") {
                self?.imageView.sd_setImage(with: url)
            }
            
            self?.barsStackView.arrangedSubviews.forEach { v in
                v.backgroundColor = self?.barDeselectedColor
            }
            
            self?.barsStackView.arrangedSubviews[idx].backgroundColor = UIColor.white
        }
    }
    
    lazy var moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(systemName: "info")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
        button.layer.cornerRadius = 44 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleMoreInfoButton), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleMoreInfoButton() {
        print("handleMoreInfoButton")
        
        guard let cardViewModel = self.cardViewModel else { return }
        self.delegate?.didTapMoreInfo(cardViewModel: cardViewModel)

    }
    
    fileprivate func setupLayout() {
        // custom drawing code
        layer.cornerRadius = 10
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupBarsStackView()
        
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        informationLabel.text = "TEST nAME TESSSSS"
        informationLabel.font = .boldSystemFont(ofSize: 34)
        informationLabel.numberOfLines = 0
        informationLabel.textColor = .white
        
        addSubview(moreInfoButton)
        
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        // some dummy bars for now
        
    }
    
    fileprivate func setupGradientLayer() {
        // how we can draw a gradient with Swift
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        // in here you know what you CardView frame will be
        gradientLayer.frame = self.frame
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        // rotation
        // some not that scary math here to convert radians to degrees
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        
        // hack solution
        
        if shouldDismissCard {
            guard let homeController = self.delegate as? HomeViewController else { return }
            
            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
