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

    init(view: LoginViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    
    func login(email: String, password: String)
    func getUserInfo(id: String)
    func saveUser(_ user: UserData)
}

class LoginPresenter: LoginPresenterProtocol {

// MARK: - Construction

    required init(view: LoginViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }

// MARK: - Properties

    weak var view: LoginViewProtocol?
    weak var coordinator: GuestCoordinator?
    var service: UserServiceProtocol?
    var authorizationService: IAuthorizationService = AuthorizationService()

// MARK: - Methods

    func viewDidLoad() {
        Task {
            await view?.configure()
        }
    }

    func login(email: String, password: String) {
        Task {
            do {
                let user = try await authorizationService.login(email: email, password: password)
                getUserInfo(id: user.uid)
            } catch {
                await view?.showErrorMessage(message: "Произошла ошибка при авторизации")
            }
        }
    }
    
    func getUserInfo(id: String) {
        service?.fetchUserData(by: id, completion: { [weak self] result in
            switch result {
            case .success(let user):
                self?.saveUser(user)

                //                Task {
                //                    await self?.view?.showSuccessMessage(message: Constants.Messages.successUserLogin)
                //                }

                self?.coordinator?.finishFlow()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
    func saveUser(_ user: UserData) {
        let firstName = user.firstName
        let lastName = user.lastName
        let userId = user.id
        
        let userFullName = ["firstName": firstName, "lastName": lastName]
        
        SettingsService.sharedInstance.saveUserData(userId: userId, userFullName: userFullName)
    }
}
