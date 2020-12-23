import UIKit
import CloudKit
import AVFoundation
import CoreLocation

class EditHazardReportViewController: UIViewController,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
CLLocationManagerDelegate {
    
    @IBOutlet weak var emergencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var hazardDescriptionTextView: UITextView!
    @IBOutlet weak var hazardImageView: UIImageView!
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Add border to hazard description text view
        hazardDescriptionTextView.layer.borderWidth = CGFloat(0.5)
        hazardDescriptionTextView.layer.borderColor = UIColor(red: 204/255,
                                                              green: 204/255,
                                                              blue: 204/255,
                                                              alpha: 1.0).cgColor
        hazardDescriptionTextView.layer.cornerRadius = 5
        hazardDescriptionTextView.clipsToBounds = true
        
        startLocationServices()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Track and Store Current Location
    func startLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        switch locationAuthorizationStatus {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        case .restricted, .denied: alertLocationAccessNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: break
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        case .restricted, .denied: alertLocationAccessNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    func alertLocationAccessNeeded() {
        let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Location Access",
            message: "Location access is required for including the location of the hazard.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Location Access",
                                      style: .cancel,
                                      handler: { (alert) -> Void in
                                        UIApplication.shared.open(settingsAppURL,
                                                                  options: [:],
                                                                  completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Present Camera and Snap Photo
    @IBAction func snapPictureButtonTapped(_ sender: UIButton) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: presentCamera()
        case .restricted, .denied: alertCameraAccessNeeded()
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video,
                                      completionHandler: {accessGranted in
                                        guard accessGranted == true else { return }
                                        self.presentCamera()
        })
    }
    
    func presentCamera() {
        let hazardPhotoPicker = UIImagePickerController()
        hazardPhotoPicker.sourceType = .camera
        hazardPhotoPicker.delegate = self
        
        self.present(hazardPhotoPicker, animated: true, completion: nil)
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplicationOpenSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required for including pictures of hazards.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL,
                                      options: [:],
                                      completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        let hazardPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.hazardImageView.image = hazardPhoto
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Cancelling & Saving
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        let hazardReport = CKRecord(recordType: "HazardReport")
        hazardReport["isEmergency"] = emergencySegmentedControl.selectedSegmentIndex as NSNumber
        hazardReport["hazardDescription"] = hazardDescriptionTextView.text as NSString
        hazardReport["hazardLocation"] = currentLocation
        hazardReport["isResolved"] = NSNumber(integerLiteral: 0) // no booleans
        
        if let hazardPhoto = hazardImageView.image {
            // Generate unique file name
            let hazardPhotoFileName = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            
            // Create4 URL in temp directory
            let hazardPhotoFileURL = URL.init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(hazardPhotoFileName)
            
            // Make JPEG
            let hazardPhotoData = UIImageJPEGRepresentation(hazardPhoto, 0.70)
            
            // Write to disk
            do {
                try hazardPhotoData?.write(to: hazardPhotoFileURL)
            } catch {
                print("Could not save hazard photo to disk")
            }
            
            // Convert to CKAsset and store with CKRecord
            hazardReport["hazardPhoto"] = CKAsset(fileURL: hazardPhotoFileURL)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
