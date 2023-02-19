// ----------------------------------------------------------------------------
//
//  LoginAssembler.swift
//
//  @author     Artem Lashmanov <https://github.com/qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import CoreFirebaseService
import UIKit

// ----------------------------------------------------------------------------

class LoginAssembler {

// MARK: - Methods

    static func build(coordinator: GuestCoordinator) -> UIViewController {

        let view = LoginViewController()
        let authorizationService = AuthorizationService()

        let presenter = LoginPresenter(
            view: view,
            coordinator: coordinator,
            authorizationService: authorizationService
        )

        view.presenter = presenter

        return view
    }
}
