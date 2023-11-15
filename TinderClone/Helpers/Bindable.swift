//
//  Bindable.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 15.11.23.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
