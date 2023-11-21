//
//  SettingsController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 16.11.23.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage
import FirebaseStorage

protocol SettingsControllerDelegate: AnyObject {
    func didSaveSettings()
}

class SettingsController: UITableViewController {

    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    var user: User?
    weak var delegate: SettingsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.register(AgeRangeCell.self, forCellReuseIdentifier: "ageCellId")
        tableView.keyboardDismissMode = .interactive
        
        fetchCurrentUser()
    }
    
    fileprivate func fetchCurrentUser() {
        // fetch user from Firestore
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, err in
            if let err = err {
                print(err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            self?.user = user
            
            self?.loadUserPhotos()
            
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos() {
        if let imageUrl = self.user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = self.user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = self.user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { image, _, _, _, _, _ in
                
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        
        //self.user?.imageUrl1 = imageUrl
    }
    
    @objc fileprivate func handleMinAgeChange(slider: UISlider) {
        print(slider.value)
        
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
        
        self.user?.minSeekingAge = Int(slider.value)
    }
    
    @objc fileprivate func handleMaxAgeChange(slider: UISlider) {
        print(slider.value)
        
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
        ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
        
        self.user?.maxSeekingAge = Int(slider.value)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 5 {
            let ageRangeCell = tableView.dequeueReusableCell(withIdentifier: "ageCellId", for: indexPath) as! AgeRangeCell
            
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
            
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? 18)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? 99)"
            
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? 18)
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? 99)
            
            return ageRangeCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! SettingsTableViewCell
            
            switch indexPath.section {
            case 1:
                cell.textField.placeholder = "Enter name"
                cell.textField.text = self.user?.name ?? ""
                cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
                cell.textField.keyboardType = .default
            case 2:
                cell.textField.placeholder = "Enter profession"
                cell.textField.text = self.user?.profession ?? ""
                cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
                cell.textField.keyboardType = .default
            case 3:
                cell.textField.placeholder = "Enter age"
                cell.textField.keyboardType = .phonePad
                if let age = self.user?.age {
                    cell.textField.text = "\(age)"
                }
                cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            default:
                cell.textField.placeholder = "Enter bio"
                cell.textField.text = self.user?.bio
                cell.textField.addTarget(self, action: #selector(handleBioChange), for: .editingChanged)
                cell.textField.keyboardType = .default
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 5 ? 100 : 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = setupHeaderView()
            return header
        }
        
        let headerLabel = HeaderLabel()
        headerLabel.font = .boldSystemFont(ofSize: 16)
        
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "0")
    }
    
    @objc fileprivate func handleBioChange(textField: UITextField) {
        self.user?.bio = textField.text
    }
    
    @objc fileprivate func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Settings"
        hud.show(in: self.view)
        
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": self.user?.name ?? "",
            "imageUrl1": self.user?.imageUrl1 ?? "",
            "imageUrl2": self.user?.imageUrl2 ?? "",
            "imageUrl3": self.user?.imageUrl3 ?? "",
            "age": self.user?.age ?? 0,
            "profession": self.user?.profession ?? "",
            "bio": self.user?.bio ?? "",
            "minSeekingAge": self.user?.minSeekingAge ?? 18,
            "maxSeekingAge": self.user?.maxSeekingAge ?? 99
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { err in
            hud.dismiss()
            
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            
            print("Finished saving user info")
            
            self.dismiss(animated: true) {
                self.delegate?.didSaveSettings()
            }
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout)),
        ]
    }
    
    fileprivate func setupHeaderView() -> UIView {
        let header = UIView()
        
        header.addSubview(image1Button)
        
        let padding: CGFloat = 16
        
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.spacing = padding
        stackView.distribution = .fillEqually
        
        header.addSubview(stackView)
        
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        
        return header
    }
    
    fileprivate func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
}

extension SettingsController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.originalImage] as? UIImage
        
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true)
        
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: self.view)
        
        ref.putData(uploadData, metadata: nil) { [weak self] _, err in
            hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            
            print("Finished uploading image")
            ref.downloadURL { url, err in
                
                hud.dismiss()
                
                if let err = err {
                    print("Failed to retrieve download URL:", err)
                    return
                }
                
                print("Finished getting download url:", url?.absoluteString ?? "")
                
                if imageButton == self?.image1Button {
                    self?.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self?.image2Button {
                    self?.user?.imageUrl2 = url?.absoluteString
                } else {
                    self?.user?.imageUrl3 = url?.absoluteString
                }
            }
        }
    }
}
