//
//  DonateViewController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit
import StoreKit
import SnapKit

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
    
    // 内容容器视图
    private let contentContainer = UIView()
    
    // 标题标签
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "支持我们"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    // 描述标签
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "您的支持将帮助我们持续改进产品\n感谢您的爱心捐赠！"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    // 图标视图
    private let appIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = UIColor.red
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.red.cgColor
        return imageView
    }()
    
    // 捐赠金额按钮数组
    private var amountButtons = [UIButton]()
    
    // 确认捐赠按钮
    private let donateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确认捐赠", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.isEnabled = false
        button.backgroundColor = UIColor.lightGray
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // 隐私说明标签
    private let privacyNoteLabel: UILabel = {
        let label = UILabel()
        label.text = "所有支付信息将通过安全通道处理\n您的个人信息不会被收集"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    
    // 恢复购买按钮
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("恢复购买", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.blue, for: .normal)
        return button
    }()
    
    // 加载指示器
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // 装饰性元素 - 顶部波浪
    private let waveView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题 - 使用本地化字符串
        self.title = "donate_title".localized
        
        // 配置视图
        setupUI()
        setupConstraints()
        setupAnimations()
        
        // 添加手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // 设置StoreKit观察者
        SKPaymentQueue.default().add(self)
        
        // 加载产品信息
        loadProducts()
        
        // 注册语言变化通知
        registerForLanguageChanges()
    }
    
    deinit {
        // 移除观察者
        SKPaymentQueue.default().remove(self)
        
        // 取消注册语言变化通知
        unregisterForLanguageChanges()
    }
    
    // 配置UI
    private func setupUI() {
        // 设置背景色
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        // 添加装饰性波浪
        waveView.backgroundColor = UIColor(red: 255/255, green: 200/255, blue: 200/255, alpha: 0.3)
        waveView.layer.cornerRadius = 150
        waveView.transform = CGAffineTransform(scaleX: 2.0, y: 1.0)
        
        // 创建内容容器
        contentContainer.backgroundColor = .white
        contentContainer.layer.cornerRadius = 20
        contentContainer.layer.shadowColor = UIColor.black.cgColor
        contentContainer.layer.shadowOpacity = 0.1
        contentContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentContainer.layer.shadowRadius = 10
        
        // 添加子视图
        view.addSubview(waveView)
        view.addSubview(contentContainer)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(descriptionLabel)
        contentContainer.addSubview(appIconView)
        contentContainer.addSubview(activityIndicator)
        
        // 更新UI文本为本地化字符串
        updateLocalizedText()
        
        // 创建金额按钮
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually
        contentContainer.addSubview(buttonStackView)
        
        for amount in donationAmounts {
            let button = createAmountButton(amount: amount)
            amountButtons.append(button)
            buttonStackView.addArrangedSubview(button)
        }
        
        // 添加确认按钮、恢复购买按钮和隐私说明
        contentContainer.addSubview(donateButton)
        contentContainer.addSubview(restoreButton)
        contentContainer.addSubview(privacyNoteLabel)
        
        // 添加按钮点击事件
        donateButton.addTarget(self, action: #selector(donateButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
    }
    
    // 更新本地化文本
    private func updateLocalizedText() {
        titleLabel.text = "donate_title".localized
        descriptionLabel.text = "donate_full_description".localized
        donateButton.setTitle("donate_confirm_button".localized, for: .normal)
        restoreButton.setTitle("donate_restore_button".localized, for: .normal)
        privacyNoteLabel.text = "donate_privacy_note".localized
        
        // 更新金额按钮文本（如果已有产品信息）
        for product in products {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            if let priceString = formatter.string(from: product.price) {
                for button in amountButtons {
                    if let buttonTitle = button.title(for: .normal),
                       let buttonAmount = Double(buttonTitle.dropFirst()),
                       product.price == NSDecimalNumber(value: buttonAmount) {
                        button.setTitle(priceString, for: .normal)
                        break
                    }
                }
            }
        }
    }
    
    // 当语言变化时调用
    override func languageDidChange() {
        updateLocalizedText()
    }
    
    // 创建金额按钮
    private func createAmountButton(amount: Double) -> UIButton {
        let button = UIButton(type: .system)
        
        // 根据当前语言设置不同的货币符号
        let currencySymbol = LocalizableManager.shared.currentLanguage == "zh-Hans" ? "$" : "$"
        button.setTitle("\(currencySymbol)\(amount)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(amountButtonTapped(_:)), for: .touchUpInside)
        button.isEnabled = false // 默认禁用，加载产品后启用
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        return button
    }
    
    // 配置约束
    private func setupConstraints() {
        // 波浪装饰视图约束
        waveView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-200)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(400)
        }
        
        // 内容容器约束
        contentContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        // 标题标签约束
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        // 描述标签约束
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(30)
        }
        
        // 图标视图约束
        appIconView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        
        // 加载指示器约束
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(appIconView)
        }
        
        // 获取金额按钮堆栈视图
        guard let buttonStackView = contentContainer.subviews.first(where: { $0 is UIStackView }) as? UIStackView else {
            return
        }
        
        // 金额按钮堆栈视图约束
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(appIconView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(220)
        }
        
        // 确认捐赠按钮约束
        donateButton.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        // 恢复购买按钮约束
        restoreButton.snp.makeConstraints {
            $0.top.equalTo(donateButton.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        // 隐私说明标签约束
        privacyNoteLabel.snp.makeConstraints {
            $0.top.equalTo(restoreButton.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }
    
    // 添加动画效果
    private func setupAnimations() {
        // 初始状态设置为不可见
        contentContainer.alpha = 0.0
        contentContainer.transform = CGAffineTransform(translationX: 0, y: 30)
        
        appIconView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // 添加淡入和上移动画
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.contentContainer.alpha = 1.0
            self.contentContainer.transform = .identity
        }, completion: nil)
        
        // 添加图标缩放动画
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, animations: {
            self.appIconView.transform = .identity
        }, completion: nil)
        
        // 波浪装饰动画
        UIView.animate(withDuration: 10.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut], animations: {
            self.waveView.transform = CGAffineTransform(scaleX: 2.2, y: 1.1).rotated(by: 0.05)
        }, completion: nil)
    }
    
    // 金额按钮选中状态更新
    private func updateButtonSelectionStates() {
        for button in amountButtons {
            if button.isSelected {
                button.layer.borderColor = UIColor.red.cgColor
                button.backgroundColor = UIColor(red: 255/255, green: 240/255, blue: 240/255, alpha: 1.0)
                button.setTitleColor(.red, for: .normal)
            } else {
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        }
        
        // 更新捐赠按钮状态
        donateButton.isEnabled = selectedAmount != nil
        donateButton.backgroundColor = selectedAmount != nil ? UIColor.red : UIColor.lightGray
        
        // 添加选中按钮的动画效果
        if let selectedButton = amountButtons.first(where: { $0.isSelected }) {
            UIView.animate(withDuration: 0.2, animations: {
                selectedButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    selectedButton.transform = .identity
                })
            })
        }
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
        updateButtonSelectionStates()
    }
    
    // 捐赠按钮点击事件
    @objc private func donateButtonTapped() {
        // 隐藏键盘
        dismissKeyboard()
        
        // 检查是否有选中的金额
        guard let selectedAmount = selectedAmount else {
            showToast("donate_select_amount".localized)
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
                showToast("donate_product_not_found".localized)
            }
        } else {
            showToast("donate_enable_in_app_purchase".localized)
        }
    }
    
    // 恢复购买
    @objc private func restorePurchases() {
        if SKPaymentQueue.canMakePayments() {
            showActivityIndicator()
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            showToast("donate_enable_in_app_purchase".localized)
        }
    }
    
    // 隐藏键盘
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 显示提示信息
    private func showToast(_ message: String) {
        // 创建提示标签
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.layer.shadowColor = UIColor.black.cgColor
        toastLabel.layer.shadowOpacity = 0.2
        toastLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        toastLabel.layer.shadowRadius = 4
        toastLabel.layer.masksToBounds = false
        
        // 添加到视图
        view.addSubview(toastLabel)
        
        // 设置约束，增加内边距效果
        toastLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            $0.left.right.greaterThanOrEqualToSuperview().inset(40)
            $0.width.lessThanOrEqualTo(view.frame.width - 80)
            $0.height.greaterThanOrEqualTo(60) // 增加最小高度来模拟内边距效果
        }
        
        // 初始状态设置为不可见
        toastLabel.alpha = 0.0
        toastLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        
        // 显示动画
        UIView.animate(withDuration: 0.3) {
            toastLabel.alpha = 1.0
            toastLabel.transform = .identity
        }
        
        // 隐藏动画
        UIView.animate(withDuration: 0.3, delay: 2.0) {
            toastLabel.alpha = 0.0
            toastLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: {_ in 
            toastLabel.removeFromSuperview()
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
                self.updateLocalizedText()
            } else {
                print("无法加载产品: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { 
            self.hideActivityIndicator()
            self.showToast("donate_load_product_error".localized + error.localizedDescription)
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
            let productIdentifier = transaction.payment.productIdentifier
            if let product = self.productMap[productIdentifier] {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                let priceString = formatter.string(from: product.price) ?? ""
                
                self.showToast(String(format: "donate_thank_you_with_amount".localized, priceString))
            } else {
                self.showToast("donate_thank_you".localized)
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
                    self.showToast("donate_payment_failed".localized + error.localizedDescription)
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
            self.showToast("donate_purchases_restored".localized)
            
            // 完成交易
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func deferredTransaction(_ transaction: SKPaymentTransaction) {
        DispatchQueue.main.async { 
            self.hideActivityIndicator()
            self.showToast("donate_transaction_pending".localized)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async { 
            self.hideActivityIndicator()
            
            if queue.transactions.isEmpty {
                self.showToast("donate_no_purchases_found".localized)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async { 
            self.hideActivityIndicator()
            self.showToast("donate_restore_failed".localized + error.localizedDescription)
        }
    }
}
