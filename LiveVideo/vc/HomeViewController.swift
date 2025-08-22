//
//  HomeViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/2/19.
//

import UIKit
import SnapKit
import HXPhotoPicker
import JKSwiftExtension
import Toast_Swift
import Reusable
import Photos
import PhotosUI // 添加PhotosUI导入以支持PHLivePhotoView和PHPickerViewController
import AVFoundation
import MobileCoreServices // 添加MobileCoreServices导入以支持kUTTypeMovie
import AVKit // 添加AVKit导入以支持AVPlayerViewController

class HomeViewController: UIViewController {
    
    // 创建转换工具实例
    let videoToLivePhotoConverter = VideoToLivePhotoConverter()
    let livePhotoToVideoConverter = LivePhotoToVideoConverter()
    
    // 进度指示器
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.isHidden = true
        progressView.progressTintColor = UIColor(hexString: "067425")
        progressView.trackTintColor = UIColor.lightGray
        progressView.layer.cornerRadius = 4
        progressView.layer.masksToBounds = true
        return progressView
    }()
    
    lazy var segmentControl: UISegmentedControl = {
        // 使用新的初始化方式避免iOS版本兼容性问题
        let segment = UISegmentedControl(items: ["视频转Live实况", "Live实况转视频"])
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // 设置样式
        if #available(iOS 13.0, *) {
            let appearance = UISegmentedControl.appearance()
            appearance.selectedSegmentTintColor = UIColor(hexString: "067425")
            appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "067425")], for: .normal)
        } else {
            segment.tintColor = UIColor(hexString: "067425")
            segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
            segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hexString: "067425")], for: .normal)
        }
        
        return segment
    }()
    
    // 标题标签
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "视频与Live实况互转"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    // 展示转换后的数组
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: HomeItemCollectionViewCell.self)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.layer.cornerRadius = 12
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 0.1
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowRadius = 4
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    // 选择转换资源
    lazy var selectedMediaButton: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.addTarget(self, action: #selector(selectMediaAction), for: .touchUpInside)
        btn.setTitle("选择视频文件", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor(hexString: "067425")
        btn.layer.cornerRadius = 22
        // 修复: 确保UIColor不为nil，安全地访问cgColor
        if let backgroundColor = btn.backgroundColor {
            btn.layer.shadowColor = backgroundColor.cgColor
        }
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 6
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return btn
    }()
    
    // 说明标签
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "选择要转换的媒体文件，转换后的文件将自动保存到相册"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /// 是否选择视频转livephoto  默认true
    var isVideoToLivePhoto: Bool = true {
        didSet{
            if isVideoToLivePhoto {
                selectedMediaButton.setTitle("选择视频文件", for: .normal)
            } else {
                selectedMediaButton.setTitle("选择Live Photo", for: .normal)
            }
            // 刷新集合视图显示
            collection.reloadData()
        }
    }
    
    ///已经转换的livephoto数组 video转的
    lazy var videoToLivephotoList: NSMutableArray = { // 存储PHLivePhoto对象
        let arr = NSMutableArray()
        return arr
    }()
    
    ///已经转换的video数组 livephoto转的
    lazy var livephotoToVideoList: NSMutableArray = { // 存储视频URL
        let arr = NSMutableArray()
        return arr
    }()
    
    // 跟踪LivePhotoView的播放状态（修复isPlaying不存在的问题）
    var isLivePhotoPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景颜色为渐变色效果
        view.backgroundColor = UIColor(hexString: "f8f9fa")
        
        // 添加子视图
        view.addSubview(titleLabel)
        view.addSubview(segmentControl)
        view.addSubview(progressView)
        view.addSubview(selectedMediaButton)
        view.addSubview(descriptionLabel)
        view.addSubview(collection)
        
        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(36)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(40)
        }
        
        selectedMediaButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        
        collection.snp.makeConstraints { make in
            make.top.equalTo(selectedMediaButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        // 初始加载相册中的媒体
        loadMediaFromAlbum()
    }
    
    // 从相册加载媒体文件
    func loadMediaFromAlbum() {
        // 请求权限
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self?.view.makeToast("需要相册访问权限", duration: 2.0, position: .center)
                }
                return
            }
            
            // 此处可以添加从相册加载历史转换记录的逻辑
        }
    }
    
    // 显示加载中提示
    func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.progressView.isHidden = !isLoading
            self.selectedMediaButton.isEnabled = !isLoading
            if !isLoading {
                self.progressView.progress = 0.0
            }
        }
    }
    
    // 显示错误信息
    func showError(_ message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(message, duration: 2.0, position: .center)
        }
    }
    
    // 显示成功信息
    func showSuccess(_ message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(message, duration: 2.0, position: .center)
            self.collection.reloadData() // 刷新列表
        }
    }
}

