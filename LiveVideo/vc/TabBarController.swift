//  TabBarController.swift
//  LiveVideo
//
//  Created by chenpeng on 2025/3/10.
//

import UIKit

class TabBarController: UITabBarController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置标签栏外观
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .systemBackground
            tabBar.standardAppearance = appearance
            
            // 将scrollEdgeAppearance移动到iOS 15.0的版本检查中
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.barTintColor = .white
        }
        
        // 初始化标签栏项目
        setupTabBarItems()
        
        // 注册语言变化通知
        registerForLanguageChanges()
    }
    
    deinit {
        // 取消注册语言变化通知
        unregisterForLanguageChanges()
    }
    
    // 初始化标签栏项目
    private func setupTabBarItems() {
        // 创建并配置HomeViewController
        let homeVC = HomeViewController()
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        homeNavVC.tabBarItem = UITabBarItem(
            title: "tabbar_convert".localized, 
            image: UIImage(systemName: "photo.on.rectangle.angled"),
            tag: 0
        )
        homeNavVC.delegate = self // 设置导航控制器代理
        
        // 创建并配置CustomLivePhotoViewController
        let customLivePhotoVC = CustomLivePhotoViewController()
        let customLivePhotoNavVC = UINavigationController(rootViewController: customLivePhotoVC)
        customLivePhotoNavVC.tabBarItem = UITabBarItem(
            title: "tabbar_custom".localized, 
            image: UIImage(systemName: "wand.and.stars"),
            tag: 1
        )
        customLivePhotoNavVC.delegate = self // 设置导航控制器代理
        
        // 创建并配置SettingsViewController
        let settingsVC = SettingsViewController()
        let settingsNavVC = UINavigationController(rootViewController: settingsVC)
        settingsNavVC.tabBarItem = UITabBarItem(
            title: "tabbar_settings".localized, 
            image: UIImage(systemName: "gear"),
            tag: 2
        )
        settingsNavVC.delegate = self // 设置导航控制器代理
        
        // 添加到标签栏
        viewControllers = [homeNavVC, customLivePhotoNavVC, settingsNavVC]
    }
    
    // 当语言变化时调用
    override func languageDidChange() {
        // 更新标签栏项目标题
        if let items = tabBar.items {
            items[0].title = "tabbar_convert".localized
            items[1].title = "tabbar_custom".localized
            items[2].title = "tabbar_settings".localized
        }
        
        // 如果当前显示的是HomeViewController，更新其标题
        if let navVC = viewControllers?[0] as? UINavigationController,
           let homeVC = navVC.topViewController as? HomeViewController {
//            homeVC.title = "home_title".localized
        }
        
        // 如果当前显示的是CustomLivePhotoViewController，更新其标题
        if let navVC = viewControllers?[1] as? UINavigationController,
           let customVC = navVC.topViewController as? CustomLivePhotoViewController {
//            customVC.title = "home_custom_live_photo".localized
        }
        
        // 如果当前显示的是SettingsViewController，更新其标题
        if let navVC = viewControllers?[2] as? UINavigationController,
           let settingsVC = navVC.topViewController as? SettingsViewController {
//            settingsVC.title = "settings_title".localized
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    // 导航控制器显示新视图控制器之前调用
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 检查导航控制器的视图控制器栈的大小
        // 如果只有一个视图控制器（根控制器），则显示tabBar
        // 否则隐藏tabBar
        let hidesBottomBar = navigationController.viewControllers.count > 1
        viewController.hidesBottomBarWhenPushed = hidesBottomBar
        
        // 立即更新tabBar的显示状态，确保视觉效果一致
        if #available(iOS 13.0, *) {
            tabBar.isHidden = hidesBottomBar
        } else {
            // 对于iOS 13之前的版本，使用动画隐藏/显示tabBar
            UIView.animate(withDuration: 0.3) {
                self.tabBar.alpha = hidesBottomBar ? 0 : 1
            }
        }
    }
}
