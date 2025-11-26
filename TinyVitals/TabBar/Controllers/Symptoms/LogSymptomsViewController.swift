import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreGraphics
import QuickLook

// MARK: - Delegate Protocol
protocol LogSymptomsDelegate: AnyObject {
    func didLogNewSymptom(_ entry: SymptomEntry)
    func didUpdateSymptom(_ entry: SymptomEntry)
}

// MARK: - Class Definition
class LogSymptomsViewController: UIViewController, UITextViewDelegate, SymptomSelectionDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var symptomsView: UIView!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var heightView: UIView!
    @IBOutlet weak var selectedSymptomsLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var addPhotoView: UIView!
    
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: LogSymptomsDelegate?
    var existingEntry: SymptomEntry?
    
    var selectedSymptoms: [String] = []
    var selectedTemperature: Double?
    var selectedWeight: Double?
    var selectedHeight: Double?
    var selectedPhotoData: Data?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.delegate = self
        noteTextView.delegate = self
        
        addTapGesture(to: symptomsView, action: #selector(symptomsTapped))
        addTapGesture(to: temperatureView, action: #selector(temperatureTapped))
        addTapGesture(to: weightView, action: #selector(weightTapped))
        addTapGesture(to: heightView, action: #selector(heightTapped))
        addTapGesture(to: addPhotoView, action: #selector(addPhotoTapped))
        
        let previewTap = UITapGestureRecognizer(target: self, action: #selector(photoPreviewTapped))
        previewTap.delegate = self
        previewTap.cancelsTouchesInView = false
        photoPreviewImageView.isUserInteractionEnabled = true
        photoPreviewImageView.addGestureRecognizer(previewTap)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressed(_:)))
        photoPreviewImageView.addGestureRecognizer(longPressGesture)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)
        
        if let entry = existingEntry {
            self.title = "Edit Log"
            populateForm(with: entry)
            
        } else {
            self.title = "Log Symptoms"
            setupPlaceholderText()
            
            selectedSymptomsLabel.text = "None selected"
            selectedSymptomsLabel.textColor = .systemGray
            photoPreviewImageView.isHidden = true
            addPhotoView.isHidden = false
        }
    }
    
    
    // MARK: - Save Action
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showConfirmationMessage(title: "Title Required", message: "...")
            return
        }
        let description = (descriptionTextView.textColor == .systemGray) ? nil : descriptionTextView.text
        let notes = (noteTextView.textColor == .systemGray) ? nil : noteTextView.text
        let date = datePicker.date
        let symptoms = self.selectedSymptoms
        let temperature = self.selectedTemperature
        let weight = self.selectedWeight
        let height = self.selectedHeight
        
        if var entryToUpdate = existingEntry {
            let updatedEntry = SymptomEntry(
                id: entryToUpdate.id,
                date: date,
                title: title,
                description: description,
                symptoms: symptoms,
                temperature: temperature,
                weight: weight,
                height: height,
                notes: notes,
                photoData: selectedPhotoData,
                diagnosisID: entryToUpdate.diagnosisID,
                diagnosedBy: entryToUpdate.diagnosedBy
            )
            delegate?.didUpdateSymptom(updatedEntry)
            
        } else {
            let newEntry = SymptomEntry(
                id: UUID(),
                date: date,
                title: title,
                description: description,
                symptoms: symptoms,
                temperature: temperature,
                weight: weight,
                height: height,
                notes: notes,
                photoData: selectedPhotoData,
                diagnosisID: nil,
                diagnosedBy: nil
            )
            delegate?.didLogNewSymptom(newEntry)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup & Action Handlers
    func populateForm(with entry: SymptomEntry) {
        titleTextField.text = entry.title
        
        descriptionTextView.text = entry.description
        descriptionTextView.textColor = entry.description == nil ? .systemGray : .black
        
        noteTextView.text = entry.notes
        noteTextView.textColor = entry.notes == nil ? .systemGray : .black
        
        datePicker.date = entry.date
        
        selectedSymptoms = entry.symptoms
        selectedTemperature = entry.temperature
        selectedWeight = entry.weight
        selectedHeight = entry.height
        selectedPhotoData = entry.photoData
        
        if let data = entry.photoData {
            photoPreviewImageView.image = UIImage(data: data)
            photoPreviewImageView.isHidden = false
            addPhotoView.isHidden = true
        } else {
            photoPreviewImageView.isHidden = true
            addPhotoView.isHidden = false
        }
    }
    
    func setupPlaceholderText() {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Description"
            descriptionTextView.textColor = .systemGray
        }
        if noteTextView.text.isEmpty {
            noteTextView.text = "Add a note"
            noteTextView.textColor = .systemGray
        }
    }
    
    func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func symptomsTapped() {
        let selectionVC = SymptomSelectionViewController(nibName: "SymptomSelectionViewController", bundle: nil)
        selectionVC.delegate = self
        selectionVC.selectedSymptoms = self.selectedSymptoms
        selectionVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    @objc func temperatureTapped() {
        let alert = UIAlertController(title: "Enter Temperature", message: "Enter a value in °F", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "e.g., 98.6"; $0.keyboardType = .decimalPad }
        let saveAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let temp = Double(text) {
                self?.selectedTemperature = temp
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    @objc func weightTapped() {
        let alert = UIAlertController(title: "Enter Weight", message: "Enter a value (e.g., kg or lbs)", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "e.g., 2.5"; $0.keyboardType = .decimalPad }
        let saveAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let weight = Double(text) {
                self?.selectedWeight = weight
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    @objc func heightTapped() {
        let alert = UIAlertController(title: "Enter Height", message: "Enter a value (e.g., cm)", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "e.g., 23.5"; $0.keyboardType = .decimalPad }
        let saveAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let height = Double(text) {
                self?.selectedHeight = height
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showConfirmationMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Photo Picker Logic
    
    @objc func addPhotoTapped() {
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
        guard self.selectedPhotoData != nil else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        self.present(previewController, animated: true)
    }
    
    // MARK: - Photo Actions

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

    func handleImageSelected(data: Data) {
        self.selectedPhotoData = data
        
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = UIImage(data: data)
            self.photoPreviewImageView.isHidden = false
            self.addPhotoView.isHidden = true
        }
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
extension LogSymptomsViewController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .systemGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == descriptionTextView {
                textView.text = "Description"
            } else if textView == noteTextView {
                textView.text = "Add a note"
            }
            textView.textColor = .systemGray
        }
    }
}

// MARK: - SymptomSelectionDelegate
extension LogSymptomsViewController {
    
    func didSelectSymptoms(_ symptoms: [String]) {
        
        self.selectedSymptoms = symptoms
        
        if symptoms.isEmpty {
            selectedSymptomsLabel.text = "None selected"
            selectedSymptomsLabel.textColor = .systemGray
        } else {
            selectedSymptomsLabel.text = symptoms.joined(separator: ", ")
            selectedSymptomsLabel.textColor = .label
        }
    }
}

// MARK: - QLPreviewControllerDataSource
extension LogSymptomsViewController {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return (self.selectedPhotoData != nil) ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("symptom_photo.jpg")
        
        do {
            try self.selectedPhotoData?.write(to: tempURL)
            return tempURL as QLPreviewItem
        } catch {
            print("Error writing temp file for QuickLook: \(error)")
            return URL(fileURLWithPath: "") as QLPreviewItem
        }
    }
}