//MARK: 方法
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // 处理段改变事件
        isVideoToLivePhoto = (sender.selectedSegmentIndex == 0)
    }
    
    @objc func selectMediaAction() {
        // 请求相册权限
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self, status == .authorized else {
                DispatchQueue.main.async {
                    self?.view.makeToast("需要相册访问权限", duration: 2.0, position: .center)
                }
                return
            }
            
            // 根据当前模式选择媒体类型
            if self.isVideoToLivePhoto {
                self.pickVideo()
            } else {
                self.pickLivePhoto()
            }
        }
    }
    
    // 选择视频文件 - 修复主线程警告
    func pickVideo() {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            // 在主线程设置mediaTypes
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // 实现缺失的 pickLivePhoto 方法
    func pickLivePhoto() {
        DispatchQueue.main.async {
            // 使用传统的 UIImagePickerController 来选择照片
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            
            // 检查设备是否支持 Live Photo
            if #available(iOS 9.1, *) {
                self.present(picker, animated: true, completion: nil)
            } else {
                self.showError("您的设备不支持 Live Photo 功能")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 修复 UIImagePickerControllerDelegate 方法中的 PHLivePhoto.request 调用
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if isVideoToLivePhoto {
            // 处理视频选择
            if let videoURL = info[.mediaURL] as? URL {
                // 确保使用正确的方法名
                self.convertVideoToLivePhoto(videoURL: videoURL)
            }
        } else {
            // 处理 Live Photo 选择
            // 获取选择的图片的 PHAsset
            if let assetURL = info[.referenceURL] as? URL {
                // 修复 PHAsset 加载方法
                let fetchOptions = PHFetchOptions()
                let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: fetchOptions)
                if let asset = fetchResult.firstObject {
                    // 检查是否为 Live Photo
                    if asset.mediaSubtypes.contains(.photoLive) {
                        // 请求加载 Live Photo
                        // 修复 PHLivePhoto.request 方法调用 - 使用正确的方法签名
                        if #available(iOS 13.0, *) {
                            // 使用 PHAssetResourceManager 加载 Live Photo 数据
                            let resources = PHAssetResource.assetResources(for: asset)
                            var imageURL: URL?
                            var videoURL: URL?
                            
                            for resource in resources {
                                if resource.type == .photo {
                                    // 获取图片资源
                                    let tempImageURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(UUID().uuidString + ".jpg"))
                                    PHAssetResourceManager.default().writeData(for: resource, toFile: tempImageURL, options: nil) { error in
                                        if error == nil {
                                            imageURL = tempImageURL
                                            self.loadLivePhotoIfBothResourcesAvailable(imageURL: imageURL, videoURL: videoURL)
                                        }
                                    }
                                } else if resource.type == .pairedVideo {
                                    // 获取视频资源
                                    let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(UUID().uuidString + ".mov"))
                                    PHAssetResourceManager.default().writeData(for: resource, toFile: tempVideoURL, options: nil) { error in
                                        if error == nil {
                                            videoURL = tempVideoURL
                                            self.loadLivePhotoIfBothResourcesAvailable(imageURL: imageURL, videoURL: videoURL)
                                        }
                                    }
                                }
                            }
                        } else {
                            // 旧版本 iOS 的兼容方案
                            self.showError("您的系统版本不支持此功能")
                        }
                    } else {
                        self.showError("请选择一个 Live Photo")
                    }
                }
            }
        }
    }
    
    // 辅助方法：当图片和视频资源都准备好时加载 Live Photo
    func loadLivePhotoIfBothResourcesAvailable(imageURL: URL?, videoURL: URL?) {
        guard let imageURL = imageURL, let videoURL = videoURL else {
            return
        }
        
        // 使用正确的方法签名创建 Live Photo
        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL],
                            placeholderImage: nil,
                            targetSize: CGSize.zero,
                            contentMode: .aspectFit) { [weak self] (livePhoto, info) in
            if let livePhoto = livePhoto {
                self?.convertLivePhotoToVideo(livePhoto: livePhoto)
            } else {
                self?.showError("无法加载 Live Photo")
            }
            
            // 清理临时文件
            try? FileManager.default.removeItem(at: imageURL)
            try? FileManager.default.removeItem(at: videoURL)
        }
    }
    
}

