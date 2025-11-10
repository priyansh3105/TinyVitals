//
//  profileCompletionStatus.swift
//  TinyVitals
//

import UIKit
import QuartzCore // Import QuartzCore for CAShapeLayer

@IBDesignable // Allows you to see the design in Storyboard
class CircularProgressView: UIView {
    
    // Customization properties
    @IBInspectable var ringColor: UIColor = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0)
    @IBInspectable var ringWidth: CGFloat = 20.0
    @IBInspectable var trackColor: UIColor = UIColor(white: 0.95, alpha: 1.0)
    
    // NEW: Label for displaying the percentage in the middle
    private let progressLabel = UILabel()
    
    // The property to set the completion percentage (0.0 to 1.0)
    var progress: CGFloat = 0.0 {
        didSet {
            // Update the label text with the new percentage
            let percentage = Int(progress * 100)
            progressLabel.text = "\(percentage)%"
            
            // Apply animation for a smooth filling effect
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            progressLayer.strokeEnd = progress
            CATransaction.commit()
        }
    }
    
    private var trackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    
    // --- Initialization and Setup ---
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupProgressLabel() // NEW: Call label setup
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupProgressLabel() // NEW: Call label setup
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the path is correct after Auto Layout calculates the frame
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - ringWidth / 2
        
        // Define the circular path starting at 12 o'clock (-90 degrees)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: -(.pi / 2),
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    private func setupView() {
        self.backgroundColor = .clear // Ensure the view background is clear

        // Setup Track Layer (The empty background ring)
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = ringWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // Setup Progress Layer (The filling ring)
        progressLayer.strokeColor = ringColor.cgColor
        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }
    
    // --- NEW: Percentage Label Setup Function ---
    private func setupProgressLabel() {
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold) // Appropriate size for percentage
        progressLabel.textColor = .black
        progressLabel.text = "0%" // Initial value
        
        addSubview(progressLabel)
        
        // Center the label horizontally and vertically within the custom view
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
