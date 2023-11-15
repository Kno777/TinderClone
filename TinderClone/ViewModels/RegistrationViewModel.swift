//
//  RegistrationViewModel.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 14.11.23.
//

import UIKit
import Firebase
import FirebaseStorage

class RegistrationViewModel {
        
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    var email: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    var password: String?{
        didSet {
            checkFormValidity()
        }
    }
    
    func preformRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        self.bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] res, err in
            if let err = err {
                print(err)
                completion(err)
                return
            }
            
            print("Successfully registered user: ", res?.user.uid ?? "")
            
            // Only upload images to Firebase Storage once you are authorized
            let filename = UUID().uuidString
            let ref = Storage.storage().reference(withPath: "/images/\(filename)")
            let imageData = self?.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
            
            ref.putData(imageData) { _, err in
                if let err = err {
                    print(err)
                    completion(err)
                    return
                }
                
                print("Finished uplading image to storage")
                ref.downloadURL { url, err in
                    if let err = err {
                        print(err)
                        completion(err)
                        return
                    }
                    
                    self?.bindableIsRegistering.value = false
                    print("Download url of our image is:", url?.absoluteString ?? "")
                    
                    // store the download url into FireStore next lesson
                }
            }
        }
    }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
}
