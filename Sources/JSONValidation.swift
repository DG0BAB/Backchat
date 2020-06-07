//
//  JSONValidation.swift
//  Backchat
//
//  Created by Joachim Deelen on 03.05.19.
//  Copyright © 2019 micabo-software UG. All rights reserved.
//

import Foundation


public protocol JSONValidating {
	static var requiredKeys: [CodingKey] { get }
	static func isValidJSONData(_ data: Data) -> Bool
}

public extension JSONValidating {
	static func isValidJSONData(_ data: Data) -> Bool {
		guard data.count > 0 else { return false }
		guard !requiredKeys.isEmpty else {
			Log.info("RequiredKeys of \(self) is empty. Returning true for `isValidJSONData`")
			return true
		}
		return requiredKeys.reduce(true) {
			guard $0 else { return false }
			return data.contains($1.stringValue)
		}
	}
}

public extension JSONValidating where Self: Decodable {
	init(jsonData: Data) throws {
		let decoder = JSONDecoder()
		self = try decoder.decode(Self.self, from: jsonData)
	}
}

// Adding convenience methods to make searching for string within `Data` easier
// Can i.e. be used by implementations of the `JSONValidating` protocol
extension Data {
	/// Initializes a Data instance with the UTF8 bytes of the given string
	init(string: String) {
		self.init(string.utf8)
	}

	/// Finds the range of the given string within this data object
	func range(of string: String) -> Range<Data.Index>? {
		return self.range(of: Data(string: string))
	}

	/// Returns true if the given string is contained in this data object
	func contains(_ string: String) -> Bool {
		return self.range(of: string) != nil
	}
}
