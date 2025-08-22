import UIKit
import Photos
import AVFoundation
import ImageIO
import MobileCoreServices
import CoreGraphics
import UniformTypeIdentifiers

// Date扩展，提供ISO 8601格式的时间字符串
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withFullDate, .withFullTime, .withTimeZone, .withInternetDateTime]
        return formatter.string(from: self)
    }
}

class VideoToLivePhotoConverter {
    // 错误类型定义
    enum ConversionError: Error, LocalizedError {
        case invalidVideoFormat
        case videoTooShort
        case videoProcessingFailed
        case imageExtractionFailed
        case livePhotoCreationFailed
        case saveToAlbumFailed
        case permissionDenied
        case fileAccessError
        case unknownError
        case resourceLoadingFailed
        case invalidResource
        case metadataCreationFailed
        case temporaryFileCreationFailed
        case exportSessionFailed

        var errorDescription: String? {
            switch self {
            case .invalidVideoFormat:
                return "不支持的视频格式"
            case .videoTooShort:
                return "视频时长太短（至少需要3秒）"
            case .videoProcessingFailed:
                return "视频处理失败"
            case .imageExtractionFailed:
                return "提取封面图片失败"
            case .livePhotoCreationFailed:
                return "创建Live Photo失败"
            case .saveToAlbumFailed:
                return "保存到相册失败"
            case .permissionDenied:
                return "需要相册访问权限"
            case .fileAccessError:
                return "文件访问错误"
            case .unknownError:
                return "未知错误"
            case .resourceLoadingFailed:
                return "资源加载失败"
            case .invalidResource:
                return "资源无效"
            case .metadataCreationFailed:
                return "元数据创建失败"
            case .temporaryFileCreationFailed:
                return "临时文件创建失败"
            case .exportSessionFailed:
                return "导出会话失败"
            }
        }
    }

    // 检查视频格式是否支持
    func isSupportedVideoFormat(_ url: URL) -> Bool {
        let supportedExtensions = Set(["mov", "mp4", "m4v"])
        let fileExtension = url.pathExtension.lowercased()
        return supportedExtensions.contains(fileExtension)
    }

    // 提取封面图片并添加必要的元数据
    private func extractCoverImage(from asset: AVURLAsset) throws -> URL {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero

        // 在视频开始的0.5秒处提取关键帧作为封面
        let imageTimeSeconds = 0.5
        let time = CMTime(seconds: imageTimeSeconds, preferredTimescale: 600)
        var actualTime = CMTime.zero

        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: &actualTime)

            // 创建临时图片URL
            let tempImageURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("cover_\(UUID().uuidString)")
                .appendingPathExtension("jpg")

            // 创建UIImage并保存为JPEG
            let uiImage = UIImage(cgImage: cgImage)
            guard let jpegData = uiImage.jpegData(compressionQuality: 0.9) else {
                throw ConversionError.imageExtractionFailed
            }

            try jpegData.write(to: tempImageURL)

            // 验证文件是否存在
            guard FileManager.default.fileExists(atPath: tempImageURL.path) else {
                throw ConversionError.fileAccessError
            }

            // 添加必要的元数据
            let finalImageURL = try addMetadataToImage(imageURL: tempImageURL)

            // 删除临时文件
            try? FileManager.default.removeItem(at: tempImageURL)

