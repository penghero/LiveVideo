//
//  SplashViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/8/22.
//
import UIKit

class SplashViewController: UIViewController {
    
    // 应用Logo图片视图
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        if let logoImage = UIImage(named: "live_logo") {
            imageView.image = logoImage
        } else {
            // 如果找不到logo，创建一个简单的圆形视图作为替代
            let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            placeholderView.backgroundColor = UIColor(hexString: "067425")
            placeholderView.layer.cornerRadius = 20
            
            let renderer = UIGraphicsImageRenderer(size: placeholderView.bounds.size)
            let image = renderer.image { _ in
                placeholderView.drawHierarchy(in: placeholderView.bounds, afterScreenUpdates: true)
            }
            
            imageView.image = image
        }
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return imageView
    }()
    
    // 应用名称标签
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "LiveVideo"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = UIColor(hexString: "067425")
        label.alpha = 0.0
        return label
    }()
    
    // 应用标语标签
    private lazy var sloganLabel: UILabel = {
        let label = UILabel()
        label.text = "视频与Live实况互转"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        label.alpha = 0.0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置背景色 - 与应用主题一致
        view.backgroundColor = UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(hexString: "1c1c1e")! : // 深色模式背景色
            UIColor(hexString: "f8f9fa")!  // 浅色模式背景色
        }
        
        // 添加子视图
        setupSubviews()
        
        // 添加约束
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 开始动画
        startAnimation()
    }
    
    private func setupSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(sloganLabel)
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.height.equalTo(160)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
        }
        
        sloganLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appNameLabel.snp.bottom).offset(8)
        }
    }
    
    private func startAnimation() {
        // 动画序列
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: {
            // Logo淡入并放大
            self.logoImageView.alpha = 1.0
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { _ in
            // Logo动画完成后，显示应用名称
            UIView.animate(withDuration: 0.6, delay: 0.2, animations: {
                self.appNameLabel.alpha = 1.0
            }) { _ in
                // 应用名称动画完成后，显示标语
                UIView.animate(withDuration: 0.6, delay: 0.2, animations: {
                    self.sloganLabel.alpha = 1.0
                }) { _ in
                    // 所有元素显示完成后，短暂停留再淡出
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        UIView.animate(withDuration: 0.6, animations: {
                            self.logoImageView.alpha = 0.0
                            self.appNameLabel.alpha = 0.0
                            self.sloganLabel.alpha = 0.0
                            self.logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        }) { _ in
                            // 动画完成后，跳转到主界面
                            self.transitionToMainViewController()
                        }
                    }
                }
            }
        }
    }
    
    private func transitionToMainViewController() {
        // 创建主界面控制器
        let mainViewController = TabBarController()
        
        // 设置为窗口的根控制器
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = mainViewController
            window.makeKeyAndVisible()
        }
    }
}
