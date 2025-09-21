import UIKit

class PresetLocationsViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private let locationManager = VirtualLocationManager.shared
    private var presetLocations: [VirtualLocation] = []
    
    weak var delegate: LocationSelectionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadPresetLocations()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "预设位置"
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationCell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadPresetLocations() {
        presetLocations = locationManager.getPresetLocations()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PresetLocationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        let location = presetLocations[indexPath.row]
        cell.configure(with: location, showFavoriteButton: true)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLocation = presetLocations[indexPath.row]
        delegate?.didSelectLocation(selectedLocation)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - LocationTableViewCellDelegate
extension PresetLocationsViewController: LocationTableViewCellDelegate {
    func didTapFavoriteButton(for location: VirtualLocation) {
        if locationManager.isLocationFavorited(location) {
            locationManager.removeFromFavorites(location)
        } else {
            locationManager.addToFavorites(location)
        }
        tableView.reloadData()
    }
}