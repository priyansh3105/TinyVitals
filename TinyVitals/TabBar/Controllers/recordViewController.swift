//
//  recordViewController.swift
//  TinyVitals
//
//  Created by admin0 on 08/11/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreGraphics

class recordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRecordDelegate, UISearchBarDelegate, AddSectionDelegate {
    
    // MARK: - Outlets
    @IBOutlet var recordSuperView: UIView!
    @IBOutlet weak var recordTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var tagScrollView: UIScrollView!
    @IBOutlet weak var tagStackView: UIStackView!
    
    // MARK: - Data Properties
    var records: [Record] = []
    var filteredRecords: [Record] = []
    var isSearching: Bool = false
    var allSections: [String] = ["All", "Prescription", "+"]
    var selectedSection: String = "All"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        
        // Setup Order: Style -> Table/Search -> Load Data -> Build Custom UI
        setupSearchBarAppearance()
        setupTableViews()
        
        // CRITICAL: Call the tag setup to build the filter bar
        setupSectionTags()
        
        loadSampleData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure size and circularity are enforced for the Floating Action Button
        let desiredSize: CGFloat = 60.0
        let cornerRadius: CGFloat = 30.0
        
        if addButton.layer.cornerRadius != cornerRadius {
            addButton.frame.size = CGSize(width: desiredSize, height: desiredSize)
            addButton.layer.cornerRadius = cornerRadius
            addButton.clipsToBounds = true
        }
        view.bringSubviewToFront(addButton)
    }
    
    // MARK: - Setup and Styling Helpers
    
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

    private func setupSearchBarAppearance() {
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = .white
            searchField.layer.borderWidth = 1.0
            searchField.layer.borderColor = UIColor.systemGray4.cgColor
            searchField.layer.cornerRadius = 10.0
            searchField.layer.masksToBounds = true
        }
    }
    
    private func setupTableViews() {
        recordTableView.dataSource = self
        recordTableView.delegate = self
        recordTableView.rowHeight = 120
        recordTableView.tableFooterView = UIView()
    }
    
    // MARK: - Tag View Builder Logic (ScrollView/StackView)
    
    func setupSectionTags() {
        // 1. Clear all existing buttons before rebuilding
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 2. Iterate through all sections to create buttons
        for sectionName in allSections {
            let isAddButton = (sectionName == "+")
            let isSelected = (sectionName == selectedSection)
            
            let button = createTagButton(title: sectionName, isAddButton: isAddButton, isSelected: isSelected)
            
            // Add button to the stack view
            tagStackView.addArrangedSubview(button)
        }
    }
    
    private func createTagButton(title: String, isAddButton: Bool, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        
        // Set Title/Image
        if isAddButton {
            button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            button.setTitle(nil, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }

        // Styling (Pill Shape)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.layer.cornerRadius = 11 // Half of a 36pt effective button height
        
        // Color Logic
        let backgroundColor = isSelected ? UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0) : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        let textColor: UIColor = isSelected ? .white : .black
        let tintColor: UIColor = isSelected ? .white : .systemBlue
        
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.tintColor = tintColor
        
        // Tagging (Use the section name as the identifier string)
        button.accessibilityIdentifier = title
        
        // Action Connection
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }

    @objc func tagButtonTapped(_ sender: UIButton) {
        guard let selectedName = sender.accessibilityIdentifier else { return }

        if selectedName == "+" {
            // FIX: The action is now correctly defined and called here
            self.addSectionButtonTapped(sender as Any)
        } else {
            selectedSection = selectedName
            setupSectionTags()
            filterRecords()
        }
    }
    
    // MARK: - Actions & Delegate Implementations
    
    @IBAction func addSectionButtonTapped(_ sender: Any) {
        let addSectionVC = AddSectionViewController(nibName: "AddSectionViewController", bundle: nil)
        addSectionVC.delegate = self
        present(UINavigationController(rootViewController: addSectionVC), animated: true)
    }
    
    @IBAction func addDocumentTapped(_ sender: Any) {
        let addVC = AddRecordViewController(nibName: "AddRecordViewController", bundle: nil)
        addVC.delegate = self
        addVC.targetSectionName = self.selectedSection
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    func didAddSection(name: String) {
        // 1. Insert new section before the "+" button
        if let plusIndex = allSections.lastIndex(of: "+") {
            allSections.insert(name, at: plusIndex)
        } else {
            allSections.append(name) // Should only happen if '+' is missing
        }
        
        // 2. Set the new section as selected and rebuild the UI
        selectedSection = name
        setupSectionTags() // <<< This function clears the StackView and rebuilds all buttons
        
        // 3. Filter the table view to show the empty content for the new section
        filterRecords()
    }
    
    func didAddRecord(_ record: Record) {
        records.insert(record, at: 0)
        filterRecords()
    }
    
    // MARK: - Filtering & Data Management
    
    func filterRecords() {
        var scopedRecords = records

        if selectedSection != "All" {
            scopedRecords = records.filter { $0.sectionName == selectedSection }
        }
        
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
    
    func loadSampleData() {
        let pdfURL = Bundle.main.url(forResource: "SamplePDF", withExtension: "pdf") ?? URL(fileURLWithPath: "/simulated/missing/path.pdf")
        let imageURL = Bundle.main.url(forResource: "SampleImage", withExtension: "jpg") ?? URL(fileURLWithPath: "/simulated/missing/path.jpg")
        
        records = [
            Record(fileName: "CT-Chest Scan", source: "Dr. Raj Kumar's Clinic", addedDate: Date().addingTimeInterval(-100000), type: "PDF", fileURL: pdfURL, sectionName: "Prescription"),
            Record(fileName: "Blood Test Report (CBC)", source: "Apollo Diagnostics", addedDate: Date().addingTimeInterval(-200000), type: "PDF", fileURL: pdfURL, sectionName: "Prescription"),
            Record(fileName: "X-Ray - Left Leg", source: "MedLife Imaging Center", addedDate: Date().addingTimeInterval(-300000), type: "Image", fileURL: imageURL, sectionName: "X-Ray"),
        ]
        
        filterRecords()
    }
    
    // MARK: - Thumbnail Generation Logic
    
    func generateThumbnailFromImage(url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url),
              let fullImage = UIImage(data: data) else { return nil }
        
        let targetSize = CGSize(width: 50, height: 50)
        let imageSize = fullImage.size
        let scaleFactor = min(targetSize.width / imageSize.width, targetSize.height / imageSize.height)
        
        let scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
        let origin = CGPoint(x: (targetSize.width - scaledImageSize.width) / 2.0, y: (targetSize.height - scaledImageSize.height) / 2.0)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let thumbnail = renderer.image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: targetSize))
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
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            let scaleX = targetSize.width / pageRect.width
            let scaleY = targetSize.height / pageRect.height
            let scale = min(scaleX, scaleY)
            
            let scaledWidth = pageRect.width * scale
            let scaledHeight = pageRect.height * scale
            let offsetX = (targetSize.width - scaledWidth) / 2
            let offsetY = (targetSize.height - scaledHeight) / 2
            
            context.cgContext.translateBy(x: offsetX, y: offsetY + scaledHeight)
            context.cgContext.scaleBy(x: scale, y: -scale)
            context.cgContext.translateBy(x: -pageRect.origin.x, y: -pageRect.origin.y)
            context.cgContext.drawPDFPage(page)
        }
        return thumbnail
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordListCell", for: indexPath) as? RecordListCell else {
            fatalError("Unable to dequeue RecordListCell.")
        }
        
        let record = filteredRecords[indexPath.row]
        cell.configure(with: record)
        cell.setThumbnail(image: nil)
        
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
        let record = filteredRecords[indexPath.row]
        print("Selected record: \(record.fileName)")
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        filterRecords()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        filterRecords()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
