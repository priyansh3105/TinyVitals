//
//  AddChildProfileViewController.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

protocol AddChildProfileDelegate: AnyObject {
    func didAddChildProfile(_ profile: ChildDetails)
}

class AddChildProfileViewController: UIViewController {
    
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Male", "Female", "Other"]
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateOfBirth: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var childImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    private let datePicker = UIDatePicker()
    weak var delegate: AddChildProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupGenderPicker()
        setupImageViewTap()
    }
    
    private func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneGenderSelection))
        toolbar.setItems([doneButton], animated: true)
        genderTextField.inputAccessoryView = toolbar
    }
    
    @objc private func doneGenderSelection() {
        view.endEditing(true)
    }
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "en_GB")
        dateOfBirth.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        dateOfBirth.inputAccessoryView = toolbar
    }
    
    @objc private func donePressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateOfBirth.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    private func setupImageViewTap() {
        childImageView.isUserInteractionEnabled = true
        childImageView.contentMode = .scaleAspectFill
        childImageView.layer.cornerRadius = childImageView.bounds.height / 2
        childImageView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        childImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
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
        
        let selectedImage = childImageView.image
        let newProfile = ChildDetails(name: name, dob: dob, gender: gender, image: selectedImage)
        
        delegate?.didAddChildProfile(newProfile)
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddChildProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genderOptions.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        genderOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderOptions[row]
    }
}

extension AddChildProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            childImageView.image = selectedImage
        }
        dismiss(animated: true)
    }
}
