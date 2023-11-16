//
//  AgeRangeCell.swift
//  TinderClone
//
//  Created by Kno Harutyunyan on 16.11.23.
//

import UIKit

class AgeRangeCell: UITableViewCell {
    
    let minSlider: UISlider = {
       let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    
    let maxSlider: UISlider = {
       let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()
    
    let minLabel: AgeRangeLabel = {
       let label = AgeRangeLabel()
        label.text = "Min 18"
        return label
    }()
    
    let maxLabel: AgeRangeLabel = {
       let label = AgeRangeLabel()
        label.text = "Max 100"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let overallStackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider])
        ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 16
        contentView.addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
