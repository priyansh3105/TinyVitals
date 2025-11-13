//
//  ChildProfileCell.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

protocol ChildProfileCellDelegate: AnyObject {
    func didTapChildImage(in cell: ChildProfileCell)
}

class ChildProfileCell: UICollectionViewCell {

    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: ChildProfileCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundContainer.clipsToBounds = true
        childImageView.contentMode = .scaleAspectFill
        childImageView.clipsToBounds = true
        childImageView.isUserInteractionEnabled = true   // Needed for taps

        // Tap gesture recognizer for image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        childImageView.addGestureRecognizer(tapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        childImageView.layer.cornerRadius = childImageView.bounds.height / 2
    }

    @objc private func imageTapped() {
        delegate?.didTapChildImage(in: self)
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
