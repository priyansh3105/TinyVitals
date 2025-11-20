//
//  AddSectionViewController.swift
//  TinyVitals
//
//  Created by admin0 on 12/11/25.
//

import UIKit

protocol AddSectionDelegate: AnyObject {
    func didAddSection(name: String)
    func didEditSection(oldName: String, newName: String)
}

class AddSectionViewController: UIViewController {

    weak var delegate: AddSectionDelegate?
    @IBOutlet weak var nameTextField: UITextField!
    
    var currentSectionName: String?
    var isEditingMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = isEditingMode ? "Edit Section" : "Add Section"
        
        if isEditingMode, let name = currentSectionName {
            nameTextField.text = name
        }
        let buttonTitle = isEditingMode ? "Save" : "Add"
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: buttonTitle,
                    style: .done,
                    target: self,
                    action: #selector(finalAddButtonTapped)
                )
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(cancelButtonTapped))
    }
    
    @objc func finalAddButtonTapped(_ sender: Any) {
        guard let newName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newName.isEmpty else {
            showConfirmationMessage(title: "Required", message: "Please enter a name for the new section.")
            return
        }

        if isEditingMode, let oldName = currentSectionName {
            delegate?.didEditSection(oldName: oldName, newName: newName)
        } else {
            delegate?.didAddSection(name: newName)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
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
