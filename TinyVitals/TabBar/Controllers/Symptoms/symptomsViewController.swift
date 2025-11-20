//
//  symptomsViewController.swift
//  TinyVitals
//
//  Created by admin0 on 08/11/25.
//

import UIKit

class symptomsViewController: UIViewController, LogSymptomsDelegate {

    @IBOutlet var symptomsSuperView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var allSymptomEntries: [SymptomEntry] = []
        
    // Date formatter for displaying cell data
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        tableView.dataSource = self
        tableView.delegate = self
        // Load sample data
        loadSampleData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logNewSymptomTapped(_ sender: Any) {
        let logVC = LogSymptomsViewController(nibName: "LogSymptomsViewController", bundle: nil)
        logVC.delegate = self
        logVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(logVC, animated: true)
    }
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        
        // Top Color: Light Blue (#82C3FF) - Based on your color codes
        // RGB: 130/255, 195/255, 255/255
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        
        // Bottom Color: White (#FFFFFF) - Based on your color codes
        let colorBottom = UIColor.white.cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        
        // Set for a Vertical Gradient (Top to Bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Center Top
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Center Bottom
        
        // Apply to the view
        gradientLayer.frame = symptomsSuperView.bounds
        symptomsSuperView.layer.insertSublayer(gradientLayer, at: 0)
    }
    func loadSampleData() {
        // Create sample data matching your design
        self.allSymptomEntries = [
            SymptomEntry(
                id: UUID(),
                date: Date(),
                title: "Skin Redness", // <<< ADDED
                description: "Rashes observed on upper thigh.", // <<< ADDED
                symptoms: ["Skin Redness", "Mild Fever"],
                temperature: 91.0,
                weight: 2.3,
                height: 23.03,
                notes: "Rashes appeared on the upper thigh.",
                photoData: nil,
                diagnosisID: nil,
                diagnosedBy: "Albert Dane"
            )
        ]
        
        tableView.reloadData()
    }
    func didLogNewSymptom(_ entry: SymptomEntry) {
        allSymptomEntries.insert(entry, at: 0)
        tableView.reloadData()
    }
    
    func didUpdateSymptom(_ entry: SymptomEntry) {
        if let index = allSymptomEntries.firstIndex(where: { $0.id == entry.id }) {
            allSymptomEntries[index] = entry
            tableView.reloadData()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension symptomsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSymptomEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Dequeue your custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCardCell", for: indexPath) as? SymptomCardCell else {
            return UITableViewCell()
        }
        
        // 2. Get the data for this row
        let entry = allSymptomEntries[indexPath.row]
        
        // 3. Configure the cell outlets
        cell.symptomTitle.text = entry.symptoms.first ?? "Symptom" // Show the first symptom as title
        
        if let temp = entry.temperature {
            cell.temperature.text = "Temperature: \(temp)°F"
        } else {
            cell.temperature.text = "No temperature recorded"
        }
        
        cell.date.text = dateFormatter.string(from: entry.date)
        cell.time.text = timeFormatter.string(from: entry.date)
        
        // You also need an outlet for "Diagnosed By"
        // cell.diagnosedByLabel.text = "By \(entry.diagnosedBy ?? "N/A")"
        
        // 4. Add targets for the buttons
        // We use .tag to pass the row number to the action method
        cell.viewButton.tag = indexPath.row
        cell.viewButton.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
        
        cell.diagnosisButton.tag = indexPath.row
        cell.diagnosisButton.addTarget(self, action: #selector(diagnosisButtonTapped(_:)), for: .touchUpInside)

        return cell
    }
    
    // MARK: - Cell Button Actions
    
    @objc func viewButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let selectedEntry = allSymptomEntries[row]
        
        let detailVC = SymptomDetailViewController(nibName: "SymptomDetailViewController", bundle: nil)
        detailVC.symptomEntry = selectedEntry
        
        // --- THIS IS THE FIX ---
        
        // 1. Create a navigation controller to hold the detail view
        // This is necessary to show the title and "Done" button.
        let nav = UINavigationController(rootViewController: detailVC)
        
        // 2. (Optional) Set the modal style to a card (HIGHLY RECOMMENDED)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.large()] // Or [.medium(), .large()]
            }
        }

        // 3. Present the navigation controller modally
        self.present(nav, animated: true)
    }
    
    @objc func diagnosisButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let selectedEntry = allSymptomEntries[row]
        
        // We will implement this navigation in a future step
        print("Tapped ADD DIAGNOSIS for entry: \(selectedEntry.symptoms.first ?? "")")
    }
}
