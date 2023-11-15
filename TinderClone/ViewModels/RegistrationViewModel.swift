//
//  RegistrationViewModel.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 14.11.23.
//

import UIKit

class RegistrationViewModel {
    
    var image: UIImage? {
        didSet {
            imageObserver?(image)
        }
    }
    
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
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        isFormValidObserver?(isFormValid)
    }
    
    // Reactive programming
    var isFormValidObserver: ((Bool) -> ())?
    
    var imageObserver: ((UIImage?) -> ())?
    
    
}
