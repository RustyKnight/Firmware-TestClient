//
//  DictionaryOperators.swift
//  CioffiServer
//
//  Created by Shane Whitehead on 22/07/2016.
//  Copyright © 2016 Beam Communications. All rights reserved.
//

import Foundation

/**
 newDict = leftDict + rightDict
 */

/**
 `+` operator for merging two dictionaries
 
 `newDict = leftDict + rightDict`
 
 - parameter left:  Dictionary to be merged
 - parameter right: Dictionary to be merged
 
 - returns: A new dictionary which is a merge of the left and right values,
 where the right will override any duplicate keys from the left
 */
public func + <K, V> (left: [K:V], right: [K:V]) -> [K:V] {
    var new = [K:V]()
    for (k, v) in left {
        new[k] = v
    }
    for (k, v) in right {
        new[k] = v
    }
    return new
}

/**
 += operator for merging two dictionaries, inplace
 
 leftDict += rightDict
 */

/**
 `+=` operator for merging two dictionaries, inplace
 
 `leftDict += rightDict`
 
 - parameter left:  Source dictionary
 - parameter right: Dictionary to be merged
 */
public func += <K, V> ( left: inout [K:V], right: [K:V]?) {
    guard let right = right else { return }
    right.forEach { key, value in
        left.updateValue(value, forKey: key)
    }
}

public func + <K, V, P> (left: [K:[V:P]], right: [K:[V:P]]) -> [K:[V:P]] {
    var new = [K:[V:P]]()
    for (k, v) in left {
        new[k] = v
    }
    for (k, v) in right {
        new[k] = v
    }
    return new
}


public func += <K, V, P> ( left: inout [K:[V:P]], right: [K:[V:P]]?) {
    guard let right = right else { return }
    right.forEach { key, value in
        left.updateValue(value, forKey: key)
    }
}
