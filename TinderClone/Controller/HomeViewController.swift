////
////  ViewController.swift
////  TinderClone
////
////  Created by Kno Harutyunyan on 13.11.23.
////
//
//import UIKit
//import Firebase
//import JGProgressHUD
//
//class HomeViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
//    
//    func didTapMoreInfo(cardViewModel: CardViewModel) {
//        let userDetailController = UserDetailController()
//        userDetailController.cardViewModel = cardViewModel
//        userDetailController.modalPresentationStyle = .fullScreen
//        present(userDetailController, animated: true)
//    }
//    
//    func didFinishLoggingIn() {
//        self.fetchCurrentUser()
//    }
//    
//    
//    func didSaveSettings() {
//        self.fetchCurrentUser()
//    }
//    
//    
//    let topStackView = TopNavigationStackView()
//    let cardsDeckView = UIView()
//    let bottomControls = HomeBottomControlsStackView()
//    
//    var lastFetchedUser: User?
//    var topCardView: CardView?
//    
//    private var user: User?
//    
//    var cardViewModels = [CardViewModel]() // empty array
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if Auth.auth().currentUser == nil {
//            let loginController = LoginController()
//            loginController.delegate = self
//            let navController = UINavigationController(rootViewController: loginController)
//            navController.modalPresentationStyle = .fullScreen
//            present(navController, animated: true)
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
//        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefreshBUtton), for: .touchUpInside)
//        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
//        
//        setupLayout()
//        
//        fetchCurrentUser()
//        
//        //setupFirestoreUserCards()
//        //fetchUsersFromFirestore()
//    }
//    
//    @objc private func handleLike() {
//        print("handleLike")
//        self.topCardView?.removeFromSuperview()
//        topCardView = topCardView?.nextCardView
//    }
//    
//    @objc private func handleSettings() {
//        let settingsController = SettingsController()
//        settingsController.delegate = self
//        let navControler = UINavigationController(rootViewController: settingsController)
//        navControler.modalPresentationStyle = .fullScreen
//        self.present(navControler, animated: true)
//    }
//
//    // MARK: - Fileprivate functions
//    
//    fileprivate func fetchCurrentUser() {
//        
//        let hud = JGProgressHUD(style: .dark)
//        hud.textLabel.text = "Loading..."
//        hud.show(in: self.view)
//        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, err in
//            hud.dismiss()
//            if let err = err {
//                print(err)
//                return
//            }
//            
//            // fetched our user here
//            guard let dictionary = snapshot?.data() else { return }
//            let user = User(dictionary: dictionary)
//            self?.user = user
//            self?.fetchUsersFromFirestore()
//        }
//    }
//    
//    @objc fileprivate func handleRefreshBUtton() {
//        self.fetchUsersFromFirestore()
//    }
//    
//    fileprivate func fetchUsersFromFirestore() {
//        
//        //guard let minAge = self.user?.minSeekingAge, let maxAge = self.user?.maxSeekingAge else { return }
//        
//        let minAge = self.user?.minSeekingAge ?? 18
//        let maxAge = self.user?.maxSeekingAge  ?? 99
//        
//        let hud = JGProgressHUD(style: .dark)
//        hud.textLabel.text = "Fetching Users"
//        hud.show(in: self.view)
//        
//        // i will introduce pagination here to page through 2 users at a time
//        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
//        query.getDocuments { snapshot, err in
//            hud.dismiss()
//            if let err = err {
//                print("Failed to fetch users:", err)
//                return
//            }
//            
//            var prevCardView: CardView?
//            
//            snapshot?.documents.forEach({ [weak self] docSnapshot in
//                let userDictionary = docSnapshot.data()
//                let user = User(dictionary: userDictionary)
//                self?.cardViewModels.append(user.toCardViewModel())
//                self?.lastFetchedUser = user
//                
//                if user.uid != Auth.auth().currentUser?.uid {
//                    let cardView = self?.setupCardFromUser(user: user)
//                    
//                    prevCardView?.nextCardView = cardView
//                    prevCardView = cardView
//                    
//                    if self?.topCardView == nil {
//                        self?.topCardView = cardView
//                    }
//                }
//            })
//            //self.setupFirestoreUserCards()
//        }
//    }
//    
//    fileprivate func setupCardFromUser(user: User) -> CardView {
//        let cardView = CardView(frame: .zero)
//        cardView.delegate = self
//        cardView.cardViewModel = user.toCardViewModel()
//        cardsDeckView.addSubview(cardView)
//        cardView.fillSuperview()
//        return cardView
//    }
//    
//    fileprivate func setupLayout() {
//        view.backgroundColor = .white
//        
//        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
//        
//        overallStackView.axis = .vertical
//        
//        view.addSubview(overallStackView)
//        
//        // this enables auto layout for us
//        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
//        
//        overallStackView.isLayoutMarginsRelativeArrangement = true
//        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
//        
//        overallStackView.bringSubviewToFront(cardsDeckView)
//    }
//    
//    fileprivate func setupFirestoreUserCards() {
//        
//        cardViewModels.forEach { cardVM in
//            let cardView = CardView(frame: .zero)
//            cardView.cardViewModel = cardVM
//            cardsDeckView.addSubview(cardView)
//            cardView.fillSuperview()
//        }
//    }
//}
//


//
//  ViewController.swift
//  SwipeMatchFirestoreLBTA
//
//  Created by Brian Voong on 10/31/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var cardViewModels = [CardViewModel]() // empty array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, err in
            hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            self?.user = user
            self?.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUsersFromFirestore()
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        let minAge = user?.minSeekingAge ?? 18
        let maxAge = user?.maxSeekingAge ?? 99
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            self.hud.dismiss()
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            
            // we are going to set up the nextCardView relationship for all cards somehow?
            
            // Linked List
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var topCardView: CardView?
    
    fileprivate func preformSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        
        translationAnimation.fillMode = .forwards
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    @objc fileprivate func handleDislike() {
        preformSwipeAnimation(translation: -700, angle: -15)
    }
    
    @objc fileprivate func handleLike() {
        preformSwipeAnimation(translation: 700, angle: 15)
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print("Home controller:", cardViewModel.attributedString)
        let userDetailsController = UserDetailController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
    }
    
    func didSaveSettings() {
        print("Notified of dismissal from SettingsController in HomeController")
        fetchCurrentUser()
    }

    // MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }

}

