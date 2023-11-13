//
//  ViewController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit

class ViewController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let buttonsStackView = HomeBottomControlsStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        let blueView = UIView()
        blueView.backgroundColor = .blue
        
        
        setupLayout(blueView)
    }

    // MARK: - setupLayout
    fileprivate func setupLayout(_ blueView: UIView) {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, blueView, buttonsStackView])
        
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        // this enables auto layout for us
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
    }
}

