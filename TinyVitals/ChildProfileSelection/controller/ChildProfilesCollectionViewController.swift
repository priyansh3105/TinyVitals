//
//  ChildProfilesCollectionViewController.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//


import UIKit

class ChildProfilesCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    var profiles: [ChildDetails] = [
        ChildDetails(name: "", dob: "", gender: "", image: nil)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ChildProfileCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ChildProfileCell")

        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }

        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.clipsToBounds = true
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let addVC = AddChildProfileViewController(nibName: "AddChildProfileViewController", bundle: nil)
        addVC.delegate = self
        present(addVC, animated: true)
    }
}

// MARK: - Collection View
extension ChildProfilesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChildProfileCellDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCell", for: indexPath) as! ChildProfileCell
        let model = profiles[indexPath.item]

        if model.name.isEmpty {
            cell.nameLabel.text = ""
//            cell.childImageView.image = UIImage(named: "ChildPhoto")
        } else {
            cell.nameLabel.text = model.name
            cell.childImageView.image = model.image ?? UIImage(named: "ChildPhoto")
            
        }

        // ✅ Assign delegate to handle image tap
        cell.delegate = self

        return cell
    }

    // Layout logic
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let collectionWidth = collectionView.bounds.width
        let spacing: CGFloat = 20
        let sideInset: CGFloat = 20

        if profiles.count == 1 {
            let cellWidth = collectionWidth * 0.6
            let xInset = (collectionWidth - cellWidth) / 2
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 20, left: xInset, bottom: 20, right: xInset)
            }
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 20, left: sideInset, bottom: 20, right: sideInset)
            }
            let totalSpacing = (2 - 1) * spacing + sideInset * 2
            let cellWidth = (collectionWidth - totalSpacing) / 2
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }

    // MARK: - ChildProfileCellDelegate
    func didTapChildImage(in cell: ChildProfileCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let selectedChild = profiles[indexPath.item]

        // Navigate to HomeViewController
//        if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
//            homeVC.selectedChild = selectedChild
//            navigationController?.pushViewController(homeVC, animated: true)
//        }
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
}

// MARK: - AddChildProfileDelegate
extension ChildProfilesCollectionViewController: AddChildProfileDelegate {
    func didAddChildProfile(_ profile: ChildDetails) {
        if profiles.count == 1 && profiles[0].name.isEmpty {
            profiles[0] = profile
        } else {
            profiles.append(profile)
        }
        collectionView.reloadData()
    }
}
