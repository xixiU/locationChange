import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private let locationManager = VirtualLocationManager.shared
    private var favoriteLocations: [VirtualLocation] = []
    
    weak var delegate: LocationSelectionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadFavoriteLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteLocations()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "收藏位置"
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
    
    private func loadFavoriteLocations() {
        favoriteLocations = locationManager.getFavoriteLocations()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteLocations.isEmpty {
            // 显示空状态
            let emptyLabel = UILabel()
            emptyLabel.text = "暂无收藏位置\n长按地图上的位置标记可添加收藏"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = UIColor.secondaryLabel
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            emptyLabel.numberOfLines = 0
            tableView.backgroundView = emptyLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return favoriteLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        let location = favoriteLocations[indexPath.row]
        cell.configure(with: location, showFavoriteButton: false) // 收藏页面不显示收藏按钮
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLocation = favoriteLocations[indexPath.row]
        delegate?.didSelectLocation(selectedLocation)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = favoriteLocations[indexPath.row]
            locationManager.removeFromFavorites(location)
            favoriteLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if favoriteLocations.isEmpty {
                tableView.reloadData() // 重新加载以显示空状态
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消收藏"
    }
}