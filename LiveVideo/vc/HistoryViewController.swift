//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import SnapKit
import Photos
// 导入AVFoundation以支持视频预览
import AVFoundation
import AVKit

// 历史记录数据模型
struct HistoryItem: Codable {
    enum ItemType: String, Codable {
        case videoToLivePhoto
        case livePhotoToVideo
        case customLivePhoto
    }
    
    let id: String
    let type: ItemType
    let originalName: String
    let convertedName: String
    let filePath: String
    let thumbnailPath: String?
    let timestamp: Date
    let duration: Double? // 视频时长
    
    init(type: ItemType, originalName: String, convertedName: String, filePath: String, thumbnailPath: String?, duration: Double? = nil) {
        self.id = UUID().uuidString
        self.type = type
        self.originalName = originalName
        self.convertedName = convertedName
        self.filePath = filePath
        self.thumbnailPath = thumbnailPath
        self.timestamp = Date()
        self.duration = duration
    }
}

class HistoryViewController: UIViewController {
    
    // 历史记录列表
    private var historyItems: [HistoryItem] = []
    
    // 表格视图用于展示历史记录
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    // 创建空历史标签
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无转换历史"
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    // 存储键名
    private let historyStorageKey = "LiveVideo_HistoryItems"
    
    // 在HistoryViewController类中添加以下修改
    
    // 重写languageDidChange方法以响应语言变化
    override func languageDidChange() {
        super.languageDidChange()
        
        // 更新标题
        self.title = "history_title".localized
        
        // 更新清除按钮
        navigationItem.rightBarButtonItem?.title = "history_clear".localized
        
        // 更新空历史标签
        emptyLabel.text = "history_empty".localized
        
        // 刷新表格数据以更新单元格中的文本
        tableView.reloadData()
    }
    
    // 在viewDidLoad中使用本地化字符串
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        self.title = "history_title".localized
        
        // 设置背景颜色
        view.backgroundColor = .systemBackground
        
        // 添加清除历史按钮
        let clearButton = UIBarButtonItem(title: "history_clear".localized, style: .plain, target: self, action: #selector(clearHistory))
        navigationItem.rightBarButtonItem = clearButton
        
        // 添加表格视图
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 添加空历史标签
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        emptyLabel.text = "history_empty".localized
        
        // 加载历史记录
        loadHistoryItems()
        
        // 检查是否显示空历史标签
        updateEmptyLabelVisibility()
    }
    
    // 加载历史记录
    private func loadHistoryItems() {
        if let data = UserDefaults.standard.data(forKey: historyStorageKey),
           let items = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            // 过滤掉不存在的文件
            historyItems = items.filter { item in
                return FileManager.default.fileExists(atPath: item.filePath)
            }
            // 按时间倒序排列
            historyItems.sort { $0.timestamp > $1.timestamp }
        }
    }
    
    // 保存历史记录
    private func saveHistoryItems() {
        if let data = try? JSONEncoder().encode(historyItems) {
            UserDefaults.standard.set(data, forKey: historyStorageKey)
        }
    }
    
    // 添加新的历史记录
    public func addHistoryItem(_ item: HistoryItem) {
        // 检查是否已存在相同的文件路径
        if let existingIndex = historyItems.firstIndex(where: { $0.filePath == item.filePath }) {
            historyItems[existingIndex] = item // 更新已存在的项目
        } else {
            historyItems.insert(item, at: 0) // 添加到列表开头
        }
        saveHistoryItems()
        tableView.reloadData()
        updateEmptyLabelVisibility()
    }
    
    // 清除历史记录
    @objc func clearHistory() {
        let alertController = UIAlertController(title: "history_clear_confirm_title".localized, message: "history_clear_confirm_message".localized, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "ok".localized, style: .destructive) { _ in
            // 清除历史记录逻辑
            self.historyItems.removeAll()
            self.saveHistoryItems()
            self.tableView.reloadData()
            self.updateEmptyLabelVisibility()
            self.showToast("history_record_cleared".localized)
        })
        
        alertController.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // 更新空历史标签可见性
    private func updateEmptyLabelVisibility() {
        emptyLabel.isHidden = !historyItems.isEmpty
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

// 历史记录表格单元格
class HistoryTableViewCell: UITableViewCell {
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 添加子视图
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(timeLabel)
        
        // 设置约束
        thumbnailImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.equalTo(thumbnailImageView.snp.height).multipliedBy(16/9)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(thumbnailImageView.snp.right).offset(16)
            $0.right.equalTo(timeLabel.snp.left).offset(-8)
            $0.top.equalTo(thumbnailImageView.snp.top).offset(4)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.left.equalTo(thumbnailImageView.snp.right).offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalTo(thumbnailImageView.snp.bottom).offset(-4)
        }
        
        timeLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalTo(titleLabel.snp.top)
            $0.width.greaterThanOrEqualTo(80)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: HistoryItem) {
        // 设置标题
        switch item.type {
        case .videoToLivePhoto:
            titleLabel.text = "视频转Live Photo"
        case .livePhotoToVideo:
            titleLabel.text = "Live Photo转视频"
        case .customLivePhoto:
            titleLabel.text = "自定义Live Photo"
        }
        
        // 设置副标题
        subtitleLabel.text = item.convertedName
        
        // 设置时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        timeLabel.text = dateFormatter.string(from: item.timestamp)
        
        // 设置缩略图
        if let thumbnailPath = item.thumbnailPath, FileManager.default.fileExists(atPath: thumbnailPath) {
            thumbnailImageView.image = UIImage(contentsOfFile: thumbnailPath)
        } else {
            // 如果没有缩略图，尝试从文件路径生成
            if item.filePath.hasSuffix(".mov") || item.filePath.hasSuffix(".mp4") {
                // 视频文件
                if let url = URL(string: item.filePath), let thumbnail = Tools.shared.getFirstFrameOfVideo(videoURL: url, targetSize: CGSize(width: 120, height: 67.5)) {
                    thumbnailImageView.image = thumbnail
                }
            } else if item.filePath.hasSuffix(".jpg") { 
                // Live Photo的照片部分
                thumbnailImageView.image = UIImage(contentsOfFile: item.filePath)
            }
        }
    }
}

