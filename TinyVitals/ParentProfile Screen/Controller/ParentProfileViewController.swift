//
//  ParentProfileViewController.swift
//  TinyVitals
//
//  Created by user45 on 09/11/25.
//

import UIKit

class ParentProfileViewController: UIViewController {

    @IBOutlet weak var genderButton: UIButton!
    
    @IBOutlet weak var parentRelationButton: UIButton!
    
    @IBOutlet weak var childSelectionButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let male = UIAction(title: "Male") { _ in
                    self.genderButton.setTitle("Male", for: .normal)
                }
                let female = UIAction(title: "Female") { _ in
                    self.genderButton.setTitle("Female", for: .normal)
                }
                let others = UIAction(title: "Others") { _ in
                    self.genderButton.setTitle("Others", for: .normal)
                }

                let genderMenu = UIMenu(title: "Select Gender", options: .displayInline, children: [male, female, others])
                genderButton.menu = genderMenu
                genderButton.showsMenuAsPrimaryAction = true
                genderButton.changesSelectionAsPrimaryAction = true
                genderButton.preferredMenuElementOrder = .fixed


                // ========================
                // MARK: - Parent Relation Menu
                // ========================
                let mother = UIAction(title: "Mother") { _ in
                    self.parentRelationButton.setTitle("Mother", for: .normal)
                }
                let father = UIAction(title: "Father") { _ in
                    self.parentRelationButton.setTitle("Father", for: .normal)
                }
                let othersRelation = UIAction(title: "Others") { _ in
                    self.parentRelationButton.setTitle("Others", for: .normal)
                }

                let relationMenu = UIMenu(title: "Select Relation", options: .displayInline, children: [mother, father, othersRelation])
                parentRelationButton.menu = relationMenu
                parentRelationButton.showsMenuAsPrimaryAction = true
                parentRelationButton.changesSelectionAsPrimaryAction = true
                parentRelationButton.preferredMenuElementOrder = .fixed


                // ========================
                // MARK: - Child Selection Menu
                // ========================
                let child1 = UIAction(title: "Child-1") { _ in
                    self.childSelectionButton.setTitle("Child-1", for: .normal)
                }
                let child2 = UIAction(title: "Child-2") { _ in
                    self.childSelectionButton.setTitle("Child-2", for: .normal)
                }
                let child3 = UIAction(title: "Child-3") { _ in
                    self.childSelectionButton.setTitle("Child-3", for: .normal)
                }

                let childMenu = UIMenu(title: "Select Child", options: .displayInline, children: [child1, child2, child3])
                childSelectionButton.menu = childMenu
                childSelectionButton.showsMenuAsPrimaryAction = true
                childSelectionButton.changesSelectionAsPrimaryAction = true
                childSelectionButton.preferredMenuElementOrder = .fixed

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
