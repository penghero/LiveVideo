//
//  CustomLivePhotoViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/8/22.
//
import UIKit
import PhotosUI
import AVFoundation
import SnapKit
import Photos
import Toast_Swift

class CustomLivePhotoViewController: UIViewController {
    
    // 选择的图片和视频URL
    private var selectedImageURL: URL?
    private var selectedVideoURL: URL?
    
    // 预览的LivePhoto
    private var generatedLivePhoto: PHLivePhoto?
    
    // 跟踪LivePhoto的播放状态
    private var isLivePhotoPlaying = false
    
    // 标题标签
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "custom_live_photo_title".localized
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    // 说明标签
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "custom_live_photo_description".localized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // 图片选择按钮
    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("custom_live_photo_select_image".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "067425")?.cgColor
        button.setTitleColor(UIColor(hexString: "067425"), for: .normal)
        button.backgroundColor = .systemBackground
        button.addTarget(self, action: #selector(selectImageAction), for: .touchUpInside)
        return button
    }()
    
    // 视频选择按钮
    private lazy var selectVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("custom_live_photo_select_video".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexString: "067425")?.cgColor
        button.setTitleColor(UIColor(hexString: "067425"), for: .normal)
        button.backgroundColor = .systemBackground
        button.addTarget(self, action: #selector(selectVideoAction), for: .touchUpInside)
        return button
    }()
    
