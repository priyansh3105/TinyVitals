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
        // 1. Validate the text field (assuming nameTextField is connected)
        guard let sectionName = nameTextField.text, !sectionName.isEmpty else {
            // Show an alert if the name is empty
            return
        }
        
        // 2. Delegate the new section name back to the recordViewController
        delegate?.didAddSection(name: sectionName)
        
        // 3. Dismiss the modal screen
        dismiss(animated: true, completion: nil)
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
