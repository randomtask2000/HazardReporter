import UIKit
import MapKit

class HazardReportDetailsViewController: UIViewController {
	@IBOutlet weak var emergencyIndicatorLabel: UILabel!
	@IBOutlet weak var hazardDescriptionLabel: UILabel!
	@IBOutlet weak var hazardImageView: UIImageView!
	@IBOutlet weak var hazardLocationMapView: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        let location = CLLocation(latitude: 34.111, longitude: -97.111)
        let hazardRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        hazardLocationMapView.setRegion(hazardRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Hazard!"
        annotation.coordinate = location.coordinate
        
        hazardLocationMapView.addAnnotation(annotation)
    }
	
    // MARK: - Delete Hazard Report
	@IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: "Delete Hazard Report",
												message: "Are you sure you want to delete this hazard report?",
												preferredStyle: .actionSheet)
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
			(_) -> Void in
			
			let _ = self.navigationController?.popViewController(animated: true)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alertController.addAction(deleteAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
    // MARK: - Resolve Hazard Report
	@IBAction func resolveButtonTapped(_ sender: UIBarButtonItem) {
		let _ = self.navigationController?.popViewController(animated: true)
	}
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "editHazardReport":
            let navigationController = segue.destination as! UINavigationController
            _ = navigationController.viewControllers[0] as! EditHazardReportViewController
        default: break
        }
    }
}