    // 开始转换按钮
    private lazy var convertButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("custom_live_photo_start_convert".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor(hexString: "067425")
        button.setTitleColor(.white, for: .normal)
        if let backgroundColor = button.backgroundColor {
            button.layer.shadowColor = backgroundColor.cgColor
        }
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(startConvertAction), for: .touchUpInside)
        return button
    }()
    
    // 图片预览视图
    private lazy var imagePreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var imagePreviewLabel: UILabel = {
        let label = UILabel()
        label.text = "custom_live_photo_image_preview".localized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var imagePreviewView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()
    
    // 视频预览视图
    private lazy var videoPreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var videoPreviewLabel: UILabel = {
        let label = UILabel()
        label.text = "custom_live_photo_video_preview".localized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var videoPreviewView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.image = UIImage(systemName: "video")
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()
    
    // LivePhoto预览视图容器
    private lazy var livePhotoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.isHidden = true
        return view
    }()
    
    private lazy var livePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "custom_live_photo_live_preview".localized
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // LivePhoto预览视图
    private lazy var livePhotoPreviewView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .secondarySystemBackground
        view.isUserInteractionEnabled = true
        
        // 添加点击手势以播放LivePhoto
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleLivePhotoPlayback))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    // 进度指示器
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.isHidden = true
        progressView.progressTintColor = UIColor(hexString: "067425")
        progressView.trackTintColor = UIColor.lightGray
        progressView.layer.cornerRadius = 4
        progressView.layer.masksToBounds = true
        return progressView
    }()
    
    // 修改viewDidLoad方法，添加右侧导航栏按钮
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加右侧导航重置按钮
        let resetButton = UIBarButtonItem(title: "custom_live_photo_reset".localized, style: .plain, target: self, action: #selector(resetPage))
        resetButton.tintColor = UIColor(hexString: "067425")
        self.navigationItem.rightBarButtonItem = resetButton
        
        // 设置动态颜色支持深色模式
        view.backgroundColor = UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ?
            UIColor(hexString: "1c1c1e")! : // 深色模式背景色
            UIColor(hexString: "f8f9fa")!  // 浅色模式背景色
        }
        
        // 添加子视图
        setupSubviews()
        
        // 添加约束
        setupConstraints()
        
        // 注册语言变化通知
        registerForLanguageChanges()
    }
    
    deinit {
        // 取消注册语言变化通知
        unregisterForLanguageChanges()
    }
    
    // 当语言变化时调用
    override func languageDidChange() {
        // 更新界面文本
        titleLabel.text = "custom_live_photo_title".localized
        descriptionLabel.text = "custom_live_photo_description".localized
        selectImageButton.setTitle("custom_live_photo_select_image".localized, for: .normal)
        selectVideoButton.setTitle("custom_live_photo_select_video".localized, for: .normal)
        convertButton.setTitle("custom_live_photo_start_convert".localized, for: .normal)
        imagePreviewLabel.text = "custom_live_photo_image_preview".localized
        videoPreviewLabel.text = "custom_live_photo_video_preview".localized
        livePhotoLabel.text = "custom_live_photo_live_preview".localized
        self.navigationItem.rightBarButtonItem?.title = "custom_live_photo_reset".localized
    }
    
    // 添加重置页面方法
    @objc private func resetPage() {
        // 清空选择的图片和视频URL
        selectedImageURL = nil
        selectedVideoURL = nil
        
        // 重置预览视图
        imagePreviewView.image = UIImage(systemName: "photo")
        imagePreviewView.tintColor = .tertiaryLabel
        
        videoPreviewView.image = UIImage(systemName: "video")
        videoPreviewView.tintColor = .tertiaryLabel
        
        // 重置LivePhoto相关
        generatedLivePhoto = nil
        livePhotoPreviewView.livePhoto = nil
        livePhotoContainer.isHidden = true
        isLivePhotoPlaying = false
        
        // 重置进度条
        progressView.progress = 0.0
        progressView.isHidden = true
        
        // 禁用转换按钮
        convertButton.isEnabled = false
        convertButton.alpha = 0.5
        
        // 显示重置成功提示
        view.makeToast("custom_live_photo_reset_success".localized, duration: 1.5, position: .center)
    }
    
    // 设置子视图
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(selectImageButton)
        view.addSubview(selectVideoButton)
        view.addSubview(convertButton)
        view.addSubview(progressView)
        
        // 添加图片预览相关视图
        view.addSubview(imagePreviewContainer)
        imagePreviewContainer.addSubview(imagePreviewLabel)
        imagePreviewContainer.addSubview(imagePreviewView)
        
        // 添加视频预览相关视图
        view.addSubview(videoPreviewContainer)
        videoPreviewContainer.addSubview(videoPreviewLabel)
        videoPreviewContainer.addSubview(videoPreviewView)
        
        // 添加LivePhoto预览相关视图
        view.addSubview(livePhotoContainer)
        livePhotoContainer.addSubview(livePhotoLabel)
        livePhotoContainer.addSubview(livePhotoPreviewView)
    }
    
    // 设置约束
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(40)
        }
        
        selectImageButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 50) / 2)
            make.height.equalTo(50)
        }
        
        selectVideoButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo((view.frame.width - 50) / 2)
            make.height.equalTo(50)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(selectImageButton.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(8)
        }
        
        convertButton.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        
        // 图片预览容器约束
        imagePreviewContainer.snp.makeConstraints { make in
            make.top.equalTo(convertButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 50) / 2)
            make.height.equalTo(200)
        }
        
        imagePreviewLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        imagePreviewView.snp.makeConstraints { make in
            make.top.equalTo(imagePreviewLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
        
        // 视频预览容器约束
        videoPreviewContainer.snp.makeConstraints { make in
            make.top.equalTo(convertButton.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo((view.frame.width - 50) / 2)
            make.height.equalTo(200)
        }
        
        videoPreviewLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        videoPreviewView.snp.makeConstraints { make in
            make.top.equalTo(videoPreviewLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
        
        // LivePhoto预览容器约束
        livePhotoContainer.snp.makeConstraints { make in
            make.top.equalTo(imagePreviewContainer.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        livePhotoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        livePhotoPreviewView.snp.makeConstraints { make in
            make.top.equalTo(livePhotoLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
    }
    
    // 选择图片按钮点击事件
    @objc private func selectImageAction() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true, completion: nil)
    }
    
    // 选择视频按钮点击事件
    @objc private func selectVideoAction() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true, completion: nil)
    }
    
    // 开始转换按钮点击事件
    @objc private func startConvertAction() {
        guard let imageURL = selectedImageURL, let videoURL = selectedVideoURL else {
            showAlert(message: "custom_live_photo_select_both".localized)
            return
        }
        
        // 显示进度条
        progressView.progress = 0.0
        progressView.isHidden = false
        
        // 禁用转换按钮
        convertButton.isEnabled = false
        convertButton.alpha = 0.5
        
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { (percent) in
            DispatchQueue.main.async {
                self.progressView.progress = Float(percent)
            }
        }) {[weak self] (livePhoto, resources) in
            DispatchQueue.main.async {
                // 隐藏进度条
                self?.progressView.isHidden = true
                
                // 启用转换按钮
                self?.convertButton.isEnabled = true
                self?.convertButton.alpha = 1.0
            }

            if let resources = resources {
                LivePhoto.saveToLibrary(resources, completion: {[weak self] (success) in
                    if success {
                        DispatchQueue.main.async {
                            
                            // 保存生成的LivePhoto
                            self?.generatedLivePhoto = livePhoto
                            
                            // 显示LivePhoto预览
                            self?.showLivePhotoPreview(livePhoto: livePhoto!)
                            
                            // 显示成功提示
                            self?.view.makeToast("custom_live_photo_convert_success".localized, duration: 2.0, position: .center)
                        }
                    }
                    else {
                        self?.postAlert("custom_live_photo_convert_failed".localized, message:"custom_live_photo_save_failed".localized)
                    }
                })
            }
        }
    }
    
    // 显示LivePhoto预览
    private func showLivePhotoPreview(livePhoto: PHLivePhoto) {
        // 显示LivePhoto预览容器
        livePhotoContainer.isHidden = false
        
        // 设置LivePhoto
        livePhotoPreviewView.livePhoto = livePhoto
        
        // 重置播放状态
        isLivePhotoPlaying = false
        
        // 自动开始播放
        if #available(iOS 9.1, *) {
            livePhotoPreviewView.startPlayback(with: .full)
            isLivePhotoPlaying = true
        }
    }
    
    // 切换LivePhoto播放状态
    @objc private func toggleLivePhotoPlayback() {
        if #available(iOS 9.1, *) {
            if isLivePhotoPlaying {
                livePhotoPreviewView.stopPlayback()
            } else {
                livePhotoPreviewView.startPlayback(with: .full)
            }
            // 更新播放状态
            isLivePhotoPlaying = !isLivePhotoPlaying
        }
    }
    
    // 保存图片到临时文件并返回URL
    private func saveImageToTempFile(_ image: UIImage) -> URL? {
        // 创建临时目录
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("temp_image_\(UUID().uuidString).jpg")
        
        // 保存图片到临时文件
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: tempFileURL)
                return tempFileURL
            } catch {
                print("保存图片失败: \(error)")
            }
        }
        
        return nil
    }
    
    // 显示警告对话框
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "custom_live_photo_alert_title".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 检查是否可以启用转换按钮
    private func checkEnableConvertButton() {
        if selectedImageURL != nil && selectedVideoURL != nil {
            convertButton.isEnabled = true
            convertButton.alpha = 1.0
        } else {
            convertButton.isEnabled = false
            convertButton.alpha = 0.5
        }
    }
}

