// ----------------------------------------------------------------------------
//
//  LoginPresenter.swift
//
//  @author     Artem Lashmanov <https://github.com/qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import CoreFirebaseService

// ----------------------------------------------------------------------------

protocol LoginPresenterProtocol {

    // MARK: - Methods

    func viewDidLoad()
    
    func login(email: String, password: String)
}

class LoginPresenter {

// MARK: - Construction

    init(
        view: LoginViewProtocol,
        coordinator: GuestCoordinator,
        authorizationService: IAuthorizationService
    ) {

        self.view = view
        self.coordinator = coordinator
        self.authorizationService = authorizationService
    }

// MARK: - Properties

    weak var view: LoginViewProtocol?

    weak var coordinator: GuestCoordinator?

    var authorizationService: IAuthorizationService
}

// ----------------------------------------------------------------------------
// MARK: - @protocol LoginPresenterProtocol
// ----------------------------------------------------------------------------

extension LoginPresenter: LoginPresenterProtocol {

// MARK: - Methods

    func viewDidLoad() {
        // Do nothing
    }

    func login(email: String, password: String) {
        Task {
            do {
                let user = try await authorizationService.login(email: email, password: password)

                saveUserData(user.uid)

                finishFlow()
            } catch {
                await view?.showErrorMessage(message: "Произошла ошибка при авторизации")
            }
        }
    }

    private func finishFlow() {
        Task { @MainActor in
            self.coordinator?.finishFlow()
        }
    }

    private func saveUserData(_ uid: String) {
        SettingsService.sharedInstance.saveUserData(userId: uid, userFullName: nil)
    }
}