// UITableViewDataSource和UITableViewDelegate扩展
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let item = historyItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = historyItems[indexPath.row]
        
        // 预览历史记录项
        if FileManager.default.fileExists(atPath: item.filePath) {
            let fileURL = URL(fileURLWithPath: item.filePath)

            // 根据文件类型选择预览方式
            if item.type == .videoToLivePhoto || item.type == .customLivePhoto {
                // 预览Live Photo
                // 这里可以实现Live Photo预览逻辑
//                if let livePhoto = videoToLivephotoList[indexPath.item] as? PHLivePhoto {
//                    // 使用新的预览控制器
//                    let previewVC = LivePhotoPreviewViewController(livePhoto: livePhoto)
//                    let navigationController = UINavigationController(rootViewController: previewVC)
//                    present(navigationController, animated: true, completion: nil)
//                }
                showToast("预览Live Photo: \(item.convertedName)")
            } else {
                // 预览视频
                let playerViewController = AVPlayerViewController()
                playerViewController.player = AVPlayer(url: fileURL)
                playerViewController.showsPlaybackControls = true
                present(playerViewController, animated: true) { [weak playerViewController] in
                    playerViewController?.player?.play()
                }
            }
        } else {
            showToast("文件不存在")
        }
    }
    
    // 实现左滑删除功能
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 删除历史记录项
            let item = historyItems[indexPath.row]
            
            // 可以选择是否同时删除文件
            // try? FileManager.default.removeItem(atPath: item.filePath)
            // if let thumbnailPath = item.thumbnailPath {
            //     try? FileManager.default.removeItem(atPath: thumbnailPath)
            // }
            
            historyItems.remove(at: indexPath.row)
            saveHistoryItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateEmptyLabelVisibility()
        }
    }
}

// 为UIViewController添加保存到历史记录的扩展方法
extension UIViewController {
    
    // 保存视频转Live Photo到历史记录
    func saveVideoToLivePhotoHistory(originalName: String, convertedName: String, filePath: String, thumbnailPath: String?) {
        if let historyVC = self as? HistoryViewController {
            let item = HistoryItem(type: .videoToLivePhoto, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath)
            historyVC.addHistoryItem(item)
        } else {
            // 从导航堆栈中查找HistoryViewController
            if let historyVC = findViewController(ofType: HistoryViewController.self) {
                let item = HistoryItem(type: .videoToLivePhoto, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath)
                historyVC.addHistoryItem(item)
            }
        }
    }
    
    // 保存Live Photo转视频到历史记录
    func saveLivePhotoToVideoHistory(originalName: String, convertedName: String, filePath: String, thumbnailPath: String?, duration: Double?) {
        if let historyVC = self as? HistoryViewController {
            let item = HistoryItem(type: .livePhotoToVideo, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath, duration: duration)
            historyVC.addHistoryItem(item)
        } else {
            // 从导航堆栈中查找HistoryViewController
            if let historyVC = findViewController(ofType: HistoryViewController.self) {
                let item = HistoryItem(type: .livePhotoToVideo, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath, duration: duration)
                historyVC.addHistoryItem(item)
            }
        }
    }
    
    // 保存自定义Live Photo到历史记录
    func saveCustomLivePhotoHistory(originalName: String, convertedName: String, filePath: String, thumbnailPath: String?) {
        if let historyVC = self as? HistoryViewController {
            let item = HistoryItem(type: .customLivePhoto, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath)
            historyVC.addHistoryItem(item)
        } else {
            // 从导航堆栈中查找HistoryViewController
            if let historyVC = findViewController(ofType: HistoryViewController.self) {
                let item = HistoryItem(type: .customLivePhoto, originalName: originalName, convertedName: convertedName, filePath: filePath, thumbnailPath: thumbnailPath)
                historyVC.addHistoryItem(item)
            }
        }
    }
    
    // 查找指定类型的ViewController
    private func findViewController<T: UIViewController>(ofType type: T.Type) -> T? {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if let targetController = controller as? T {
                    return targetController
                }
            }
        }
        return nil
    }
}

