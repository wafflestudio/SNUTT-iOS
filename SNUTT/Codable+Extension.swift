//
//  Codable+Extension.swift
//  SNUTT
//
//  Created by Rajin on 2019. 1. 1..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension Dictionary {
    func toObject<T: Decodable>(_ type: T.Type) throws -> T{
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode(type, from: data)
    }
}

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()

        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey){
                swiftDictionary[stringKey] = keyValue
            }
        }

        return swiftDictionary
    }
}
