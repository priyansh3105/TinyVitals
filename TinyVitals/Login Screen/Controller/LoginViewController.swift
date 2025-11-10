//
//  LoginViewController.swift
//  TinyVitals
//
//  Created by user45 on 08/11/25.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUpButtontapped(_ sender: UIButton) {
        let signUpVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
                navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let tabBarVC = tabBarStoryBoardViewController(nibName: "tabBarStoryBoardViewController", bundle: nil)
                navigationController?.pushViewController(tabBarVC, animated: true)
    }

     @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
         let forgotPasswordVC = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
                 navigationController?.pushViewController(forgotPasswordVC, animated: true)
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
