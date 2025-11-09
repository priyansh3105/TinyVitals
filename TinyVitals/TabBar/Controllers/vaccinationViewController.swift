//
//  vaccinationViewController.swift
//  TinyVitals
//
//  Created by user70 on 06/11/25.
//

import UIKit

class vaccinationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var arr: [String] = ["All","At Birth","6 Weeks","10 Weeks","14 Weeks","Month 9","Month 12","Month 15","Month 16","Month 18","Month 23","Year 5","Year 9","Year 10"]
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCollecctionViewCellCollectionViewCell
        
        cell.myLabel.text = arr[indexPath.row]
        return cell
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
