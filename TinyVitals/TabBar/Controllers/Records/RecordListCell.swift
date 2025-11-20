//
//  RecordListCell.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit

protocol RecordListCellDelegate: AnyObject {
    // Passes the URL of the record that needs to be shared
    func didTapShare(for record: Record)
}

class RecordListCell: UITableViewCell {
    
    weak var delegate: RecordListCellDelegate? // <<< New property
    var currentRecord: Record? // <<< To hold the record data
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var recordTitleLabel: UILabel!
    @IBOutlet weak var shareActionButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var clinicLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 🛠️ HIG Styling: Make the card look good
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        // Apply corner radius and shadow to the container view
//        cardContainerView.layer.cornerRadius = 16
//        cardContainerView.layer.shadowColor = UIColor.black.cgColor
//        cardContainerView.layer.shadowOpacity = 0.1
//        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cardContainerView.layer.shadowRadius = 4
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 4.0
        
        // Set up the share button icon (use SF Symbols)
        shareActionButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
    }
    
    // 1. HIG: Prevent stale content when scrolling (crucial for responsiveness)
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image properties while we wait for the new thumbnail to load
        thumbnailImageView.image = nil
        thumbnailImageView.contentMode = .center // Reset for placeholder center
        thumbnailImageView.tintColor = .systemBlue
    }
    
    // MARK: - Configuration
    
//    func configure(with record: Record) {
//        self.currentRecord = record
//        recordTitleLabel.text = record.fileName
////        recordTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
//        
//        // HIG: Use a contrasting color for the source text
//        clinicLabel.text = record.source
////        clinicLabel.textColor = .secondaryLabel
//        
//        // Set up the location icon
////        locationIconView.image = UIImage(systemName: "mappin.circle.fill")
////        locationIconView.tintColor = .systemGray
//        
//        // Format the date for the label
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM dd yyyy" // Use desired format (e.g., 25th Aug 2025)
//
//        dateLabel.text = "Visited \(dateFormatter.string(from: record.addedDate))"
//        dateLabel.font = UIFont.systemFont(ofSize: 15) // Use a smaller font size
////        dateLabel.textColor = .systemGray
//        
//        // ... (rest of the thumbnail placeholder logic remains the same) ...
//    }
    func configure(with record: Record) {
        currentRecord = record
        recordTitleLabel.text = record.fileName
        clinicLabel.text = record.source
        let df = DateFormatter()
        df.dateFormat = "MMM dd yyyy"
        dateLabel.text = "Visited \(df.string(from: record.addedDate))"

        if let data = record.previewData, let img = UIImage(data: data) {
            setThumbnail(image: img)
        } else {
            setThumbnail(image: UIImage(named: "sample medical report image"))
        }
    }


    
    // 2. NEW FUNCTION: Used by the ViewController to deliver the final image
    func setThumbnail(image: UIImage?) {
        if let image = image {
            self.thumbnailImageView.image = image
            
            // HIG Fix: Use .scaleAspectFit to contain the image entirely within the view.
            self.thumbnailImageView.contentMode = .scaleAspectFit
            
            // This is often the fix: ensure the content view clips the drawn image
            self.thumbnailImageView.clipsToBounds = true
            
            self.thumbnailImageView.tintColor = nil // Remove tint for the preview image
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Ensure selection style doesn't interfere with the card look
        // You might want to remove the default selection style in Storyboard/XIB.
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let record = currentRecord else { return }
        delegate?.didTapShare(for: record) // Communicate back to the ViewController
    }
    

}
