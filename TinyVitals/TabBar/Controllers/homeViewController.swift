//
//  homeViewController.swift
//  TinyVitals
//
//  Created by admin0 on 08/11/25.
//

import UIKit

class homeViewController: UIViewController {

    @IBOutlet var homeSuperView: UIView!
    
    @IBOutlet weak var childProfileImageView: UIImageView!
    
    @IBOutlet weak var childProfileCompletionStatus: CircularProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        childProfileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        childProfileCompletionStatus.progress = 0.6
        // Do any additional setup after loading the view.
    }
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        
        // Top Color: Light Blue (#82C3FF) - Based on your color codes
        // RGB: 130/255, 195/255, 255/255
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        
        // Bottom Color: White (#FFFFFF) - Based on your color codes
        let colorBottom = UIColor.white.cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        
        // Set for a Vertical Gradient (Top to Bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Center Top
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Center Bottom
        
        // Apply to the view
        gradientLayer.frame = homeSuperView.bounds
        homeSuperView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func parentProfileButtonTapped(_ sender: UIBarButtonItem) {
        let parentProfileVC = ParentProfileViewController(nibName: "ParentProfileViewController", bundle: nil)
                navigationController?.pushViewController(parentProfileVC, animated: true)
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
