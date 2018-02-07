//
//  SplitViewCoordinator.swift
//  MVVMC-SplitViewController
//
//  Created by Mathew Gacy on 12/28/17.
//  Copyright © 2017 Mathew Gacy. All rights reserved.
//

import RxSwift

class SplitViewCoordinator: BaseCoordinator<Void> {
    typealias Dependencies = HasClient & HasUserManager

    private let window: UIWindow
    private let dependencies: Dependencies

    // swiftlint:disable:next weak_delegate
    private let viewDelegate: SplitViewDelegate

    enum SectionTab {
        case posts
        case albums
        case todos
        case profile

        var title: String {
            switch self {
            case .posts: return "Posts"
            case .albums: return "Albums"
            case .todos: return "Todos"
            case .profile: return "Profile"
            }
        }

        var image: UIImage {
            switch self {
            case .posts: return #imageLiteral(resourceName: "PostsTabIcon")
            case .albums: return #imageLiteral(resourceName: "AlbumsTabIcon")
            case .todos: return #imageLiteral(resourceName: "TodosTabIcon")
            case .profile: return #imageLiteral(resourceName: "ProfileTabIcon")
            }
        }

    }

    // MARK: - Lifecycle

    init(window: UIWindow, dependencies: Dependencies) {
        self.window = window
        self.dependencies = dependencies

        let detailNavigationController = DetailNavigationController()
        self.viewDelegate = SplitViewDelegate(detailNavigationController: detailNavigationController)
    }

    override func start() -> Observable<CoordinationResult> {
        let tabBarController = UITabBarController()
        let tabs: [SectionTab] = [.posts, .albums, .todos, .profile]
        let coordinationResults = Observable.from(configure(tabBarController: tabBarController, withTabs: tabs)).merge()

        if let initialPrimaryView = tabBarController.selectedViewController as? PrimaryContainerType {
            viewDelegate.updateSecondaryWithDetail(from: initialPrimaryView)
        }

        let splitViewController = UISplitViewController()
        splitViewController.delegate = viewDelegate
        splitViewController.viewControllers = [tabBarController, viewDelegate.detailNavigationController]
        splitViewController.preferredDisplayMode = .allVisible

        window.rootViewController = splitViewController
        window.makeKeyAndVisible()

        return coordinationResults
    }

    private func configure(tabBarController: UITabBarController, withTabs tabs: [SectionTab]) -> [Observable<Void>] {
        let navControllers = tabs
            .map { tab -> UINavigationController in
                let navController = NavigationController()
                navController.tabBarItem = UITabBarItem(title: tab.title, image: tab.image, selectedImage: nil)
                //navController.navigationBar.prefersLargeTitles = true
                //navController.navigationItem.largeTitleDisplayMode = .automatic
                return navController
            }

        tabBarController.viewControllers = navControllers
        tabBarController.delegate = viewDelegate
        tabBarController.view.backgroundColor = UIColor.white  // Fix dark shadow in nav bar on segue

        return zip(tabs, navControllers)
            .map { (tab, navCtrl) in
                switch tab {
                case .posts:
                    let coordinator = PostsCoordinator(navigationController: navCtrl, dependencies: dependencies)
                    return coordinate(to: coordinator)
                case .albums:
                    let coordinator = AlbumsCoordinator(navigationController: navCtrl, dependencies: dependencies)
                    return coordinate(to: coordinator)
                case .todos:
                    let coordinator = TodosCoordinator(navigationController: navCtrl, dependencies: dependencies)
                    return coordinate(to: coordinator)
                case .profile:
                    let coordinator = ProfileCoordinator(navigationController: navCtrl, dependencies: dependencies)
                    return coordinate(to: coordinator)
                }
            }
    }

}
