//
//  RecordListCell.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit

protocol RecordListCellDelegate: AnyObject {
    func didTapShare(for record: Record)
}

class RecordListCell: UITableViewCell {
    
    weak var delegate: RecordListCellDelegate?
    var currentRecord: Record?
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var recordTitleLabel: UILabel!
    @IBOutlet weak var shareActionButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var clinicLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 4.0
        shareActionButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        thumbnailImageView.contentMode = .center
        thumbnailImageView.tintColor = .systemBlue
    }
    
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
    
    func setThumbnail(image: UIImage?) {
        if let image = image {
            self.thumbnailImageView.image = image

            self.thumbnailImageView.contentMode = .scaleAspectFit
            
            self.thumbnailImageView.clipsToBounds = true
            
            self.thumbnailImageView.tintColor = nil
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let record = currentRecord else { return }
        delegate?.didTapShare(for: record)
    }
    

}
