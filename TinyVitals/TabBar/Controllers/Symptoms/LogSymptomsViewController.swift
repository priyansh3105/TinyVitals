import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import CoreGraphics
import QuickLook // <<< ADD IMPORT

// MARK: - Delegate Protocol
protocol LogSymptomsDelegate: AnyObject {
    func didLogNewSymptom(_ entry: SymptomEntry)
    func didUpdateSymptom(_ entry: SymptomEntry) // <<< ADD THIS NEW METHOD
}

// MARK: - Class Definition
// Add all new delegate conformances
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
    
    // <<< ADD THESE NEW OUTLETS >>>
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: LogSymptomsDelegate?
    var existingEntry: SymptomEntry?
    
    var selectedSymptoms: [String] = []
    var selectedTemperature: Double?
    var selectedWeight: Double?
    var selectedHeight: Double?
    var selectedPhotoData: Data? // <<< ADD PROPERTY
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // --- Setup Delegates ---
        descriptionTextView.delegate = self
        noteTextView.delegate = self
        
        // --- Add Tap Gestures ---
        addTapGesture(to: symptomsView, action: #selector(symptomsTapped))
        addTapGesture(to: temperatureView, action: #selector(temperatureTapped))
        addTapGesture(to: weightView, action: #selector(weightTapped))
        addTapGesture(to: heightView, action: #selector(heightTapped))
        addTapGesture(to: addPhotoView, action: #selector(addPhotoTapped))
        
        // --- Setup Photo Taps ---
        let previewTap = UITapGestureRecognizer(target: self, action: #selector(photoPreviewTapped))
        previewTap.delegate = self
        previewTap.cancelsTouchesInView = false
        photoPreviewImageView.isUserInteractionEnabled = true
        photoPreviewImageView.addGestureRecognizer(previewTap)
        
        // Add Long Press gesture for Deletion
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(photoLongPressed(_:)))
        photoPreviewImageView.addGestureRecognizer(longPressGesture)
        
        // Add gesture to dismiss keyboard
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        viewTap.cancelsTouchesInView = false
        view.addGestureRecognizer(viewTap)
        
        // --- NEW: Check if we are Editing or Creating ---
        if let entry = existingEntry {
            // --- EDIT MODE ---
            // We are editing, so populate the form with existing data
            self.title = "Edit Log"
            populateForm(with: entry)
            
        } else {
            // --- CREATE NEW MODE ---
            // We are creating a new log, set up placeholders
            self.title = "Log Symptoms"
            setupPlaceholderText()
            
            // Set initial label text
            selectedSymptomsLabel.text = "None selected"
            selectedSymptomsLabel.textColor = .lightGray // Use lightGray for placeholder
            
            // Set initial photo state
            photoPreviewImageView.isHidden = true
            addPhotoView.isHidden = false
        }
    }
    
    
    // MARK: - Save Action
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // --- 1. Get Data from UI ---
        guard let title = titleTextField.text, !title.isEmpty else {
            showConfirmationMessage(title: "Title Required", message: "...")
            return
        }
        // ... (get all other data from text fields, pickers, etc.) ...
        let description = (descriptionTextView.textColor == .lightGray) ? nil : descriptionTextView.text
        let notes = (noteTextView.textColor == .lightGray) ? nil : noteTextView.text
        let date = datePicker.date
        let symptoms = self.selectedSymptoms
        let temperature = self.selectedTemperature
        let weight = self.selectedWeight
        let height = self.selectedHeight
        
        // --- 2. Check if we are Editing or Saving New ---
        if var entryToUpdate = existingEntry {
            // --- We are UPDATING ---
            // Create a *new* entry object based on the old one's ID
            let updatedEntry = SymptomEntry(
                id: entryToUpdate.id, // <<< Use the ORIGINAL ID
                date: date,
                title: title,
                description: description,
                symptoms: symptoms,
                temperature: temperature,
                weight: weight,
                height: height,
                notes: notes,
                photoData: selectedPhotoData,
                diagnosisID: entryToUpdate.diagnosisID, // Keep old diagnosis link
                diagnosedBy: entryToUpdate.diagnosedBy
            )
            // Call the UPDATE delegate method
            delegate?.didUpdateSymptom(updatedEntry)
            
        } else {
            // --- We are CREATING NEW ---
            let newEntry = SymptomEntry(
                id: UUID(), // <<< Create a NEW ID
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
            // Call the NEW entry delegate method
            delegate?.didLogNewSymptom(newEntry)
        }
        // --- 3. Go Back ---
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup & Action Handlers
    func populateForm(with entry: SymptomEntry) {
        titleTextField.text = entry.title
        
        descriptionTextView.text = entry.description
        descriptionTextView.textColor = entry.description == nil ? .lightGray : .black
        
        noteTextView.text = entry.notes
        noteTextView.textColor = entry.notes == nil ? .lightGray : .black
        
        datePicker.date = entry.date
        
        // Populate vitals
        selectedSymptoms = entry.symptoms
        selectedTemperature = entry.temperature
        selectedWeight = entry.weight
        selectedHeight = entry.height
        selectedPhotoData = entry.photoData
        
        // Update photo view
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
            descriptionTextView.textColor = .lightGray
        }
        if noteTextView.text.isEmpty {
            noteTextView.text = "Add a note"
            noteTextView.textColor = .lightGray
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
        // We only want to trigger this once when the press begins
        guard gesture.state == .began else { return }
        
        // Show a confirmation alert
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to remove this photo?", preferredStyle: .actionSheet)
        
        // Add the "Delete" action
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: { [weak self] _ in
            self?.removePhoto()
        }))
        
        // Add a "Cancel" action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad compatibility
        if let popover = alert.popoverPresentationController {
            popover.sourceView = photoPreviewImageView
            popover.sourceRect = photoPreviewImageView.bounds
        }
        
        present(alert, animated: true)
    }

    // This is the helper function you already have
    func removePhoto() {
        self.selectedPhotoData = nil
        
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = nil
            self.photoPreviewImageView.isHidden = true
            self.addPhotoView.isHidden = false // Show the "Add Photo" button again
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

    // Unified function to handle the selected image
    func handleImageSelected(data: Data) {
        self.selectedPhotoData = data
        
        UIView.animate(withDuration: 0.3) {
            self.photoPreviewImageView.image = UIImage(data: data)
            self.photoPreviewImageView.isHidden = false
            self.addPhotoView.isHidden = true // Hide the "Add Photo" button
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
        if textView.textColor == .lightGray {
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
            textView.textColor = .lightGray
        }
    }
}

// MARK: - SymptomSelectionDelegate
extension LogSymptomsViewController {
    
    func didSelectSymptoms(_ symptoms: [String]) {
        // 1. Save the received symptoms to your local property
        self.selectedSymptoms = symptoms
        
        // 2. --- THIS IS THE FIX ---
        // Update the new label to show the selected items
        if symptoms.isEmpty {
            selectedSymptomsLabel.text = "None selected"
            selectedSymptomsLabel.textColor = .lightGray
        } else {
            // Join the array of strings into a single string
            selectedSymptomsLabel.text = symptoms.joined(separator: ", ")
            selectedSymptomsLabel.textColor = .label // Back to default color
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
