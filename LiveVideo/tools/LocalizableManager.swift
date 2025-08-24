//
//  LocalizableManager.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/8/24.
//

import Foundation
import UIKit

class LocalizableManager: NSObject {
    
    // 单例实例
    static let shared = LocalizableManager()
    
    // 当前语言偏好设置键
    private let currentLanguageKey = "LiveVideo_CurrentLanguage"
    
    // 支持的语言列表
    let supportedLanguages = ["en", "zh-Hans"]
    
    // 当前语言
    var currentLanguage: String {
        get {
            // 首先检查用户偏好设置
            if let language = UserDefaults.standard.string(forKey: currentLanguageKey) {
                return language
            }
            // 如果没有用户偏好，返回系统首选语言
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            
            // 检查系统语言是否在支持的语言列表中
            for supportedLanguage in supportedLanguages {
                if systemLanguage.hasPrefix(supportedLanguage) {
                    return supportedLanguage
                }
            }
            
            // 默认返回英语
            return "en"
        }
        set {
            if supportedLanguages.contains(newValue) {
                UserDefaults.standard.set(newValue, forKey: currentLanguageKey)
                UserDefaults.standard.synchronize()
                // 发送语言变化通知
                NotificationCenter.default.post(name: .languageDidChange, object: nil)
            }
        }
    }
    
    // 获取本地化字符串
    func localizedString(for key: String, comment: String = "") -> String {
        // 检查是否存在自定义语言
        if let customBundle = customBundle {
            return NSLocalizedString(key, tableName: "Localizable", bundle: customBundle, comment: comment)
        }
        
        // 否则使用系统本地化
        return NSLocalizedString(key, comment: comment)
    }
    
    // 自定义bundle
    private var customBundle: Bundle? {
        guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }
    
    // 切换语言
    func changeLanguage(to languageCode: String, completion: (() -> Void)? = nil) {
        if supportedLanguages.contains(languageCode) {
            currentLanguage = languageCode
            
            // 调用完成回调
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    // 获取当前语言的显示名称
    func displayName(for languageCode: String) -> String {
        let locale = Locale(identifier: languageCode)
        return locale.localizedString(forLanguageCode: languageCode) ?? languageCode
    }
    
    // 初始化方法
    private override init() {
        super.init()
    }
}

// 为String添加本地化扩展
extension String {
    var localized: String {
        return LocalizableManager.shared.localizedString(for: self)
    }
    
    func localized(withComment comment: String = "") -> String {
        return LocalizableManager.shared.localizedString(for: self, comment: comment)
    }
}

// 为UIViewController添加语言切换通知
protocol LanguageChangeable: AnyObject {
    func languageDidChange()
}

// 语言变化通知
extension Notification.Name {
    static let languageDidChange = Notification.Name("LiveVideo_LanguageDidChange")
}

// 为UIViewController添加语言切换支持
extension UIViewController: LanguageChangeable {
    // 将方法标记为@objc，允许子类重写
    @objc func languageDidChange() {
        // 默认实现为空，子类可以重写此方法以响应语言变化
    }
    
    // 注册语言变化通知
    func registerForLanguageChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageDidChange, object: nil)
    }
    
    // 取消注册语言变化通知
    func unregisterForLanguageChanges() {
        NotificationCenter.default.removeObserver(self, name: .languageDidChange, object: nil)
    }
    
    // 处理语言变化
    @objc func handleLanguageChange() {
        languageDidChange()
    }
}