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

	/// A closure returning a Promise that gets fulfilled with a token
	typealias TokenHook = () -> Promise<String?>

	/**
	Initialize a network Session with the parameters
	- Parameters:
	- baseURL: The base URL of the server
	- urlSession: The URLSession to use
	- xHeaderFields: Additional header fields used for every request send by this service
	- tokenHook: Optional `TokenHook` that returns a Promise which gets fulfilled with a token
	*/
	init(baseURL: URL, urlSession: URLSession, xHeaderFields: [String: String], tokenHook: TokenHook?)

	/** Sends the given `URLRequest` to a server. Using the servers base URL
	and `URLSession` this `NetworkService` was initilazied with.

	- Parameter request: The `URLRequest` that will be send to the server
	- Returns: A `NetworkServiceResponse` containign the response and the received data, if any
	*/
	func sendRequest(_ request: URLRequest) -> NetworkServiceResponse
}
