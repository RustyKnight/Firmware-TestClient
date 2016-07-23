//
//  ProtocolUtilitiesExtension.swift
//  TestCioffiServer
//
//  Created by Shane Whitehead on 22/07/2016.
//  Copyright © 2016 Beam Communications. All rights reserved.
//

import Foundation
import CioffiAPI
import SwiftyJSON

extension ProtocolUtils {
	
	class func dataFor(request: RequestType, payload: [String: [String: AnyObject]]? = nil) throws -> Data {
		var message = header(forRequest: request)
		if let payload = payload {
			message += payload
		}
		return try dataFor(payload: message)
	}
	
	
	class func processRequest(header: Data, body: Data) throws {
		guard validCRC(fromHeader: header, body: body) else {
			throw ProtocolError.invalidCRC
		}
		guard let _ = String(data: body, encoding: String.Encoding.isoLatin1) else {
			throw ProtocolError.requestDecodingError
		}
		
		log(info: "Request: \(body)")
		
		let json = JSON(data: body)
		log(info: "json: \(json)")
		guard let typeCode = json["header"]["type"].int else {
			throw ProtocolError.missingRequestType
		}
		
		let requestType = ResponseType.for(typeCode)
		log(info: "requestType: \(requestType)")
	}
}
