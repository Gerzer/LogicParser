//
//  LogicNode.swift
//  Logic Parser
//
//  Created by Gabriel Jacoby-Cooper on 3/28/22.
//

import Covfefe

/// A parser that builds a formal-logic tree from an input string.
public struct LogicParser {
	
	let string: String
	
	/// Creates a logic parser.
	/// - Parameter string: The raw logic string from which to construct a formal-logic tree.
	public init(_ string: String) {
		self.string = "(\(string))"
			.filter { (character) in
				return !character.isWhitespace
			}
	}
	
	/// Parses this parser’s associated raw string into a formal-logic tree.
	/// - Returns: The formal-logic tree.
	/// - Throws: When an error occurs while parsing the raw string or constructing the formal-logic tree.
	public func parse() throws -> RootNode {
		let formula = n("formula")
		let atom = try rt("[[a-z][A-Z]]")
		let parenthetical = t("(") <+> formula <+> t(")")
		let negation = t("¬") <+> formula
		let conjunction = t("(") <+> formula <+> t("∧") <+> formula <+> t(")")
		let disjunction = t("(") <+> formula <+> t("∨") <+> formula <+> t(")")
		let conditional = t("(") <+> formula <+> t("→") <+> formula <+> t(")")
		let biconditional = t("(") <+> formula <+> t("↔") <+> formula <+> t(")")
		let productions = "formula" --> atom <|> parenthetical <|> negation <|> conjunction <|> disjunction <|> conditional <|> biconditional
		let grammar = Grammar(productions: productions, start: "formula")
		let parser = EarleyParser(grammar: grammar)
		let syntaxTree = try parser.syntaxTree(for: self.string)
		let root = RootNode()
		try self.buildLogicTree(from: syntaxTree, asChildOf: root)
		return root
	}
	
	private func buildLogicTree(from syntaxTree: ParseTree, asChildOf parent: any LogicNode) throws {
		guard let syntaxChildren = syntaxTree.children else {
			print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Syntax tree doesn’t have any children")
			throw LogicParsingError.invalidSyntaxTree
		}
		switch syntaxChildren.count {
		case 1:
			guard let range = syntaxChildren[0].leaf else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Expected a leaf in the syntax tree but found none")
				throw LogicParsingError.noLeafFound
			}
			guard let character = self.string[range].first else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Couldn’t get the first character from the syntax tree leaf’s associated substring")
				throw LogicParsingError.emptySubstring
			}
			guard let child = self.createLogicNode(from: character) else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Encountered an invalid character")
				throw LogicParsingError.invalidCharacter
			}
			try parent.setNextChild(to: child)
		case 2:
			guard let range = syntaxChildren[0].leaf else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Expected a leaf in the syntax tree but found none")
				throw LogicParsingError.noLeafFound
			}
			guard let character = self.string[range].first else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Couldn’t get the first character from the syntax tree leaf’s associated substring")
				throw LogicParsingError.emptySubstring
			}
			guard let node = self.createLogicNode(from: character) else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Encountered an invalid character")
				throw LogicParsingError.invalidCharacter
			}
			try self.buildLogicTree(from: syntaxChildren[1], asChildOf: node)
			try parent.setNextChild(to: node)
		case 3:
			try self.buildLogicTree(from: syntaxChildren[1], asChildOf: parent)
		case 5:
			guard let range = syntaxChildren[2].leaf else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Expected a leaf in the syntax tree but found none")
				throw LogicParsingError.noLeafFound
			}
			guard let character = self.string[range].first else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Couldn’t get the first character from the syntax tree leaf’s associated substring")
				throw LogicParsingError.emptySubstring
			}
			guard let node = self.createLogicNode(from: character) else {
				print("[LogicParser buildLogicTree(from:asChildOf:)] Error: Encountered an invalid character")
				throw LogicParsingError.invalidCharacter
			}
			try self.buildLogicTree(from: syntaxChildren[1], asChildOf: node)
			try self.buildLogicTree(from: syntaxChildren[3], asChildOf: node)
			try parent.setNextChild(to: node)
		default:
			return
		}
	}
	
	private func createLogicNode(from character: Character) -> (any LogicNode)? {
		switch character {
		case "¬":
			return NegationNode()
		case "∧":
			return ConjunctionNode()
		case "∨":
			return DisjunctionNode()
		case "→":
			return ConditionalNode()
		case "↔":
			return BiconditionalNode()
		case let atomicCharacter where character.isLetter:
			if atomicCharacter.isLowercase {
				print("[LogicParser createLogicNode(from:)] Warning: Encountered a lowercase letter, which will automatically be converted to the equivalent uppercase letter; this might cause unintentional atom conflicts")
			}
			return AtomicNode(atomicCharacter.uppercased().first!)
		default:
			return nil
		}
	}
	
}
