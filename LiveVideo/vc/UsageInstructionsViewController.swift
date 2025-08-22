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
        
        // 设置背景颜色
        view.backgroundColor = .systemBackground
        
        // 创建文本视图
        let textView = UITextView()
        textView.text = "1. 视频转Live Photo\n   - 点击'选择视频文件'按钮\n   - 从相册中选择一个长度不超过3秒的视频\n   - 等待转换完成，结果将显示在下方列表中\n\n2. Live Photo转视频\n   - 点击顶部'Live实况转视频'切换模式\n   - 点击'选择Live Photo'按钮\n   - 从相册中选择一个Live Photo\n   - 等待转换完成，结果将显示在下方列表中\n\n3. 预览功能\n   - 点击列表中的项目可以预览转换结果\n\n4. 注意事项\n   - 转换过程可能需要一定时间，请耐心等待\n   - 请确保应用有相册访问权限"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = true
        
        // 添加文本视图
        view.addSubview(textView)
        
        // 设置约束
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}