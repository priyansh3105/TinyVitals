//
//  SymptomDetailViewController.swift
//  TinyVitals
//
//  Created by admin0 on 18/11/25.
//

import UIKit

protocol SymptomDetailDelegate: AnyObject {
    func didUpdateEntry(entry: SymptomEntry)
    // func didDeleteEntry(entry: SymptomEntry)
}


class SymptomDetailViewController: UIViewController, LogSymptomsDelegate {
    
    var symptomEntry: SymptomEntry?
    weak var delegate: SymptomDetailDelegate?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        populateData()
        
    }

    func populateData() {
        guard let entry = symptomEntry else { return }
        
        self.title = entry.title
        
        descriptionLabel.text = entry.description ?? "No description added."
        
        if entry.symptoms.isEmpty {
            symptomsLabel.text = "No symptoms listed."
        } else {
            let bulletedSymptoms = entry.symptoms.map { "• \($0)" }.joined(separator: "\n")
            symptomsLabel.text = bulletedSymptoms
        }
        
        
        if let temp = entry.temperature {
            temperatureLabel.text = "Temperature: \(temp)°F"
        } else {
            temperatureLabel.text = "Temperature: N/A"
        }
        
        if let weight = entry.weight {
            weightLabel.text = "Weight: \(weight) kg"
        } else {
            weightLabel.text = "Weight: N/A"
        }
        
        if let height = entry.height {
            heightLabel.text = "Height: \(height) cm"
        } else {
            heightLabel.text = "Height: N/A"
        }
        noteLabel.text = entry.notes ?? "No note added."
        
        if let data = entry.photoData {
            photoImageView.image = UIImage(data: data)
            photoImageView.isHidden = false
        } else {
            photoImageView.isHidden = true
        }
    }
    
    @objc func doneTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editButtonTapped() {
        let logVC = LogSymptomsViewController(nibName: "LogSymptomsViewController", bundle: nil)
        logVC.delegate = self
        logVC.existingEntry = self.symptomEntry
        self.navigationController?.pushViewController(logVC, animated: true)
    }
}


extension SymptomDetailViewController {
    func didUpdateSymptom(_ entry: SymptomEntry) {
        self.symptomEntry = entry
        populateData()
        delegate?.didUpdateEntry(entry: entry)
    }
    func didLogNewSymptom(_ entry: SymptomEntry) {
        
    }
}
