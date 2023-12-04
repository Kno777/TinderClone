//
//  ChatLogController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 04.12.23.
//

import LBTATools
import Firebase

struct Message {
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    let isFromCurrentLoggedUser: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.isFromCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
        
    }
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
    
    // input accessory view
    
    class CustomInputAccessoryView: UIView {
        
        let textView = UITextView()
        let sendButton = UIButton(title: "SEND", titleColor: .black, font: .boldSystemFont(ofSize: 14))
        let placeHolderLabel = UILabel(text: "Enter Message", font: .systemFont(ofSize: 16), textColor: .lightGray)
        
        override var intrinsicContentSize: CGSize {
            return .zero
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .white
            
            setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
            
            autoresizingMask = .flexibleHeight
            
            
            //textView.text = ""
            textView.isScrollEnabled = false
            textView.font = .systemFont(ofSize: 16)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
            
            hstack(textView,
                           sendButton.withSize(.init(width: 60, height: 60)),
                           alignment: .center
            ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
            
            addSubview(placeHolderLabel)
            placeHolderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 0))
            placeHolderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        }
        
        @objc fileprivate func handleTextChange() {
            self.placeHolderLabel.isHidden = self.textView.text.count != 0
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    lazy var customInputView: CustomInputAccessoryView = {
        let civ = CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return civ
    }()
    
    @objc fileprivate func handleSendButton() {
        print(customInputView.textView.text ?? "")
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let collection = Firestore.firestore()
            .collection("matches_messages")
            .document(currentUserId)
            .collection(match.uid)
        
        
        let messageData = ["text": customInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestemp": Timestamp(date: Date())] as [String: Any]
        
        collection.addDocument(data: messageData) { err in
            if let err = err {
                print("Failed to save message: ", err)
                return
            }
            
            print("Successfully saved msg into FireStore")
            self.customInputView.textView.text = nil
            self.customInputView.placeHolderLabel.isHidden = false
        }
        
        let toCollection = Firestore.firestore()
            .collection("matches_messages")
            .document(match.uid)
            .collection(currentUserId)
        
        toCollection.addDocument(data: messageData) { err in
            if let err = err {
                print("Failed to save message: ", err)
                return
            }
            
            print("Successfully saved msg into FireStore")
            self.customInputView.textView.text = nil
            self.customInputView.placeHolderLabel.isHidden = false
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactiveWithAccessory
        
        fetchMessages()
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    fileprivate func fetchMessages() {
        print("Fetching user msg...")
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore()
            .collection("matches_messages")
            .document(currentUserId)
            .collection(match.uid).order(by: "timestemp")
        
        query.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Failed to get user msg...", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.items.append(.init(dictionary: data))
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
        
        
    }
    
    fileprivate func setupUI() {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
