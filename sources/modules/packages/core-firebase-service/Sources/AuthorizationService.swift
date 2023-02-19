// ----------------------------------------------------------------------------
//
//  AuthorizationService.swift
//
//  @author     Artem Lashmanov <@qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import FirebaseAuth

// ----------------------------------------------------------------------------

public final class AuthorizationService: IAuthorizationService {

// MARK: - Construction

    public init() {
        // Do nothing
    }

// MARK: - Methods

    public func login(
        email: String,
        password: String,
        completion: @escaping (AuthorizationResult) -> Void
    ) {

        runTask(completion: completion) { [unowned self] in
            return try await login(email: email, password: password)
        }
    }

    public func login(email: String, password: String) async throws -> User {

        return try await withCheckedThrowingContinuation { continuation in
            _auth.signIn(withEmail: email, password: password) { authResult, error in

                if let authResult {
                    continuation.resume(returning: authResult.user)
                } else {
                    continuation.resume(throwing: error ?? AuthorizationError())
                }
            }
        }
    }

    public func register(
        email: String,
        password: String,
        completion: @escaping (AuthorizationResult) -> Void
    ) {

        runTask(completion: completion) { [unowned self] in
            return try await register(email: email, password: password)
        }
    }

    public func register(email: String, password: String) async throws -> User {

        return try await withCheckedThrowingContinuation { continuation in
            _auth.createUser(withEmail: email, password: password) { authResult, error in

                if let authResult {
                    continuation.resume(returning: authResult.user)
                } else {
                    continuation.resume(throwing: error ?? AuthorizationError())
                }
            }
        }
    }

    public func logout() throws {
        do {
            try _auth.signOut()
        }
        catch {
            throw AuthorizationError()
        }
    }

// MARK: - Variables

    private let _auth = Auth.auth()
}
