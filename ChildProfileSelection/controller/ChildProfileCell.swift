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
        // Visual polishing
        backgroundContainer.clipsToBounds = true

        childImageView.contentMode = .scaleAspectFill
        childImageView.clipsToBounds = true
        // If you want circle avatar, set cornerRadius in layoutSubviews
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // make image circular if it's square
        childImageView.layer.cornerRadius = childImageView.bounds.height / 2
    }

    // ---- ADD THIS METHOD ----
    func configure(with model: ChildProfile) {
        nameLabel.text = model.name
        if let img = UIImage(named: model.imageName) {
            childImageView.image = img
        } else {
            // fallback placeholder if asset missing
            childImageView.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}

