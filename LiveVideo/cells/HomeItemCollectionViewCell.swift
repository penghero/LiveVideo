//
//  HomeItemCollectionViewCell.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/2/28.
//

import UIKit
import SnapKit
import Reusable
import JKSwiftExtension
import Photos
import PhotosUI // 添加PhotosUI导入以支持PHLivePhotoView

class HomeItemCollectionViewCell: UICollectionViewCell, Reusable {
    
    // 用于显示普通图片和视频缩略图
    lazy var icon: UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFill
        i.layer.cornerRadius = 8
        i.layer.masksToBounds = true
        i.tag = 100
        return i
    }()
    
    // 用于显示Live Photo
    lazy var livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.tag = 100
        view.isHidden = true
        return view
    }()
    
    // 视频指示器
    lazy var videoIndicator: UIImageView = {
        let indicator = UIImageView()
        // 使用系统图标作为视频指示器
        if #available(iOS 13.0, *) {
            indicator.image = UIImage(systemName: "play.circle.fill")
            indicator.tintColor = UIColor.white.withAlphaComponent(0.8)
        } else {
            // 为iOS 13以下版本创建一个简单的播放图标
            let playIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            playIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            playIndicator.layer.cornerRadius = 12
            
            let triangle = UIBezierPath()
            triangle.move(to: CGPoint(x: 8, y: 6))
            triangle.addLine(to: CGPoint(x: 8, y: 18))
            triangle.addLine(to: CGPoint(x: 18, y: 12))
            triangle.close()
            
            let triangleLayer = CAShapeLayer()
            triangleLayer.path = triangle.cgPath
            triangleLayer.fillColor = UIColor.white.cgColor
            playIndicator.layer.addSublayer(triangleLayer)
            
            UIGraphicsBeginImageContext(playIndicator.bounds.size)
            playIndicator.layer.render(in: UIGraphicsGetCurrentContext()!)
            indicator.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        indicator.isHidden = true
        return indicator
    }()
    
    // Live Photo标记
    lazy var livePhotoBadge: UILabel = {
        let badge = UILabel()
        badge.text = "LIVE"
        badge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        badge.textColor = UIColor.white
        badge.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        badge.layer.cornerRadius = 4
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.isHidden = true
        return badge
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(hexString: "999999", alpha: 0.8)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor(hexString: "888888", alpha: 0.5)?.cgColor
        self.layer.borderWidth = 2
        
        // 添加子视图
        self.addSubview(self.icon)
        self.addSubview(self.livePhotoView)
        self.addSubview(self.videoIndicator)
        self.addSubview(self.livePhotoBadge)
        
        // 设置约束
        self.icon.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.livePhotoView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.videoIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.right.equalTo(self).offset(-8)
            make.bottom.equalTo(self).offset(-8)
        }
        
        self.livePhotoBadge.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(16)
            make.right.equalTo(self).offset(-8)
            make.bottom.equalTo(self).offset(-8)
        }
    }
    
    // 设置普通图片
    func setImage(_ image: UIImage) {
        // 隐藏Live Photo视图，显示普通图片视图
        livePhotoView.isHidden = true
        icon.isHidden = false
        
        // 隐藏所有指示器
        videoIndicator.isHidden = true
        livePhotoBadge.isHidden = true
        
        // 设置图片
        icon.image = image
    }
    
    // 设置Live Photo
    func setLivePhoto(_ livePhoto: PHLivePhoto) {
        // 隐藏普通图片视图，显示Live Photo视图
        icon.isHidden = true
        livePhotoView.isHidden = false
        
        // 隐藏视频指示器，显示Live Photo标记
        videoIndicator.isHidden = true
        livePhotoBadge.isHidden = false
        
        // 设置Live Photo并开始播放
        livePhotoView.livePhoto = livePhoto
        livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full) // 明确指定枚举类型
    }
    
    // 设置视频缩略图
    func setVideoThumbnail(_ thumbnail: UIImage) {
        // 隐藏Live Photo视图，显示普通图片视图
        livePhotoView.isHidden = true
        icon.isHidden = false
        
        // 显示视频指示器，隐藏Live Photo标记
        videoIndicator.isHidden = false
        livePhotoBadge.isHidden = true
        
        // 设置缩略图
        icon.image = thumbnail
    }
    
    // 清除内容，用于重用
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置视图状态
        icon.image = nil
        livePhotoView.livePhoto = nil
        livePhotoView.stopPlayback()
        
        // 隐藏所有视图，等待下一次设置
        icon.isHidden = true
        livePhotoView.isHidden = true
        videoIndicator.isHidden = true
        livePhotoBadge.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
