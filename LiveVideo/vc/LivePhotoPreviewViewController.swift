import UIKit
import PhotosUI
import SnapKit

class LivePhotoPreviewViewController: UIViewController {
    // Live Photo属性
    private let livePhoto: PHLivePhoto
    
    // Live Photo视图
    private var livePhotoView: PHLivePhotoView! = nil
    
    // 播放状态标志
    private var isLivePhotoPlaying = false
    
    // 初始化方法
    init(livePhoto: PHLivePhoto) {
        self.livePhoto = livePhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色
        view.backgroundColor = .black
        
        // 设置标题
        title = "Live Photo预览"
        
        // 创建并配置LivePhotoView
        setupLivePhotoView()
        
        // 添加完成按钮
        setupNavigationItem()
    }
    
    private func setupLivePhotoView() {
        // 创建LivePhotoView
        livePhotoView = PHLivePhotoView(frame: view.bounds)
        livePhotoView.livePhoto = livePhoto
        livePhotoView.isUserInteractionEnabled = true
        
        // 添加点击手势以开始/停止播放
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleLivePhotoPlayback(_:)))
        livePhotoView.addGestureRecognizer(tapGesture)
        
        // 添加到视图并设置约束
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationItem() {
        // 添加完成按钮
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPreview))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 视图出现时自动开始播放
        if #available(iOS 9.1, *) {
            livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
            isLivePhotoPlaying = true
        }
    }
    
    // 切换Live Photo播放状态
    @objc func toggleLivePhotoPlayback(_ gesture: UITapGestureRecognizer) {
        if #available(iOS 9.1, *) {
            if isLivePhotoPlaying {
                livePhotoView.stopPlayback()
            } else {
                livePhotoView.startPlayback(with: PHLivePhotoViewPlaybackStyle.full)
            }
            // 切换播放状态
            isLivePhotoPlaying.toggle()
        }
    }
    
    // 关闭预览
    @objc func dismissPreview() {
        dismiss(animated: true, completion: nil)
    }
}