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
    
    // --- DATA SOURCE UPDATED ---
    // We replace the flat [String] array with our new sectioned structure
    var symptomCategories: [SymptomCategory] = []
    // This holds the default, hard-coded symptoms
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
    
    // Key for saving to device storage
    let customSymptomsKey = "CustomSymptoms"
    
    var selectedSymptoms: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Symptoms"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Allow multiple selection
        tableView.allowsMultipleSelection = true
        
        // --- CORRECTED NAVIGATION BAR SETUP ---
        // 1. "Done" button (Confirmation) goes on the RIGHT
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        // 2. "Add" button (Secondary action) goes on the LEFT
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCustomSymptomTapped))
        
        loadAndBuildCategories()
        // ------------------------------------
    }
    
    @objc func doneButtonTapped() {
        // This logic doesn't change
        delegate?.didSelectSymptoms(selectedSymptoms)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UITableViewDataSource
    
    // --- NEW ---
    // Return the number of categories
    func numberOfSections(in tableView: UITableView) -> Int {
        return symptomCategories.count
    }
    
    // --- NEW ---
    // Return the title for each category
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return symptomCategories[section].name
    }
    
    // --- UPDATED ---
    // Return the number of symptoms *in this section*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptomCategories[section].symptoms.count
    }
    
    // --- UPDATED ---
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        // Get the specific symptom from the specific category
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        
        cell.textLabel?.text = symptom
        
        // Show checkmark if it's already selected
        if selectedSymptoms.contains(symptom) {
            cell.accessoryType = .checkmark
            // Re-select the row if it was in the saved list
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    // --- UPDATED ---
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the symptom from the sectioned array
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        
        // Add to selected list and show checkmark
        selectedSymptoms.append(symptom)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    // --- UPDATED ---
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Get the symptom from the sectioned array
        let symptom = symptomCategories[indexPath.section].symptoms[indexPath.row]
        
        // Remove from selected list and hide checkmark
        if let index = selectedSymptoms.firstIndex(of: symptom) {
            selectedSymptoms.remove(at: index)
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    // In SymptomSelectionViewController.swift

    @objc func addCustomSymptomTapped() {
        // 1. Create the alert
        let alert = UIAlertController(title: "Add Custom Symptom", message: "Enter a symptom not found in the list.", preferredStyle: .alert)
        
        // 2. Add a text field
        alert.addTextField { textField in
            textField.placeholder = "e.g., 'Shaking hands'"
        }
        
        // 3. Add the "Add" action
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newSymptom = textField.text?.trimmingCharacters(in: .whitespaces),
                  !newSymptom.isEmpty else { return }
            
            // 4. Add the new symptom to the list and select it
            self.addNewSymptom(newSymptom)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
    
    
    func loadAndBuildCategories() {
        // 1. Start with the default categories
        symptomCategories = defaultCategories
        
        // 2. Load custom symptoms saved on the device
        let savedSymptoms = UserDefaults.standard.array(forKey: customSymptomsKey) as? [String] ?? []
        
        // 3. Find the "General" section
        if let generalIndex = symptomCategories.firstIndex(where: { $0.name == "General" }) {
            // 4. Add the saved custom symptoms to the end of the "General" list
            symptomCategories[generalIndex].symptoms.append(contentsOf: savedSymptoms)
        } else {
            // Fallback: If "General" doesn't exist, create a "Custom" section
            if !savedSymptoms.isEmpty {
                let customCategory = SymptomCategory(name: "Custom", symptoms: savedSymptoms)
                symptomCategories.append(customCategory)
            }
        }
    }
    
    // 4. Create a helper function to add the symptom
    func addNewSymptom(_ newSymptom: String) {
        // 1. Load existing custom symptoms from device
        var savedSymptoms = UserDefaults.standard.array(forKey: customSymptomsKey) as? [String] ?? []
        
        // 2. Add the new one (if it doesn't already exist)
        if !savedSymptoms.contains(newSymptom) {
            savedSymptoms.append(newSymptom)
            // 3. Save the updated list back to the device
            UserDefaults.standard.set(savedSymptoms, forKey: customSymptomsKey)
        }
        
        // 4. Rebuild the entire category list from scratch
        loadAndBuildCategories()
        
        // 5. Add to the *currently* selected list
        if !selectedSymptoms.contains(newSymptom) {
            selectedSymptoms.append(newSymptom)
        }
        
        // 6. Refresh the table to show the new item
        tableView.reloadData()
        
        // 7. Scroll to and highlight the new item
        if let sectionIndex = symptomCategories.firstIndex(where: { $0.symptoms.contains(newSymptom) }),
           let rowIndex = symptomCategories[sectionIndex].symptoms.firstIndex(of: newSymptom) {
            
            let newIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
            tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
        }
    }
    
    
}
