//
//  ChildProfilesCollectionViewController.swift
//  TinyVitals
//
//  Created by user45 on 12/11/25.
//

import UIKit

struct ChildProfile {
    let name: String
    let imageName: String
}

class ChildProfilesCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    var profiles: [ChildProfile] = [
        ChildProfile(name: "Charlie", imageName: "Charlie")
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

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let newChild = ChildProfile(name: "Child-\(profiles.count + 1)", imageName: "Charlie")
        profiles.append(newChild)
        collectionView.reloadData()
    }
}

extension ChildProfilesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCell", for: indexPath) as! ChildProfileCell
        let model = profiles[indexPath.item]
        cell.nameLabel.text = model.name
        cell.childImageView.image = UIImage(named: model.imageName)
        return cell
    }

    // ✅ Dynamic sizing logic
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let collectionWidth = collectionView.bounds.width
        let spacing: CGFloat = 20
        let sideInset: CGFloat = 20

        if profiles.count == 1 {
            // 💡 Center the only cell horizontally
            let cellWidth = collectionWidth * 0.6
            let xInset = (collectionWidth - cellWidth) / 2
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 20, left: xInset, bottom: 20, right: xInset)
            }
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            // 💡 Arrange 2 cells per row (like before)
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 20, left: sideInset, bottom: 20, right: sideInset)
            }
            let totalSpacing = (2 - 1) * spacing + sideInset * 2
            let cellWidth = (collectionWidth - totalSpacing) / 2
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
}
