//
//  ViewController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 13.11.23.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomControlsStackView()
    
//    let cardViewModels: [CardViewModel] = {
//        let producers = [
//            User(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1", "kelly2", "kelly3"]).toCardViewModel(),
//            User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]).toCardViewModel(),
//            Advertiser(title: "Knoyi Mot", brandName: "Hamov Tnak", posterPhotoName: "panda").toCardViewModel(),
//        ] as [ProducesCardViewModel]
//        
//        let viewModels = producers.map ({ return $0.toCardViewModel() })
//        return viewModels
//    }()
    
    var cardViewModels = [CardViewModel]() // empty array

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        
        setupLayout()
        setupDummyCards()
        fetchUsersFromFirestore()
    }
    
    @objc private func handleSettings() {
        let registrationController = RegistrationController()
        self.present(registrationController, animated: true)
    }

    // MARK: - Fileprivate functions
    fileprivate func fetchUsersFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { snapshot, err in
            if let err = err {
                print("Failed to fetch users:", err)
                return
            }
            
            snapshot?.documents.forEach({ [weak self] docSnapshot in
                let userDictionary = docSnapshot.data()
                let user = User(dictionary: userDictionary)
                self?.cardViewModels.append(user.toCardViewModel())
            })
            self.setupDummyCards()
        }
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        // this enables auto layout for us
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupDummyCards() {
        
        cardViewModels.forEach { cardVM in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
}

