// ----------------------------------------------------------------------------
//
//  AuthorizationResult.swift
//
//  @author     Artem Lashmanov <@qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import FirebaseAuth

// ----------------------------------------------------------------------------

public typealias AuthorizationResult =
    Result<User, Error>
