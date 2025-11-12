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
}

class AddSectionViewController: UIViewController {

    weak var delegate: AddSectionDelegate?
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finalAddButtonTapped(_ sender: Any) {
        // 1. Validate input
        guard let sectionName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sectionName.isEmpty else {
            showConfirmationMessage(title: "Required", message: "Please enter a name for the new section.")
            return
        }
        
        // 2. Delegate the new name back to the recordViewController
        // This calls the didAddSection(name:) method in the main view controller.
        delegate?.didAddSection(name: sectionName)
        
        // 3. Dismiss the modal screen (The main VC will refresh the tags after this returns)
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
