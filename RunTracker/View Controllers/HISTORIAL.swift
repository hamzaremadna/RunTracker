
import UIKit
import Firebase

class historique: UITableViewController {
    
    let cellId = "cellId"
    
    var data = [User]()
    @IBOutlet var bar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      let uid = Auth.auth().currentUser?.uid

        Database.database().reference().child("users").child(uid!).child("profil").observeSingleEvent(of: .value, with: { (snapshot) in
                   
                   if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.bar.title = dictionary["nom"] as? String ?? ""
                 }
  })
    
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    func fetchUser() {
      let uid = Auth.auth().currentUser?.uid

      Database.database().reference().child("data").child(uid!).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.data.append(user)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
            }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        let user = data[indexPath.row]
        cell.textLabel?.text = user.Date
      cell.textLabel!.font = UIFont(name:"Noteworthy-Bold", size:20)

      cell.detailTextLabel?.text = user.hist
      cell.detailTextLabel!.font = UIFont(name:"Noteworthy", size:13)

        return cell
    }

}

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
