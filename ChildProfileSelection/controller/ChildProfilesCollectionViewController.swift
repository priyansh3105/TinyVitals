//
//  ChildProfilesCollectionViewController.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

struct ChildProfile {
    var name: String
    var imageName: String
}

class ChildProfilesCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    // 🧩 Start with one empty placeholder profile
    var profiles: [ChildProfile] = [
        ChildProfile(name: "", imageName: "")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register your custom cell XIB
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

    // ✅ Show Add Profile screen
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let addVC = AddChildProfileViewController(nibName: "AddChildProfileViewController", bundle: nil)
        addVC.delegate = self
        present(addVC, animated: true)
    }
}

// MARK: - Collection View Setup
extension ChildProfilesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCell", for: indexPath) as! ChildProfileCell
        let model = profiles[indexPath.item]

        // If profile is empty, show placeholder
        if model.name.isEmpty {
            cell.nameLabel.text = ""
            cell.childImageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
        } else {
            cell.nameLabel.text = model.name
            cell.childImageView.image = UIImage(named: model.imageName)
        }

        return cell
    }

    // ✅ Layout logic (center first card / 2x2 grid later)
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
}

// MARK: - Delegate from AddChildProfileViewController
extension ChildProfilesCollectionViewController: AddChildProfileDelegate {
    func didAddChildProfile(_ profile: ChildProfile) {
        // If first card is empty, replace it
        if profiles.count == 1 && profiles[0].name.isEmpty {
            profiles[0] = profile
        } else {
            profiles.append(profile)
        }
        collectionView.reloadData()
    }
}


