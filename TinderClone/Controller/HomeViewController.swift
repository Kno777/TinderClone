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
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailController = UserDetailController()
        userDetailController.cardViewModel = cardViewModel
        userDetailController.modalPresentationStyle = .fullScreen
        present(userDetailController, animated: true)
    }
    
    func didFinishLoggingIn() {
        self.fetchCurrentUser()
    }
    
    
    func didSaveSettings() {
        self.fetchCurrentUser()
    }
    
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var lastFetchedUser: User?
    
    private var user: User?
    
    var cardViewModels = [CardViewModel]() // empty array
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefreshBUtton), for: .touchUpInside)
        
        setupLayout()
        
        fetchCurrentUser()
        
        //setupFirestoreUserCards()
        //fetchUsersFromFirestore()
    }
    
    @objc private func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navControler = UINavigationController(rootViewController: settingsController)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }

    // MARK: - Fileprivate functions
    
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
    
    @objc fileprivate func handleRefreshBUtton() {
        self.fetchUsersFromFirestore()
    }
    
    fileprivate func fetchUsersFromFirestore() {
        
        //guard let minAge = self.user?.minSeekingAge, let maxAge = self.user?.maxSeekingAge else { return }
        
        let minAge = self.user?.minSeekingAge ?? 18
        let maxAge = self.user?.maxSeekingAge  ?? 99
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: self.view)
        
        // i will introduce pagination here to page through 2 users at a time
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { snapshot, err in
            hud.dismiss()
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            
            snapshot?.documents.forEach({ [weak self] docSnapshot in
                let userDictionary = docSnapshot.data()
                let user = User(dictionary: userDictionary)
                self?.cardViewModels.append(user.toCardViewModel())
                self?.lastFetchedUser = user
                
                if user.uid != Auth.auth().currentUser?.uid {
                    self?.setupCardFromUser(user: user)
                }
            })
            //self.setupFirestoreUserCards()
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardView.fillSuperview()
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        // this enables auto layout for us
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupFirestoreUserCards() {
        
        cardViewModels.forEach { cardVM in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
}

