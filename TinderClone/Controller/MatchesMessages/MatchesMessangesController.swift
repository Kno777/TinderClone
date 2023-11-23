//
//  MatchesMessangesController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 23.11.23.
//

import LBTATools

class MatchesMessangesController: UICollectionViewController {
    
    lazy var customNavBar: UIView = {
        let navBar = UIView(backgroundColor: .white)
        
        let imageView = UIImageView(image: UIImage(named: "top_messages_icon")!.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        imageView.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        let messageLabel = UILabel(text: "Message", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        
        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        navBar.stack(imageView.withHeight(44), navBar.hstack(messageLabel, feedLabel, distribution: .fillEqually)).padTop(10)
        
        return navBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        
        collectionView.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: .init(width: 0, height: 150))
    }
}
