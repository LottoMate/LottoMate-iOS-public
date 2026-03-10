//
//  TabBarViewController.swift
//  LottoMate
//
//  Created by Mirae on 7/26/24.
//  The current initial view controller.

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        tabBar.tintColor = .red50Default
        
        let border = UIView()
        border.backgroundColor = .gray_D9D9D9 // 원하는 테두리 색상
        border.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(border)
        
        // 오토레이아웃으로 테두리 위치 및 크기 설정
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            border.topAnchor.constraint(equalTo: tabBar.topAnchor),
            border.heightAnchor.constraint(equalToConstant: 1) // 테두리 높이
        ])
        
        
        let normalAttributes = [NSAttributedString.Key.font: Typography.caption1.font(), NSAttributedString.Key.foregroundColor: UIColor.gray]
        let selectedAttributes = [NSAttributedString.Key.font: Typography.caption1.font(), NSAttributedString.Key.foregroundColor: UIColor.red50Default]

        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
        
        
        // MARK: 홈
        let homeViewController = HomeViewController()
        let homeTabIcon = UITabBarItem(title: "홈", image: UIImage(named: "icon_clover"), selectedImage: UIImage(named: "icon_clover_selected"))
        homeViewController.tabBarItem = homeTabIcon
        homeViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        
        // MARK: 지도
        let mapViewController = MapViewController()
        let mapTabIcon = UITabBarItem(title: "지도", image: UIImage(named: "icon_map"), selectedImage: UIImage(named: "icon_map_selected"))
        mapViewController.tabBarItem = mapTabIcon
        mapViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        
        // MARK: 보관소
        let storageViewController = StorageViewController()
        let storageTabIcon = UITabBarItem(title: "랜덤 번호", image: UIImage(named: "icon_pocket"), selectedImage: UIImage(named: "icon_pocket_selected"))
        storageViewController.tabBarItem = storageTabIcon
        storageViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        
        // MARK: 라운지
        let loungeViewController = LoungeViewController()
        let loungeTabIcon = UITabBarItem(title: "라운지", image: UIImage(named: "icon_person2"), selectedImage: UIImage(named: "icon_person2_selected"))
        loungeViewController.tabBarItem = loungeTabIcon
        loungeViewController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        
        
        let tabViewControllers = [homeViewController, mapViewController, storageViewController, loungeViewController]
        self.viewControllers = tabViewControllers
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
}

#Preview {
    let preview = TabBarViewController()
    return preview
}
