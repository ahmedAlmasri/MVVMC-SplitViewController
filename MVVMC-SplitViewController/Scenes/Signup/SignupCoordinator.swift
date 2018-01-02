//
//  SignupCoordinator.swift
//  MVVMC-SplitViewController
//
//  Created by Mathew Gacy on 1/1/18.
//  Copyright © 2018 Mathew Gacy. All rights reserved.
//

import RxCocoa
import RxSwift

/// Type defining possible coordination results of the `SignupCoordinator`.
///
/// - signUp: Signup completed successfully.
/// - cancel: Cancel button was tapped.
enum SignupCoordinationResult {
    case signUp
    case cancel
}

class SignupCoordinator: BaseCoordinator<SignupCoordinationResult> {

    private let rootViewController: UIViewController
    private let client: APIClient

    init(rootViewController: UIViewController, client: APIClient) {
        self.rootViewController = rootViewController
        self.client = client
    }

    override func start() -> Observable<CoordinationResult> {
        var viewController = SignupViewController.instance()
        let navigationController = UINavigationController(rootViewController: viewController)

        var avm: Attachable<SignupViewModel> = .detached(SignupViewModel.Dependency(client: client))
        let viewModel = viewController.bind(toViewModel: &avm)

        let cancel = viewModel.cancelled
            .map { _ in CoordinationResult.cancel }
        let signUp = viewModel.signedUp
            .map { _ in CoordinationResult.signUp }

        rootViewController.present(navigationController, animated: true)

        return Driver.merge(cancel, signUp)
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] _ in self?.rootViewController.dismiss(animated: true) })
    }

}
