//
//  SymptomSelectionViewController.swift
//  TinyVitals
//
//  Created by admin0 on 17/11/25.
//
import UIKit

class SymptomSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SymptomSelectionDelegate?
    


    var symptomCategories: [SymptomCategory] = []

    let defaultCategories: [SymptomCategory] = [
        SymptomCategory(name: "General",
                        symptoms: ["Fever", "Chills", "Fatigue / Lethargy", "Poor Appetite", "Difficulty Sleeping", "Irritability / Fussy"]),
        SymptomCategory(name: "Head / Ear / Throat",
                        symptoms: ["Headache", "Sore Throat", "Dizziness", "Earache / Ear Pulling", "Swollen Glands"]),
        SymptomCategory(name: "Respiratory / Nasal",
                        symptoms: ["Cough (Dry)", "Cough (Wet)", "Runny Nose", "Nasal Congestion", "Sneezing", "Shortness of Breath", "Wheezing"]),
        SymptomCategory(name: "Digestive",
                        symptoms: ["Nausea", "Vomiting", "Diarrhea", "Constipation", "Stomach Ache (Abdominal Pain)", "Gas / Bloating", "Poor Feeding"]),
        SymptomCategory(name: "Skin",
                        symptoms: ["Skin Redness", "Rash", "Itching", "Hives", "Eczema", "Unexplained Bruising", "Pale Skin"]),
        SymptomCategory(name: "Vision / Oral",
                        symptoms: ["Blurry Vision", "Watery Eyes", "Red / Pink Eye", "Mouth Sores", "Excessive Drooling"])
    ]
    
    
    let customSymptomsKey = "CustomSymptoms"
    
    var selectedSymptoms: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Symptoms"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCustomSymptomTapped))
        
        loadAndBuildCategories()
    }
    
    @objc func doneButtonTapped() {
        delegate?.didSelectSymptoms(selectedSymptoms)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return symptomCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return symptomCategories[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptomCategories[section].symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        cell.textLabel?.text = symptom
        if selectedSymptoms.contains(symptom) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        selectedSymptoms.append(symptom)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        if let index = selectedSymptoms.firstIndex(of: symptom) {
            selectedSymptoms.remove(at: index)
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    @objc func addCustomSymptomTapped() {
        let alert = UIAlertController(title: "Add Custom Symptom", message: "Enter a symptom not found in the list.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "e.g., 'Shaking hands'"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newSymptom = textField.text?.trimmingCharacters(in: .whitespaces),
                  !newSymptom.isEmpty else { return }
            self.addNewSymptom(newSymptom)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
    
    
    func loadAndBuildCategories() {
        symptomCategories = defaultCategories
        let savedSymptoms = UserDefaults.standard.array(forKey: customSymptomsKey) as? [String] ?? []
        if let generalIndex = symptomCategories.firstIndex(where: { $0.name == "General" }) {
            symptomCategories[generalIndex].symptoms.append(contentsOf: savedSymptoms)
        } else {
            if !savedSymptoms.isEmpty {
                let customCategory = SymptomCategory(name: "Custom", symptoms: savedSymptoms)
                symptomCategories.append(customCategory)
            }
        }
    }
    
    func addNewSymptom(_ newSymptom: String) {
        var savedSymptoms = UserDefaults.standard.array(forKey: customSymptomsKey) as? [String] ?? []
        if !savedSymptoms.contains(newSymptom) {
            savedSymptoms.append(newSymptom)
            UserDefaults.standard.set(savedSymptoms, forKey: customSymptomsKey)
        }
        loadAndBuildCategories()
        if !selectedSymptoms.contains(newSymptom) {
            selectedSymptoms.append(newSymptom)
        }
        tableView.reloadData()
        if let sectionIndex = symptomCategories.firstIndex(where: { $0.symptoms.contains(newSymptom) }),
           let rowIndex = symptomCategories[sectionIndex].symptoms.firstIndex(of: newSymptom) {
            let newIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
        }
    }
}
