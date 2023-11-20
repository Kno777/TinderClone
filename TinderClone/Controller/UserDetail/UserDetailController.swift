//
//  UserDetailController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 19.11.23.
//

import UIKit
import SDWebImage

class UserDetailController: UIViewController {
    
    var cardViewModel: CardViewModel? {
        didSet {
            guard let cardViewModel = cardViewModel else { return }
            infoLabel.attributedText = cardViewModel.attributedString
            
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.delegate = self
        return scroll
    }()
    
    private let swipingPhotosController = SwipingPhotosVController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    

    let extraSwipingHeight: CGFloat = 80
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name 30\nDoctor\nSome bio text below"
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dissmisButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss_down_arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDissmisButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var dislikeButton = self.createButton(image: UIImage(named: "dismiss_circle")!, selector: #selector(handleDislikeButton))
    
    private lazy var superLikeButton = self.createButton(image: UIImage(named: "super_like_circle")!, selector: #selector(handleSuperLikeButton))
    
    private lazy var likeButton = self.createButton(image: UIImage(named: "like_circle")!, selector: #selector(handleLikeButton))
    
    // 3 buttom controls buttons
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.contentMode = .scaleAspectFill
        return button
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
    }
    
    @objc fileprivate func handleDislikeButton() {
        print("handleDislikeButton")
    }
    
    @objc fileprivate func handleSuperLikeButton() {
        print("handleSuperLikeButton")
    }
    
    @objc fileprivate func handleLikeButton() {
        print("handleLikeButton")
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        
        view.addSubview(visualEffect)
        visualEffect.anchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.fillSuperview()
        
        let swipingView = swipingPhotosController.view!
        
        scrollView.addSubview(swipingView)
        
       
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDissmis)))
        
        scrollView.addSubview(dissmisButton)
        dissmisButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 16), size: .init(width: 50, height: 50))
    }
    
    @objc fileprivate func handleTapDissmis(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleDissmisButton() {
        self.dismiss(animated: true)
    }
}

extension UserDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        print(changeY)
        
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width + extraSwipingHeight)
    }
}
