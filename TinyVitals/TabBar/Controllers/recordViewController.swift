//
//  recordViewController.swift
//  TinyVitals
//
//  Created by admin0 on 08/11/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class recordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRecordDelegate, UISearchBarDelegate, AddSectionDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var recordSuperView: UIView!
    @IBOutlet weak var recordTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
    
    var records: [Record] = []
    var filteredRecords: [Record] = [] // <<< NEW: Holds results shown in the table
    var isSearching: Bool = false      // <<< NEW: Flag to track search state
    var allSections: [String] = ["All", "Prescription", "+"] // Initial and user-added sections
    var selectedSection: String = "All"
    
    @IBOutlet weak var sectionCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        sectionCollectionView.register(UINib(nibName: "SectionTagCell", bundle: nil),forCellWithReuseIdentifier: "SectionTagCell")
        sectionCollectionView.dataSource = self // <<< NEW LINE
        sectionCollectionView.delegate = self
        // Set up the Collection View Layout (essential for sizing)
        if let layout = sectionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // <<< CRITICAL for pill shape
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8 // Spacing between cells
        }
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        self.filteredRecords = self.records
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = .white
            searchField.layer.borderWidth = 1.0
            searchField.layer.borderColor = UIColor.systemGray4.cgColor
            searchField.layer.cornerRadius = 10.0 // Ensure roundness
            searchField.layer.masksToBounds = true // Ensure clipping for the border
        }
        
        recordTableView.dataSource = self
        recordTableView.delegate = self
        recordTableView.rowHeight = 120
        recordTableView.tableFooterView = UIView()
        
        loadSampleData()
    }
    
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 0.51, green: 0.76, blue: 1.00, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = recordSuperView.bounds
        recordSuperView.layer.insertSublayer(gradientLayer, at: 0)
    }
    // 💡 IMPORTANT: This method must be connected to your physical "+" button in the Storyboard/XIB.
    @IBAction func addSectionButtonTapped(_ sender: Any) {
        let addSectionVC = AddSectionViewController(nibName: "AddSectionViewController", bundle: nil)
        addSectionVC.delegate = self // Use a new delegate (AddSectionDelegate)
        // Present modally
        present(UINavigationController(rootViewController: addSectionVC), animated: true)
    }
    
    @IBAction func addDocumentTapped(_ sender: Any) {
        let addVC = AddRecordViewController(nibName: "AddRecordViewController", bundle: nil)
        addVC.delegate = self
        
        // CRITICAL: Passes the name of the currently selected section (e.g., "Prescription")
        addVC.targetSectionName = self.selectedSection
        
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    func didAddSection(name: String) {
        // 1. Add the new section name to the master list
        allSections.append(name)
        
        // 2. Automatically select the newly created section
        selectedSection = name
        
        // 3. Reload the UI to show the new tag
        sectionCollectionView.reloadData() // <<< Ensure this outlet name is correct
        filterRecords() // <<< This function updates the table view based on selectedSection
        
        // NOTE: The AddSectionVC handles its own dismissal now.
    }
    
    func didAddRecord(_ record: Record) {
        // 💡 HIG: Use insertRows for better animation/performance
        records.insert(record, at: 0)
        recordTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // We only need this if automaticSize isn't working perfectly,
        // but it ensures minimal height and maximal stability.
        
        // Calculate the width needed for the text (important for the 'pill' look)
        let sectionName = allSections[indexPath.item]
        let isAddButton = (sectionName == "+")
        
        // Calculate width based on text
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let textWidth = sectionName.size(withAttributes: [.font: font]).width
        
        // Add margin, padding, and size for the optional plus button
        var totalWidth = textWidth + 20 // 10pt padding on each side
        if isAddButton {
            totalWidth += 20 // Extra space for the plus icon
        }
        
        // Set a fixed height (e.g., 32 or 36) and the calculated width
        return CGSize(width: totalWidth, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allSections.count
    }

    // 2. Configure the SectionTagCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionTagCell", for: indexPath) as? SectionTagCell else {
            fatalError("Unable to dequeue SectionTagCell")
        }
        
        let sectionName = allSections[indexPath.item]
        
        // Determine the state of the cell
        let isSelected = (sectionName == selectedSection)
        let isAddButton = (indexPath.item == allSections.count - 1 && sectionName == "+") // Check if it's the custom "+" button cell
        
        cell.configure(with: sectionName, isAddButton: isAddButton, isSelected: isSelected)
        
        return cell
    }

    // MARK: - UICollectionViewDelegate (Handling Taps)

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedName = allSections[indexPath.item]
        
        if selectedName == "+" {
            // 1. If user taps the '+' button, navigate to the Add Section screen
            addSectionButtonTapped(collectionView) // Reuse your existing action method
        } else {
            // 2. If user taps a filter tag, update the selection state
            selectedSection = selectedName
            collectionView.reloadData() // Update the tags visual state
            filterRecords()             // Refresh the table view data
        }
    }
    
    func showConfirmationMessage(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func addRecord(_ record: Record) {
        // This function is now fully implemented inside didAddRecord to use insertRows
        records.insert(record, at: 0)
        recordTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func loadSampleData() {
        let pdfURL = Bundle.main.url(forResource: "SamplePDF", withExtension: "pdf") ?? URL(fileURLWithPath: "/simulated/missing/path.pdf")
        let imageURL = Bundle.main.url(forResource: "SampleImage", withExtension: "jpg") ?? URL(fileURLWithPath: "/simulated/missing/path.jpg")
          
        // FIX 2: Add the sectionName property to every record
        records = [
            Record(fileName: "CT-Chest Scan", source: "Dr. Raj Kumar's Clinic", addedDate: Date().addingTimeInterval(-100000), type: "PDF", fileURL: pdfURL, sectionName: "Prescription"), // <<< Added sectionName
            Record(fileName: "Blood Test Report (CBC)", source: "Apollo Diagnostics", addedDate: Date().addingTimeInterval(-200000), type: "PDF", fileURL: pdfURL, sectionName: "Prescription"), // <<< Added sectionName
            Record(fileName: "X-Ray - Left Leg", source: "MedLife Imaging Center", addedDate: Date().addingTimeInterval(-300000), type: "Image", fileURL: imageURL, sectionName: "X-Ray"), // <<< Added sectionName
        ]
    }
    
    // MARK: - 2. Thumbnail Generation Logic
    
    func generateThumbnailFromImage(url: URL) -> UIImage? {
        
        // 1. Load the full image data
        guard let data = try? Data(contentsOf: url),
              let fullImage = UIImage(data: data) else { return nil }
        
        let targetSize = CGSize(width: 50, height: 50)
        let imageSize = fullImage.size
        
        // 2. Calculate the scaling factor to fit the image into the target size (100x100)
        let widthRatio = targetSize.width / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        // 3. Determine the final scaled size
        let scaledImageSize = CGSize(
            width: imageSize.width * scaleFactor,
            height: imageSize.height * scaleFactor
        )
        
        // 4. Center the scaled image within the target 100x100 canvas
        let origin = CGPoint(
            x: (targetSize.width - scaledImageSize.width) / 2.0,
            y: (targetSize.height - scaledImageSize.height) / 2.0
        )
        
        // 5. Use UIGraphicsImageRenderer to generate the scaled thumbnail
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let thumbnail = renderer.image { _ in
            // Fill background with white (optional, but good for PDFs/Images with transparency)
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: targetSize))
            
            // Draw the image at its calculated scaled and centered position
            fullImage.draw(in: CGRect(origin: origin, size: scaledImageSize))
        }
        
        return thumbnail
    }

    func generateThumbnailFromPDF(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL),
              let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let targetSize = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let thumbnail = renderer.image { context in
            
            // Fill the background white
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // --- CORRECTED SCALING AND TRANSFORMATION ---
            
            // 1. Calculate scale factor to fit the page into the targetSize
            let scaleX = targetSize.width / pageRect.width
            let scaleY = targetSize.height / pageRect.height
            let scale = min(scaleX, scaleY)
            
            // 2. Calculate the offset needed to center the page
            let scaledWidth = pageRect.width * scale
            let scaledHeight = pageRect.height * scale
            let offsetX = (targetSize.width - scaledWidth) / 2
            let offsetY = (targetSize.height - scaledHeight) / 2
            
            // 3. Apply the transformations:
            // Translate to the center of the canvas and scale appropriately
            context.cgContext.translateBy(x: offsetX, y: offsetY + scaledHeight)
            context.cgContext.scaleBy(x: scale, y: -scale)
            
            // Translate to align the PDF content (accounts for original PDF offset)
            context.cgContext.translateBy(x: -pageRect.origin.x, y: -pageRect.origin.y)
            
            // 4. Draw the PDF page
            context.cgContext.drawPDFPage(page)
        }
        
        return thumbnail
    }
    
    // MARK: - UITableViewDataSource & Delegate Implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredRecords.count : records.count
    }
    
    // MARK: - 3. Updated cellForRowAt with Background Threading
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordListCell", for: indexPath) as? RecordListCell else {
            fatalError("The dequeued cell is not an instance of RecordListCell.")
        }
        
        let record = isSearching ? filteredRecords[indexPath.row] : records[indexPath.row]
        cell.configure(with: record)
        cell.setThumbnail(image: nil) // Reset thumbnail immediately

        // HIG: Start thumbnail generation on a background thread
        if let fileURL = record.fileURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail: UIImage? = record.type.uppercased() == "PDF" ?
                                          self.generateThumbnailFromPDF(url: fileURL) :
                                          self.generateThumbnailFromImage(url: fileURL)
                
                DispatchQueue.main.async {
                    if tableView.indexPath(for: cell) == indexPath {
                        cell.setThumbnail(image: thumbnail)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = records[indexPath.row]
        print("Selected record: \(record.fileName)")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredRecords = records
        } else {
            isSearching = true
            // HIG: Filter based on relevant criteria (file name and source)
            filteredRecords = records.filter { record in
                let lowercasedSearchText = searchText.lowercased()
                return record.fileName.lowercased().contains(lowercasedSearchText) ||
                       record.source.lowercased().contains(lowercasedSearchText)
            }
        }
        recordTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = nil
        searchBar.resignFirstResponder() // Dismiss the keyboard
        recordTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterRecords() {
        // 1. Filter by section first
        var scopedRecords = records

        if selectedSection != "All" {
            scopedRecords = records.filter { $0.sectionName == selectedSection }
        }
        
        // 2. Then apply the search filter (your existing logic)
        if isSearching, let searchText = searchBar.text, !searchText.isEmpty {
            let lowercasedSearchText = searchText.lowercased()
            filteredRecords = scopedRecords.filter { record in
                return record.fileName.lowercased().contains(lowercasedSearchText) ||
                       record.source.lowercased().contains(lowercasedSearchText)
            }
        } else {
            filteredRecords = scopedRecords
        }
        
        recordTableView.reloadData()
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
