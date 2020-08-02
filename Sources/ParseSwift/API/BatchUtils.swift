//
//  RESTBatchCommand.swift
//  ParseSwift
//
//  Created by Florent Vilmart on 17-08-19.
//  Copyright © 2020 Parse Community. All rights reserved.
//

import Foundation

typealias ParseObjectBatchCommand<T> = BatchCommand<T, T> where T: ObjectType
typealias ParseObjectBatchResponse<T> = [(Result<T, ParseError>)]
// swiftlint:disable line_length
typealias RESTBatchCommandType<T> = API.Command<ParseObjectBatchCommand<T>, ParseObjectBatchResponse<T>> where T: ObjectType
// swiftlint:enable line_length

internal struct BatchCommand<T, U>: Encodable where T: Encodable {
    let requests: [API.Command<T, U>]
}

internal struct BatchResponseItem<T>: Codable where T: Codable {
    let success: T?
    let error: ParseError?
}

internal struct SaveOrUpdateResponse: Codable {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?

    func asSaveResponse() -> SaveResponse {
        guard let objectId = objectId, let createdAt = createdAt else {
            fatalError("Cannot create a SaveResponse without objectId")
        }
        return SaveResponse(objectId: objectId, createdAt: createdAt)
    }

    func asUpdateResponse() -> UpdateResponse {
        guard let updatedAt = updatedAt else {
            fatalError("Cannot create an UpdateResponse without updatedAt")
        }
        return UpdateResponse(updatedAt: updatedAt)
    }

    func apply<T>(_ object: T, method: API.Method) -> T where T: ObjectType {
        switch method {
        case .POST:
            return asSaveResponse().apply(object)
        case .PUT:
            return asUpdateResponse().apply(object)
        default:
            fatalError("There is no configured way to apply for method: \(method)")
        }
    }
}
