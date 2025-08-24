//  SettingsViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 设置项数据
    enum SettingSection {
        case appearance
        case language
        case information
        case storage
        case history
        
        var title: String {
            switch self {
            case .appearance: return "外观"
            case .language: return "语言"
            case .information: return "信息"
            case .storage: return "存储"
            case .history: return "历史记录"
            }
        }
    }
    
    enum SettingItem {
        case darkMode
        case language
        case about
        case usageInstructions
        case clearCache
        case history
        case donate  // 添加打赏选项
        
        var title: String {
            switch self {
            case .darkMode: return "深色模式"
            case .language: return "语言设置"
            case .about: return "关于我们"
            case .usageInstructions: return "使用说明"
            case .clearCache: return "清除缓存"
            case .history: return "历史记录"
            case .donate: return "打赏支持"  // 添加打赏标题
            }
        }
        
        var iconName: String {
            switch self {
            case .darkMode: return "moon.fill"
            case .language: return "globe"
            case .about: return "info.circle"
            case .usageInstructions: return "book"
            case .clearCache: return "trash"
            case .history: return "clock.arrow.circlepath"
            case .donate: return "heart.fill"  // 添加打赏图标
            }
        }
    }
    
    // 设置数据结构
    let settingData: [(section: SettingSection, items: [SettingItem])] = [
        (.appearance, [.darkMode]),
        (.language, [.language]),
        (.information, [.about, .usageInstructions, .donate]),  // 将打赏添加到信息部分
        (.storage, [.clearCache]),
        (.history, [.history])
    ]
    
    // 表格视图
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        self.title = "设置"
        
        // 设置背景颜色
        view.backgroundColor = .systemGroupedBackground
        
        // 添加表格视图
        view.addSubview(tableView)
        
        // 设置约束
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingData[section].section.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let settingItem = settingData[indexPath.section].items[indexPath.row]
        
        // 配置单元格
        cell.textLabel?.text = settingItem.title
        
        if #available(iOS 13.0, *) {
            cell.imageView?.image = UIImage(systemName: settingItem.iconName)
        } else {
            // 为iOS 13以下版本设置占位图标
            cell.imageView?.image = UIImage()
        }
        
        // 为深色模式设置开关
        if settingItem == .darkMode {
            let switchControl = UISwitch()
            switchControl.isOn = isDarkModeEnabled()
            switchControl.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
            cell.accessoryView = switchControl
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let settingItem = settingData[indexPath.section].items[indexPath.row]
        
        switch settingItem {
        case .language:
            showLanguageOptions()
        case .about:
            // 使用新的AboutViewController
            let aboutVC = AboutViewController()
            navigationController?.pushViewController(aboutVC, animated: true)
        case .usageInstructions:
            // 使用新的UsageInstructionsViewController
            let instructionsVC = UsageInstructionsViewController()
            navigationController?.pushViewController(instructionsVC, animated: true)
        case .clearCache:
            clearCache()
        case .history:
            // 使用新的HistoryViewController
            let historyVC = HistoryViewController()
            navigationController?.pushViewController(historyVC, animated: true)
        case .donate:
            // 使用新的DonateViewController
            let donateVC = DonateViewController()
            donateVC.hidesBottomBarWhenPushed = true  // 隐藏底部标签栏
            navigationController?.pushViewController(donateVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: - 设置功能实现
    
    // 检查深色模式是否开启
    func isDarkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    // 切换深色模式
    @objc func toggleDarkMode(_ sender: UISwitch) {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            window?.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
        } else {
            showToast("您的系统版本不支持深色模式")
            sender.isOn = false
        }
    }
    
    // 显示语言选项
    func showLanguageOptions() {
        let alertController = UIAlertController(title: "选择语言", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "简体中文", style: .default) { _ in
            self.saveLanguagePreference("zh-Hans")
            self.showToast("语言设置将在下次启动时生效")
        })
        
        alertController.addAction(UIAlertAction(title: "English", style: .default) { _ in
            self.saveLanguagePreference("en")
            self.showToast("Language will take effect on next launch")
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 保存语言偏好
    func saveLanguagePreference(_ languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "appLanguage")
    }
    
    
    // 清除缓存
    func clearCache() {
        let alertController = UIAlertController(title: "清除缓存", message: "确定要清除所有缓存数据吗？", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            // 清除临时文件
            let fileManager = FileManager.default
            let tempDir = NSTemporaryDirectory()
            
            do {
                let files = try fileManager.contentsOfDirectory(atPath: tempDir)
                for file in files {
                    let fileURL = URL(fileURLWithPath: tempDir).appendingPathComponent(file)
                    try fileManager.removeItem(at: fileURL)
                }
                self.showToast("缓存清除成功",)
            } catch {
                self.showToast("缓存清除失败：\(error.localizedDescription)")
            }
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 清除历史记录
    @objc func clearHistory() {
        let alertController = UIAlertController(title: "清除历史记录", message: "确定要清除所有转换历史吗？", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            // 清除历史记录逻辑
            // 这里可以根据实际存储方式清除历史数据
            self.showToast("历史记录已清除")
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 显示提示信息
    func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 100, y: view.frame.height - 150, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}
