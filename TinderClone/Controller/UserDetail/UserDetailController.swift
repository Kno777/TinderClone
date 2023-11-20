//
//  UserDetailController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 19.11.23.
//

import UIKit

class UserDetailController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
       let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var imageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImage(named: "jane1")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var infoLabel: UILabel = {
       let label = UILabel()
        label.text = "User name 30\nDoctor\nSome bio text below"
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.fillSuperview()
        
        scrollView.addSubview(imageView)
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDissmis)))
    }
    
    @objc fileprivate func handleTapDissmis(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}

extension UserDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        print(changeY)
        
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width)
    }
}
