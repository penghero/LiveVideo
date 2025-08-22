//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import StoreKit // 导入StoreKit框架

class DonateViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // 打赏金额选项
    private let donationAmounts = [1.0, 5.0, 10.0, 99.0]
    private var selectedAmount: Double?
    
    // 产品标识符（需要与App Store Connect中设置的一致）
    private let productIdentifiers = [
        "pgg.com.VideoToLove.1",  // $1
        "pgg.com.VideoToLove.5",  // $5
        "pgg.com.VideoToLove.10", // $10
        "pgg.com.VideoToLove.99"  // $99
    ]
    
    // 存储加载的产品
    private var products = [SKProduct]()
    // 存储产品ID和产品的映射关系
    private var productMap = [String: SKProduct]()
    
    // 标题标签
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "支持我们"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    // 描述标签
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "您的支持将帮助我们持续改进产品\n感谢您的爱心捐赠！"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    // 图标视图
    private let appIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = UIColor.systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemPink.cgColor
        // 添加阴影效果
        imageView.layer.shadowColor = UIColor.systemPink.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowRadius = 6
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    // 捐赠金额按钮数组
    private var amountButtons = [UIButton]()
    
    // 确认捐赠按钮
    private let donateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确认捐赠", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.isEnabled = false
        // 添加阴影效果
        button.layer.shadowColor = UIColor.systemPink.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
        return button
    }()
    
    // 隐私说明标签
    private let privacyNoteLabel: UILabel = {
        let label = UILabel()
        label.text = "所有支付信息将通过安全通道处理\n您的个人信息不会被收集"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // 恢复购买按钮
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("恢复购买", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 加载指示器
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        title = "打赏"
        
        // 配置视图
        configureUI()
        configureConstraints()
        configureTheme()
        
        // 添加手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // 设置StoreKit观察者
        SKPaymentQueue.default().add(self)
        
        // 加载产品信息
        loadProducts()
    }
    
    deinit {
        // 移除观察者
        SKPaymentQueue.default().remove(self)
    }
    
    // 配置UI
    private func configureUI() {
        // 添加子视图
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(appIconView)
        view.addSubview(activityIndicator)
        
        // 创建金额按钮
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        view.addSubview(buttonStackView)
        
        for amount in donationAmounts {
            let button = createAmountButton(amount: amount)
            amountButtons.append(button)
            buttonStackView.addArrangedSubview(button)
        }
        
        // 添加确认按钮、恢复购买按钮和隐私说明
        view.addSubview(donateButton)
        view.addSubview(restoreButton)
        view.addSubview(privacyNoteLabel)
        
        // 添加按钮点击事件
        donateButton.addTarget(self, action: #selector(donateButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
    }
    
    // 创建金额按钮
    private func createAmountButton(amount: Double) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("$\(amount)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(amountButtonTapped(_:)), for: .touchUpInside)
        button.isEnabled = false // 默认禁用，加载产品后启用
        // 添加轻微的阴影效果
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
        button.layer.masksToBounds = false
        return button
    }
    
    // 配置约束
    private func configureConstraints() {
        // 使用SnapKit设置约束
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(30)
        }
        
        appIconView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(appIconView)
        }
        
        // 获取金额按钮堆栈视图
        guard let buttonStackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            return
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(appIconView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(200)
        }
        
        donateButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        restoreButton.snp.makeConstraints {
            $0.top.equalTo(donateButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        privacyNoteLabel.snp.makeConstraints {
            $0.top.equalTo(restoreButton.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(30)
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    // 配置主题
    private func configureTheme() {
        updateColorsForCurrentTheme()
        
        // 跟随系统主题
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .unspecified
        }
    }
    
    // 更新当前主题的颜色
    private func updateColorsForCurrentTheme() {
        let isDarkMode = view.traitCollection.userInterfaceStyle == .dark
        
        // 背景颜色
        view.backgroundColor = .systemBackground
        
        // 金额按钮
        for button in amountButtons {
            button.layer.borderColor = (button.isSelected ? UIColor.systemPink.cgColor : (isDarkMode ? UIColor.systemGray4.cgColor : UIColor.systemGray3.cgColor))
            button.backgroundColor = button.isSelected ? UIColor.systemPink.withAlphaComponent(0.1) : UIColor.clear
            button.setTitleColor(button.isSelected ? UIColor.systemPink : .label, for: .normal)
        }
        
        // 捐赠按钮
        donateButton.backgroundColor = donateButton.isEnabled ? UIColor.systemPink : UIColor.systemGray
        donateButton.setTitleColor(.white, for: .normal)
    }
    
    // 金额按钮点击事件
    @objc private func amountButtonTapped(_ sender: UIButton) {
        // 重置所有按钮状态
        for button in amountButtons {
            button.isSelected = false
        }
        
        // 设置选中按钮状态
        sender.isSelected = true
        
        // 获取选中的金额
        if let title = sender.title(for: .normal), let amount = Double(title.dropFirst()) {
            selectedAmount = amount
        }
        
        // 更新按钮状态
        donateButton.isEnabled = true
        updateColorsForCurrentTheme()
    }
    
    // 捐赠按钮点击事件
    @objc private func donateButtonTapped() {
        // 隐藏键盘
        dismissKeyboard()
        
        // 检查是否有选中的金额
        guard let selectedAmount = selectedAmount else {
            showToast("请选择捐赠金额")
            return
        }
        
        // 检查用户是否允许应用内购买
        if SKPaymentQueue.canMakePayments() {
            // 查找对应的产品
            if let product = getProductForAmount(selectedAmount) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
                showActivityIndicator()
            } else {
                showToast("无法找到对应金额的产品")
            }
        } else {
            showToast("请在设备设置中启用应用内购买")
        }
    }
    
    // 恢复购买
    @objc private func restorePurchases() {
        if SKPaymentQueue.canMakePayments() {
            showActivityIndicator()
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            showToast("请在设备设置中启用应用内购买")
        }
    }
    
    // 隐藏键盘
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 显示提示信息
    private func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.width/2 - 150, y: view.frame.height - 120, width: 300, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
    
    // 系统主题变化时调用
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateColorsForCurrentTheme()
            }
        }
    }
    
    // MARK: - StoreKit 相关方法
    
    // 加载产品信息
    private func loadProducts() {
        showActivityIndicator()
        
        let productIdentifiersSet = Set(productIdentifiers)
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiersSet)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // 根据金额获取产品
    private func getProductForAmount(_ amount: Double) -> SKProduct? {
        // 这里简单匹配金额，实际项目中应该根据产品ID精确匹配
        let targetPrice = NSDecimalNumber(value: amount)
        
        for product in products {
            if product.price == targetPrice {
                return product
            }
        }
        
        return nil
    }
    
    // 显示加载指示器
    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        donateButton.isEnabled = false
        for button in amountButtons {
            button.isEnabled = false
        }
    }
    
    // 隐藏加载指示器
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        if selectedAmount != nil {
            donateButton.isEnabled = true
        }
        for button in amountButtons {
            button.isEnabled = true
        }
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            
            if !response.products.isEmpty {
                self.products = response.products
                
                // 构建产品映射
                for product in response.products {
                    self.productMap[product.productIdentifier] = product
                }
                
                // 启用金额按钮
                for button in self.amountButtons {
                    button.isEnabled = true
                }
                
                // 更新按钮标题为本地化价格
                for product in response.products {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = product.priceLocale
                    let priceString = formatter.string(from: product.price)
                    
                    // 这里可以根据产品ID设置对应的按钮标题
                    // 为了简化，我们保持原有的美元金额显示
                }
            } else {
                self.showToast("无法加载产品信息")
                print("无法加载产品: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.showToast("加载产品信息失败: \(error.localizedDescription)")
            print("产品请求失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // 购买中，无需处理
                break
            case .purchased:
                // 购买成功
                completeTransaction(transaction)
            case .failed:
                // 购买失败
                failedTransaction(transaction)
            case .restored:
                // 恢复购买
                restoreTransaction(transaction)
            case .deferred:
                // 交易延迟（儿童隐私设置等）
                deferredTransaction(transaction)
            @unknown default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            
            // 提供购买的内容（对于打赏功能，这里只是感谢）
            // 修复SKPayment没有product属性的问题
            let productIdentifier = transaction.payment.productIdentifier
            if let product = self.productMap[productIdentifier] {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                let priceString = formatter.string(from: product.price) ?? ""
                
                self.showToast("感谢您的 \(priceString) 捐赠！")
            } else {
                self.showToast("感谢您的捐赠！")
            }
            
            // 完成交易
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            
            if let error = transaction.error as? SKError {
                if error.code != .paymentCancelled {
                    self.showToast("支付失败: \(error.localizedDescription)")
                }
            }
            
            // 完成交易
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            // 对于打赏功能，恢复购买主要是为了用户在更换设备时能看到他们的捐赠记录
            self.hideActivityIndicator()
            self.showToast("购买记录已恢复")
            
            // 完成交易
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func deferredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.showToast("交易等待中，请稍候...")
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            
            if queue.transactions.isEmpty {
                self.showToast("没有找到购买记录")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.showToast("恢复购买失败: \(error.localizedDescription)")
        }
    }
}
