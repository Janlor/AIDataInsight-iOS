//
//  StringExtensions.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

extension String {
    
    func toDictionary() throws -> [String : Any]  {
        
        guard !self.isEmpty else {
            return [String : Any]()
        }
        
        guard let data = self.data(using: .utf8) else {
            return [String : Any]()
        }
        
        let dict = try JSONSerialization.jsonObject(with: data,
                                                    options: .fragmentsAllowed) as? [String : Any]
        if let dict = dict {
            return dict
        }
        
        return [String : Any]()
    }
    
}
