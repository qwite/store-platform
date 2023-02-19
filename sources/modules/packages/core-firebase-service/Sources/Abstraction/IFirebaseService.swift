// ----------------------------------------------------------------------------
//
//  IFirebaseService.swift
//
//  @author     Artem Lashmanov <@qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

public protocol IFirebaseService {
    // Do nothing
}

// ----------------------------------------------------------------------------

extension IFirebaseService {

// MARK: - Methods

    func runTask<T>(
        priority: TaskPriority = .utility,
        completion: @escaping (R<T>) -> Void,
        action: @escaping () async throws -> T
    ) {

        Task(priority: priority) {
            do {
                let success = try await action()
                completion(.success(success))
            } catch {
                completion(.failure(error))
            }
        }
    }

// MARK: - Inner Types

    typealias R<T> = Result<T, Error>
}
