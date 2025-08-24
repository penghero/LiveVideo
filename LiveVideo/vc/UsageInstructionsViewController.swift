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
        
        // 设置标题
        self.title = "使用说明"
        
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
        appTitle.text = "Live Video Converter"
        appTitle.font = UIFont.boldSystemFont(ofSize: 24)
        appTitle.textColor = .label
        contentView.addSubview(appTitle)
        
        let appSubtitle = UILabel()
        appSubtitle.text = "轻松实现视频与Live Photo之间的互相转换"
        appSubtitle.font = UIFont.systemFont(ofSize: 16)
        appSubtitle.textColor = .secondaryLabel
        appSubtitle.textAlignment = .center
        appSubtitle.numberOfLines = 0
        contentView.addSubview(appSubtitle)
        
        // 创建功能说明部分
        let featuresSection = createSection(title: "核心功能")
        contentView.addSubview(featuresSection)
        
        // 创建功能项容器
        let featuresContainer = UIView()
        featuresSection.addSubview(featuresContainer)
        
        let feature1 = createFeatureItem(
            title: "视频转Live Photo",
            description: "将普通视频文件转换为可交互的Live Photo，让静态照片动起来。"
        )
        featuresContainer.addSubview(feature1)
        
        let feature2 = createFeatureItem(
            title: "Live Photo转视频",
            description: "将iPhone拍摄的Live Photo转换回标准视频格式，便于分享和使用。"
        )
        featuresContainer.addSubview(feature2)
        
        let feature3 = createFeatureItem(
            title: "自定义Live Photo制作",
            description: "选择一张图片和一段视频，将它们合成为独特的Live Photo效果。"
        )
        featuresContainer.addSubview(feature3)
        
        // 创建使用步骤部分 - 视频转Live Photo
        let videoToLiveSection = createSection(title: "视频转Live Photo步骤")
        contentView.addSubview(videoToLiveSection)
        
        let videoStep1 = createStepItem(
            number: "1",
            title: "选择转换模式",
            description: "在首页选择'视频转Live实况'模式。"
        )
        videoToLiveSection.addSubview(videoStep1)
        
        let videoStep2 = createStepItem(
            number: "2",
            title: "选择视频",
            description: "点击'选择视频文件'按钮，从相册中选择一个视频文件。"
        )
        videoToLiveSection.addSubview(videoStep2)
        
        let videoStep3 = createStepItem(
            number: "3",
            title: "等待转换",
            description: "系统会自动处理视频并生成Live Photo，转换过程中显示进度。"
        )
        videoToLiveSection.addSubview(videoStep3)
        
        let videoStep4 = createStepItem(
            number: "4",
            title: "查看结果",
            description: "转换完成后，Live Photo将显示在下方列表中，并自动保存到相册。"
        )
        videoToLiveSection.addSubview(videoStep4)
        
        // 创建使用步骤部分 - Live Photo转视频
        let liveToVideoSection = createSection(title: "Live Photo转视频步骤")
        contentView.addSubview(liveToVideoSection)
        
        let liveStep1 = createStepItem(
            number: "1",
            title: "选择转换模式",
            description: "在首页点击'Live实况转视频'切换模式。"
        )
        liveToVideoSection.addSubview(liveStep1)
        
        let liveStep2 = createStepItem(
            number: "2",
            title: "选择Live Photo",
            description: "点击'选择Live Photo'按钮，从相册中选择一个Live Photo。"
        )
        liveToVideoSection.addSubview(liveStep2)
        
        let liveStep3 = createStepItem(
            number: "3",
            title: "等待转换",
            description: "系统会自动提取Live Photo中的视频部分并进行处理。"
        )
        liveToVideoSection.addSubview(liveStep3)
        
        let liveStep4 = createStepItem(
            number: "4",
            title: "查看结果",
            description: "转换完成后，视频将显示在下方列表中，并自动保存到相册。"
        )
        liveToVideoSection.addSubview(liveStep4)
        
        // 创建使用步骤部分 - 自定义Live Photo
        let customLiveSection = createSection(title: "自定义Live Photo步骤")
        contentView.addSubview(customLiveSection)
        
        let customStep1 = createStepItem(
            number: "1",
            title: "进入自定义界面",
            description: "从底部导航栏选择'定制'功能进入自定义Live Photo制作界面。"
        )
        customLiveSection.addSubview(customStep1)
        
        let customStep2 = createStepItem(
            number: "2",
            title: "选择图片和视频",
            description: "分别点击'选择图片'和'选择视频'按钮，从相册中选择素材。"
        )
        customLiveSection.addSubview(customStep2)
        
        let customStep3 = createStepItem(
            number: "3",
            title: "开始转换",
            description: "确认素材选择后，点击'开始转换'按钮开始生成自定义Live Photo。"
        )
        customLiveSection.addSubview(customStep3)
        
        let customStep4 = createStepItem(
            number: "4",
            title: "预览与保存",
            description: "转换完成后可直接预览效果，系统会自动将结果保存到相册中。"
        )
        customLiveSection.addSubview(customStep4)
        
        // 创建预览和历史记录部分
        let previewSection = createSection(title: "预览与历史记录")
        contentView.addSubview(previewSection)
        
        let previewContent = createTextItem(text: "在首页的转换结果列表中，点击任意项目可以预览转换效果：\n- 对于Live Photo，点击可以播放/暂停动态效果\n- 对于视频，点击可以播放完整视频\n\n所有转换结果都会自动保存到系统相册中，您可以随时查看和使用。")
        previewSection.addSubview(previewContent)
        
        // 创建注意事项部分
        let notesSection = createSection(title: "注意事项")
        contentView.addSubview(notesSection)
        
        // 创建注意事项容器
        let notesContainer = UIView()
        notesSection.addSubview(notesContainer)
        
        let note1 = createNoteItem(text: "请确保应用已获得相册访问权限，否则无法选择和保存媒体文件。")
        notesContainer.addSubview(note1)
        
        let note2 = createNoteItem(text: "转换过程可能需要一定时间，取决于您的设备性能和媒体文件大小。")
        notesContainer.addSubview(note2)
        
        let note3 = createNoteItem(text: "建议使用较短的视频（最好不超过3秒）以获得最佳的Live Photo效果。")
        notesContainer.addSubview(note3)
        
        let note4 = createNoteItem(text: "如有任何问题或建议，请在'关于'页面联系开发者。")
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
}