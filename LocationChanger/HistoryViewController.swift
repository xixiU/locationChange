import UIKit

class HistoryViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private let locationManager = VirtualLocationManager.shared
    private var historicalLocations: [VirtualLocation] = []
    
    weak var delegate: LocationSelectionDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadHistoricalLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoricalLocations()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = "历史记录"
        
        // 添加清除按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "清除",
            style: .plain,
            target: self,
            action: #selector(clearHistory)
        )
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
    
    private func loadHistoricalLocations() {
        historicalLocations = locationManager.getHistoricalLocations()
        tableView.reloadData()
        
        // 更新清除按钮状态
        navigationItem.rightBarButtonItem?.isEnabled = !historicalLocations.isEmpty
    }
    
    // MARK: - Actions
    @objc private func clearHistory() {
        let alert = UIAlertController(
            title: "清除历史记录",
            message: "确定要清除所有历史记录吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "清除", style: .destructive) { _ in
            // 清除历史记录的逻辑需要在LocationManager中实现
            self.historicalLocations.removeAll()
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historicalLocations.isEmpty {
            // 显示空状态
            let emptyLabel = UILabel()
            emptyLabel.text = "暂无历史记录"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = UIColor.secondaryLabel
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = emptyLabel
            return 0
        } else {
            tableView.backgroundView = nil
            return historicalLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        let location = historicalLocations[indexPath.row]
        cell.configure(with: location, showFavoriteButton: true)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLocation = historicalLocations[indexPath.row]
        delegate?.didSelectLocation(selectedLocation)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            historicalLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if historicalLocations.isEmpty {
                navigationItem.rightBarButtonItem?.isEnabled = false
                tableView.reloadData() // 重新加载以显示空状态
            }
        }
    }
}

// MARK: - LocationTableViewCellDelegate
extension HistoryViewController: LocationTableViewCellDelegate {
    func didTapFavoriteButton(for location: VirtualLocation) {
        if locationManager.isLocationFavorited(location) {
            locationManager.removeFromFavorites(location)
        } else {
            locationManager.addToFavorites(location)
        }
        tableView.reloadData()
    }
}