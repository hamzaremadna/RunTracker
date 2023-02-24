import UIKit
import CoreLocation
import MapKit
import Firebase

class NewRunViewController: UIViewController {
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var resumeButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!

  private var run: Run?
  private let locationManager = LocationManager.shared
  private var seconds = 0
  private var timer: Timer?
  private var z = true

private var distance = Measurement(value: 0, unit: UnitLength.kilometers)
  private var locationList: [CLLocation] = []
  var ref: DatabaseReference!
    
  override func viewDidLoad() {
    timeLabel.text = "00:00:00"
    distanceLabel.text = "0 mi"
    paceLabel.text = "0 min/km"
    super.viewDidLoad()
    stopButton.isHidden = true
    resumeButton.isHidden = true
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(long))
    resumeButton.addGestureRecognizer(longGesture)
    
    ref = Database.database().reference()


  }
  
  @objc func long() {
     let alertController = UIAlertController(title: "End run?",
                                             message: "¿Desea finalizar su carrera?",
                                             preferredStyle: .actionSheet)
     alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
     alertController.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
       self.stopRun()
      let date = Date()
      let formatter = DateFormatter()

      formatter.dateFormat = "dd.MM.yyyy"
      let result = formatter.string(from: date)
       let uid = Auth.auth().currentUser?.uid
      self.ref.child("data").child(uid!).childByAutoId().setValue(["time": self.timeLabel.text,"distance": self.distanceLabel.text,"pace": self.paceLabel.text,"Date": result,"hist": "\(self.distanceLabel.text!) en \(self.timeLabel.text!)"])
       self.saveRun()
       self.performSegue(withIdentifier: .details, sender: nil)

     })
     alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
       self.stopRun()
       _ = self.navigationController?.popToRootViewController(animated: true)
     })
     
     present(alertController, animated: true)
    }



    override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    locationManager.stopUpdatingLocation()
  }
  
  @IBAction func resumeTapped() {
    resumeButton.isHidden = true
    stopButton.isHidden = false
    b = true
    timer?.fire()
   }

    
  @IBAction func startTapped() {
        startButton.isHidden = true
    stopButton.isHidden = false
    startRun()
  }
 
  var sec = 0
  @IBAction func stopTapped() {
    stopButton.isHidden = true
    resumeButton.isHidden = false
    stopRun()
   sec = seconds
    locationManager.stopUpdatingLocation()

  }

  private func startRun() {
    updateDisplay()
    locationList.removeAll()
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      self.eachSecond()
    }
    startLocationUpdates()
}

  private func stopRun() {
    timer?.invalidate()
    c = false
  }
  var k = 0

  func eachSecond() {
    if b {seconds = sec
      distance = d
      
      c = true
      b = false
    }

    k += 1
    if k == 10 {
      seconds += 1
      k = 0
    }
      updateDisplay()
    
  }
  var c = true
  var d = Measurement(value: 0, unit: UnitLength.meters)
  private func updateDisplay() {
    
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.minutesPerKilometer)
    if c {d = distance}
    distanceLabel.text = "\(formattedDistance)"
    timeLabel.text = "\(formattedTime)"
      paceLabel.text = "\(formattedPace)"
    
  }
   var b = false
  private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 0.1
      locationManager.startUpdatingLocation()
    }
  
  
  private func saveRun() {
    let newRun = Run(context: CoreDataStack.context)
    newRun.distance = distance.value
    newRun.duration = Int16(seconds)
    newRun.timestamp = Date()
    
    for location in locationList {
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newRun.addToLocations(locationObject)
    }
    
    CoreDataStack.saveContext()
    
    run = newRun
  }
}


extension NewRunViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "RunDetailsViewController"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! RunDetailsViewController
      destination.run = run
    }
  }
}




extension NewRunViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 1 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}



extension NewRunViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
      renderer.strokeColor = .red
    renderer.lineWidth = 3
    return renderer
  }
}
