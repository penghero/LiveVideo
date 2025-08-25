//
//  UsageInstructionsViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import SnapKit

class UsageInstructionsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题 - 使用本地化字符串
//        self.title = "usage_instructions_title".localized
        
        // 设置背景颜色，支持深色模式
        view.backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ? 
            UIColor(hexString: "1c1c1e")! : 
            UIColor(hexString: "f8f9fa")!
        }
        
        // 创建滚动视图
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // 创建内容视图
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        // 添加应用图标和标题
        let appIcon = UIImageView(image: UIImage(named: "live_logo"))
        appIcon.contentMode = .scaleAspectFit
        appIcon.layer.cornerRadius = 16
        appIcon.layer.masksToBounds = true
        contentView.addSubview(appIcon)
        
        let appTitle = UILabel()
        appTitle.text = "app_name".localized
        appTitle.font = UIFont.boldSystemFont(ofSize: 24)
        appTitle.textColor = .label
        contentView.addSubview(appTitle)
        
        let appSubtitle = UILabel()
        appSubtitle.text = "usage_app_subtitle".localized
        appSubtitle.font = UIFont.systemFont(ofSize: 16)
        appSubtitle.textColor = .secondaryLabel
        appSubtitle.textAlignment = .center
        appSubtitle.numberOfLines = 0
        contentView.addSubview(appSubtitle)
        
        // 创建功能说明部分
        let featuresSection = createSection(title: "usage_features_section_title".localized)
        contentView.addSubview(featuresSection)
        
        // 创建功能项容器
        let featuresContainer = UIView()
        featuresSection.addSubview(featuresContainer)
        
        let feature1 = createFeatureItem(
            title: "home_video_to_live_photo".localized,
            description: "usage_feature_video_to_live_desc".localized
        )
        featuresContainer.addSubview(feature1)
        
        let feature2 = createFeatureItem(
            title: "home_live_photo_to_video".localized,
            description: "usage_feature_live_to_video_desc".localized
        )
        featuresContainer.addSubview(feature2)
        
        let feature3 = createFeatureItem(
            title: "home_custom_live_photo".localized,
            description: "usage_feature_custom_live_desc".localized
        )
        featuresContainer.addSubview(feature3)
        
        // 创建使用步骤部分 - 视频转Live Photo
        let videoToLiveSection = createSection(title: "usage_video_to_live_section_title".localized)
        contentView.addSubview(videoToLiveSection)
        
        let videoStep1 = createStepItem(
            number: "1",
            title: "usage_step_select_mode_title".localized,
            description: "usage_video_step1_desc".localized
        )
        videoToLiveSection.addSubview(videoStep1)
        
        let videoStep2 = createStepItem(
            number: "2",
            title: "usage_step_select_file_title".localized,
            description: "usage_video_step2_desc".localized
        )
        videoToLiveSection.addSubview(videoStep2)
        
        let videoStep3 = createStepItem(
            number: "3",
            title: "usage_step_wait_conversion_title".localized,
            description: "usage_video_step3_desc".localized
        )
        videoToLiveSection.addSubview(videoStep3)
        
        let videoStep4 = createStepItem(
            number: "4",
            title: "usage_step_view_result_title".localized,
            description: "usage_video_step4_desc".localized
        )
        videoToLiveSection.addSubview(videoStep4)
        
        // 创建使用步骤部分 - Live Photo转视频
        let liveToVideoSection = createSection(title: "usage_live_to_video_section_title".localized)
        contentView.addSubview(liveToVideoSection)
        
        let liveStep1 = createStepItem(
            number: "1",
            title: "usage_step_select_mode_title".localized,
            description: "usage_live_step1_desc".localized
        )
        liveToVideoSection.addSubview(liveStep1)
        
        let liveStep2 = createStepItem(
            number: "2",
            title: "usage_step_select_live_photo_title".localized,
            description: "usage_live_step2_desc".localized
        )
        liveToVideoSection.addSubview(liveStep2)
        
        let liveStep3 = createStepItem(
            number: "3",
            title: "usage_step_wait_conversion_title".localized,
            description: "usage_live_step3_desc".localized
        )
        liveToVideoSection.addSubview(liveStep3)
        
        let liveStep4 = createStepItem(
            number: "4",
            title: "usage_step_view_result_title".localized,
            description: "usage_live_step4_desc".localized
        )
        liveToVideoSection.addSubview(liveStep4)
        
        // 创建使用步骤部分 - 自定义Live Photo
        let customLiveSection = createSection(title: "usage_custom_live_section_title".localized)
        contentView.addSubview(customLiveSection)
        
        let customStep1 = createStepItem(
            number: "1",
            title: "usage_custom_step1_title".localized,
            description: "usage_custom_step1_desc".localized
        )
        customLiveSection.addSubview(customStep1)
        
        let customStep2 = createStepItem(
            number: "2",
            title: "usage_custom_step2_title".localized,
            description: "usage_custom_step2_desc".localized
        )
        customLiveSection.addSubview(customStep2)
        
        let customStep3 = createStepItem(
            number: "3",
            title: "usage_custom_step3_title".localized,
            description: "usage_custom_step3_desc".localized
        )
        customLiveSection.addSubview(customStep3)
        
        let customStep4 = createStepItem(
            number: "4",
            title: "usage_custom_step4_title".localized,
            description: "usage_custom_step4_desc".localized
        )
        customLiveSection.addSubview(customStep4)
        
        // 创建预览和历史记录部分
        let previewSection = createSection(title: "usage_preview_section_title".localized)
        contentView.addSubview(previewSection)
        
        let previewContent = createTextItem(text: "usage_preview_content".localized)
        previewSection.addSubview(previewContent)
        
        // 创建注意事项部分
        let notesSection = createSection(title: "usage_notes_section_title".localized)
        contentView.addSubview(notesSection)
        
        // 创建注意事项容器
        let notesContainer = UIView()
        notesSection.addSubview(notesContainer)
        
        let note1 = createNoteItem(text: "usage_note_permission".localized)
        notesContainer.addSubview(note1)
        
        let note2 = createNoteItem(text: "usage_note_conversion_time".localized)
        notesContainer.addSubview(note2)
        
        let note3 = createNoteItem(text: "usage_note_video_length".localized)
        notesContainer.addSubview(note3)
        
        let note4 = createNoteItem(text: "usage_note_keep_app_active".localized)
        notesContainer.addSubview(note4)
        
        // 设置约束
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        // 应用信息约束
        appIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        appTitle.snp.makeConstraints {
            $0.top.equalTo(appIcon.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        appSubtitle.snp.makeConstraints {
            $0.top.equalTo(appTitle.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(40)
        }
        
        // 核心功能约束
        featuresSection.snp.makeConstraints {
            $0.top.equalTo(appSubtitle.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        featuresContainer.snp.makeConstraints {
            $0.top.equalTo(featuresSection.snp.top).offset(40)
            $0.left.right.bottom.equalTo(featuresSection).inset(16)
        }
        
        feature1.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        feature2.snp.makeConstraints {
            $0.top.equalTo(feature1.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        feature3.snp.makeConstraints {
            $0.top.equalTo(feature2.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview()
        }
        
        // 视频转Live Photo步骤约束
        videoToLiveSection.snp.makeConstraints {
            $0.top.equalTo(featuresSection.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        videoStep1.snp.makeConstraints {
            $0.top.equalTo(videoToLiveSection.snp.top).offset(40)
            $0.left.right.equalTo(videoToLiveSection).inset(16)
        }
        
        videoStep2.snp.makeConstraints {
            $0.top.equalTo(videoStep1.snp.bottom).offset(16)
            $0.left.right.equalTo(videoToLiveSection).inset(16)
        }
        
        videoStep3.snp.makeConstraints {
            $0.top.equalTo(videoStep2.snp.bottom).offset(16)
            $0.left.right.equalTo(videoToLiveSection).inset(16)
        }
        
        videoStep4.snp.makeConstraints {
            $0.top.equalTo(videoStep3.snp.bottom).offset(16)
            $0.left.right.equalTo(videoToLiveSection).inset(16)
            $0.bottom.equalTo(videoToLiveSection).offset(-16)
        }
        
        // Live Photo转视频步骤约束
        liveToVideoSection.snp.makeConstraints {
            $0.top.equalTo(videoToLiveSection.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        liveStep1.snp.makeConstraints {
            $0.top.equalTo(liveToVideoSection.snp.top).offset(40)
            $0.left.right.equalTo(liveToVideoSection).inset(16)
        }
        
        liveStep2.snp.makeConstraints {
            $0.top.equalTo(liveStep1.snp.bottom).offset(16)
            $0.left.right.equalTo(liveToVideoSection).inset(16)
        }
        
        liveStep3.snp.makeConstraints {
            $0.top.equalTo(liveStep2.snp.bottom).offset(16)
            $0.left.right.equalTo(liveToVideoSection).inset(16)
        }
        
        liveStep4.snp.makeConstraints {
            $0.top.equalTo(liveStep3.snp.bottom).offset(16)
            $0.left.right.equalTo(liveToVideoSection).inset(16)
            $0.bottom.equalTo(liveToVideoSection).offset(-16)
        }
        
        // 自定义Live Photo步骤约束
        customLiveSection.snp.makeConstraints {
            $0.top.equalTo(liveToVideoSection.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        customStep1.snp.makeConstraints {
            $0.top.equalTo(customLiveSection.snp.top).offset(40)
            $0.left.right.equalTo(customLiveSection).inset(16)
        }
        
        customStep2.snp.makeConstraints {
            $0.top.equalTo(customStep1.snp.bottom).offset(16)
            $0.left.right.equalTo(customLiveSection).inset(16)
        }
        
        customStep3.snp.makeConstraints {
            $0.top.equalTo(customStep2.snp.bottom).offset(16)
            $0.left.right.equalTo(customLiveSection).inset(16)
        }
        
        customStep4.snp.makeConstraints {
            $0.top.equalTo(customStep3.snp.bottom).offset(16)
            $0.left.right.equalTo(customLiveSection).inset(16)
            $0.bottom.equalTo(customLiveSection).offset(-16)
        }
        
        // 预览与历史记录约束
        previewSection.snp.makeConstraints {
            $0.top.equalTo(customLiveSection.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        previewContent.snp.makeConstraints {
            $0.top.equalTo(previewSection.snp.top).offset(40)
            $0.left.right.equalTo(previewSection).inset(16)
            $0.bottom.equalTo(previewSection).offset(-16)
        }
        
        // 注意事项约束
        notesSection.snp.makeConstraints {
            $0.top.equalTo(previewSection.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        notesContainer.snp.makeConstraints {
            $0.top.equalTo(notesSection.snp.top).offset(40)
            $0.left.right.bottom.equalTo(notesSection).inset(16)
        }
        
        note1.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        note2.snp.makeConstraints {
            $0.top.equalTo(note1.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        note3.snp.makeConstraints {
            $0.top.equalTo(note2.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        note4.snp.makeConstraints {
            $0.top.equalTo(note3.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview()
        }
    }
    
    // 创建功能区块
    private func createSection(title: String) -> UIView {
        let section = UIView()
        section.backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ? 
            UIColor(hexString: "2c2c2e")! : 
            UIColor.white
        }
        section.layer.cornerRadius = 16
        section.layer.shadowColor = UIColor.black.cgColor
        section.layer.shadowOpacity = 0.1
        section.layer.shadowOffset = CGSize(width: 0, height: 2)
        section.layer.shadowRadius = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(hexString: "067425")
        section.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ? 
            UIColor(hexString: "3c3c3e")! : 
            UIColor(hexString: "f0f0f0")!
        }
        section.addSubview(separator)
        
        separator.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        return section
    }
    
    // 创建功能项
    private func createFeatureItem(title: String, description: String) -> UIView {
        let item = UIView()
        item.backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ? 
            UIColor(hexString: "3c3c3e")! : 
            UIColor(hexString: "f8f9fa")!
        }
        item.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        item.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        item.addSubview(descriptionLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.bottom.equalToSuperview().inset(12)
        }
        
        return item
    }
    
    // 创建步骤项
    private func createStepItem(number: String, title: String, description: String) -> UIView {
        let item = UIView()
        
        // 步骤数字背景
        let numberBackground = UIView()
        numberBackground.backgroundColor = UIColor(hexString: "067425")
        numberBackground.layer.cornerRadius = 16
        item.addSubview(numberBackground)
        
        // 步骤数字
        let numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.font = UIFont.boldSystemFont(ofSize: 16)
        numberLabel.textColor = .white
        numberBackground.addSubview(numberLabel)
        
        // 内容容器
        let contentContainer = UIView()
        item.addSubview(contentContainer)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        contentContainer.addSubview(titleLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        contentContainer.addSubview(descriptionLabel)
        
        // 约束
        numberBackground.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        numberLabel.snp.makeConstraints {
            $0.center.equalTo(numberBackground)
        }
        
        contentContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(numberBackground.snp.right).offset(12)
            $0.right.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.right.bottom.equalToSuperview()
        }
        
        return item
    }
    
    // 创建注意事项项
    private func createNoteItem(text: String) -> UIView {
        let item = UIView()
        
        let iconView = UIImageView(image: UIImage(systemName: "info.circle"))
        iconView.tintColor = UIColor(hexString: "067425")
        iconView.contentMode = .scaleAspectFit
        item.addSubview(iconView)
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        item.addSubview(textLabel)
        
        iconView.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(iconView.snp.right).offset(8)
            $0.right.bottom.equalToSuperview()
        }
        
        return item
    }
    
    // 创建文本项
    private func createTextItem(text: String) -> UIView {
        let item = UIView()
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        item.addSubview(textLabel)
        
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        return item
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
        // 重新加载视图以更新所有本地化文本
        self.viewDidLoad()
    }
}
