//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import SnapKit

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        self.title = "关于我们"
        
        // 设置背景颜色
        view.backgroundColor = .systemBackground
        
        // 创建内容视图
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 创建应用名称标签
        let appNameLabel = UILabel()
        appNameLabel.text = "LiveVideo"
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        appNameLabel.textAlignment = .center
        
        // 创建版本标签
        let versionLabel = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "版本 \(version)"
        }
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.textColor = .gray
        versionLabel.textAlignment = .center
        
        // 创建描述标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = "视频与Live Photo互转工具\n\n© 2025 chenpeng"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        // 添加子视图
        contentView.addSubview(appNameLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(descriptionLabel)
        
        // 设置约束
        appNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(150)
            $0.centerX.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(versionLabel.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
    }
}
