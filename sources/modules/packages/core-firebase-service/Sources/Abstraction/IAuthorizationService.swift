// ----------------------------------------------------------------------------
//
//  IAuthorizationService.swift
//
//  @author     Artem Lashmanov <@qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import FirebaseAuth

// ----------------------------------------------------------------------------

public protocol IAuthorizationService: IFirebaseService {

// MARK: - Methods

    func login(
        email: String,
        password: String,
        completion: @escaping (AuthorizationResult) -> Void
    )

    func login(email: String, password: String) async throws -> User

    func register(
        email: String,
        password: String,
        completion: @escaping (AuthorizationResult) -> Void
    )

    func register(email: String, password: String) async throws -> User

    func logout() throws
}
