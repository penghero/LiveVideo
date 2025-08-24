//
//  AboutViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import SnapKit

class AboutViewController: UIViewController {
    
    // 应用图标视图
    private let appIconView = UIImageView()
    
    // 应用标题标签
    private let appTitleLabel = UILabel()
    
    // 版本信息标签
    private let versionLabel = UILabel()
    
    // 应用描述标签
    private let descriptionLabel = UILabel()
    
    // 功能亮点标签
    private let featuresLabel = UILabel()
    
    // 版权信息标签
    private let copyrightLabel = UILabel()
    
    // 内容卡片视图
    private let contentCard = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题 - 使用本地化字符串
        self.title = "about_title".localized
        
        // 设置背景颜色
        view.backgroundColor = .white
        
        // 初始化UI元素
        setupUI()
        
        // 添加子视图
        setupSubviews()
        
        // 设置约束
        setupConstraints()
        
        // 添加动画效果
        setupAnimations()
    }
    
    private func setupUI() {
        // 配置应用图标
        if let appIcon = UIImage(named: "live_logo") {
            appIconView.image = appIcon
        } else {
            // 如果没有找到自定义图标，使用系统默认图标
            appIconView.image = UIImage(systemName: "video.fill")
        }
        appIconView.contentMode = .scaleAspectFit
        appIconView.layer.cornerRadius = 20.0
        appIconView.layer.masksToBounds = true
        appIconView.layer.borderWidth = 2.0
        
        // 修复错误：将accentColor替换为系统蓝色
        if #available(iOS 13.0, *) {
            appIconView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            appIconView.layer.borderColor = UIColor.blue.cgColor
        }
        
        // 配置应用标题 - 使用本地化字符串
        appTitleLabel.text = "app_name".localized
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        appTitleLabel.textAlignment = .center
        
        // 配置版本信息
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, 
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLabel.text = String(format: "about_version".localized, version, build)
        } else if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = String(format: "about_version".localized, version)
        }
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.textColor = .gray
        versionLabel.textAlignment = .center
        
        // 配置应用描述 - 使用本地化字符串
        descriptionLabel.text = "about_full_description".localized
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        // 配置功能亮点 - 使用本地化字符串
        featuresLabel.text = "about_features_list".localized
        featuresLabel.font = UIFont.systemFont(ofSize: 16)
        featuresLabel.textColor = .darkGray
        featuresLabel.textAlignment = .center
        featuresLabel.numberOfLines = 0
        featuresLabel.lineBreakMode = .byWordWrapping
        
        // 配置版权信息 - 使用本地化字符串
        copyrightLabel.text = String(format: "about_copyright".localized, "2025", "chenpeng")
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textColor = .lightGray
        copyrightLabel.textAlignment = .center
        copyrightLabel.numberOfLines = 0
        
        // 配置内容卡片
        contentCard.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        contentCard.layer.cornerRadius = 20.0
        contentCard.layer.shadowColor = UIColor.black.cgColor
        contentCard.layer.shadowOpacity = 0.1
        contentCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentCard.layer.shadowRadius = 8.0
    }
    
    private func setupSubviews() {
        view.addSubview(contentCard)
        contentCard.addSubview(appIconView)
        contentCard.addSubview(appTitleLabel)
        contentCard.addSubview(versionLabel)
        contentCard.addSubview(descriptionLabel)
        contentCard.addSubview(featuresLabel)
        contentCard.addSubview(copyrightLabel)
    }
    
    private func setupConstraints() {
        // 内容卡片约束
        contentCard.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
        
        // 应用图标约束
        appIconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        // 应用标题约束
        appTitleLabel.snp.makeConstraints {
            $0.top.equalTo(appIconView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
        }
        
        // 版本信息约束
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(appTitleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        // 应用描述约束
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview().inset(30)
        }
        
        // 功能亮点约束
        featuresLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
        }
        
        // 版权信息约束
        copyrightLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(featuresLabel.snp.bottom).offset(30)
            $0.bottom.equalToSuperview().offset(-40)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupAnimations() {
        // 初始状态设置为不可见
        contentCard.alpha = 0.0
        contentCard.transform = CGAffineTransform(translationX: 0, y: 50)
        
        appIconView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // 添加淡入和上移动画
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.contentCard.alpha = 1.0
            self.contentCard.transform = .identity
        }, completion: nil)
        
        // 添加图标缩放动画
        UIView.animate(withDuration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, animations: {
            self.appIconView.transform = .identity
        }, completion: nil)
    }
    
    // 添加语言变化响应方法
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForLanguageChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForLanguageChanges()
    }
    
    // 重写语言变化方法，更新UI
    override func languageDidChange() {
        self.title = "about_title".localized
        
        // 重新设置UI以更新本地化文本
        setupUI()
        
        // 触发重新布局
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
