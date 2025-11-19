//
//  SymptomCardCell.swift
//  TinyVitals
//
//  Created by admin0 on 17/11/25.
//

import UIKit

class SymptomCardCell: UITableViewCell {

    
    @IBOutlet weak var symptomTitle: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var diagnosisButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
