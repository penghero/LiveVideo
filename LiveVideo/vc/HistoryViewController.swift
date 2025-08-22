//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import SnapKit

class HistoryViewController: UIViewController {
    
    // 创建空历史标签
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无转换历史"
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        self.title = "历史记录"
        
        // 设置背景颜色
        view.backgroundColor = .systemBackground
        
        // 添加清除历史按钮
        let clearButton = UIBarButtonItem(title: "清除", style: .plain, target: self, action: #selector(clearHistory))
        navigationItem.rightBarButtonItem = clearButton
        
        // 添加空历史标签
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // 这里可以根据需要实现历史记录功能
        // 目前只是显示一个空的界面
    }
    
    // 清除历史记录
    @objc func clearHistory() {
        let alertController = UIAlertController(title: "清除历史记录", message: "确定要清除所有转换历史吗？", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "确定", style: .destructive) { _ in
            // 清除历史记录逻辑
            // 这里可以根据实际存储方式清除历史数据
            self.showToast("历史记录已清除")
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 显示提示信息
    func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 100, y: view.frame.height - 100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}