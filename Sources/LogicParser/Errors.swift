//
//  Errors.swift
//  Logic Parser
//
//  Created by Gabriel Jacoby-Cooper on 4/4/22.
//

import Foundation

enum LogicParsingError: Error {
	
	case invalidSyntaxTree
	
	case noLeafFound
	
	case emptySubstring
	
	case invalidCharacter
	
}

enum LogicNodeConfigurationError: Error {
	
	case invalidChildrenType
	
	case allChildrenAlreadyConfigured
	
}
