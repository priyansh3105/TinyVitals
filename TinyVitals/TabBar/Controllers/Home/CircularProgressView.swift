//
//  profileCompletionStatus.swift
//  TinyVitals
//

import UIKit
import QuartzCore
@IBDesignable
class CircularProgressView: UIView {
    @IBInspectable var ringColor: UIColor = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0)
    @IBInspectable var ringWidth: CGFloat = 20.0
    @IBInspectable var trackColor: UIColor = UIColor(white: 0.95, alpha: 1.0)
    private let progressLabel = UILabel()
    var progress: CGFloat = 0.0 {
        didSet {
            let percentage = Int(progress * 100)
            progressLabel.text = "\(percentage)%"
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            progressLayer.strokeEnd = progress
            CATransaction.commit()
        }
    }
    
    private var trackLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupProgressLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupProgressLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - ringWidth / 2
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: -(.pi / 2),
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = ringWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        progressLayer.strokeColor = ringColor.cgColor
        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }

    private func setupProgressLabel() {
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        progressLabel.textColor = .black
        progressLabel.text = "0%"
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
