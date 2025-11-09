//
//  SignupViewController.swift
//  TinyVitals
//
//  Created by user45 on 08/11/25.
//

import UIKit

class SignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func SignUpBottontapped(_ sender: UIButton) {
        let tabBarVC = homeViewController(nibName: "homeViewController", bundle: nil)
        self.navigationController?.pushViewController(tabBarVC, animated: true)
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
