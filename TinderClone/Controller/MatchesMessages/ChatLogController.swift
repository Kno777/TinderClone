//
//  ChatLogController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 04.12.23.
//

import LBTATools

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

class MessageCell: LBTAListCell<Message> {
    
    let textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    let bubbleContainer = UIView(backgroundColor: .lightGray.withAlphaComponent(0.5))
    
    var anchoredConstraints: AnchoredConstraints!
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            
            if item.isFromCurrentLoggedUser {
                
                // right eadg
                anchoredConstraints.trailing?.isActive = true
                anchoredConstraints.leading?.isActive = false
        
                bubbleContainer.backgroundColor = .systemBlue
                textView.textColor = .white
                
            } else {
                
                anchoredConstraints.trailing?.isActive = false
                anchoredConstraints.leading?.isActive = true
                
                bubbleContainer.backgroundColor = .lightGray.withAlphaComponent(0.5)
                textView.textColor = .black
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        
        bubbleContainer.layer.cornerRadius = 12
        
        self.anchoredConstraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.trailing?.constant = -20
        
        
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
}


class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    private lazy var customNavBar = MessageNavBar(match: match)
    
    private let navBarHeight: CGFloat = 120
    
    private let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        
        items = [
            .init(text: "Hello baby,Hello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello baby", isFromCurrentLoggedUser: true),
            .init(text: "Hello baby", isFromCurrentLoggedUser: false),
            .init(text: "Hello baby", isFromCurrentLoggedUser: true),
            .init(text: "Hello baby,Hello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello babyHello baby", isFromCurrentLoggedUser: false),
        ]
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight + 20
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
    
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // estimated sizing
        let estimatedizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        
        estimatedizeCell.item = self.items[indexPath.row]
        
        estimatedizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    @objc fileprivate func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
