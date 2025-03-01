### vscdoe-tuby
- https://github.com/rubyide/vscode-ruby/wiki/2.-Launching-from-VS-Code

### XCFramework 构建工具使用说明

`xcframework.rb` 是一个用于构建 iOS/macOS XCFramework 的自动化工具。它可以帮助你轻松地将框架打包成支持多平台的 XCFramework 格式。

#### 基本用法

```bash
ruby xcframework.rb --sdk_target_name <target_name> [options]
```

#### 参数说明

必需参数：
- `--sdk_target_name <target>`: Xcode 项目中的目标名称

可选参数：
- `--dst_path <path>`: 输出目录路径（默认为 'framework'）
- `--product_name <name>`: 产品名称（默认与 sdk_target_name 相同）
- `--extra_simulator_build_settings <settings>`: 模拟器额外的构建设置
- `--build_macos`: 是否构建 macOS 框架版本
- `-h, --help`: 显示帮助信息

#### 使用示例

1. 基本用法（仅构建 iOS 版本）：
```bash
ruby xcframework.rb --sdk_target_name MyFramework
```

2. 指定输出目录：
```bash
ruby xcframework.rb --sdk_target_name MyFramework --dst_path output
```

3. 构建包含 macOS 版本：
```bash
ruby xcframework.rb --sdk_target_name MyFramework --build_macos
```

4. 完整示例：
```bash
ruby xcframework.rb \
  --sdk_target_name MyFramework \
  --dst_path output \
  --product_name CustomName \
  --extra_simulator_build_settings "ENABLE_BITCODE=YES" \
  --build_macos
```

#### 输出说明

- 脚本会在指定目录（默认为 'framework'）下生成 `.xcframework` 文件
- 构建过程中会显示详细的进度信息
- 构建完成后会自动打开输出目录
- 支持的平台：
  - iOS 设备（arm64）
  - iOS 模拟器（x86_64/arm64）
  - macOS（可选）

#### 注意事项

1. 确保已安装 Xcode 命令行工具
2. 在包含 Xcode 项目的目录中运行脚本
3. 目标必须正确配置支持框架构建
4. 构建过程中会自动清理临时文件