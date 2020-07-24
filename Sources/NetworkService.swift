//
//  NetworkService.swift
//
//  Created by Joachim Deelen on 08.01.18.
//  Copyright © 2018 micabo-software UG. All rights reserved.
//
import Foundation
import PromiseKit

/// Encapsulates the `HTTPURLRsponse` with the received `Data`
public typealias NetworkServiceResponse = Promise<(response: HTTPURLResponse, data: Data)>


/** Base protocol for any kind of NetworkService.
*/
public protocol NetworkService {

	typealias TokenHook = () -> Promise<String>

	/** Initialize a network Session with the given base `URL` and `URLSession`
	*/
	init(baseURL: URL, urlSession: URLSession, xHeaderFields: [String: String], tokenHook: TokenHook?)

	/** Sends the given `URLRequest` to a server. Using the servers base URL
	and `URLSession` this `NetworkService` was initilazied with.

	- Parameter request: The `URLRequest` that will be send to the server
	- Returns: A `NetworkServiceResponse` containign the response and the received data, if any
	*/
	func sendRequest(_ request: URLRequest) -> NetworkServiceResponse
}
