import UIKit
import CloudKit

class ActiveHazardReportsViewController:    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    var hazardReports = [HazardReport]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let predicate = NSPredicate(format: "isResolved == 0")
        let activeHazardsQuery = CKQuery(recordType: "HazardReport", predicate: predicate)
        
        let creationDateSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        activeHazardsQuery.sortDescriptors = [creationDateSortDescriptor]
        
        CKContainer.default().publicCloudDatabase.perform(activeHazardsQuery,
                                                          inZoneWith: nil)
        { (records, error) in
            guard let records = records else {return}
            self.hazardReports = records.map { HazardReport(record:$0) }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView Data Source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hazardReportCell",
                                                 for: indexPath)
        
        cell.textLabel?.text = "January 1, 2018"
        cell.detailTextLabel?.text = "At the entrance to building 4 there's a puddle of water. I just about slipped and fell!"
        
        return cell
    }
    
    // MARK: TableView Delegate methods
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "hazardReportDetails":
            _ = segue.destination as! HazardReportDetailsViewController
        case "addHazardReport":
            let navigationController = segue.destination as! UINavigationController
            _ = navigationController.viewControllers[0] as! EditHazardReportViewController
        default: break
        }
    }
}
