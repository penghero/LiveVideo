//
//  Tools.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/8/22.
//
import UIKit
import AVFoundation
import CoreMedia

class Tools: NSObject {
    
    static let shared = Tools()
    
    private override init() {
        super.init()
    }
    
    // MARK: - 获取视频第一帧图片 (同步方法)
    func getFirstFrameOfVideo(videoURL: URL) -> UIImage? {
        do {
            // 创建视频资产
            let asset = AVAsset(url: videoURL)
            
            // 创建图像生成器
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceAfter = .zero
            imageGenerator.requestedTimeToleranceBefore = .zero
            
            // 设置时间为视频开始处（第一帧）
            let time = CMTime(seconds: 0, preferredTimescale: 600)
            
            // 获取第一帧图像
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
            
        } catch {
            print("Error getting first frame of video: \(error)")
            return nil
        }
    }
    
    // MARK: - 获取视频第一帧图片 (异步方法)
    func getFirstFrameOfVideoAsync(videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        // 使用后台队列进行处理，避免阻塞主线程
        let processingQueue = DispatchQueue(label: "com.tools.getFirstFrame")
        processingQueue.async {
            do {
                // 创建视频资产
                let asset = AVAsset(url: videoURL)
                
                // 创建图像生成器
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                imageGenerator.requestedTimeToleranceAfter = .zero
                imageGenerator.requestedTimeToleranceBefore = .zero
                
                // 设置时间为视频开始处（第一帧）
                let time = CMTime(seconds: 0, preferredTimescale: 600)
                
                // 获取第一帧图像
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                // 在主线程上回调结果
                DispatchQueue.main.async {
                    completion(uiImage)
                }
                
            } catch {
                print("Error getting first frame of video: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - 高级版本：获取视频第一帧并可指定尺寸
    func getFirstFrameOfVideo(videoURL: URL, targetSize: CGSize? = nil) -> UIImage? {
        guard let image = getFirstFrameOfVideo(videoURL: videoURL) else {
            return nil
        }
        
        // 如果没有指定目标尺寸，直接返回原始图像
        guard let targetSize = targetSize else {
            return image
        }
        
        // 调整图像尺寸
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        image.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}