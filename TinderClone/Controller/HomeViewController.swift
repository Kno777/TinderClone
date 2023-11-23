//
//  ViewController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit
import Firebase
import JGProgressHUD


class HomeViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var cardViewModels = [CardViewModel]() // empty array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        
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
    
    @objc fileprivate func handleMessage() {
        print("message")
        
        let vc = MatchesMessangesController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
            self?.fetchSwipes()
        }
    }
    
    var swipes: [String: Int] = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("Failed to fetch swipes:", err)
                return
            }
            
            print("Swipes data: ", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else { return }
            
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh() {
        //fetchSwipes()
        self.cardsDeckView.subviews.forEach({ $0.removeFromSuperview() })
        self.fetchUsersFromFirestore()
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
                
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                //let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                
                let hasNotSwipedBefore = true
                
                if isNotCurrentUser && hasNotSwipedBefore {
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
    
    @objc func handleDislike() {
        saveSwipeInformationToFirestore(didLike: 0)
        preformSwipeAnimation(translation: -700, angle: -15)
    }
    
    @objc func handleLike() {
        saveSwipeInformationToFirestore(didLike: 1)
        preformSwipeAnimation(translation: 700, angle: 15)
    }
    
    fileprivate func saveSwipeInformationToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let cardUID = self.topCardView?.cardViewModel?.uid else { return }
        
        if didLike == 1 {
            checkIfMatchExists(cardUID: cardUID)
        }
        
        let docData: [String: Any] = [
            cardUID: didLike,
        ]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(docData) { err in
                    if let err = err {
                        print("Failed to update swipe info:", err)
                        return
                    }
                    
                    print("Successfully updated swiping information...")
                    
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(docData) { err in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    print("Successfully save swiping information...")
                    
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        print("Detecting match: ", cardUID)
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { snapshot, err in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has Matched")
                
                self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
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