//MARK: PHPickerViewControllerDelegate
extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            // 修复崩溃问题：确保在主线程中处理完成回调
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            result.itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] object, error in
                defer { dispatchGroup.leave() }
                
                if let livePhoto = object as? PHLivePhoto {
                    // 开始转换Live Photo为视频
                    DispatchQueue.main.async {
                        self?.convertLivePhotoToVideo(livePhoto: livePhoto)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showError("选择的不是有效的Live Photo")
                    }
                }
            }
            
            dispatchGroup.wait()
        }
    }
}

//MARK: 代理
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isVideoToLivePhoto ? videoToLivephotoList.count : livephotoToVideoList.count
    }
    
    // 修改collectionView(_:cellForItemAt:)方法
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemCollectionViewCell", for: indexPath) as! HomeItemCollectionViewCell
        
        if isVideoToLivePhoto {
            // 修复这里：处理PHAsset类型
            if let asset = videoToLivephotoList[indexPath.item] as? PHAsset {
                // 使用PHCachingImageManager从PHAsset加载Live Photo
                let targetSize = CGSize(width: 300, height: 300)
                let options = PHLivePhotoRequestOptions()
                options.deliveryMode = .highQualityFormat
                
                PHCachingImageManager.default().requestLivePhoto(for: asset,
                                                                 targetSize: targetSize,
                                                                 contentMode: .aspectFill,
                                                                 options: options) {
                    livePhoto, info in
                    if let livePhoto = livePhoto {
                        DispatchQueue.main.async {
                            cell.setLivePhoto(livePhoto)
                        }
                    } else {
                        // 如果无法加载Live Photo，使用占位图
                        let placeholder = UIImage(named: "placeholder") ?? UIImage()
                        cell.setImage(placeholder)
                    }
                }
            } else {
                let placeholder = UIImage(named: "placeholder") ?? UIImage()
                cell.setImage(placeholder)
            }
        } else {
            // 显示视频缩略图
            if let videoURL = livephotoToVideoList[indexPath.item] as? URL {
                // 生成视频缩略图
                let asset = AVURLAsset(url: videoURL)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                
                do {
                    let thumbnailCGImage = try generator.copyCGImage(at: CMTime(seconds: 0.5, preferredTimescale: 600), actualTime: nil)
                    let thumbnail = UIImage(cgImage: thumbnailCGImage)
                    
                    cell.setVideoThumbnail(thumbnail)
                } catch {
                    print("生成缩略图失败: \(error)")
                    // 显示错误占位图
                    if #available(iOS 13.0, *) {
                        cell.setImage(UIImage(systemName: "exclamationmark.triangle.fill") ?? UIImage())
                    } else {
                        let errorImage = UIImage(named: "error_placeholder") ?? UIImage()
                        cell.setImage(errorImage)
                    }
                }
            } else {
                // 如果视频URL无效，显示占位图
                let placeholder = UIImage(named: "placeholder") ?? UIImage()
                cell.setImage(placeholder)
            }
        }
        
        return cell
    }
    
    // 在collectionView(_:didSelectItemAt:)方法中
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 点击预览功能
        if isVideoToLivePhoto {
            if let livePhoto = videoToLivephotoList[indexPath.item] as? PHLivePhoto {
                // 使用新的预览控制器
                let previewVC = LivePhotoPreviewViewController(livePhoto: livePhoto)
                let navigationController = UINavigationController(rootViewController: previewVC)
                present(navigationController, animated: true, completion: nil)
            }
        } else {
            if let videoURL = livephotoToVideoList[indexPath.item] as? URL {
                // 预览视频
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                playerViewController.showsPlaybackControls = true
                
                present(playerViewController, animated: true) { player.play() }
            }
        }
    }
    
    // 切换Live Photo播放状态 - 修复isPlaying不存在的问题
    @objc func toggleLivePhotoPlayback(_ gesture: UITapGestureRecognizer) {
        if let livePhotoView = gesture.view as? PHLivePhotoView {
            if #available(iOS 9.1, *) {
                // 使用自定义变量跟踪播放状态
                if isLivePhotoPlaying {
                    livePhotoView.stopPlayback()
                } else {
                    livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
                }
                // 切换播放状态
                isLivePhotoPlaying.toggle()
            }
        }
    }
    
    // 关闭预览
    @objc func dismissPreview() {
        dismiss(animated: true, completion: nil)
        // 重置播放状态
        isLivePhotoPlaying = false
    }
    
    // 设置单元格大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2 // 两列布局，考虑间距
        return CGSize(width: width, height: width * 4/3) // 保持4:3的宽高比
    }
}

