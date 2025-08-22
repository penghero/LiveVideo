//
//  LivePhotoToVideoConverter.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import Photos
import AVFoundation
import ImageIO
import MobileCoreServices

class LivePhotoToVideoConverter {
    // 错误类型定义
    enum ConversionError: Error, LocalizedError {
        case invalidLivePhoto
        case videoCreationFailed
        case resourceExtractionFailed
        case saveToAlbumFailed
        case permissionDenied
        case fileAccessError
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .invalidLivePhoto:
                return "无效的Live Photo"
            case .videoCreationFailed:
                return "视频创建失败"
            case .resourceExtractionFailed:
                return "提取资源失败"
            case .saveToAlbumFailed:
                return "保存到相册失败"
            case .permissionDenied:
                return "需要相册访问权限"
            case .fileAccessError:
                return "文件访问错误"
            case .unknownError:
                return "未知错误"
            }
        }
    }
    
    // 转换Live Photo到视频
    func convertLivePhotoToVideo(
        livePhoto: PHLivePhoto,
        progressHandler: ((Float) -> Void)? = nil,
        completion: @escaping (Result<URL, ConversionError>) -> Void
    ) {
        // 在后台线程执行转换操作
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // 提取Live Photo中的资源
                let (imageURL, videoURL) = try self.extractResources(from: livePhoto)
                
                // 合并图片和视频创建最终视频
                let finalVideoURL = try self.mergeImageAndVideo(
                    imageURL: imageURL,
                    videoURL: videoURL,
                    progressHandler: progressHandler
                )
                
                // 清理临时文件
                try? FileManager.default.removeItem(at: imageURL)
                try? FileManager.default.removeItem(at: videoURL)
                
                DispatchQueue.main.async {
                    completion(.success(finalVideoURL))
                }
            } catch let error as ConversionError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError))
                }
            }
        }
    }
    
    // 从Live Photo中提取资源
    private func extractResources(from livePhoto: PHLivePhoto) throws -> (URL, URL) {
        // 创建临时文件路径
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("livephoto_image_\(UUID().uuidString)").appendingPathExtension("jpg")
        let videoURL = tempDir.appendingPathComponent("livephoto_video_\(UUID().uuidString)").appendingPathExtension("mov")
        
        // 获取Live Photo的资源
        let resources = PHAssetResource.assetResources(for: livePhoto)
        
        // 标记是否找到图片和视频资源
        var foundImage = false
        var foundVideo = false
        
        // 提取资源
        for resource in resources {
            if resource.type == .photo {
                // 提取照片资源
                let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true
                
                let semaphore = DispatchSemaphore(value: 0)
                var imageError: Error?
                
                PHAssetResourceManager.default().requestData(for: resource, options: options) { data in
                    do {
                        try data.write(to: imageURL)
                        foundImage = true
                    } catch {
                        imageError = error
                    }
                } completionHandler: { error in
                    if let error = error {
                        imageError = error
                    }
                    semaphore.signal()
                }
                
                // 等待完成
                semaphore.wait()
                
                if let error = imageError {
                    throw error
                }
            } else if resource.type == .pairedVideo {
                // 提取视频资源
                let options = PHAssetResourceRequestOptions()
                options.isNetworkAccessAllowed = true
                
                let semaphore = DispatchSemaphore(value: 0)
                var videoError: Error?
                
                PHAssetResourceManager.default().requestData(for: resource, options: options) { data in
                    do {
                        try data.write(to: videoURL)
                        foundVideo = true
                    } catch {
                        videoError = error
                    }
                } completionHandler: { error in
                    if let error = error {
                        videoError = error
                    }
                    semaphore.signal()
                }
                
                // 等待完成
                semaphore.wait()
                
                if let error = videoError {
                    throw error
                }
            }
        }
        
        // 检查是否成功提取所有资源
        guard foundImage && foundVideo else {
            // 清理已创建的文件
            try? FileManager.default.removeItem(at: imageURL)
            try? FileManager.default.removeItem(at: videoURL)
            
            throw ConversionError.resourceExtractionFailed
        }
        
        return (imageURL, videoURL)
    }
    
    // 合并图片和视频
    private func mergeImageAndVideo(
        imageURL: URL,
        videoURL: URL,
        progressHandler: ((Float) -> Void)? = nil
    ) throws -> URL {
        // 创建输出文件URL
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("livephoto_export_\(UUID().uuidString)")
            .appendingPathExtension("mp4")
        
        // 创建视频合成对象
        let composition = AVMutableComposition()
        
        // 添加视频轨道
        let videoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        
        // 添加音频轨道
        let audioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        
        // 加载视频资源
        let videoAsset = AVURLAsset(url: videoURL)
        
        guard let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first else {
            throw ConversionError.videoCreationFailed
        }
        
        // 获取视频尺寸
        let videoSize = videoAssetTrack.naturalSize
        
        do {
            // 插入视频片段
            try videoTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: videoAsset.duration),
                of: videoAssetTrack,
                at: .zero
            )
            
            // 插入音频（如果有）
            if let audioAssetTrack = videoAsset.tracks(withMediaType: .audio).first {
                try audioTrack?.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoAsset.duration),
                    of: audioAssetTrack,
                    at: .zero
                )
            }
            
            // 配置视频导出会话
            guard let exportSession = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality
            ) else {
                throw ConversionError.videoCreationFailed
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            // 监听导出进度
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            exportSession.exportAsynchronously { 
                dispatchGroup.leave()
            }
            
            // 定期检查进度
            let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    progressHandler?(exportSession.progress)
                }
            }
            
            // 等待导出完成
            dispatchGroup.wait()
            progressTimer.invalidate()
            
            // 检查导出状态
            if exportSession.status == .completed {
                return outputURL
            } else {
                throw exportSession.error ?? ConversionError.videoCreationFailed
            }
        } catch {
            throw error
        }
    }
    
    // 保存视频到相册
    func saveVideoToAlbum(
        videoURL: URL,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        // 请求相册权限
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false, ConversionError.permissionDenied)
                return
            }
            
            // 保存到相册
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(
                    with: .video,
                    fileURL: videoURL,
                    options: nil
                )
            }, completionHandler: completion)
        }
    }
}