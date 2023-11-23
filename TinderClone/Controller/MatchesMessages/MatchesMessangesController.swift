//
//  MatchesMessangesController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 23.11.23.
//

import LBTATools
import Firebase

struct Match {
    let name: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView = UIImageView(image: UIImage(named: "jane1"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "Username here", font: .systemFont(ofSize: 14, weight: .semibold), textColor: .darkGray, textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        stack(stack(profileImageView, alignment: .center), usernameLabel)
    }
}

class MatchesMessangesController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
    
    let customNavBar = MatchesNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        items = [
//            .init(name: "Test", profileImageUrl: "1"),
//            .init(name: "Test 2", profileImageUrl: "2"),
//            .init(name: "Test 3", profileImageUrl: "3"),
//        ]
        
        self.collectionView.contentInset.top = 150
        self.collectionView.backgroundColor = .white
                
        setupCustomNavBarView()
        setupFetchMatches()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupFetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { snapshot, err in
            
            if let err = err {
                print("Failed to fetch matches:", err)
                return
            }
            
            var matches = [Match]()
            snapshot?.documents.forEach({ snpashot in
                
                let dictionary = snpashot.data()
                matches.append(.init(dictionary: dictionary))
            })
            
            self.items = matches
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func setupCustomNavBarView() {
        collectionView.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: .init(width: 0, height: 150))
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
}
