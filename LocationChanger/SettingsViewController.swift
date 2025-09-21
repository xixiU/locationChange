import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private let sections = ["应用设置", "位置设置", "关于"]
    private let settingsData = [
        [("自动保存历史", "switch"), ("显示坐标", "switch")],
        [("默认地图类型", "detail"), ("位置精度", "detail")],
        [("版本信息", "detail"), ("帮助与反馈", "detail")]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "设置"
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods
    private func showMapTypeSelection() {
        let alert = UIAlertController(title: "选择地图类型", message: nil, preferredStyle: .actionSheet)
        
        let mapTypes = [("标准", "standard"), ("卫星", "satellite"), ("混合", "hybrid")]
        let currentMapType = UserDefaults.standard.string(forKey: "MapType") ?? "standard"
        
        for (title, type) in mapTypes {
            let action = UIAlertAction(title: title, style: .default) { _ in
                UserDefaults.standard.set(type, forKey: "MapType")
                self.tableView.reloadData()
            }
            if type == currentMapType {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showLocationAccuracySelection() {
        let alert = UIAlertController(title: "选择位置精度", message: nil, preferredStyle: .actionSheet)
        
        let accuracies = [("最佳", "best"), ("十米", "nearestTenMeters"), ("百米", "hundredMeters")]
        let currentAccuracy = UserDefaults.standard.string(forKey: "LocationAccuracy") ?? "best"
        
        for (title, accuracy) in accuracies {
            let action = UIAlertAction(title: title, style: .default) { _ in
                UserDefaults.standard.set(accuracy, forKey: "LocationAccuracy")
                self.tableView.reloadData()
            }
            if accuracy == currentAccuracy {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    private func showVersionInfo() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        
        let alert = UIAlertController(
            title: "版本信息",
            message: "虚拟定位 v\(version) (\(build))\n\n一款简单易用的虚拟定位工具",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showHelpAndFeedback() {
        let alert = UIAlertController(
            title: "帮助与反馈",
            message: "使用说明:\n1. 点击地图设置虚拟位置\n2. 搜索地址快速定位\n3. 收藏常用位置\n4. 查看历史记录\n\n如有问题请联系开发者",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (title, type) = settingsData[indexPath.section][indexPath.row]
        
        if type == "switch" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(with: title)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
            
            // 设置详细文本
            switch title {
            case "默认地图类型":
                let mapType = UserDefaults.standard.string(forKey: "MapType") ?? "standard"
                cell.detailTextLabel?.text = mapType == "standard" ? "标准" : mapType == "satellite" ? "卫星" : "混合"
            case "位置精度":
                let accuracy = UserDefaults.standard.string(forKey: "LocationAccuracy") ?? "best"
                cell.detailTextLabel?.text = accuracy == "best" ? "最佳" : accuracy == "nearestTenMeters" ? "十米" : "百米"
            case "版本信息":
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                cell.detailTextLabel?.text = "v\(version)"
            default:
                cell.detailTextLabel?.text = nil
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let (title, _) = settingsData[indexPath.section][indexPath.row]
        
        switch title {
        case "默认地图类型":
            showMapTypeSelection()
        case "位置精度":
            showLocationAccuracySelection()
        case "版本信息":
            showVersionInfo()
        case "帮助与反馈":
            showHelpAndFeedback()
        default:
            break
        }
    }
}

// MARK: - SwitchTableViewCell
class SwitchTableViewCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        
        // 根据标题设置开关状态
        switch title {
        case "自动保存历史":
            switchControl.isOn = UserDefaults.standard.bool(forKey: "AutoSaveHistory")
        case "显示坐标":
            switchControl.isOn = UserDefaults.standard.bool(forKey: "ShowCoordinates")
        default:
            switchControl.isOn = false
        }
    }
    
    @objc private func switchValueChanged() {
        switch titleLabel.text {
        case "自动保存历史":
            UserDefaults.standard.set(switchControl.isOn, forKey: "AutoSaveHistory")
        case "显示坐标":
            UserDefaults.standard.set(switchControl.isOn, forKey: "ShowCoordinates")
        default:
            break
        }
    }
}