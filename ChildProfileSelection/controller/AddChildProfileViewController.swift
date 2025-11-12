//
//  AddChildProfileViewController.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

protocol AddChildProfileDelegate: AnyObject {
    func didAddChildProfile(_ profile: ChildProfile)
}

class AddChildProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    weak var delegate: AddChildProfileDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard
            let name = nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty,
            let dob = dateOfBirth.text, !dob.trimmingCharacters(in: .whitespaces).isEmpty,
            let gender = genderTextField.text, !gender.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            showAlert(title: "Missing Information", message: "Please fill in all fields before submitting.")
            return
        }

        // Create a new profile (you can later add image picker functionality)
        let newProfile = ChildProfile(name: name, imageName: "Aditya")

        // Pass the data back to the main screen
        delegate?.didAddChildProfile(newProfile)

        // Dismiss this view controller
        dismiss(animated: true)
    }

    // MARK: - Helper Alert Function
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
