# 虚拟定位 iOS 应用

![CI Status](https://github.com/your-username/location_change/workflows/Continuous%20Integration/badge.svg)
![iOS Build](https://github.com/your-username/location_change/workflows/iOS%20Build%20and%20Archive/badge.svg)
![Release](https://github.com/your-username/location_change/workflows/Release%20Build/badge.svg)
![iOS Version](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)
![Xcode Version](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg)
![Swift Version](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)

一款功能完整的iOS虚拟定位应用，支持自定义位置设置、位置搜索、历史记录和收藏功能。

## 功能特性

### 🎯 核心功能

- **虚拟定位设置**: 点击地图或搜索地址设置虚拟位置
- **实时位置切换**: 一键开启/关闭虚拟定位功能
- **地图交互**: 支持长按地图选择位置
- **位置搜索**: 智能搜索地址和地点

### 📍 位置管理

- **预设位置**: 内置热门城市和地标位置
- **历史记录**: 自动保存使用过的位置
- **收藏功能**: 收藏常用位置便于快速访问
- **位置详情**: 显示位置名称、地址和坐标信息

### ⚙️ 设置选项

- **地图类型**: 支持标准、卫星、混合地图
- **位置精度**: 可选择不同的定位精度
- **显示设置**: 控制坐标显示等界面选项
- **历史管理**: 自动保存历史记录开关

## 项目结构

```
LocationChanger/
├── AppDelegate.swift              # 应用程序代理
├── SceneDelegate.swift            # 场景代理
├── LocationManager.swift          # 核心定位管理器
├── MainViewController.swift       # 主界面控制器
├── MapViewController.swift        # 地图选择界面
├── LocationSearchViewController.swift  # 位置搜索界面
├── PresetLocationsViewController.swift # 预设位置界面
├── HistoryViewController.swift    # 历史记录界面
├── FavoritesViewController.swift  # 收藏位置界面
├── SettingsViewController.swift   # 设置界面
├── LocationTableViewCell.swift    # 位置列表单元格
├── Base.lproj/
│   ├── Main.storyboard           # 主界面故事板
│   └── LaunchScreen.storyboard   # 启动界面故事板
├── Assets.xcassets/              # 应用资源
└── Info.plist                    # 应用配置文件
```

## 技术实现

### 框架依赖

- **UIKit**: 用户界面框架
- **MapKit**: 地图和位置服务
- **CoreLocation**: 位置定位功能

### 核心类说明

#### VirtualLocationManager

- 单例模式的位置管理器
- 处理虚拟位置的设置和切换
- 管理历史记录和收藏位置
- 提供位置权限管理

#### VirtualLocation

- 位置数据模型
- 包含坐标、名称、地址和时间戳
- 支持数据持久化

#### 界面控制器

- **MainViewController**: 主界面，包含地图和功能按钮
- **LocationSearchViewController**: 位置搜索界面
- **MapViewController**: 地图选择界面
- **其他ViewController**: 各种功能界面

## 使用说明

### 基本操作

1. **设置虚拟位置**:
   - 点击"搜索位置"按钮搜索地址
   - 或长按地图选择位置
   - 或从预设位置中选择

2. **开启虚拟定位**:
   - 设置位置后，打开虚拟定位开关
   - 应用将使用设置的虚拟位置

3. **管理位置**:
   - 查看历史记录中的使用过的位置
   - 收藏常用位置便于快速访问
   - 在设置中调整应用行为

### 权限要求

- **位置权限**: 应用需要"使用应用时"的位置权限
- 首次使用时会自动请求权限

## 注意事项

### 重要说明

⚠️ **本应用仅供开发测试使用**

- 虚拟定位可能违反某些应用的使用条款
- 请勿用于欺诈或其他违法行为
- 使用前请了解相关法律法规

### 技术限制

- 虚拟定位仅在应用内生效
- 系统级定位服务不受影响
- 部分应用可能有反虚拟定位机制

## 开发环境

- **Xcode**: 15.0+
- **iOS**: 17.0+
- **Swift**: 5.0+
- **部署目标**: iPhone & iPad

## 安装说明

### 本地开发安装

1. 克隆项目到本地

   ```bash
   git clone https://github.com/your-username/location_change.git

   cd location_change

   ```

2. 使用Xcode打开项目文件

   ```bash
   open LocationChanger.xcodeproj
   ```

3. 连接iOS设备或选择模拟器
4. 点击运行按钮编译安装
5. 首次运行需要信任开发者证书

### 自动化构建

本项目配置了GitHub Actions自动化工作流：

- **持续集成**: 每次推送代码时自动进行代码检查和构建测试
- **自动构建**: 合并到主分支时自动构建IPA文件
- **发布管理**: 创建Release时自动生成发布包和说明

#### 创建发布版本

1. **手动触发发布**:
   - 访问GitHub Actions页面
   - 选择"Release Build"工作流
   - 点击"Run workflow"输入版本信息

2. **自动发布**:
   - 在GitHub上创建新的Release
   - 系统将自动构建并上传发布包

详细的GitHub Actions配置说明请查看 [.github/README.md](.github/README.md)

## 许可证

本项目仅供学习和研究使用，请勿用于商业用途。
