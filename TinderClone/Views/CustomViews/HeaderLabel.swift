//
//  HeaderLabel.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 16.11.23.
//

import UIKit

class HeaderLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}
