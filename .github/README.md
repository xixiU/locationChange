# GitHub Actions 工作流说明

本项目包含三个GitHub Actions工作流，用于自动化iOS应用的构建、测试和发布流程。

## 📋 工作流概览

### 1. 持续集成 (CI) - `ci.yml`

**触发条件**:

- 推送到 `main`、`develop`、`feature/*` 分支
- 创建针对 `main`、`develop` 分支的Pull Request

**主要功能**:

- ✅ 代码质量检查
- ✅ Swift语法验证
- ✅ 项目编译测试
- ✅ 安全性扫描
- ✅ 代码统计分析

### 2. iOS构建和归档 - `ios-build.yml`

**触发条件**:

- 推送到 `main`、`develop` 分支
- 创建针对 `main` 分支的Pull Request
- 发布新版本

**主要功能**:

- 🔨 完整的iOS项目构建
- 🧪 运行单元测试
- 📦 创建IPA归档文件
- ☁️ 上传构建产物
- 📱 (可选) 上传到App Store Connect

### 3. 发布构建 - `release.yml`

**触发条件**:

- 创建新的GitHub Release
- 手动触发 (workflow_dispatch)

**主要功能**:

- 📝 自动更新版本号
- 🏗️ 构建Release版本
- 📦 创建发布包
- 📋 生成发布说明
- 🚀 创建GitHub Release

## 🚀 使用指南

### 基本开发流程

1. **功能开发**:

   ```bash
   git checkout -b feature/new-feature
   # 进行开发...
   git push origin feature/new-feature
   ```

   → 触发 `ci.yml` 进行代码检查

2. **合并到主分支**:

   ```bash
   # 创建Pull Request到main分支
   ```

   → 触发 `ci.yml` 和 `ios-build.yml`

3. **发布新版本**:
   - **方法1**: 手动触发发布工作流
     - 访问Actions页面
     - 选择"Release Build"
     - 点击"Run workflow"
     - 输入版本号和发布说明

   - **方法2**: 创建GitHub Release
     - 在GitHub上创建新的Release
     - 设置tag (如: v1.0.0)
     - 工作流将自动触发

### 配置代码签名 (可选)

如果需要生成可安装的IPA文件，需要配置以下Secrets:

```bash
# 在GitHub仓库设置中添加以下Secrets:
BUILD_CERTIFICATE_BASE64      # iOS开发证书 (Base64编码)
P12_PASSWORD                 # 证书密码
BUILD_PROVISION_PROFILE_BASE64 # 描述文件 (Base64编码)
APPSTORE_ISSUER_ID           # App Store Connect API密钥
APPSTORE_KEY_ID              # App Store Connect API密钥ID
APPSTORE_PRIVATE_KEY         # App Store Connect私钥
```

### 设置步骤

1. **准备证书和描述文件**:

   ```bash
   # 将.p12证书转换为Base64
   base64 -i certificate.p12 -o certificate.txt
   
   # 将.mobileprovision文件转换为Base64
   base64 -i profile.mobileprovision -o profile.txt
   ```

2. **在GitHub中配置Secrets**:
   - 访问仓库的 Settings → Secrets and variables → Actions
   - 添加上述Secrets

## 📊 工作流状态徽章

在README.md中添加状态徽章:

```markdown
![CI Status](https://github.com/your-username/location_change/workflows/Continuous%20Integration/badge.svg)
![iOS Build](https://github.com/your-username/location_change/workflows/iOS%20Build%20and%20Archive/badge.svg)
![Release](https://github.com/your-username/location_change/workflows/Release%20Build/badge.svg)
```

## 🔧 自定义配置

### 修改iOS版本和Xcode版本

在工作流文件中修改以下配置:

```yaml
# 修改Xcode版本
- name: Setup Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.0'  # 修改为所需版本

# 修改iOS模拟器版本
-destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

### 添加额外的检查步骤

可以在`ci.yml`中添加更多检查:

```yaml
- name: SwiftLint检查
  run: |
    if which swiftlint >/dev/null; then
      swiftlint
    else
      echo "SwiftLint未安装，跳过代码风格检查"
    fi

- name: 依赖安全检查
  run: |
    # 检查第三方依赖的安全漏洞
    # 可以集成其他安全扫描工具
```

## 📝 注意事项

1. **权限配置**: 确保GitHub Actions有足够的权限访问仓库
2. **资源限制**: 注意GitHub Actions的使用限制和配额
3. **敏感信息**: 不要在代码中硬编码密钥和密码
4. **构建时间**: iOS构建可能需要较长时间，合理设置超时时间
5. **存储空间**: 定期清理旧的构建产物以节省存储空间

## 🆘 故障排除

### 常见问题

1. **构建失败**: 检查Xcode版本和iOS SDK兼容性
2. **代码签名错误**: 验证证书和描述文件配置
3. **权限问题**: 确保Secrets配置正确
4. **依赖问题**: 检查第三方库的兼容性

### 调试方法

1. 查看Actions运行日志
2. 在本地复现构建环境
3. 使用`workflow_dispatch`手动触发测试
4. 检查项目配置文件

## 📚 相关资源

- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Xcode构建设置](https://developer.apple.com/documentation/xcode)
- [iOS代码签名指南](https://developer.apple.com/support/code-signing/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
