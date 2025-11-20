//
//  AddRecordViewController.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers // Required for UTType
import CoreGraphics

// Delegate Protocol (Unchanged)
protocol AddRecordDelegate: AnyObject {
    func didAddRecord(_ record: Record)
}

class AddRecordViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var clinicTextField: UITextField!
    @IBOutlet weak var uploadArea: UIView!
    
    // CRITICAL CHANGE: The date input is now a direct UIDatePicker outlet
    @IBOutlet weak var visitDate: UIDatePicker! // <<< Now correctly linked
    
    @IBOutlet weak var filePreviewImageView: UIImageView!
    @IBOutlet weak var dummyImageView: UIImageView!
    
    var targetSectionName: String = "All"
    // MARK: - Properties
    weak var delegate: AddRecordDelegate?
    var selectedFileURL: URL?
    var selectedFileType: String = "N/A"
    
    // Date Formatter (Used only for display/logging if needed, but not for input parsing)
    let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Use a standard format for consistency, e.g., "dd MMM yyyy"
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    @IBOutlet weak var selectedSectionLabel: UILabel!
    
    @IBOutlet weak var sectionSelectionView: UIView!
    
    var selectedSectionName: String = "All"
    
    var availableSections: [String] = []
    
    var selectedPreviewData: Data?
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(cancelButtonTapped))
        // 2. ADD Button (The Primary Action) goes on the RIGHT
        // We use the selector to trigger the existing saveButtonTapped logic.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(addButtonTapped))
        selectedSectionName = targetSectionName
        selectedSectionLabel.text = targetSectionName // Set initial text
        // Add tap gesture to the new section row
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectSectionTapped))
        sectionSelectionView.addGestureRecognizer(tapGesture)
        
        // 1. Setup Upload Area Tap Gesture (Existing)
        let uploadTapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadAreaTapped))
        uploadArea.addGestureRecognizer(uploadTapGesture)
        // 2. HIG: Ensure DatePicker mode is set to Date only (Existing)
        visitDate.datePickerMode = .date
        // 4. Implement Tap-to-Dismiss Keyboard
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Crucial: Allows taps to pass through to underlying controls (like the Add button)
        // but still registers a general tap to dismiss the keyboard.
        keyboardDismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardDismissTap)
        // Ensure you also set the title for the Nav Bar
        self.title = "Add Record"
    }

    // MARK: - Actions

    @objc func cancelButtonTapped() {
        // Dismiss the modal stack if the user taps "Done" without saving
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadAreaTapped() {
        showDocumentSourceOptions()
    }
    
    @objc func dismissKeyboard() {
        // This method tells the view (and all its subviews) to resign the first responder status,
        // forcing the keyboard to dismiss.
        view.endEditing(true)
    }
    
    // In AddRecordViewController.swift

    @objc func addButtonTapped() { // Removed '_ sender: UIButton' argument for Navbar selector compatibility
        
        // 1. Collect and validate data
        guard let title = titleTextField.text, !title.isEmpty,
              let clinic = clinicTextField.text, !clinic.isEmpty,
              let fileURL = selectedFileURL
        else {
            showConfirmationMessage(title: "Missing Information", message: "Please fill Title, Clinic, and upload a file.")
            return
        }
        
        // 2. Get Date
        let addedDate = visitDate.date
        
        // 3. Determine Section
        // Use selectedSectionName if the user picked one, otherwise fallback to targetSectionName (the default from previous screen)
        // If selectedSectionName is "All", we might want to force a specific section or just keep it as "All".
        // A robust fallback is to use targetSectionName if selectedSectionName hasn't been changed from default.
        let finalSection = self.selectedSectionName == "All" ? self.targetSectionName : self.selectedSectionName
        
        // 4. Create Record
        let newRecord = Record(
            fileName: title,
            source: clinic,
            addedDate: addedDate,
            type: selectedFileType,
            fileURL: fileURL,
            sectionName: finalSection,
            previewData: selectedPreviewData
        )
        
        // 5. Delegate & Dismiss
        delegate?.didAddRecord(newRecord)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func selectSectionTapped() {
        // We will build the picker here
        presentSectionPicker()
    }
    
    // MARK: - Document/Image Picker Flow
    
    func showDocumentSourceOptions() {
        let alert = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Choose from Files", style: .default, handler: { _ in self.presentDocumentPicker() }))
        alert.addAction(UIAlertAction(title: "Scan with Camera", style: .default, handler: { _ in self.presentImagePicker(source: .camera) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.uploadArea
            popoverController.sourceRect = self.uploadArea.bounds
        }
        present(alert, animated: true)
    }

    func presentDocumentPicker() {
        let allowedUTIs: [UTType] = [.image, .pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedUTIs, asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true)
    }
    
    // MARK: - UIDocumentPickerDelegate
    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        guard let url = urls.first else {
//            controller.dismiss(animated: true); return
//        }
//        
//        _ = url.startAccessingSecurityScopedResource()
//        selectedFileURL = url
//        selectedFileType = url.pathExtension.uppercased()
//        
//        // 2. Generate Thumbnail on Background Thread (HIG: Responsiveness)
//        controller.dismiss(animated: true) {
//            DispatchQueue.global(qos: .userInitiated).async {
//                let type = self.selectedFileType
//                var thumbnail: UIImage?
//                
//                if type == "PDF" {
//                    thumbnail = self.generateThumbnailFromPDF(url: url)
//                } else if ["IMAGE", "JPG", "PNG"].contains(type) {
//                    thumbnail = self.generateThumbnailFromImage(url: url)
//                }
//                
//                // 3. Update UI on Main Thread
//                DispatchQueue.main.async {
//                    self.filePreviewImageView.image = thumbnail
//                    self.filePreviewImageView.contentMode = .scaleAspectFill
//                    self.filePreviewImageView.clipsToBounds = true
//                    self.dummyImageView.image = nil
//                }
//            }
//        }
//    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            controller.dismiss(animated: true); return
        }
        _ = url.startAccessingSecurityScopedResource()
        selectedFileURL = url
        selectedFileType = url.pathExtension.uppercased()
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                var thumbnailImage: UIImage?
                let type = self.selectedFileType
                if type == "PDF" {
                    thumbnailImage = self.generateThumbnailFromPDF(url: url)
                } else {
                    thumbnailImage = self.generateThumbnailFromImage(url: url)
                }
                let thumbData = thumbnailImage?.jpegData(compressionQuality: 0.7)
                DispatchQueue.main.async {
                    self.selectedPreviewData = thumbData
                    self.filePreviewImageView.image = thumbnailImage
                    self.filePreviewImageView.contentMode = .scaleAspectFill
                    self.filePreviewImageView.clipsToBounds = true
                    self.dummyImageView.image = nil
                }
            }
        }
    }

    
    // MARK: - UIImagePickerControllerDelegate (Simplified for brevity)
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true) {
//            // ... (Simulated save logic to get temp URL) ...
//            guard let tempURL = URL(string: "/simulated/temp/path") else { return }
//            self.selectedFileURL = tempURL
//            self.selectedFileType = "IMAGE"
//            
//            // Generate and display the thumbnail from the image data immediately
//            if let originalImage = info[.originalImage] as? UIImage {
//                self.filePreviewImageView.image = originalImage
//                self.filePreviewImageView.contentMode = .scaleAspectFill
//                self.filePreviewImageView.clipsToBounds = true
//                
//            }
//        }
//    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let originalImage = info[.originalImage] as? UIImage else { return }
            let size = CGSize(width: 200, height: 200)
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: size))
            }
            let thumbData = img.jpegData(compressionQuality: 0.7)
            self.selectedFileURL = nil
            self.selectedFileType = "IMAGE"
            self.selectedPreviewData = thumbData
            self.filePreviewImageView.image = img
            self.filePreviewImageView.contentMode = .scaleAspectFill
            self.filePreviewImageView.clipsToBounds = true
        }
    }

    // MARK: - Utility
    
    func showConfirmationMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func generateThumbnailFromImage(url: URL) -> UIImage? {
        // Note: The logic here ensures the image is scaled and centered to 50x50
        guard let data = try? Data(contentsOf: url),
              let fullImage = UIImage(data: data) else { return nil }
        
        let targetSize = CGSize(width: 50, height: 50)
        let imageSize = fullImage.size
        
        let widthRatio = targetSize.width / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: imageSize.width * scaleFactor,
            height: imageSize.height * scaleFactor
        )
        
        let origin = CGPoint(
            x: (targetSize.width - scaledImageSize.width) / 2.0,
            y: (targetSize.height - scaledImageSize.height) / 2.0
        )
        
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
}
// Add this extension to the bottom of AddRecordViewController.swift
extension AddRecordViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func presentSectionPicker() {
        let alert = UIAlertController(title: "Select Category", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let picker = UIPickerView(frame: CGRect(x: 60, y: 50, width: 270, height: 150))
        
        picker.dataSource = self
        picker.delegate = self
        picker.tag = 1 // Use tag to distinguish this picker if you have others
        
        alert.view.addSubview(picker)
        
        let saveAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Get the selected section from the picker wheel
            let selectedRow = picker.selectedRow(inComponent: 0)
            let chosenSection = self.availableSections[selectedRow]
            
            // Update UI and internal property
            self.selectedSectionName = chosenSection
            self.selectedSectionLabel.text = chosenSection
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }

    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableSections.count
    }
    
    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableSections[row]
    }
}
