//
//  AddSectionViewController.swift
//  TinyVitals
//
//  Created by admin0 on 12/11/25.
//

import UIKit

protocol AddSectionDelegate: AnyObject {
    // This method will be called when the user hits 'Add' on the modal screen
    func didAddSection(name: String)
    func didEditSection(oldName: String, newName: String) // <<< NEW
}

class AddSectionViewController: UIViewController {

    weak var delegate: AddSectionDelegate?
    @IBOutlet weak var nameTextField: UITextField!
    
    var currentSectionName: String? // Holds the name if in Edit Mode
    var isEditingMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = isEditingMode ? "Edit Section" : "Add Section"
        
        if isEditingMode, let name = currentSectionName {
            nameTextField.text = name
        }
        // --- Setup Navigation Bar Buttons ---
        // 1. ADD Button (The Primary Action on the Right)
        // The action will call the existing finalAddButtonTapped logic.
        let buttonTitle = isEditingMode ? "Save" : "Add"
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: buttonTitle,
                    style: .done,
                    target: self,
                    action: #selector(finalAddButtonTapped) // Renamed for generic action
                )
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(cancelButtonTapped))
    }
    
    @objc func finalAddButtonTapped(_ sender: Any) {
        // 1. Validate input
        guard let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else {
            showConfirmationMessage(title: "Required", message: "Please enter a name for the new section.")
            return
        }

        if isEditingMode, let oldName = currentSectionName {
            // 2. EDIT MODE: Delegate the change
            delegate?.didEditSection(oldName: oldName, newName: newName)
        } else {
            // 2. ADD MODE: Delegate the new name
            delegate?.didAddSection(name: newName)
        }
        // 3. Dismiss the modal screen
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        // Simply dismiss the modal presentation
        dismiss(animated: true, completion: nil)
    }
    
    func showConfirmationMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
