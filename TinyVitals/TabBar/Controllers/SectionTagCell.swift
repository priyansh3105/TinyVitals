//
//  SectionTagCell.swift
//  TinyVitals
//
//  Created by admin0 on 12/11/25.
//

import UIKit

class SectionTagCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var sectionLabel: UILabel!
    
    @IBOutlet weak var plusButton: UIButton!
    
    let selectedColor = UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0) // Darker Blue
    let defaultColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 16 // Assuming cell height is ~32 points
        containerView.clipsToBounds = true
    }
    func configure(with name: String, isAddButton: Bool, isSelected: Bool) {
        sectionLabel.text = name
        plusButton.isHidden = !isAddButton
        
        // HIG: Update appearance based on selection state
        updateAppearance(isSelected: isSelected)
    }
    
    func updateAppearance(isSelected: Bool) {
        if isSelected {
            containerView.backgroundColor = selectedColor
            sectionLabel.textColor = .white
            // If the cell has a plus button, set its tint to white when selected
            plusButton.tintColor = .white
        } else {
            containerView.backgroundColor = defaultColor
            sectionLabel.textColor = .black
            plusButton.tintColor = .systemBlue // Standard blue when unselected
        }
    }
}
