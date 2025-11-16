//
//  VaccineTableViewCell.swift
//  TinyVitals
//
//  Created by admin0 on 14/11/25.
//

import UIKit

class VaccineCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with vaccine: Vaccine) {
        titleLabel.text = vaccine.name
        subtitleLabel.text = vaccine.fullName // <<< USE fullName HERE
    }

}