            print("封面图片保存成功: \(finalImageURL.path)")
            return finalImageURL
        } catch {
            print("封面提取失败: \(error)")
            throw ConversionError.imageExtractionFailed
        }
    }

    // 为图片添加必要的元数据
    private func addMetadataToImage(imageURL: URL) throws -> URL {
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
            throw ConversionError.metadataCreationFailed
        }

        // 获取图片属性
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            throw ConversionError.metadataCreationFailed
        }

        // 创建新的元数据
        var mutableMetadata = imageProperties

        // 添加方向信息
        mutableMetadata[kCGImagePropertyOrientation as String] = 1

        // 创建EXIF字典
        var exifDict = [String: Any]()
        // 设置原始拍摄时间
        exifDict[kCGImagePropertyExifDateTimeOriginal as String] = Date().iso8601String
        exifDict[kCGImagePropertyExifDateTimeDigitized as String] = Date().iso8601String
        exifDict[kCGImagePropertyExifUserComment as String] = "Live Photo Key Frame"

        // 添加到mutableMetadata
        mutableMetadata[kCGImagePropertyExifDictionary as String] = exifDict

        // 创建一个临时URL用于输出
        let outputImageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("live_photo_\(UUID().uuidString)")
            .appendingPathExtension("jpg")

        // 创建图像目标
        guard let imageDestination = CGImageDestinationCreateWithURL(outputImageURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw ConversionError.metadataCreationFailed
        }

        // 添加图像数据和元数据
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, mutableMetadata as CFDictionary)

        // 完成写入
        guard CGImageDestinationFinalize(imageDestination) else {
            throw ConversionError.metadataCreationFailed
        }

        // 验证新文件是否存在
        guard FileManager.default.fileExists(atPath: outputImageURL.path) else {
            throw ConversionError.fileAccessError
        }

        return outputImageURL
    }

    // 处理视频片段，截取前3秒
    private func processVideoSegment(videoURL: URL, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: videoURL)
    
        // 创建临时视频URL
        let tempVideoURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("live_segment_\(UUID().uuidString)")
            .appendingPathExtension("mov")
    
        // 检查目录是否存在，不存在则创建
        let directory = tempVideoURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completion(.failure(ConversionError.videoProcessingFailed))
                return
            }
        }
    
        // 如果文件已存在，先删除
        if FileManager.default.fileExists(atPath: tempVideoURL.path) {
            do {
                try FileManager.default.removeItem(at: tempVideoURL)
            } catch {
                completion(.failure(ConversionError.videoProcessingFailed))
            }
        }
    
        // 创建视频合成对象
        let composition = AVMutableComposition()
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(.failure(ConversionError.videoProcessingFailed))
            return
        }
    
        guard let videoCompositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            completion(.failure(ConversionError.videoProcessingFailed))
            return
        }
    
        // 添加音频轨道（如果有）
        let audioTracks = asset.tracks(withMediaType: .audio)
        var audioCompositionTrack: AVMutableCompositionTrack?
    
        if let audioTrack = audioTracks.first {
            audioCompositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
        }
    
        // 设置截取时间范围（前3秒）
        let timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 3.0, preferredTimescale: 600))
    
        do {
            // 插入视频片段
            try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
    
            // 插入音频片段（如果有）
            if let audioTrack = audioTracks.first, let audioCompositionTrack = audioCompositionTrack {
                try audioCompositionTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
            }
    
            // 配置视频导出会话
            guard let exportSession = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality
            ) else {
                completion(.failure(ConversionError.videoProcessingFailed))
                return
            }
    
            // 针对Live Photo特别优化的设置
            exportSession.outputURL = tempVideoURL
            exportSession.outputFileType = .mov
            exportSession.shouldOptimizeForNetworkUse = false
    
            // 定期更新进度
            let progressTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
            progressTimer.schedule(deadline: .now(), repeating: 0.1)
            progressTimer.setEventHandler {
                DispatchQueue.main.async {
                    progressHandler?(Double(exportSession.progress))
                }
            }
            progressTimer.resume()
    
            // 异步导出
            exportSession.exportAsynchronously {
                progressTimer.cancel()
    
                if exportSession.status == .failed {
                    if let error = exportSession.error {
                        print("视频导出失败: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        completion(.failure(ConversionError.videoProcessingFailed))
                    }
                } else if exportSession.status == .completed {
                    print("视频导出成功: \(tempVideoURL.path)")
                    completion(.success(tempVideoURL))
                } else {
                    print("视频导出状态: \(exportSession.status.rawValue)")
                    completion(.failure(ConversionError.exportSessionFailed))
                }
            }
        } catch {
            print("视频处理异常: \(error)")
            completion(.failure(ConversionError.videoProcessingFailed))
        }
    }
    
    // 主要转换方法
    func convertVideoToLivePhoto(videoURL: URL, progressHandler: ((Double) -> Void)? = nil, completion: @escaping (Result<PHAsset, Error>) -> Void) {
        // 1. 检查视频格式
        guard isSupportedVideoFormat(videoURL) else {
            DispatchQueue.main.async {
                completion(.failure(ConversionError.invalidVideoFormat))
            }
            return
        }
    
        // 2. 检查视频时长
        let asset = AVURLAsset(url: videoURL)
        let duration = asset.duration.seconds
    
        if duration < 3.0 {
            DispatchQueue.main.async {
                completion(.failure(ConversionError.videoTooShort))
            }
            return
        }
    
        // 在全局队列上执行耗时操作
        DispatchQueue.global(qos: .utility).async {
            // 3. 显示初始进度
            DispatchQueue.main.async {
                progressHandler?(0.0)
            }
    
            // 4. 提取封面图片
            do {
                let imageURL = try self.extractCoverImage(from: asset)
                DispatchQueue.main.async {
                    progressHandler?(25.0)
                }
    
                // 5. 异步处理视频片段
                self.processVideoSegment(videoURL: videoURL) { segmentProgress in
                    DispatchQueue.main.async {
                        // 将处理进度映射到总体进度的25%-75%
                        progressHandler?(25.0 + segmentProgress * 50.0)
                    }
                } completion: { result in
                    switch result {
                    case .success(let videoSegmentURL):
                        DispatchQueue.main.async {
                            progressHandler?(75.0)
                        }
    
                        // 6. 保存Live Photo到相册，保存逻辑已优化
                        self.saveLivePhotoToAlbum(imageURL: imageURL, videoURL: videoSegmentURL) { saveResult in
                            DispatchQueue.main.async {
                                progressHandler?(100.0)
                                completion(saveResult)
                            }
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        self.cleanupTemporaryFiles([imageURL])
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // 直接转换并保存（简化版）
    func convertAndSaveDirectly(videoURL: URL, completion: @escaping (PHAsset?, Error?) -> Void) {
        convertVideoToLivePhoto(videoURL: videoURL) { result in
            switch result {
            case .success(let asset):
                completion(asset, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // 保存Live Photo到相册并返回PHAsset
    private func saveLivePhotoToAlbum(imageURL: URL, videoURL: URL, completion: @escaping (Result<PHAsset, Error>) -> Void) {
        // 1. 在主线程上请求权限
        DispatchQueue.main.async {
            // 2. 检查文件是否存在
            if !FileManager.default.fileExists(atPath: imageURL.path) || 
               !FileManager.default.fileExists(atPath: videoURL.path) {
                completion(.failure(ConversionError.fileAccessError))
                return
            }
            
            // 3. 请求相册权限
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    DispatchQueue.main.async {
                        completion(.failure(ConversionError.permissionDenied))
                    }
                    return
                }
        
                // 4. 确保在主线程执行PHPhotoLibrary操作
                DispatchQueue.main.async {
                    // 5. 使用共享实例的performChanges执行保存操作
                    PHPhotoLibrary.shared().performChanges({ 
                        // 6. 创建资源创建请求
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        
                        // 7. 为资源添加选项，特别指定资源类型
                        let options = PHAssetResourceCreationOptions()
                        
                        // 8. 添加图片和视频资源
                        creationRequest.addResource(with: .photo, fileURL: imageURL, options: nil)
                        
                        // 9. 为视频资源添加特别配置
                        let videoOptions = PHAssetResourceCreationOptions()
                        videoOptions.shouldMoveFile = false // 不移动文件，因为我们之后会手动清理
                        creationRequest.addResource(with: .pairedVideo, fileURL: videoURL, options: videoOptions)
                        
                    }, completionHandler: { success, error in
                        // 10. 确保在主线程回调
                        DispatchQueue.main.async {
                            if success {
                                // 11. 查询刚创建的资产，使用更精确的查询方式
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                                fetchOptions.fetchLimit = 1
                                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                                
                                let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                                
                                if let asset = fetchResult.firstObject {
                                    completion(.success(asset))
                                } else {
                                    completion(.failure(ConversionError.saveToAlbumFailed))
                                }
                            } else {
                                // 12. 提供更详细的错误日志
                                let errorMessage = error?.localizedDescription ?? "未知错误"
                                print("保存Live Photo失败，错误: " + errorMessage)
                                completion(.failure(error ?? ConversionError.saveToAlbumFailed))
                            }
                            
                            // 13. 无论成功失败都清理临时文件
                            self.cleanupTemporaryFiles([imageURL, videoURL])
                        }
                    })
                }
            }
        }
    }
    
    // 清理临时文件
    private func cleanupTemporaryFiles(_ urls: [URL]) {
        for url in urls {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("清理临时文件: \(url.path)")
                } catch {
                    print("清理临时文件失败: \(error)")
                }
            }
        }
    }
}

// PHLivePhotoManager辅助类
class PHLivePhotoManager {
    static let `default` = PHLivePhotoManager()
    
    private init() {}
    
    // 从PHAsset加载PHLivePhoto
    func requestLivePhoto(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHLivePhotoRequestOptions?, completion: @escaping (PHLivePhoto?, [AnyHashable: Any]?) -> Void) {
        PHCachingImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: completion)
    }
}
