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
    var masterVaccineList: [Vaccine] = []
    
    var dueVaccines: [Vaccine] = []
    var completedVaccines: [Vaccine] = []
    
    var allSchedules: [String] = ["All"] + VaccinationSchedule.allCases.map { $0.rawValue }
    var selectedSchedule: String = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
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
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for sectionName in allSchedules {
            let isAddButton = false
            let isSelected = (sectionName == selectedSchedule)
            let button = createTagButton(title: sectionName, isAddButton: isAddButton, isSelected: isSelected)
            tagStackView.addArrangedSubview(button)
        }
    }
    
    private func createTagButton(title: String, isAddButton: Bool, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        if isAddButton {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.setTitle(nil, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0).cgColor
        
        let backgroundColor = isSelected ? UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0) : UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        let textColor: UIColor = isSelected ? .white : .systemBlue
        let tintColor: UIColor = isSelected ? .white : .systemBlue
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.tintColor = tintColor
        button.accessibilityIdentifier = title
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)

        return button
    }
    
    @objc func tagButtonTapped(_ sender: UIButton) {
        guard let selectedName = sender.accessibilityIdentifier else { return }
        selectedSchedule = selectedName
        setupSectionTags()
        filterVaccines()
    }
    
    // MARK: - Data Filtering & Loading
    
    func filterVaccines() {
        var scopedVaccines: [Vaccine]
        if selectedSchedule == "All" {
            scopedVaccines = masterVaccineList
        } else {
            scopedVaccines = masterVaccineList.filter { $0.schedule.rawValue == selectedSchedule }
        }
        dueVaccines = scopedVaccines.filter { $0.status != .completed }
        completedVaccines = scopedVaccines.filter { $0.status == .completed }
        tableView.reloadData()
    }

    func loadSampleVaccines() {
        masterVaccineList = [
            // --- Birth ---
            Vaccine(name: "BCG",
                    fullName: "Bacillus Calmette Guerin",
                    longDescription: "Given once at birth to protect against Tuberculosis (TB).",
                    schedule: .atBirth, status: .completed, notes: "Given at hospital", givenDate: Date(), photoData: nil),
            
            Vaccine(name: "OPV 0",
                    fullName: "Oral Polio Vaccine",
                    longDescription: "The 'zero' dose, given at birth to protect against Polio.",
                    schedule: .atBirth, status: .completed, notes: "Given at hospital", givenDate: Date(), photoData: nil),
            
            // --- 6 Weeks ---
            Vaccine(name: "DTwP 1",
                    fullName: "Diphtheria, Tetanus, Pertussis",
                    longDescription: "First dose of Diphtheria, Tetanus & Pertussis. Given at 6 weeks.",
                    schedule: .sixWeeks, status: .completed, notes: "Given on 1/1/25", givenDate: Date(), photoData: nil),
            
            Vaccine(name: "Hep-B 2",
                    fullName: "Hepatitis B Vaccine",
                    longDescription: "Second dose to protect against Hepatitis B. Given at 6 weeks.",
                    schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "IPV 1",
                    fullName: "Inactivated Polio Vaccine",
                    longDescription: "First dose of Inactivated Polio Vaccine. Given at 6 weeks.",
                    schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Rota Virus 1",
                    fullName: "Rotavirus Vaccine",
                    longDescription: "First dose (oral) to protect against Rotavirus. Given at 6 weeks.",
                    schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "PCV 1",
                    fullName: "Pneumococcal Conjugate Vaccine",
                    longDescription: "First dose for Pneumococcal disease. Given at 6 weeks.",
                    schedule: .sixWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 10 Weeks ---
            Vaccine(name: "DTwP 2",
                    fullName: "Diphtheria, Tetanus, Pertussis",
                    longDescription: "Second dose of Diphtheria, Tetanus & Pertussis. Given at 10 weeks.",
                    schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "IPV 2",
                    fullName: "Inactivated Polio Vaccine",
                    longDescription: "Second dose of Inactivated Polio Vaccine. Given at 10 weeks.",
                    schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hib 2",
                    fullName: "Haemophilus Influenzae Type B",
                    longDescription: "Second dose for Haemophilus Influenzae Type B. Given at 10 weeks.",
                    schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Rota Virus 2",
                    fullName: "Rotavirus Vaccine",
                    longDescription: "Second dose (oral) for Rotavirus. Given at 10 weeks.",
                    schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "PCV 2",
                    fullName: "Pneumococcal Conjugate Vaccine",
                    longDescription: "Second dose for Pneumococcal disease. Given at 10 weeks.",
                    schedule: .tenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 14 Weeks ---
            Vaccine(name: "DTwP 3",
                    fullName: "Diphtheria, Tetanus, Pertussis",
                    longDescription: "Third dose of Diphtheria, Tetanus & Pertussis. Given at 14 weeks.",
                    schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "IPV 3",
                    fullName: "Inactivated Polio Vaccine",
                    longDescription: "Third dose of Inactivated Polio Vaccine. Given at 14 weeks.",
                    schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hib 3",
                    fullName: "Haemophilus Influenzae Type B",
                    longDescription: "Third dose for Haemophilus Influenzae Type B. Given at 14 weeks.",
                    schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Rota Virus 3",
                    fullName: "Rotavirus Vaccine",
                    longDescription: "Third dose (oral) for Rotavirus. Given at 14 weeks.",
                    schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "PCV 3",
                    fullName: "Pneumococcal Conjugate Vaccine",
                    longDescription: "Third dose for Pneumococcal disease. Given at 14 weeks.",
                    schedule: .fourteenWeeks, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 6 Months ---
            Vaccine(name: "OPV 1",
                    fullName: "Oral Polio Vaccine",
                    longDescription: "First booster dose for Polio. Given at 6 months.",
                    schedule: .sixMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hep-B 3",
                    fullName: "Hepatitis B Vaccine",
                    longDescription: "Third dose for Hepatitis B. Given at 6 months.",
                    schedule: .sixMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 9 Months ---
            Vaccine(name: "OPV 2",
                    fullName: "Oral Polio Vaccine",
                    longDescription: "Second booster dose for Polio. Given at 9 months.",
                    schedule: .nineMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "MMR-1",
                    fullName: "Mumps, Measles, Rubella",
                    longDescription: "First dose for Mumps, Measles, and Rubella. Given at 9 months.",
                    schedule: .nineMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 12 Months ---
            Vaccine(name: "Typhoid",
                    fullName: "Typhoid Conjugate Vaccine",
                    longDescription: "Protects against Typhoid fever. Given at 12 months.",
                    schedule: .twelveMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hep-A 1",
                    fullName: "Hepatitis A Vaccine",
                    longDescription: "First dose to protect against Hepatitis A. Given at 12 months.",
                    schedule: .twelveMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 15 Months ---
            Vaccine(name: "MMR 2",
                    fullName: "Mumps, Measles, Rubella",
                    longDescription: "Second dose for Mumps, Measles & Rubella. Given at 15 months.",
                    schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Varicella 1",
                    fullName: "Chickenpox Vaccine",
                    longDescription: "First dose to protect against Chickenpox. Given at 15 months.",
                    schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "PCV Booster",
                    fullName: "Pneumococcal Conjugate Vaccine",
                    longDescription: "Booster for Pneumococcal disease. Given at 15 months.",
                    schedule: .fifteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 18 Months ---
            Vaccine(name: "DTaP B1 / DTwP B1",
                    fullName: "Diphtheria, Tetanus, Pertussis",
                    longDescription: "First booster for Diphtheria, Tetanus & Pertussis. Given at 18 months.",
                    schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "OPV 3 / IPV B1",
                    fullName: "Polio Vaccine",
                    longDescription: "Booster dose for Polio. Given at 18 months.",
                    schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hib B1",
                    fullName: "Haemophilus Influenzae Type B",
                    longDescription: "Booster for Haemophilus Influenzae Type B. Given at 18 months.",
                    schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Hep-A 2",
                    fullName: "Hepatitis A Vaccine",
                    longDescription: "Second dose to protect against Hepatitis A. Given at 18 months.",
                    schedule: .eighteenMonths, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 2 Years ---
            Vaccine(name: "Typhoid Booster",
                    fullName: "Typhoid Vaccine",
                    longDescription: "Booster dose for Typhoid fever. Given at 2 years.",
                    schedule: .twoYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            // --- 4-6 Years ---
            Vaccine(name: "DTaP B2 / DTwP B2",
                    fullName: "Diphtheria, Tetanus, Pertussis",
                    longDescription: "Second booster for Diphtheria, Tetanus & Pertussis. Given between 4-6 years.",
                    schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "OPV 3",
                    fullName: "Oral Polio Vaccine",
                    longDescription: "Third booster dose for Polio. Given between 4-6 years.",
                    schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "Varicella 2",
                    fullName: "Chickenpox Vaccine",
                    longDescription: "Second dose to protect against Chickenpox. Given between 4-6 years.",
                    schedule: .fourToSixYears, status: .due, notes: nil, givenDate: nil, photoData: nil),

            // --- 10-12 Years ---
            Vaccine(name: "Tdap / Td",
                    fullName: "Tetanus, Diphtheria, Pertussis",
                    longDescription: "Booster for Tetanus, Diphtheria & Pertussis. Given between 10-12 years.",
                    schedule: .tenToTwelveYears, status: .due, notes: nil, givenDate: nil, photoData: nil),
            
            Vaccine(name: "HPV",
                    fullName: "Human Papillomavirus Vaccine",
                    longDescription: "Protects against Human Papillomavirus. Given between 10-12 years.",
                    schedule: .tenToTwelveYears, status: .due, notes: nil, givenDate: nil, photoData: nil)
        ]
        filterVaccines()
    }
    
    
    func didUpdateVaccine(_ updatedVaccine: Vaccine) {
        if let index = masterVaccineList.firstIndex(where: { $0.name == updatedVaccine.name }) {
            masterVaccineList[index] = updatedVaccine
            filterVaccines()
        } else {
            print("Error: Could not find matching vaccine to update.")
        }
    }
}


// MARK: - Table View Extensions

extension vaccinationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && !dueVaccines.isEmpty {
            return 20
        } else if section == 1 && !completedVaccines.isEmpty {
            return 20
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = UIColor.label
        
        if section == 0 && !dueVaccines.isEmpty {
            titleLabel.text = "Due"
        } else if section == 1 && !completedVaccines.isEmpty {
            titleLabel.text = "Completed"
        } else {
            return nil
        }
        
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dueVaccines.count
        } else {
            return completedVaccines.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as? VaccineCell else {
            fatalError("Could not dequeue VaccineCell")
        }
        
        let vaccine: Vaccine
        if indexPath.section == 0 {
            vaccine = dueVaccines[indexPath.row]
        } else {
            vaccine = completedVaccines[indexPath.row]
        }
        
        cell.configure(with: vaccine)
        return cell
    }
}

extension vaccinationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedVaccine: Vaccine
        if indexPath.section == 0 {
            selectedVaccine = dueVaccines[indexPath.row]
        } else {
            selectedVaccine = completedVaccines[indexPath.row]
        }
        
        let detailVC = EditVaccinationLogViewController(nibName: "EditVaccinationLogViewController", bundle: nil)
        
        detailVC.vaccine = selectedVaccine
        
        detailVC.delegate = self
        
        detailVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
