import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var virtualLocationSwitch: UISwitch!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var presetButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    // MARK: - Properties
    private let locationManager = VirtualLocationManager.shared
    private var currentLocationAnnotation: MKPointAnnotation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLocationDisplay()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "虚拟定位"
        view.backgroundColor = UIColor.systemBackground
        
        // 设置导航栏
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor.systemBlue
        
        // 设置当前位置标签
        currentLocationLabel.text = "当前位置: 未设置"
        currentLocationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        currentLocationLabel.textColor = UIColor.label
        currentLocationLabel.numberOfLines = 0
        
        // 设置虚拟定位开关
        virtualLocationSwitch.isOn = false
        virtualLocationSwitch.addTarget(self, action: #selector(virtualLocationSwitchChanged), for: .valueChanged)
        
        // 设置按钮样式
        setupButtons()
    }
    
    private func setupButtons() {
        let buttons = [searchButton, presetButton, historyButton, favoritesButton, settingsButton]
        
        for button in buttons {
            button?.layer.cornerRadius = 8
            button?.backgroundColor = UIColor.systemBlue
            button?.setTitleColor(UIColor.white, for: .normal)
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        searchButton.setTitle("搜索位置", for: .normal)
        presetButton.setTitle("预设位置", for: .normal)
        historyButton.setTitle("历史记录", for: .normal)
        favoritesButton.setTitle("收藏位置", for: .normal)
        settingsButton.setTitle("设置", for: .normal)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestLocationPermission()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // 设置初始地图区域（北京）
        let initialLocation = CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074)
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: false)
        
        // 添加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Actions
    @objc private func virtualLocationSwitchChanged() {
        if !virtualLocationSwitch.isOn {
            locationManager.disableVirtualLocation()
            removeCurrentLocationAnnotation()
            updateLocationDisplay()
            showAlert(title: "虚拟定位已关闭", message: "现在将使用真实位置")
        }
    }
    
    @objc private func mapLongPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            let alert = UIAlertController(title: "设置虚拟位置", message: "是否将此位置设为虚拟位置？", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                self.setVirtualLocation(coordinate: coordinate, name: "手动选择的位置")
            })
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchVC = LocationSearchViewController()
        searchVC.delegate = self
        let navController = UINavigationController(rootViewController: searchVC)
        present(navController, animated: true)
    }
    
    @IBAction func presetButtonTapped(_ sender: UIButton) {
        let presetVC = PresetLocationsViewController()
        presetVC.delegate = self
        navigationController?.pushViewController(presetVC, animated: true)
    }
    
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        let historyVC = HistoryViewController()
        historyVC.delegate = self
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @IBAction func favoritesButtonTapped(_ sender: UIButton) {
        let favoritesVC = FavoritesViewController()
        favoritesVC.delegate = self
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: - Private Methods
    private func setVirtualLocation(coordinate: CLLocationCoordinate2D, name: String, address: String = "") {
        let location = VirtualLocation(coordinate: coordinate, name: name, address: address)
        locationManager.setVirtualLocation(location)
        
        virtualLocationSwitch.isOn = true
        addLocationAnnotation(location)
        
        // 移动地图到新位置
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    private func addLocationAnnotation(_ location: VirtualLocation) {
        removeCurrentLocationAnnotation()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = location.name
        annotation.subtitle = location.address.isEmpty ? "虚拟位置" : location.address
        
        mapView.addAnnotation(annotation)
        currentLocationAnnotation = annotation
    }
    
    private func removeCurrentLocationAnnotation() {
        if let annotation = currentLocationAnnotation {
            mapView.removeAnnotation(annotation)
            currentLocationAnnotation = nil
        }
    }
    
    private func updateLocationDisplay() {
        if let currentLocation = locationManager.getCurrentLocation() {
            currentLocationLabel.text = "当前位置: \(currentLocation.name)"
            if !currentLocation.address.isEmpty {
                currentLocationLabel.text! += "\n\(currentLocation.address)"
            }
        } else {
            currentLocationLabel.text = "当前位置: 未设置"
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - LocationManagerDelegate
extension MainViewController: LocationManagerDelegate {
    func locationManager(_ manager: VirtualLocationManager, didUpdateLocation location: VirtualLocation) {
        DispatchQueue.main.async {
            self.updateLocationDisplay()
            self.addLocationAnnotation(location)
        }
    }
    
    func locationManager(_ manager: VirtualLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.showAlert(title: "定位错误", message: error.localizedDescription)
        }
    }
    
    func locationManagerDidChangeAuthorizationStatus(_ manager: VirtualLocationManager) {
        // 处理权限变化
    }
}

// MARK: - MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "VirtualLocationPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = UIColor.systemRed
            
            // 添加收藏按钮
            let favoriteButton = UIButton(type: .detailDisclosure)
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            annotationView?.rightCalloutAccessoryView = favoriteButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation,
              let title = annotation.title,
              let locationTitle = title else { return }
        
        let location = VirtualLocation(
            coordinate: annotation.coordinate,
            name: locationTitle,
            address: annotation.subtitle ?? ""
        )
        
        if locationManager.isLocationFavorited(location) {
            locationManager.removeFromFavorites(location)
            showAlert(title: "已取消收藏", message: "位置已从收藏中移除")
        } else {
            locationManager.addToFavorites(location)
            showAlert(title: "已收藏", message: "位置已添加到收藏")
        }
    }
}

// MARK: - Location Selection Delegate
protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(_ location: VirtualLocation)
}

extension MainViewController: LocationSelectionDelegate {
    func didSelectLocation(_ location: VirtualLocation) {
        setVirtualLocation(coordinate: location.coordinate, name: location.name, address: location.address)
    }
}