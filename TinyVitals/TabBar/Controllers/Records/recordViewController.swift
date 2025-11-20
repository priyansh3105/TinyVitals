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
import QuickLook

class recordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddRecordDelegate, UISearchBarDelegate, AddSectionDelegate, UIDocumentInteractionControllerDelegate, RecordListCellDelegate {
    
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
    
    var documentInteractionController: UIDocumentInteractionController?
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupSearchBarAppearance()
        setupTableViews()
        setupSectionTags()
        loadSampleData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let desiredSize: CGFloat = 60.0
        let cornerRadius: CGFloat = 25.0
        
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
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for sectionName in allSections {
            let isAddButton = (sectionName == "+")
            let isSelected = (sectionName == selectedSection)
            let button = createTagButton(title: sectionName, isAddButton: isAddButton, isSelected: isSelected)
            tagStackView.addArrangedSubview(button)
        }
    }
    
    private func createTagButton(title: String, isAddButton: Bool, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        if isAddButton {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.setTitle(nil, for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0).cgColor
        let backgroundColor = isSelected ? UIColor(red: 0.12, green: 0.45, blue: 0.9, alpha: 1.0) : UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        let textColor: UIColor = isSelected ? .white : .systemBlue
        let tintColor: UIColor = isSelected ? .white : .systemBlue
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.tintColor = tintColor
        button.accessibilityIdentifier = title
        button.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)
        if !isAddButton && title != "All" {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
            longPress.minimumPressDuration = 0.5 // Standard iOS long press duration
            button.addGestureRecognizer(longPress)
        }
        
        return button
    }

    @objc func tagButtonTapped(_ sender: UIButton) {
        guard let selectedName = sender.accessibilityIdentifier else { return }

        if selectedName == "+" {
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
        let nav = UINavigationController(rootViewController: addSectionVC)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                let smallDetent = UISheetPresentationController.Detent.custom { context in
                    return 300
                }
                sheet.detents = [smallDetent]
                sheet.largestUndimmedDetentIdentifier = smallDetent.identifier
            }
        }
        present(nav, animated: true)
    }
    
    @IBAction func addDocumentTapped(_ sender: Any) {
        let addVC = AddRecordViewController(nibName: "AddRecordViewController", bundle: nil)
        addVC.delegate = self
        addVC.targetSectionName = self.selectedSection
        addVC.availableSections = self.allSections.filter { $0 != "+" && $0 != "All" }
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                let customFixedDetent = UISheetPresentationController.Detent.custom { context in
                    return 600
                }
                sheet.detents = [customFixedDetent]
                sheet.preferredCornerRadius = 16
            }
        }

        present(nav, animated: true)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let button = gesture.view as? UIButton,
              let sectionToEdit = button.accessibilityIdentifier else { return }
        presentAddSection(sectionToEdit: sectionToEdit)
    }

    func presentAddSection(sectionToEdit: String? = nil) {
        let addSectionVC = AddSectionViewController(nibName: "AddSectionViewController", bundle: nil)
        addSectionVC.delegate = self

        if let sectionName = sectionToEdit {
            addSectionVC.currentSectionName = sectionName
            addSectionVC.isEditingMode = true
        }

        let nav = UINavigationController(rootViewController: addSectionVC)
        nav.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                let customFixedDetent = UISheetPresentationController.Detent.custom { context in
                    return 300
                }
                sheet.detents = [customFixedDetent]
                sheet.largestUndimmedDetentIdentifier = customFixedDetent.identifier
                sheet.prefersGrabberVisible = true
            }
        }
        present(nav, animated: true)
    }
    
    func didAddSection(name: String) {
        if let plusIndex = allSections.lastIndex(of: "+") {
            allSections.insert(name, at: plusIndex)
        } else {
            allSections.append(name)
        }
        selectedSection = name
        setupSectionTags()
        filterRecords()
    }
    
    func didAddRecord(_ record: Record) {
        records.insert(record, at: 0)
        filterRecords()
    }
    
    func didEditSection(oldName: String, newName: String) {
        if let index = allSections.firstIndex(of: oldName) {
            allSections[index] = newName
        }
        for i in 0..<records.count {
            if records[i].sectionName == oldName {
                let updatedRecord = Record(
                    fileName: records[i].fileName,
                    source: records[i].source,
                    addedDate: records[i].addedDate,
                    type: records[i].type,
                    fileURL: records[i].fileURL,
                    sectionName: newName,
                    previewData: records[i].previewData
                )
                records[i] = updatedRecord
            }
        }
        selectedSection = newName
        setupSectionTags()
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
        let pdfData = UIImage(named: "DummyPDF")?.jpegData(compressionQuality: 1.0)
        let xrayData = UIImage(named: "DummyXRay")?.jpegData(compressionQuality: 1.0)
        let tempDir = FileManager.default.temporaryDirectory
        let pdfUrl = tempDir.appendingPathComponent("CT_Chest_Scan.pdf")
        let xrayUrl = tempDir.appendingPathComponent("XRay_Left_Leg.jpg")
        try? pdfData?.write(to: pdfUrl)
        try? xrayData?.write(to: xrayUrl)
        records = [
            Record(
                fileName: "CT-Chest Scan",
                source: "Dr. Raj Kumar's Clinic",
                addedDate: Date().addingTimeInterval(-100000),
                type: "PDF",
                fileURL: pdfUrl,
                sectionName: "Prescription",
                previewData: pdfData
            ),
            Record(
                fileName: "Blood Test Report (CBC)",
                source: "Apollo Diagnostics",
                addedDate: Date().addingTimeInterval(-200000),
                type: "PDF",
                fileURL: pdfUrl,
                sectionName: "Prescription",
                previewData: pdfData
            ),
            Record(
                fileName: "X-Ray - Left Leg",
                source: "MedLife Imaging Center",
                addedDate: Date().addingTimeInterval(-300000),
                type: "Image",
                fileURL: xrayUrl,
                sectionName: "X-Ray",
                previewData: xrayData
            )
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
        var record = filteredRecords[indexPath.row]
        cell.delegate = self
        cell.configure(with: record)
        cell.setThumbnail(image: nil)
        if let data = record.previewData, let img = UIImage(data: data) {
            cell.setThumbnail(image: img)
        } else if let fileURL = record.fileURL {
            DispatchQueue.global(qos: .userInitiated).async {
                let thumbnail: UIImage? = record.type.uppercased() == "PDF"
                    ? self.generateThumbnailFromPDF(url: fileURL)
                    : self.generateThumbnailFromImage(url: fileURL)

                let thumbData = thumbnail?.jpegData(compressionQuality: 0.7)

                DispatchQueue.main.async {
                    if tableView.indexPath(for: cell) == indexPath {
                        cell.setThumbnail(image: thumbnail ?? UIImage(named: "medical report sample image"))
                    }

                    if let data = thumbData {
                        if let globalIndex = self.records.firstIndex(where: { $0.addedDate == record.addedDate && $0.fileName == record.fileName }) {
                            self.records[globalIndex].previewData = data
                        }
                        self.filteredRecords[indexPath.row].previewData = data
                    }
                }
            }
        } else {
            cell.setThumbnail(image: UIImage(named: "medical report sample image"))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let record = filteredRecords[indexPath.row]
        guard let fileURL = record.fileURL else {
            showConfirmationMessage(title: "File Error", message: "Document file path is unavailable.")
            return
        }
        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        documentInteractionController = UIDocumentInteractionController(url: fileURL)
        documentInteractionController?.delegate = self
        if let cell = tableView.cellForRow(at: indexPath) {
            documentInteractionController?.presentOptionsMenu(from: cell.frame, in: view, animated: true)
        }
        if didStartAccessing {
            fileURL.stopAccessingSecurityScopedResource()
        }
    }
    
    func showConfirmationMessage(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
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
    
    func didTapShare(for record: Record) {
        guard let fileURL = record.fileURL else {
            showConfirmationMessage(title: "File Error", message: "Document file path is unavailable.")
            return
        }
        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            if didStartAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(activityViewController, animated: true)
    }
}
