//
//  ChildProfileCell.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

class ChildProfileCell: UICollectionViewCell {
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundContainer.clipsToBounds = true
        childImageView.contentMode = .scaleAspectFill
        childImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        childImageView.layer.cornerRadius = childImageView.bounds.height / 2
    }

    func configure(with model: ChildDetails) {
        nameLabel.text = model.name
        if let img = model.image {
            childImageView.image = img
        } else {
            childImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}


