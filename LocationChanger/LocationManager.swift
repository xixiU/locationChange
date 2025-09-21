import Foundation
import CoreLocation
import UIKit

// 虚拟位置数据模型
struct VirtualLocation {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let timestamp: Date
    
    init(coordinate: CLLocationCoordinate2D, name: String, address: String = "") {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.timestamp = Date()
    }
}

// 定位管理器协议
protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: VirtualLocationManager, didUpdateLocation location: VirtualLocation)
    func locationManager(_ manager: VirtualLocationManager, didFailWithError error: Error)
    func locationManagerDidChangeAuthorizationStatus(_ manager: VirtualLocationManager)
}

class VirtualLocationManager: NSObject {
    
    // MARK: - Properties
    static let shared = VirtualLocationManager()
    
    weak var delegate: LocationManagerDelegate?
    private let locationManager = CLLocationManager()
    private var currentVirtualLocation: VirtualLocation?
    private var isVirtualLocationEnabled = false
    
    // 历史位置存储
    private var historicalLocations: [VirtualLocation] = []
    private var favoriteLocations: [VirtualLocation] = []
    
    // 常用位置预设
    private let presetLocations: [VirtualLocation] = [
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074), name: "天安门广场", address: "北京市东城区天安门广场"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737), name: "外滩", address: "上海市黄浦区中山东一路"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694), name: "维多利亚港", address: "香港特别行政区中环"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 34.3416, longitude: 108.9398), name: "大雁塔", address: "陕西省西安市雁塔区"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 30.2741, longitude: 120.1551), name: "西湖", address: "浙江省杭州市西湖区"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 40.7589, longitude: -73.9851), name: "时代广场", address: "纽约市曼哈顿"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 48.8584, longitude: 2.2945), name: "埃菲尔铁塔", address: "法国巴黎"),
        VirtualLocation(coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503), name: "东京塔", address: "日本东京都港区")
    ]
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        loadStoredData()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showLocationPermissionAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func setVirtualLocation(_ location: VirtualLocation) {
        currentVirtualLocation = location
        isVirtualLocationEnabled = true
        
        // 添加到历史记录
        addToHistory(location)
        
        // 通知代理
        delegate?.locationManager(self, didUpdateLocation: location)
        
        // 保存数据
        saveStoredData()
        
        print("虚拟位置已设置: \(location.name) (\(location.coordinate.latitude), \(location.coordinate.longitude))")
    }
    
    func getCurrentLocation() -> VirtualLocation? {
        if isVirtualLocationEnabled {
            return currentVirtualLocation
        } else {
            // 返回真实位置（如果有权限）
            if let realLocation = locationManager.location {
                return VirtualLocation(
                    coordinate: realLocation.coordinate,
                    name: "当前真实位置",
                    address: ""
                )
            }
        }
        return nil
    }
    
    func disableVirtualLocation() {
        isVirtualLocationEnabled = false
        currentVirtualLocation = nil
        print("虚拟定位已关闭")
    }
    
    func getPresetLocations() -> [VirtualLocation] {
        return presetLocations
    }
    
    func getHistoricalLocations() -> [VirtualLocation] {
        return historicalLocations.reversed() // 最新的在前面
    }
    
    func getFavoriteLocations() -> [VirtualLocation] {
        return favoriteLocations
    }
    
    func addToFavorites(_ location: VirtualLocation) {
        // 检查是否已经在收藏中
        if !favoriteLocations.contains(where: { $0.name == location.name }) {
            favoriteLocations.append(location)
            saveStoredData()
        }
    }
    
    func removeFromFavorites(_ location: VirtualLocation) {
        favoriteLocations.removeAll { $0.name == location.name }
        saveStoredData()
    }
    
    func isLocationFavorited(_ location: VirtualLocation) -> Bool {
        return favoriteLocations.contains { $0.name == location.name }
    }
    
    // MARK: - Private Methods
    private func addToHistory(_ location: VirtualLocation) {
        // 移除重复的位置
        historicalLocations.removeAll { $0.name == location.name }
        
        // 添加到历史记录
        historicalLocations.append(location)
        
        // 限制历史记录数量
        if historicalLocations.count > 50 {
            historicalLocations.removeFirst()
        }
    }
    
    private func showLocationPermissionAlert() {
        DispatchQueue.main.async {
            guard let topViewController = UIApplication.shared.windows.first?.rootViewController else { return }
            
            let alert = UIAlertController(
                title: "需要位置权限",
                message: "请在设置中允许应用访问位置信息以获得更好的体验",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "设置", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            
            topViewController.present(alert, animated: true)
        }
    }
    
    // MARK: - Data Persistence
    private func saveStoredData() {
        let encoder = JSONEncoder()
        
        // 保存历史位置
        if let historyData = try? encoder.encode(historicalLocations.map { LocationData(from: $0) }) {
            UserDefaults.standard.set(historyData, forKey: "HistoricalLocations")
        }
        
        // 保存收藏位置
        if let favoritesData = try? encoder.encode(favoriteLocations.map { LocationData(from: $0) }) {
            UserDefaults.standard.set(favoritesData, forKey: "FavoriteLocations")
        }
    }
    
    private func loadStoredData() {
        let decoder = JSONDecoder()
        
        // 加载历史位置
        if let historyData = UserDefaults.standard.data(forKey: "HistoricalLocations"),
           let locationDataArray = try? decoder.decode([LocationData].self, from: historyData) {
            historicalLocations = locationDataArray.map { $0.toVirtualLocation() }
        }
        
        // 加载收藏位置
        if let favoritesData = UserDefaults.standard.data(forKey: "FavoriteLocations"),
           let locationDataArray = try? decoder.decode([LocationData].self, from: favoritesData) {
            favoriteLocations = locationDataArray.map { $0.toVirtualLocation() }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension VirtualLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 如果启用了虚拟定位，忽略真实位置更新
        if !isVirtualLocationEnabled, let location = locations.last {
            let virtualLocation = VirtualLocation(
                coordinate: location.coordinate,
                name: "当前位置",
                address: ""
            )
            delegate?.locationManager(self, didUpdateLocation: virtualLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(self, didFailWithError: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManagerDidChangeAuthorizationStatus(self)
    }
}

// MARK: - Helper Structures for Persistence
private struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let name: String
    let address: String
    let timestamp: Date
    
    init(from location: VirtualLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.name = location.name
        self.address = location.address
        self.timestamp = location.timestamp
    }
    
    func toVirtualLocation() -> VirtualLocation {
        var location = VirtualLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            name: name,
            address: address
        )
        return location
    }
}