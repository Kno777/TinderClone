//
//  RegistrationController.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 14.11.23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD

class RegistrationController: UIViewController {
    
    let gradientLayer = CAGradientLayer()
    let registrationViewModel = RegistrationViewModel()
    let registerHUD = JGProgressHUD(style: .dark)

    // UI Components
    lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    lazy var fullNameTextField: CustomTextField = {
       let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter full name"
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    lazy var emailTextField: CustomTextField = {
       let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTextField: CustomTextField = {
       let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
        //button.backgroundColor = UIColor(red: 253/255, green: 91/255, blue: 95/255, alpha: 1)
        
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientLayer()

        setupLayout()
        
        setupNotificationObserver()
        
        setupTapGesture()
        
        setupRegistrationViewModelObserver()
    }
    
    // MARK: - Functions
    
    @objc fileprivate func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc fileprivate func handleRegister() {
        self.handleKeyboardDismiss()
        print("Register our User in Firebase Auth...")
        
        registrationViewModel.bindableIsRegistering.value = true
        
        registrationViewModel.preformRegistration { [weak self] err in
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            
            print("Finished registering our user...")
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        
        registerHUD.dismiss(animated: true)
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
    
    fileprivate func setupRegistrationViewModelObserver() {
        
        registrationViewModel.bindableIsFormValid.bind { [weak self] isFormValid in
            
            guard let isFormValid = isFormValid else { return }
            
            self?.registerButton.isEnabled = isFormValid
            
            if isFormValid {
                self?.registerButton.backgroundColor = UIColor(red: 253/255, green: 91/255, blue: 95/255, alpha: 1)
                self?.registerButton.setTitleColor(.white, for: .normal)
            } else {
                self?.registerButton.backgroundColor = .lightGray
                self?.registerButton.setTitleColor(.darkGray, for: .normal)
            }
        }
        
        registrationViewModel.bindableImage.bind { [unowned self] image in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        registrationViewModel.bindableIsRegistering.bind { [unowned self] isRegistering in
            if isRegistering == true {
                registerHUD.textLabel.text = "Register"
                registerHUD.show(in: self.view)
            } else {
                registerHUD.dismiss()
            }
        }
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            print("Full name chnaging...")
            registrationViewModel.fullName = fullNameTextField.text
            
        } else if textField == emailTextField {
            print("Email chnaging...")
            registrationViewModel.email = emailTextField.text
        } else {
            print("Password chnaging...")
            registrationViewModel.password = passwordTextField.text
        }
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleKeyboardDismiss)))
    }
    
    @objc fileprivate func handleKeyboardDismiss() {
        self.view.endEditing(true) // dismisses keyboard
    }
    
    fileprivate func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.transform = .identity // view come back
        }
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        // how to figure out how tall the keyboard actualli is?
        
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = value.cgRectValue
        print(keyboardFrame)
        
        // let's try to figure out how tall the gap is from the register button to the bottom of the screen
        
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        
        print(bottomSpace)
        
        let difference = keyboardFrame.height - bottomSpace
        
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
        ])
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
        
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
    ])
    
    fileprivate func setupLayout() {
        overallStackView.axis = .vertical
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.spacing = 8
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = UIColor(red: 253/255, green: 91/255, blue: 95/255, alpha: 1)
        let bottomColor = UIColor(red: 225/255, green: 0/255, blue: 114/255, alpha: 1)
    
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        
        gradientLayer.frame = view.bounds
        
        view.layer.addSublayer(gradientLayer)
    }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as? UIImage
        
        registrationViewModel.bindableImage.value = image
                
        self.dismiss(animated: true)
    }
}
