//
//  ViewController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeViewController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var lastFetchedUser: User?
    
    var cardViewModels = [CardViewModel]() // empty array

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefreshBUtton), for: .touchUpInside)
        
        setupLayout()
        setupFirestoreUserCards()
        fetchUsersFromFirestore()
    }
    
    @objc private func handleSettings() {
        let settingsController = SettingsController()
        let navControler = UINavigationController(rootViewController: settingsController)
        navControler.modalPresentationStyle = .fullScreen
        self.present(navControler, animated: true)
    }

    // MARK: - Fileprivate functions
    @objc fileprivate func handleRefreshBUtton() {
        self.fetchUsersFromFirestore()
    }
    
    fileprivate func fetchUsersFromFirestore() {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: self.view)
        
        // i will introduce pagination here to page through 2 users at a time
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
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
                self?.setupCardFromUser(user: user)
            })
            //self.setupFirestoreUserCards()
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView(frame: .zero)
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

