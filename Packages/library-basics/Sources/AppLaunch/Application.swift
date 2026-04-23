//
//  Application.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation
import UIKit


@objc public protocol AppDelegateModule: UIApplicationDelegate, UIWindowSceneDelegate {

    /// 组件名称
    var moduleName: String { get }
    
    @objc
    /// 是否为默认兜底组件
    optional var isDefalutlModule: Bool { get }
    
    @objc
    /// 组件在该方法中加载启动视图， 配合isMainApp使用
    optional func load(_ window: UIWindow?)
    
    @objc
    /// 在 application(_ :didFinishLaunchingWithOptions:) 中最先转发
    /// 注册一些高优先级的内容
    optional func applicationHighPriority(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    
    @objc
    /// scheme打开app的默认回调方法
    /// 如果被激活的视图模块返回false，或者未处理
    /// 那么就交由默认模块处理
    /// 整个工程只能实现一个默认模块
    optional func defaultApplication(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    
    @objc
    /// universal link打开app的默认回调方法
    /// 如果被激活的视图模块返回false，或者未处理
    /// 那么就交由默认模块处理
    /// 整个工程只能实现一个默认模块
    optional func defaultApplication(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool

}

/// 初始化mircapp的applicationModule实例
@discardableResult
public func entry<T: UIResponder>(_ closure: () -> T) -> Bool where T: AppDelegateModule {
    Application.agent.register(appDelegateModule: closure())
}

@objc(BLKApplication)
public class Application: NSObject {

    private override init() {}

    ///  展示在前台的MircoApp（必须传递isMircoApp为true的组件名称）
    ///  当MircoApp组件即将展示到前台之前时，MircoApp主动声明
    private var frontModule = ""

    private var window: UIWindow?

    /// 存储mircapp的applicationModule实例
    private var appDelegateModules: Set<UIResponder> = []

}

private extension Application {

    func register<T: UIResponder>(appDelegateModule mircoApp: T) -> Bool where T: AppDelegateModule {

        assert(mircoApp.moduleName != "", "mircoApp的moduleName不能为空")
#if DEBUG
        for module in appDelegateModules where module is AppDelegateModule {
            let app = module as? AppDelegateModule
            assert(app?.moduleName != mircoApp.moduleName, "mircoApp的moduleName\(app?.moduleName ?? "")不能重复")
        }
#endif
        return appDelegateModules.insert(mircoApp).inserted
    }
    
    /// 查找前台mircoApp
    func find(frontModule: String) -> AppDelegateModule? {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            if app?.moduleName == frontModule {
                return app
            }
        }
        return nil
    }
}

public extension Application {

    @objc
    /// 单例
    static let agent = Application()

    @objc
    /// 设置当前运行的视图组件名
    func frontModule(_ name: String) -> Application {
        frontModule = name
        return self
    }

    @objc
    /// 壳工程中请配置window
    func load(_ window: UIWindow?) -> Application {
        self.window = window
        return self
    }
    
    @objc
    /// 查找前台mircoApp
    func foundFrontModule() -> AppDelegateModule? {
        find(frontModule: frontModule)
    }
}

public extension Application {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {

        /// 驱动注册组件对象
        AppForwarder().engine()
        
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            app?.applicationHighPriority?(application, didFinishLaunchingWithOptions: launchOptions)
        }

        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    
    /// 屏幕旋转
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        find(frontModule: frontModule)?
            .application?(application, supportedInterfaceOrientationsFor: window) ?? UIInterfaceOrientationMask.all
    }
    
    /// 通过scheme打开 app
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let result = find(frontModule: frontModule)?.application?(app, open: url, options: options)
        if result == true {
            return true
        }
        
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let mircoApp = mircoApp as? AppDelegateModule
            if mircoApp?.isDefalutlModule == true {
                return mircoApp?.defaultApplication?(app, open: url, options: options) ?? false
            }
        }
        return false
    }
    
    /// 通过universal link打开 app
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
        let result = find(frontModule: frontModule)?.application?(application, continue: userActivity, restorationHandler: restorationHandler)
        if result == true {
            return true
        }
        
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let mircoApp = mircoApp as? AppDelegateModule
            if mircoApp?.isDefalutlModule == true {
                return mircoApp?.defaultApplication?(application, continue: userActivity, restorationHandler: restorationHandler) ?? false
            }
        }
        return false
    
    }
    
    /// 注册通知deviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }
    
    /// 接受通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.application?(application, didReceiveRemoteNotification: userInfo)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.applicationDidEnterBackground?(application)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.applicationWillEnterForeground?(application)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.applicationDidBecomeActive?(application)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.applicationWillResignActive?(application)
        }
    }
}

public extension Application {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.scene?(scene, willConnectTo: session, options: connectionOptions)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.sceneDidDisconnect?(scene)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.sceneDidBecomeActive?(scene)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.sceneWillResignActive?(scene)
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.sceneWillEnterForeground?(scene)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        for mircoApp in appDelegateModules where mircoApp is AppDelegateModule {
            let app = mircoApp as? AppDelegateModule
            _ = app?.sceneDidEnterBackground?(scene)
        }
    }
}
