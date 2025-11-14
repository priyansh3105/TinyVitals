//
//  vaccinationViewController.swift
//  TinyVitals
//
//  Created by admin0 on 08/11/25.
//

import UIKit

class vaccinationViewController: UIViewController, EditVaccinationDelegate {

    @IBOutlet var vaccinationSuperView: UIView!
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var tagStackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Data Properties
    let sectionTitles = ["Due", "Completed"]
    var masterVaccineList: [Vaccine] = [] // Holds ALL vaccines
    
    // Arrays to power the sectioned table view
    var dueVaccines: [Vaccine] = []
    var completedVaccines: [Vaccine] = []
    
    // Data source for the filter tags
    var allSchedules: [String] = ["All"] + VaccinationSchedule.allCases.map { $0.rawValue }
    var selectedSchedule: String = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        
        // CRITICAL: Set the delegates for the table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        // Build the horizontal filter tags
        setupSectionTags()
        
        loadSampleVaccines()
    }
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = vaccinationSuperView.bounds
        vaccinationSuperView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Tag/Filter Logic
    
    func setupSectionTags() {
        // 1. Clear all existing buttons before rebuilding
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 2. Iterate through all sections to create buttons
        for sectionName in allSchedules {
            // Note: This screen doesn't have a dynamic "+" button
            let isAddButton = false
            let isSelected = (sectionName == selectedSchedule)
            
            let button = createTagButton(title: sectionName, isAddButton: isAddButton, isSelected: isSelected)
            
            // Add button to the stack view
            tagStackView.addArrangedSubview(button)
        }
    }
    
    private func createTagButton(title: String, isAddButton: Bool, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        
        // Set Title/Image
        if isAddButton {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.setTitle(nil, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }

        // Styling (Pill Shape)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        button.layer.cornerRadius = 14 // Half of a 36pt effective button height
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0).cgColor
        
        // Color Logic
        let backgroundColor = isSelected ? UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0) : UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        let textColor: UIColor = isSelected ? .white : .systemBlue
        let tintColor: UIColor = isSelected ? .white : .systemBlue
        
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.tintColor = tintColor
        
        // Tagging (Use the section name as the identifier string)
        button.accessibilityIdentifier = title
        
        // Action Connection
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func tagButtonTapped(_ sender: UIButton) {
        guard let selectedName = sender.accessibilityIdentifier else { return }

        // This view doesn't add sections, so we just filter
        selectedSchedule = selectedName
        setupSectionTags()
        filterVaccines()
    }
    
    // MARK: - Data Filtering & Loading
    
    func filterVaccines() {
        var scopedVaccines: [Vaccine]
        
        // 1. Filter by the selected schedule tag
        if selectedSchedule == "All" {
            scopedVaccines = masterVaccineList
        } else {
            scopedVaccines = masterVaccineList.filter { $0.schedule.rawValue == selectedSchedule }
        }
        
        // --- THIS IS THE FIX ---
        
        // 2. "Due" now includes anything that is NOT .completed
        dueVaccines = scopedVaccines.filter { $0.status != .completed }
        
        // 3. "Completed" is only for .completed items
        completedVaccines = scopedVaccines.filter { $0.status == .completed }
        
        // 4. Refresh the table
        tableView.reloadData()
    }

    // Add some sample data to test
    func loadSampleVaccines() {
        masterVaccineList = [
            
            // --- Birth ---
            Vaccine(name: "BCG", description: "Tuberculosis Vaccine", schedule: .atBirth, status: .completed, notes: "Given at hospital", givenDate: Date(), photoData: nil),
            Vaccine(name: "OPV 0", description: "Oral Polio Vaccine", schedule: .atBirth, status: .completed, notes: "Given at hospital", givenDate: Date(), photoData: nil),
            
            // --- 6 Weeks ---
            Vaccine(name: "DTwP 1", description: "Diphtheria, Tetanus, Pertussis", schedule: .sixWeeks, status: .completed, notes: "Given on 1/1/25", givenDate: Date(), photoData: nil),
            Vaccine(name: "Hep-B 2", description: "Hepatitis B Vaccine", schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "IPV 1", description: "Inactivated Polio Vaccine", schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Rota Virus 1", description: "Rotavirus Vaccine", schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "PCV 1", description: "Pneumococcal Conjugate Vaccine", schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 10 Weeks ---
            Vaccine(name: "DTwP 2", description: "Diphtheria, Tetanus, Pertussis", schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "IPV 2", description: "Inactivated Polio Vaccine", schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hib 2", description: "Haemophilus Influenzae Type B", schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Rota Virus 2", description: "Rotavirus Vaccine", schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "PCV 2", description: "Pneumococcal Conjugate Vaccine", schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 14 Weeks ---
            Vaccine(name: "DTwP 3", description: "Diphtheria, Tetanus, Pertussis", schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "IPV 3", description: "Inactivated Polio Vaccine", schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hib 3", description: "Haemophilus Influenzae Type B", schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Rota Virus 3", description: "Rotavirus Vaccine", schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "PCV 3", description: "Pneumococcal Conjugate Vaccine", schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 6 Months ---
            Vaccine(name: "OPV 1", description: "Oral Polio Vaccine", schedule: .sixMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hep-B 3", description: "Hepatitis B Vaccine", schedule: .sixMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 9 Months ---
            Vaccine(name: "OPV 2", description: "Oral Polio Vaccine", schedule: .nineMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "MMR-1", description: "Mumps, Measles, Rubella", schedule: .nineMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 12 Months ---
            Vaccine(name: "Typhoid", description: "Typhoid Conjugate Vaccine", schedule: .twelveMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hep-A 1", description: "Hepatitis A Vaccine", schedule: .twelveMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 15 Months ---
            Vaccine(name: "MMR 2", description: "Mumps, Measles, Rubella", schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Varicella 1", description: "Chickenpox Vaccine", schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "PCV Booster", description: "Pneumococcal Conjugate Vaccine", schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 18 Months ---
            Vaccine(name: "DTaP B1 / DTwP B1", description: "Diphtheria, Tetanus, Pertussis", schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "OPV 3 / IPV B1", description: "Polio Vaccine", schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hib B1", description: "Haemophilus Influenzae Type B", schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Hep-A 2", description: "Hepatitis A Vaccine", schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 2 Years ---
            Vaccine(name: "Typhoid Booster", description: "Typhoid Vaccine", schedule: .twoYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 4-6 Years ---
            Vaccine(name: "DTaP B2 / DTwP B2", description: "Diphtheria, Tetanus, Pertussis", schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "OPV 3", description: "Oral Polio Vaccine", schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "Varicella 2", description: "Chickenpox Vaccine", schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 10-12 Years ---
            Vaccine(name: "Tdap / Td", description: "Tetanus, Diphtheria, Pertussis", schedule: .tenToTwelveYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            Vaccine(name: "HPV", description: "Human Papillomavirus Vaccine", schedule: .tenToTwelveYears, status: .due, notes: nil, givenDate: nil, photoData: nil)
        ]
        
        // Run the filter on launch to populate the list
        filterVaccines()
    }
    
    
    func didUpdateVaccine(_ updatedVaccine: Vaccine) {
        
        // 1. Find the original vaccine in the master list using its name
        if let index = masterVaccineList.firstIndex(where: { $0.name == updatedVaccine.name }) {
            
            // 2. Replace it with the updated version
            masterVaccineList[index] = updatedVaccine
            
            // 3. Re-filter and reload the table to show the change
            // This will automatically move the item from "Due" to "Completed"
            filterVaccines()
        } else {
            print("Error: Could not find matching vaccine to update.")
        }
    }
}


// MARK: - Table View Extensions
// (Extensions must come AFTER the class definition)

extension vaccinationViewController: UITableViewDataSource {
    
    // 1. Tell the table view there are two sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    // 2. Set the title for each section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Give the header some space, but only if it has content
        if section == 0 && !dueVaccines.isEmpty {
            return 20 // Height for the "Due" header
        } else if section == 1 && !completedVaccines.isEmpty {
            return 20 // Height for the "Completed" header
        }
        return 0 // No height if the section is empty
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 1. Create the container view for the header
        let headerView = UIView()
        headerView.backgroundColor = .clear // <<< This makes the background transparent

        // 2. Create the label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = UIColor.label // This will be black/white depending on light/dark mode

        // 3. Set the text based on the section
        if section == 0 && !dueVaccines.isEmpty {
            titleLabel.text = "Due"
        } else if section == 1 && !completedVaccines.isEmpty {
            titleLabel.text = "Completed"
        } else {
            return nil // Return nothing if the section is empty
        }

        // 4. Add the label and set its position
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            // Pin the label to the leading edge (left side) with 16 points of padding
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            // Center the label vertically in the header view
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    // 3. Set the number of rows for each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dueVaccines.count // Rows for "Due"
        } else {
            return completedVaccines.count // Rows for "Completed"
        }
    }
    
    // 4. Configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue your custom blue card cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as? VaccineCell else {
            fatalError("Could not dequeue VaccineCell")
        }
        
        // Get the correct vaccine from the correct array
        let vaccine: Vaccine
        if indexPath.section == 0 {
            vaccine = dueVaccines[indexPath.row]
        } else {
            vaccine = completedVaccines[indexPath.row]
        }
        
        // Configure the custom cell's labels
        cell.configure(with: vaccine)
        
        return cell
    }
}

extension vaccinationViewController: UITableViewDelegate {
    // Handle taps to see vaccine details
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1. Get the selected vaccine
        let selectedVaccine: Vaccine
        if indexPath.section == 0 {
            selectedVaccine = dueVaccines[indexPath.row]
        } else {
            selectedVaccine = completedVaccines[indexPath.row]
        }
        
        // 2. Create the detail VC
        let detailVC = EditVaccinationLogViewController(nibName: "EditVaccinationLogViewController", bundle: nil)
        
        // 3. Pass the data
        detailVC.vaccine = selectedVaccine
        
        // 4. <<< CRITICAL: SET THE DELEGATE >>>
        detailVC.delegate = self
        
        // 5. Push it onto the navigation stack
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
