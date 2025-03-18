//
//  ParticipantsTransformer.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Foundation

@objc(ParticipantsTransformer)
class ParticipantsTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let participants = value as? [String] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: participants, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [String]
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
}
