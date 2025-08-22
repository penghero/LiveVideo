//
//  LivePhotoGenerator.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/8/22.
//
import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import AVFoundation
import ImageIO

class LivePhotoGenerator: NSObject {
    
    static let shared = LivePhotoGenerator()
    
    private let fileManager = FileManager.default
    private let documentsURL: URL
    
    override init() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        super.init()
        createTempDirectory()
    }
    
    private func createTempDirectory() {
        let tempURL = documentsURL.appendingPathComponent("LivePhotoTemp")
        if !fileManager.fileExists(atPath: tempURL.path) {
            try? fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true)
        }
    }
    
    private func getTempURL(for filename: String) -> URL {
        return documentsURL.appendingPathComponent("LivePhotoTemp/\(filename)")
    }
    
    private func cleanupTempFiles() {
        let tempURL = documentsURL.appendingPathComponent("LivePhotoTemp")
        try? fileManager.removeItem(at: tempURL)
        createTempDirectory()
    }
    
    // MARK: - 视频转 Live Photo (完善版)
    func convertVideoToLivePhoto(videoURL: URL,
                               progressHandler: ((Double) -> Void)? = nil,
                               completion: @escaping (Result<(PHLivePhoto, URL, URL), Error>) -> Void) {
        
        cleanupTempFiles()
        
        let movURL = getTempURL(for: "livePhoto-\(UUID().uuidString).mov")
        let jpegURL = getTempURL(for: "livePhoto-\(UUID().uuidString).jpg")
        
        // 1. 提取关键帧并处理元数据
        extractAndProcessKeyFrame(from: videoURL, outputURL: jpegURL) { result in
            switch result {
            case .success:
                // 2. 转换视频格式并添加元数据
                self.convertAndPrepareVideo(inputURL: videoURL,
                                          outputURL: movURL,
                                          progressHandler: progressHandler) { result in
                    switch result {
                    case .success:
                        // 3. 创建 Live Photo
                        self.createLivePhotoWithMetadata(movURL: movURL,
                                                       jpegURL: jpegURL,
                                                       completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 关键帧提取和处理
    private func extractAndProcessKeyFrame(from videoURL: URL,
                                         outputURL: URL,
                                         completion: @escaping (Result<Void, Error>) -> Void) {
        
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        
        // 获取视频中间帧作为关键帧
        let duration = asset.duration
        let middleTime = CMTimeMultiplyByFloat64(duration, multiplier: 0.5)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: middleTime, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
            // 处理图像并添加必要的元数据
            self.processImageForLivePhoto(uiImage, outputURL: outputURL, completion: completion)
            
        } catch {
            completion(.failure(error))
        }
    }
    
    private func processImageForLivePhoto(_ image: UIImage,
                                        outputURL: URL,
                                        completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to create JPEG data"])))
            return
        }
        
        // 创建 CGImageSource
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -2,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to create image source"])))
            return
        }
        
        // 准备目标文件
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL,
                                                              kUTTypeJPEG, 1, nil) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -3,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to create image destination"])))
            return
        }
        
        // 复制图像属性
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
        
        // 添加 Live Photo 相关的元数据
        var finalProperties = properties ?? [:]
        var makerAppleProperties: [String: Any] = [:]
        
        // 修复错误：字典键必须是字符串类型
        makerAppleProperties["17"] = 1 // 表示这是 Live Photo 的一部分
        finalProperties["{MakerApple}"] = makerAppleProperties
        
        // 保存图像
        CGImageDestinationAddImageFromSource(destination, source, 0, finalProperties as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            completion(.success(()))
        } else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -4,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to finalize image"])))
        }
    }
    
    // MARK: - 视频转换和处理
    private func convertAndPrepareVideo(inputURL: URL,
                                      outputURL: URL,
                                      progressHandler: ((Double) -> Void)? = nil,
                                      completion: @escaping (Result<Void, Error>) -> Void) {
        
        let asset = AVAsset(url: inputURL)
        
        // 创建组合
        let composition = AVMutableComposition()
        
        // 添加视频轨道
        guard let videoTrack = asset.tracks(withMediaType: .video).first,
              let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -6,
                                      userInfo: [NSLocalizedDescriptionKey: "No video track found"])))
            return
        }
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration),
                                                    of: videoTrack,
                                                    at: .zero)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 添加音频轨道（如果有）
        if let audioTrack = asset.tracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid) {
            do {
                try compositionAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration),
                                                        of: audioTrack,
                                                        at: .zero)
            } catch {
                print("Failed to add audio track: \(error)")
                // 音频不是必需的，继续处理
            }
        }
        
        // 修复错误：使用组合创建导出会话，而不是尝试设置只读属性
        guard let exportSession = AVAssetExportSession(asset: composition,
                                                     presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -5,
                                      userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])))
            return
        }
        
        // 配置导出设置
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        
        // 监听进度
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            progressHandler?(Double(exportSession.progress))
        }
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                timer.invalidate()
                
                switch exportSession.status {
                case .completed:
                    // 为视频添加必要的元数据
                    self.addMetadataToVideo(videoURL: outputURL, completion: completion)
                case .failed:
                    completion(.failure(exportSession.error ??
                                      NSError(domain: "LivePhotoGenerator", code: -7,
                                            userInfo: [NSLocalizedDescriptionKey: "Export failed"])))
                case .cancelled:
                    completion(.failure(NSError(domain: "LivePhotoGenerator", code: -8,
                                              userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])))
                default:
                    completion(.failure(NSError(domain: "LivePhotoGenerator", code: -9,
                                              userInfo: [NSLocalizedDescriptionKey: "Export failed with unknown status"])))
                }
            }
        }
    }
    
    private func addMetadataToVideo(videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        // 这里可以使用 AVAssetWriter 或第三方库来添加元数据
        // 由于 iOS 的限制，直接的文件元数据修改比较复杂
        // 对于 Live Photo，通常系统会自动处理元数据
        
        // 目前先直接完成，后续可以扩展元数据添加功能
        completion(.success(()))
    }
    
    // MARK: - 创建 Live Photo
    private func createLivePhotoWithMetadata(movURL: URL,
                                           jpegURL: URL,
                                           completion: @escaping (Result<(PHLivePhoto, URL, URL), Error>) -> Void) {
        
        PHLivePhoto.request(withResourceFileURLs: [movURL, jpegURL],
                          placeholderImage: nil,
                          targetSize: CGSize.zero,
                          contentMode: .aspectFit) { livePhoto, info in
            
            if let livePhoto = livePhoto {
                completion(.success((livePhoto, movURL, jpegURL)))
            } else {
                let error = info[PHLivePhotoInfoErrorKey] as? Error ??
                NSError(domain: "LivePhotoGenerator", code: -10,
                      userInfo: [NSLocalizedDescriptionKey: "Failed to create Live Photo"])
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Live Photo 转视频 (完善版)
    func convertLivePhotoToVideo(livePhoto: PHLivePhoto,
                               progressHandler: ((Double) -> Void)? = nil,
                               completion: @escaping (Result<URL, Error>) -> Void) {
        
        let resources = PHAssetResource.assetResources(for: livePhoto)
        
        guard let videoResource = resources.first(where: { $0.type == .pairedVideo }) else {
            completion(.failure(NSError(domain: "LivePhotoGenerator", code: -11,
                                      userInfo: [NSLocalizedDescriptionKey: "No video resource found"])))
            return
        }
        
        let outputURL = getTempURL(for: "convertedVideo-\(UUID().uuidString).mov")
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        var progressTimer: Timer?
        if progressHandler != nil {
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                // 这里可以使用 KVO 观察进度，但 PHAssetResourceManager 不直接提供进度
                progressHandler?(0.5) // 占位值
            }
        }
        
        PHAssetResourceManager.default().writeData(for: videoResource,
                                                   toFile: outputURL,
                                                 options: options) { error in
            DispatchQueue.main.async {
                progressTimer?.invalidate()
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    // 可选：对视频进行后处理
                    self.postProcessVideo(videoURL: outputURL, completion: completion)
                }
            }
        }
    }
    
    private func postProcessVideo(videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // 这里可以添加视频后处理，如重新编码、调整质量等
        // 目前直接返回原始文件
        completion(.success(videoURL))
    }
    
    // MARK: - 批量处理
    func batchConvertVideosToLivePhotos(videoURLs: [URL],
                                      progressHandler: ((Int, Int, Double) -> Void)? = nil,
                                      completion: @escaping (Result<[(PHLivePhoto, URL, URL)], Error>) -> Void) {
        
        var results: [(PHLivePhoto, URL, URL)] = []
        var errors: [Error] = []
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.livephoto.batchconvert")
        
        for (index, videoURL) in videoURLs.enumerated() {
            group.enter()
            
            self.convertVideoToLivePhoto(videoURL: videoURL,
                                       progressHandler: { progress in
                progressHandler?(index, videoURLs.count, progress)
            }) { result in
                queue.async {
                    switch result {
                    case .success(let livePhotoData):
                        results.append(livePhotoData)
                    case .failure(let error):
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(results))
            } else {
                completion(.failure(NSError(domain: "LivePhotoGenerator", code: -12,
                                          userInfo: [NSLocalizedDescriptionKey: "Batch conversion failed with \(errors.count) errors"])))
            }
        }
    }
    
    // MARK: - 工具方法
    func getVideoDuration(url: URL) -> Double {
        let asset = AVAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
    
    func getLivePhotoDuration(livePhoto: PHLivePhoto) -> Double? {
        // Live Photo 通常持续 3 秒
        return 3.0
    }
    
    // MARK: - 文件管理
    func cleanupAllFiles() {
        cleanupTempFiles()
    }
    
    func getFileSize(url: URL) -> Int64? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
    // MARK: - 保存到相册功能
    func saveLivePhotoToAlbum(movURL: URL, jpegURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            // 创建 Live Photo 资源请求
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            // 添加图片资源
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: .photo, fileURL: jpegURL, options: options)
            
            // 添加视频资源
            creationRequest.addResource(with: .pairedVideo, fileURL: movURL, options: options)
            
        }, completionHandler: completion)
    }

    func saveVideoToAlbum(videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            // 创建视频资源请求
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }, completionHandler: completion)
    }

    // 从 PHLivePhoto 对象保存到相册
    func saveLivePhotoObjectToAlbum(livePhoto: PHLivePhoto, completion: @escaping (Bool, Error?) -> Void) {
        // 获取 Live Photo 的资源
        let resources = PHAssetResource.assetResources(for: livePhoto)
        
        // 查找图片和视频资源
        guard let photoResource = resources.first(where: { $0.type == .photo }),
              let videoResource = resources.first(where: { $0.type == .pairedVideo }) else {
            completion(false, NSError(domain: "LivePhotoGenerator", code: -20,
                                    userInfo: [NSLocalizedDescriptionKey: "无法获取 Live Photo 资源"]))
            return
        }
        
        // 创建临时文件路径
        let photoURL = getTempURL(for: "tempPhoto-\(UUID().uuidString).jpg")
        let videoURL = getTempURL(for: "tempVideo-\(UUID().uuidString).mov")
        
        // 保存资源到临时文件
        let group = DispatchGroup()
        var photoError: Error?
        var videoError: Error?
        
        // 保存图片资源
        group.enter()
        let photoOptions = PHAssetResourceRequestOptions()
        photoOptions.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: photoResource,
                                                   toFile: photoURL,
                                                 options: photoOptions) { error in
            photoError = error
            group.leave()
        }
        
        // 保存视频资源
        group.enter()
        let videoOptions = PHAssetResourceRequestOptions()
        videoOptions.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: videoResource,
                                                   toFile: videoURL,
                                                 options: videoOptions) { error in
            videoError = error
            group.leave()
        }
        
        // 所有资源保存完成后，创建 Live Photo
        group.notify(queue: .main) {
            if let error = photoError ?? videoError {
                completion(false, error)
                return
            }
            
            // 使用临时文件创建并保存 Live Photo
            self.saveLivePhotoToAlbum(movURL: videoURL, jpegURL: photoURL, completion: completion)
            
            // 清理临时文件
            try? self.fileManager.removeItem(at: photoURL)
            try? self.fileManager.removeItem(at: videoURL)
        }
    }

    // 检查相册权限
    func requestPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
