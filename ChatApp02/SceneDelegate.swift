//
//  SceneDelegate.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        var vcs: [UIViewController] = []
        
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        
        let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
        let chatListViewController = storyboard.instantiateViewController(identifier: "ChatListViewController")
        let nav = UINavigationController(rootViewController: chatListViewController)
        nav.tabBarItem = UITabBarItem(title: "トーク", image: UIImage(named: "speech"), tag: 1)
        vcs.append(nav)
        
        let pStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        
        let profileVC = pStoryboard.instantiateViewController(withIdentifier: "ProfileViewController")
        let nav2 = UINavigationController(rootViewController: profileVC)
        
        nav2.tabBarItem = UITabBarItem(title: "プロフィール", image: UIImage(named: "profile1" ), tag: 2)
        vcs.append(nav2)
        let tabc: UITabBarController = UITabBarController(nibName: nil, bundle: Bundle.main)
        tabc.setViewControllers(vcs, animated: true)
        window.rootViewController = tabc
        
        
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        
    }
    
    
    
    
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

