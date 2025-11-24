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
    
    
    // MARK: - Properties
    var selectedPhotoData: Data?
    weak var delegate: EditVaccinationDelegate?
    var vaccine: Vaccine?
    var selectedStatus: VaccinationStatus = .due
    var selectedDate: Date = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        self.title = "Vaccination Log"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        noteTextView.delegate = self
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped))
        addPhotoView.addGestureRecognizer(photoTap)
        
        let previewTap = UITapGestureRecognizer(target: self, action: #selector(photoPreviewTapped))
        photoPreviewImageView.isUserInteractionEnabled = true
        photoPreviewImageView.addGestureRecognizer(previewTap)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressed(_:)))
        photoPreviewImageView.addGestureRecognizer(longPressGesture)

        if let vaccine = vaccine {
            self.title = "Vaccination Log"
            nameLabel.text = vaccine.name
            descriptionLabel.text = vaccine.longDescription
            
            self.selectedStatus = vaccine.status
            
            if let savedDate = vaccine.givenDate {
                datePicker.setDate(savedDate, animated: false)
            }
            
            if let savedNote = vaccine.notes, !savedNote.isEmpty {
                noteTextView.text = savedNote
                noteTextView.textColor = .black
            } else {
                noteTextView.text = "Add a note"
                noteTextView.textColor = .black
            }
            
            if let data = vaccine.photoData {
                self.selectedPhotoData = data
                self.photoPreviewImageView.image = UIImage(data: data)
                self.photoPreviewImageView.isHidden = false
                self.addPhotoView.isHidden = true
            } else {
                self.photoPreviewImageView.isHidden = true
                self.addPhotoView.isHidden = false
            }
        } else {
            noteTextView.text = "Add a note"
            noteTextView.textColor = .lightText
            photoPreviewImageView.isHidden = true
            addPhotoView.isHidden = false
        }
        updateStatusButtons()
    }
    
    // MARK: - Status Button Actions
    
    @IBAction func takenButtonTapped(_ sender: UIButton) {
        selectedStatus = .completed
        updateStatusButtons()
    }
    
    @IBAction func skippedButtonTapped(_ sender: UIButton) {
        selectedStatus = .skipped
        updateStatusButtons()
    }
    
    @IBAction func rescheduleButtonTapped(_ sender: UIButton) {
        selectedStatus = .reschedule
        updateStatusButtons()
    }
    
    func handleImageSelected(data: Data) {
        self.selectedPhotoData = data
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = UIImage(data: data)
            self.photoPreviewImageView.isHidden = false
            self.addPhotoView.isHidden = true
        }
    }
    
    // MARK: - Visual Feedback Helper
    
    func updateStatusButtons() {
        
        let selectedColor = UIColor(red: 0.800, green: 0.859, blue: 0.953, alpha: 1.0)
        let selectedTextColor = UIColor.white
        
        let deselectedColor = UIColor.systemGray6
        let deselectedTextColor = UIColor.label

        takenButton.backgroundColor = deselectedColor
        takenButton.setTitleColor(deselectedTextColor, for: .normal)
        
        skippedButton.backgroundColor = deselectedColor
        skippedButton.setTitleColor(deselectedTextColor, for: .normal)
        
        rescheduleButton.backgroundColor = deselectedColor
        rescheduleButton.setTitleColor(deselectedTextColor, for: .normal)

        UIView.animate(withDuration: 0.3) {
            switch self.selectedStatus {
                
            case .completed:
                self.takenButton.backgroundColor = selectedColor
                self.takenButton.setTitleColor(selectedTextColor, for: .normal)
                
                self.datePicker.isHidden = false
                self.datePicker.alpha = 1.0
                
            case .skipped:
                self.skippedButton.backgroundColor = selectedColor
                self.skippedButton.setTitleColor(selectedTextColor, for: .normal)
                
                self.datePicker.isHidden = true
                self.datePicker.alpha = 0.0
                
            case .reschedule:
                self.rescheduleButton.backgroundColor = selectedColor
                self.rescheduleButton.setTitleColor(selectedTextColor, for: .normal)

                self.datePicker.isHidden = false
                self.datePicker.alpha = 1.0
                
            case .due:
                self.datePicker.isHidden = true
                self.datePicker.alpha = 0.0
            }
        }
    }
    
    // MARK: - Save & Cancel
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let originalVaccine = vaccine else { return }
            
        let newNotes = (noteTextView.textColor == .lightGray) ? nil : noteTextView.text
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
        
        alert.addAction(UIAlertAction(title: "Choose from Files", style: .default, handler: { _ in
            self.presentDocumentPicker()
        }))
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { _ in
                self.presentImagePicker(source: .camera)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = addPhotoView
        }
        present(alert, animated: true)
    }

    @objc func photoPreviewTapped() {
        guard self.selectedPhotoData != nil else {
            print("No photo data to preview.")
            return
        }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        
        self.present(previewController, animated: true)
    }

    @objc func photoLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to remove this photo?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: { [weak self] _ in
            self?.removePhoto()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = photoPreviewImageView
            popover.sourceRect = photoPreviewImageView.bounds
        }
        
        present(alert, animated: true)
    }

    func removePhoto() {
        self.selectedPhotoData = nil
        
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = nil
            self.photoPreviewImageView.isHidden = true
            self.addPhotoView.isHidden = false
        }
    }
    
    func presentDocumentPicker() {
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
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        _ = url.startAccessingSecurityScopedResource()
        if let data = try? Data(contentsOf: url) {
            handleImageSelected(data: data)
        }
        url.stopAccessingSecurityScopedResource()
    }

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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a note"
            textView.textColor = .lightGray
        }
    }
}

extension EditVaccinationLogViewController {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return (self.selectedPhotoData != nil) ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = self.vaccine?.name ?? "preview"
        let tempURL = tempDir.appendingPathComponent("\(fileName).jpg")
        
        do {
            try self.selectedPhotoData?.write(to: tempURL)
            return tempURL as QLPreviewItem
        } catch {
            print("Error writing temp file for QuickLook: \(error)")
            return URL(fileURLWithPath: "") as QLPreviewItem
        }
    }
}
