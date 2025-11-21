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
//        let titleLabel = UILabel()
//        titleLabel.text = "Home"
//        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
//        titleLabel.textColor = .black
//        titleLabel.sizeToFit()
//        let leftItem = UIBarButtonItem(customView: titleLabel)
//        navigationItem.leftBarButtonItem = leftItem
        
        setupGradient()
        childProfileImageView.layer.borderColor = UIColor.systemBlue.cgColor
        childProfileCompletionStatus.progress = 0.6
    }
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = homeSuperView.bounds
        homeSuperView.layer.insertSublayer(gradientLayer, at: 0)
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
