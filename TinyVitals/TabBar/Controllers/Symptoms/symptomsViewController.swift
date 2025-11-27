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
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = symptomsSuperView.bounds
        symptomsSuperView.layer.insertSublayer(gradientLayer, at: 0)
    }
    @IBAction func childProfileSelection(_ sender: UIBarButtonItem) {
        let childVC = ChildProfilesCollectionViewController(nibName: "ChildProfilesCollectionViewController", bundle: nil)
        let navVC = UINavigationController(rootViewController: childVC)

        guard let window = self.view.window else { return }

        window.rootViewController = navVC
        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    func loadSampleData() {
        self.allSymptomEntries = [
            SymptomEntry(
                id: UUID(),
                date: Date(),
                title: "Skin Redness",
                description: "Rashes observed on upper thigh.",
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCardCell", for: indexPath) as? SymptomCardCell else {
            return UITableViewCell()
        }
        let entry = allSymptomEntries[indexPath.row]
        cell.symptomTitle.text = entry.symptoms.first ?? "Symptom"
        if let temp = entry.temperature {
            cell.temperature.text = "Temperature: \(temp)°F"
        } else {
            cell.temperature.text = "No temperature recorded"
        }
        cell.date.text = dateFormatter.string(from: entry.date)
        cell.time.text = timeFormatter.string(from: entry.date)
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
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.large()]
            }
        }
        self.present(nav, animated: true)
    }
    
    @objc func diagnosisButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let selectedEntry = allSymptomEntries[row]
        print("Tapped ADD DIAGNOSIS for entry: \(selectedEntry.symptoms.first ?? "")")
    }
}