//MARK: 转换方法实现
extension HomeViewController {
    //    // 实现视频转Live Photo方法
    //    func convertVideoToLivePhoto(videoURL: URL) {
    //        showLoading(true)
    //
    //        videoToLivePhotoConverter.convertVideoToLivePhoto(videoURL: videoURL) { [weak self] result in
    //            guard let self = self else { return }
    //
    //            // 创建一个显式的DispatchWorkItem
    //            let workItem = DispatchWorkItem {
    //                self.showLoading(false)
    //
    //                switch result {
    //                case .success(let asset):
    //                    // 简化预览逻辑：直接添加asset到数组，稍后在collectionView中加载
    //                    self.videoToLivephotoList.add(asset)
    //                    self.showSuccess("转换成功并已保存到相册")
    //                    self.collection.reloadData()
    //                case .failure(let error):
    //                    self.showError("转换失败: \(error.localizedDescription)")
    //                }
    //            }
    //
    //            // 将workItem提交到主队列
    //            DispatchQueue.main.async(execute: workItem)
    //        }
    //    }
    //
    //    // 实现Live Photo转视频方法
    //    func convertLivePhotoToVideo(livePhoto: PHLivePhoto) {
    //        showLoading(true)
    //
    //        livePhotoToVideoConverter.convertLivePhotoToVideo(livePhoto: livePhoto) { [weak self] result in
    //            guard let self = self else { return }
    //
    //            // 创建一个显式的DispatchWorkItem
    //            let workItem = DispatchWorkItem {
    //                self.showLoading(false)
    //
    //                switch result {
    //                case .success(let videoURL):
    //                    // 添加到列表并保存到相册
    //                    self.livephotoToVideoList.add(videoURL)
    //                    self.showSuccess("转换成功")
    //                case .failure(let error):
    //                    self.showError("转换失败: \(error.localizedDescription)")
    //                }
    //            }
    //
    //            // 将workItem提交到主队列
    //            DispatchQueue.main.async(execute: workItem)
    //        }
    //    }
    
    // 实现视频转Live Photo方法2
    func convertVideoToLivePhoto(videoURL: URL) {
        
        
        LivePhotoGenerator.shared.convertVideoToLivePhoto(
            videoURL: videoURL,
            progressHandler: { [weak self] progress in
                self?.showLoading(true)
            },
            completion: { [weak self] result in
                self?.showLoading(false)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let (livePhoto, movURL, jpegURL)):
                        self?.videoToLivephotoList.add(livePhoto)
                        self?.collection.reloadData()
                        
                        LivePhotoGenerator.shared.saveLivePhotoToAlbum(movURL: movURL, jpegURL: jpegURL) { [weak self] success, error in
                            DispatchQueue.main.async {
                                if success {
                                    self?.showSuccess("Live Photo 已保存到相册")
                                } else {
                                    debugPrint(error?.localizedDescription ?? NSError(domain: "SaveError", code: -1, userInfo: nil) as! String)
                                    self?.showError(error?.localizedDescription ?? NSError(domain: "SaveError", code: -1, userInfo: nil) as! String)
                                }
                            }
                        }
                        
                        
                    case .failure(let error):
                        debugPrint("转换失败: \(error.localizedDescription)")
                        self?.showError("转换失败: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
    
    // 实现Live Photo转视频方法2
    func convertLivePhotoToVideo(livePhoto: PHLivePhoto) {
        
        
        LivePhotoGenerator.shared.convertLivePhotoToVideo(
            livePhoto: livePhoto,
            progressHandler: { [weak self] progress in
                self?.showLoading(true)
            },
            completion: { [weak self] result in
                self?.showLoading(false)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let videoURL):
                        self?.livephotoToVideoList.add(videoURL)
                        self?.collection.reloadData()
                        LivePhotoGenerator.shared.saveVideoToAlbum(videoURL: videoURL) { [weak self] success, error in
                            DispatchQueue.main.async {
                                if success {
                                    self?.showSuccess("视频已保存到相册")
                                } else {
                                    debugPrint(error?.localizedDescription ?? NSError(domain: "SaveError", code: -1, userInfo: nil) as! String)
                                    self?.showError(error?.localizedDescription ?? NSError(domain: "SaveError", code: -1, userInfo: nil) as! String)
                                }
                            }
                        }
                        
                    case .failure(let error):
                        debugPrint("转换失败: \(error.localizedDescription)")
                        self?.showError("转换失败: \(error.localizedDescription)")
                    }
                }
            }
        )
    }
}
