//
//  SymptomDetailViewController.swift
//  TinyVitals
//
//  Created by admin0 on 18/11/25.
//

import UIKit

protocol SymptomDetailDelegate: AnyObject {
    func didUpdateEntry(entry: SymptomEntry)
    // func didDeleteEntry(entry: SymptomEntry) // We'll add this later
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
        // Do any additional setup after loading the view.
    }
    
    
    // In SymptomDetailViewController.swift

    func populateData() {
        guard let entry = symptomEntry else { return }
        
        self.title = entry.title
        
        // --- Description ---
        descriptionLabel.text = entry.description ?? "No description added."
        
        // --- Symptoms ---
        if entry.symptoms.isEmpty {
            symptomsLabel.text = "No symptoms listed."
        } else {
            let bulletedSymptoms = entry.symptoms.map { "• \($0)" }.joined(separator: "\n")
            symptomsLabel.text = bulletedSymptoms
        }
        
        // --- VITALS FIX: Show "N/A" instead of hiding the label ---
        
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

        // --- Note ---
        noteLabel.text = entry.notes ?? "No note added."
        
        // --- Photo ---
        if let data = entry.photoData {
            photoImageView.image = UIImage(data: data)
            photoImageView.isHidden = false
        } else {
            photoImageView.isHidden = true
        }
    }
    
    @objc func doneTapped() {
        // Dismiss the modal view
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editButtonTapped() {
        // 1. Create an instance of the LogSymptoms screen
        let logVC = LogSymptomsViewController(nibName: "LogSymptomsViewController", bundle: nil)
        
        // 2. Set its delegate to *this* screen
        logVC.delegate = self
        
        // 3. THIS IS THE KEY: Pass the entry to pre-fill the form
        logVC.existingEntry = self.symptomEntry
        
        // 4. Push the edit screen
        self.navigationController?.pushViewController(logVC, animated: true)
    }
}


extension SymptomDetailViewController {
    
    // This method receives the *updated* entry from the edit screen (LogSymptomsVC)
    func didUpdateSymptom(_ entry: SymptomEntry) {
        // 1. Update this screen's local data
        self.symptomEntry = entry
        
        // 2. Refresh the UI to show the changes
        populateData()
        
        // 3. Pass the change *further back* to the main list
        delegate?.didUpdateEntry(entry: entry)
    }
    
    // This is required by the protocol, but we don't use it here
    func didLogNewSymptom(_ entry: SymptomEntry) {
        // Not used in this context
    }
}
