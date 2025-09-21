import UIKit

protocol LocationTableViewCellDelegate: AnyObject {
    func didTapFavoriteButton(for location: VirtualLocation)
}

class LocationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: LocationTableViewCellDelegate?
    private var currentLocation: VirtualLocation?
    
    // MARK: - UI Elements
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let coordinatesLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let containerStackView = UIStackView()
    private let textStackView = UIStackView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .default
        
        // 设置图标
        iconImageView.image = UIImage(systemName: "location.circle.fill")
        iconImageView.tintColor = UIColor.systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置标题标签
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.label
        titleLabel.numberOfLines = 1
        
        // 设置地址标签
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = UIColor.secondaryLabel
        addressLabel.numberOfLines = 2
        
        // 设置坐标标签
        coordinatesLabel.font = UIFont.systemFont(ofSize: 12)
        coordinatesLabel.textColor = UIColor.tertiaryLabel
        coordinatesLabel.numberOfLines = 1
        
        // 设置收藏按钮
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = UIColor.systemRed
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置文本堆栈视图
        textStackView.axis = .vertical
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        textStackView.spacing = 4
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(addressLabel)
        textStackView.addArrangedSubview(coordinatesLabel)
        
        // 设置容器堆栈视图
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.distribution = .fill
        containerStackView.spacing = 12
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(textStackView)
        containerStackView.addArrangedSubview(favoriteButton)
        
        contentView.addSubview(containerStackView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with location: VirtualLocation, showFavoriteButton: Bool = true) {
        currentLocation = location
        
        titleLabel.text = location.name
        addressLabel.text = location.address.isEmpty ? "无详细地址" : location.address
        
        // 显示坐标（如果设置中启用）
        if UserDefaults.standard.bool(forKey: "ShowCoordinates") {
            coordinatesLabel.text = String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
            coordinatesLabel.isHidden = false
        } else {
            coordinatesLabel.isHidden = true
        }
        
        // 设置收藏按钮状态
        favoriteButton.isHidden = !showFavoriteButton
        if showFavoriteButton {
            let isFavorited = VirtualLocationManager.shared.isLocationFavorited(location)
            favoriteButton.isSelected = isFavorited
        }
        
        // 根据位置类型设置图标
        switch location.name {
        case let name where name.contains("天安门"), let name where name.contains("广场"):
            iconImageView.image = UIImage(systemName: "building.columns.fill")
        case let name where name.contains("机场"):
            iconImageView.image = UIImage(systemName: "airplane")
        case let name where name.contains("火车站"), let name where name.contains("地铁"):
            iconImageView.image = UIImage(systemName: "tram.fill")
        case let name where name.contains("医院"):
            iconImageView.image = UIImage(systemName: "cross.fill")
        case let name where name.contains("学校"), let name where name.contains("大学"):
            iconImageView.image = UIImage(systemName: "book.fill")
        case let name where name.contains("公园"), let name where name.contains("山"), let name where name.contains("湖"):
            iconImageView.image = UIImage(systemName: "tree.fill")
        case "手动选择的位置", "手动选择":
            iconImageView.image = UIImage(systemName: "hand.point.up.left.fill")
        default:
            iconImageView.image = UIImage(systemName: "location.circle.fill")
        }
    }
    
    // MARK: - Actions
    @objc private func favoriteButtonTapped() {
        guard let location = currentLocation else { return }
        delegate?.didTapFavoriteButton(for: location)
        
        // 更新按钮状态
        favoriteButton.isSelected.toggle()
        
        // 添加动画效果
        UIView.animate(withDuration: 0.2, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        currentLocation = nil
        titleLabel.text = nil
        addressLabel.text = nil
        coordinatesLabel.text = nil
        favoriteButton.isSelected = false
        favoriteButton.isHidden = false
        iconImageView.image = UIImage(systemName: "location.circle.fill")
    }
}