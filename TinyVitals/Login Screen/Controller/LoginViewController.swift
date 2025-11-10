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
//        let tabBarVC = tabBarStoryBoardViewController(nibName: "tabBarStoryBoardViewController", bundle: nil)
//                navigationController?.pushViewController(tabBarVC, animated: true)
            // 1. Authenticate user (e.g., call API, check credentials)
            // ...

            // 2. ONLY proceed if sign-in is successful:

            // a. Instantiate the Tab Bar Controller using its Storyboard ID
            let storyboard = UIStoryboard(name: "tabBarStoryBoard", bundle: nil)
            guard let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarStoryBoardViewController") as? UITabBarController else {
                fatalError("Could not instantiate tabBarStoryBoardViewController from storyboard.")
            }

            // b. Get the current key window
            // This is the standard modern way to access the window in SceneDelegate-based apps
            guard let window = view.window else { return }

            // c. Set the new root view controller with an optional animation
            window.rootViewController = mainTabBarController
            
            // Add a transition animation for a smoother look
            UIView.transition(with: window,
                              duration: 0.5,
                              options: .transitionFlipFromLeft, // Choose your favorite animation!
                              animations: nil,
                              completion: nil)
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
