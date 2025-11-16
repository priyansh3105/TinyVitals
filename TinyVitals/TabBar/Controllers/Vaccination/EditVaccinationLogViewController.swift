import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreGraphics
import QuickLook

protocol EditVaccinationDelegate: AnyObject {
    func didUpdateVaccine(_ updatedVaccine: Vaccine)
}

class EditVaccinationLogViewController: UIViewController, UITextViewDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var takenButton: UIButton!
    @IBOutlet weak var skippedButton: UIButton!
    @IBOutlet weak var rescheduleButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    
    @IBOutlet weak var removePhotoButton: UIButton!
    
    // MARK: - Properties
    var selectedPhotoData: Data?
    weak var delegate: EditVaccinationDelegate?
    var vaccine: Vaccine?
    
    // This property holds the currently selected state
    var selectedStatus: VaccinationStatus = .due
    var selectedDate: Date = Date()
    // 'notes' variable is no longer needed, we read directly from noteTextView
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // This allows taps to still work on buttons, etc.
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // --- Setup Navigation Bar ---
        self.title = "Vaccination Log"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        // --- Setup Note Text View ---
        noteTextView.delegate = self // Set the delegate for placeholder logic
        
        let previewTap = UITapGestureRecognizer(target: self, action: #selector(photoPreviewTapped))
        photoPreviewImageView.isUserInteractionEnabled = true // Must be enabled for taps
        photoPreviewImageView.addGestureRecognizer(previewTap)

        // --- Populate Data ---
        if let vaccine = vaccine {
            self.title = "Vaccination Log" // Set Nav Bar title if you want it specific
            nameLabel.text = vaccine.name
            descriptionLabel.text = vaccine.longDescription
            
            self.selectedStatus = vaccine.status
            
            // Load saved date
            if let savedDate = vaccine.givenDate {
                datePicker.setDate(savedDate, animated: false)
            }
            
            // Load saved note and set placeholder if empty
            if let savedNote = vaccine.notes, !savedNote.isEmpty {
                noteTextView.text = savedNote
                noteTextView.textColor = .black
            } else {
                noteTextView.text = "Add a note"
                noteTextView.textColor = .black // Use lightGray for placeholder
            }
            
            // Load saved photo
            if let data = vaccine.photoData {
                self.selectedPhotoData = data
                self.photoPreviewImageView.image = UIImage(data: data)
                // Show preview, hide "Add" button
                self.photoPreviewImageView.isHidden = false
                self.addPhotoView.isHidden = true
                self.removePhotoButton.isHidden = false // <<< Show remove button
            } else {
                // Show "Add" button, hide preview
                self.photoPreviewImageView.isHidden = true
                self.addPhotoView.isHidden = false
                self.removePhotoButton.isHidden = true // <<< Hide remove button
            }
        } else {
            // Default state if no vaccine is passed (e.g., for placeholder)
            noteTextView.text = "Add a note"
            noteTextView.textColor = .black
            photoPreviewImageView.isHidden = true
            addPhotoView.isHidden = false
            self.removePhotoButton.isHidden = true // <<< Hide remove button
        }
        
        // Set the initial visual state for buttons and date picker
        updateStatusButtons()
    }
    
    // MARK: - Status Button Actions
    
    @IBAction func removePhotoButtonTapped(_ sender: UIButton) {
        self.selectedPhotoData = nil
        
        // Animate the UI change
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = nil
            self.photoPreviewImageView.isHidden = true
            self.removePhotoButton.isHidden = true // Hide the remove button
            self.addPhotoView.isHidden = false    // Show the "Add Photo" button again
        }
    }
    
    
    @IBAction func takenButtonTapped(_ sender: UIButton) {
        selectedStatus = .completed
        updateStatusButtons()
    }
    
    @IBAction func skippedButtonTapped(_ sender: UIButton) {
        selectedStatus = .skipped // Use the new enum case
        updateStatusButtons()
    }
    
    @IBAction func rescheduleButtonTapped(_ sender: UIButton) {
        selectedStatus = .reschedule // Use the new enum case
        updateStatusButtons()
    }
    
    func handleImageSelected(data: Data) {
        self.selectedPhotoData = data
        
        // Animate the UI change
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = UIImage(data: data)
            self.photoPreviewImageView.isHidden = false
            self.removePhotoButton.isHidden = false // <<< Show remove button
            self.addPhotoView.isHidden = true // Hide the "Add Photo" button
        }
    }
    
    // MARK: - Visual Feedback Helper
    
    func updateStatusButtons() {
        
        // --- Define your colors ---
        let selectedColor = UIColor(red: 0.525, green: 0.765, blue: 0.937, alpha: 1.0) // Color for the selected button
        let selectedTextColor = UIColor.white
        
        let deselectedColor = UIColor.systemGray6 // Light gray for unselected
        let deselectedTextColor = UIColor.label   // Standard black/white text
        // -------------------------

        // 1. Reset all buttons to the deselected state
        takenButton.backgroundColor = deselectedColor
        takenButton.setTitleColor(deselectedTextColor, for: .normal)
        
        skippedButton.backgroundColor = deselectedColor
        skippedButton.setTitleColor(deselectedTextColor, for: .normal)
        
        rescheduleButton.backgroundColor = deselectedColor
        rescheduleButton.setTitleColor(deselectedTextColor, for: .normal)

        // 2. Animate the changes
        UIView.animate(withDuration: 0.3) {
            switch self.selectedStatus {
                
            case .completed: // "Taken"
                self.takenButton.backgroundColor = selectedColor
                self.takenButton.setTitleColor(selectedTextColor, for: .normal)
                
                // Show the date picker
                self.datePicker.isHidden = false
                self.datePicker.alpha = 1.0
                
            case .skipped: // "Skipped"
                self.skippedButton.backgroundColor = selectedColor
                self.skippedButton.setTitleColor(selectedTextColor, for: .normal)
                
                // Hide the date picker
                self.datePicker.isHidden = true
                self.datePicker.alpha = 0.0
                
            case .reschedule: // "Reschedule"
                self.rescheduleButton.backgroundColor = selectedColor
                self.rescheduleButton.setTitleColor(selectedTextColor, for: .normal)

                // Show the date picker (for the new date)
                self.datePicker.isHidden = false
                self.datePicker.alpha = 1.0
                
            case .due: // Default "Due" state
                // Hide the date picker
                self.datePicker.isHidden = true
                self.datePicker.alpha = 0.0
            }
        }
    }
    
    
    // MARK: - Save & Cancel
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let originalVaccine = vaccine else { return }
            
        let newNotes = (noteTextView.textColor == .black) ? nil : noteTextView.text
        let newDate = datePicker.date
            
        let updatedVaccine = Vaccine(
            name: originalVaccine.name,
            fullName: originalVaccine.fullName,
            longDescription: originalVaccine.longDescription,
            schedule: originalVaccine.schedule,
            status: selectedStatus,
            notes: newNotes,
            givenDate: newDate,
            photoData: selectedPhotoData
        )
        delegate?.didUpdateVaccine(updatedVaccine)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        
        // Action 1: Choose from Files
        alert.addAction(UIAlertAction(title: "Choose from Files", style: .default, handler: { _ in
            self.presentDocumentPicker()
        }))
        
        // Action 2: Use Camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { _ in
                self.presentImagePicker(source: .camera)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad compatibility
        if let popover = alert.popoverPresentationController {
            popover.sourceView = addPhotoView
        }
        
        present(alert, animated: true)
    }

    @objc func photoPreviewTapped() {
        // 1. Check if there is photo data to preview
        guard self.selectedPhotoData != nil else {
            print("No photo data to preview.")
            return
        }
        
        // 2. Create and configure the QLPreviewController
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        
        // 3. Present it
        self.present(previewController, animated: true)
    }
    
    func presentDocumentPicker() {
        // Allows selecting any image type
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
        picker.delegate = self
        present(picker, animated: true)
    }

    func presentImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true)
    }


    // MARK: - Picker Delegate Callbacks

    // For UIDocumentPicker (Files)
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        _ = url.startAccessingSecurityScopedResource()
        if let data = try? Data(contentsOf: url) {
            handleImageSelected(data: data)
        }
        url.stopAccessingSecurityScopedResource()
    }

    // For UIImagePickerController (Camera)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        if let data = image.jpegData(compressionQuality: 0.8) {
            handleImageSelected(data: data)
        }
    }
}

// MARK: - UITextViewDelegate
extension EditVaccinationLogViewController {
    
    // Called when the user starts typing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    // Called when the user finishes typing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note"
            textView.textColor = .black
        }
    }
}

extension EditVaccinationLogViewController {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        // We only show the preview if we have data
        return (self.selectedPhotoData != nil) ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // QLPreviewController cannot preview raw Data. We must save the data to a
        // temporary file and return the URL to that file.
        
        let tempDir = FileManager.default.temporaryDirectory
        // Use the vaccine name for a unique-ish file name
        let fileName = self.vaccine?.name ?? "preview"
        let tempURL = tempDir.appendingPathComponent("\(fileName).jpg")
        
        do {
            // Write the saved image data to the temporary file
            try self.selectedPhotoData?.write(to: tempURL)
            // Return the file URL as the preview item
            return tempURL as QLPreviewItem
        } catch {
            print("Error writing temp file for QuickLook: \(error)")
            // Return an empty URL on failure
            return URL(fileURLWithPath: "") as QLPreviewItem
        }
    }
}