// PHPickerViewControllerDelegate实现
extension CustomLivePhotoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let result = results.first else {
            return
        }
        
        // 检查是图片还是视频选择器
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            // 处理图片选择
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // 显示图片预览
                        self?.imagePreviewView.image = image
                        self?.imagePreviewView.contentMode = .scaleAspectFit
                        
                        // 保存图片到临时文件并获取URL
                        self?.selectedImageURL = self?.saveImageToTempFile(image)
                        
                        // 检查是否可以启用转换按钮
                        self?.checkEnableConvertButton()
                    }
                } else if let error = error {
                    print("加载图片失败: \(error)")
                    DispatchQueue.main.async {
                        self?.showAlert(message: "custom_live_photo_load_image_failed".localized)
                    }
                }
            }
        } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            // 处理视频选择
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                if let videoURL = url {
                    // 创建临时文件URL
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let tempFileURL = tempDirectory.appendingPathComponent("temp_video_\(UUID().uuidString).mov")
                    
                    // 复制文件到临时目录
                    do {
                        try FileManager.default.copyItem(at: videoURL, to: tempFileURL)
                        
                        DispatchQueue.main.async {
                            // 保存视频URL
                            self?.selectedVideoURL = tempFileURL
                            
                            // 获取视频第一帧作为预览
                            if let thumbnail = Tools.shared.getFirstFrameOfVideo(videoURL: tempFileURL, targetSize: CGSize(width: 200, height: 200)) {
                                self?.videoPreviewView.image = thumbnail
                                self?.videoPreviewView.contentMode = .scaleAspectFit
                            }
                            
                            // 检查是否可以启用转换按钮
                            self?.checkEnableConvertButton()
                        }
                    } catch {
                        print("保存视频失败: \(error)")
                        DispatchQueue.main.async {
                            self?.showAlert(message: "custom_live_photo_save_video_failed".localized)
                        }
                    }
                } else if let error = error {
                    print("加载视频失败: \(error)")
                    DispatchQueue.main.async {
                        self?.showAlert(message: "custom_live_photo_load_video_failed".localized)
                    }
                }
            }
        }
    }
}
