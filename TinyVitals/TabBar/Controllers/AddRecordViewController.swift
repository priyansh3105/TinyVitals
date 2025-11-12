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
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var uploadArea: UIView!
    
    // CRITICAL CHANGE: The date input is now a direct UIDatePicker outlet
    @IBOutlet weak var visitDate: UIDatePicker! // <<< Now correctly linked
    
    @IBOutlet weak var filePreviewImageView: UIImageView!
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Upload Area Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadAreaTapped))
        uploadArea.addGestureRecognizer(tapGesture)
        
        // 2. HIG: Ensure DatePicker mode is set to Date only (can also be done in XIB)
        visitDate.datePickerMode = .date
        
        // Optional: Add a "Done" button if presented in a Navigation Controller
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }

    // MARK: - Actions

    @objc func cancelButtonTapped() {
        // Dismiss the modal stack if the user taps "Done" without saving
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadAreaTapped() {
        showDocumentSourceOptions()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        // 1. Collect and validate data (no change needed here)
        guard let title = titleTextField.text, !title.isEmpty,
              let clinic = clinicTextField.text, !clinic.isEmpty,
              let fileURL = selectedFileURL // Check if a file was selected
        else {
            showConfirmationMessage(title: "Missing Information", message: "Please fill Title, Clinic, and upload a file.")
            return
        }
        
        let addedDate = visitDate.date
        
        // 3. Create the new Record object (CRITICALLY UPDATED)
        let newRecord = Record(
            fileName: title,
            source: clinic,
            addedDate: addedDate,
            type: selectedFileType,
            fileURL: fileURL,
            sectionName: targetSectionName // <<< INCLUDE THE SECTION NAME HERE
        )
        
        // 4. Send the new record back to the presenting view controller
        delegate?.didAddRecord(newRecord)
        
        // 5. Dismiss the modal screen
        dismiss(animated: true, completion: nil)
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
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            controller.dismiss(animated: true); return
        }
        
        // 1. Store Data and Start Access
        _ = url.startAccessingSecurityScopedResource()
        selectedFileURL = url
        selectedFileType = url.pathExtension.uppercased()
        
        // 2. Generate Thumbnail on Background Thread (HIG: Responsiveness)
        controller.dismiss(animated: true) {
            
            // Reset the preview appearance (hide the plus sign if using a label/icon)
            // [Optional: Hide any text/icons indicating 'Add File' in uploadArea]
            
            DispatchQueue.global(qos: .userInitiated).async {
                let type = self.selectedFileType
                var thumbnail: UIImage?
                
                if type == "PDF" {
                    // Ensure you have copied/implemented this function
                    thumbnail = self.generateThumbnailFromPDF(url: url)
                } else if ["IMAGE", "JPG", "PNG"].contains(type) {
                    // Ensure you have copied/implemented this function
                    thumbnail = self.generateThumbnailFromImage(url: url)
                }
                
                // 3. Update UI on Main Thread
                DispatchQueue.main.async {
                    self.filePreviewImageView.image = thumbnail
                    self.filePreviewImageView.contentMode = .scaleAspectFit
                    self.filePreviewImageView.clipsToBounds = true
                }
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate (Simplified for brevity)
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            // ... (Simulated save logic to get temp URL) ...
            guard let tempURL = URL(string: "/simulated/temp/path") else { return }
            self.selectedFileURL = tempURL
            self.selectedFileType = "IMAGE"
            
            // Generate and display the thumbnail from the image data immediately
            if let originalImage = info[.originalImage] as? UIImage {
                self.filePreviewImageView.image = originalImage
                self.filePreviewImageView.contentMode = .scaleAspectFit
                self.filePreviewImageView.clipsToBounds = true
            }
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
