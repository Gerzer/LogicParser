//
//  LogicNode.swift
//  Logic Parser
//
//  Created by Gabriel Jacoby-Cooper on 3/28/22.
//

/// A node in a formal-logic tree.
public protocol LogicNode: AnyObject, CustomStringConvertible {
	
	/// A human-readable name for this type of node.
	static var name: String { get }
	
	/// The layout of the children of this type of node.
	///
	/// A node can have no children, only a lefthand child, only a righthand child, or both lefthand and righthand children.
	static var childrenType: LogicNodeChildrenType { get }
	
	/// A description of this node and its children that’s suitable for printing.
	var description: String { get }
	
	/// The parent of this node.
	var parent: (any LogicNode)! { get }
	
	/// The lefthand child of this node.
	///
	/// The value of this property may be `nil` if ``childrenType-swift.type.property`` is ``LogicNodeChildrenType/none`` or ``LogicNodeChildrenType/rightOnly`` or if it just hasn’t been configured yet.
	var left: (any LogicNode)? { get }
	
	/// The righthand child of this node.
	///
	/// The value of this property may be `nil` if ``childrenType-swift.type.property`` is ``LogicNodeChildrenType/none`` or ``LogicNodeChildrenType/leftOnly`` or if it just hasn’t been configured yet.
	var right: (any LogicNode)? { get }
	
}

extension LogicNode {
	
	public var description: String {
		get {
			switch Self.childrenType {
			case .none:
				return Self.name
			case .leftOnly:
				return "(\(Self.name) \(self.left?.description ?? "nil")|_)"
			case .rightOnly:
				return "(\(Self.name) _|\(self.right?.description ?? "nil"))"
			case .leftAndRight:
				return "(\(Self.name) \(self.left?.description ?? "nil")|\(self.right?.description ?? "nil"))"
			}
		}
	}
	
	func setNextChild(to child: any LogicNode) throws {
		guard let parent = self as? any WritableLogicNode, let child = child as? any WritableLogicNode else {
			return
		}
		try parent.setNextChild(to: child)
	}
	
}

fileprivate protocol WritableLogicNode: LogicNode {
	
	var parent: (any LogicNode)! { get set }
	
	var left: (any LogicNode)? { get set }
	
	var right: (any LogicNode)? { get set }
	
}

extension WritableLogicNode {
	
	func setNextChild(to child: any WritableLogicNode) throws {
		defer {
			child.parent = self
		}
		switch Self.childrenType {
		case .none:
			throw LogicNodeConfigurationError.invalidChildrenType
		case .leftOnly:
			guard self.left == nil else {
				throw LogicNodeConfigurationError.allChildrenAlreadyConfigured
			}
			self.left = child
		case .rightOnly:
			guard self.right == nil else {
				throw LogicNodeConfigurationError.allChildrenAlreadyConfigured
			}
			self.right = child
		case .leftAndRight:
			if self.left == nil {
				self.left = child
			} else if self.right == nil {
				self.right = child
			} else {
				throw LogicNodeConfigurationError.allChildrenAlreadyConfigured
			}
		}
	}
	
}

/// The possible layouts for children of a node.
public enum LogicNodeChildrenType {
	
	/// A layout that indicates the absence of any children.
	case none
	
	/// A layout that indicates the presence of a lefthand child but the absence of a righthand child.
	case leftOnly
	
	/// A layout that indicates the presence of a righthand child but the absence of a lefthand child.
	case rightOnly
	
	/// A layout that indicates the presence of both lefthand and righthand children.
	case leftAndRight
	
}

/// A node that serves as the root of a formal-logic tree.
public class RootNode: WritableLogicNode {
	
	public static let name = "Root"
	
	public static let childrenType: LogicNodeChildrenType = .leftOnly
	
	public fileprivate(set) var parent: (any LogicNode)! {
		willSet {
			fatalError("[RootNode parent] Can’t set the parent of a root node")
		}
	}
	
	public fileprivate(set) var left: (any LogicNode)?
	
	public fileprivate(set) var right: (any LogicNode)? {
		willSet {
			fatalError("[RootNode right] Can’t set the right child of a root node")
		}
	}
	
}

/// A node that represents an atom in a formal-logic expression.
public class AtomicNode: WritableLogicNode {
	
	public static let name = "Atomic"
	
	public static let childrenType: LogicNodeChildrenType = .none
	
	public var description: String {
		get {
			return String(self.character)
		}
	}
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)? {
		willSet {
			fatalError("[AtomicNode left] Can’t set the left child of an atomic node")
		}
	}
	
	public fileprivate(set) var right: (any LogicNode)? {
		willSet {
			fatalError("[AtomicNode right] Can’t set the right child of an atomic node")
		}
	}
	
	/// The character that’s associated with this atom.
	public let character: Character
	
	/// Creates an atomic node.
	/// - Parameter character: The character to associate with the atom.
	init(_ character: Character) {
		self.character = character
	}
	
}

/// A node that represents a negation in a formal-logic expression.
public class NegationNode: WritableLogicNode {
	
	public static let name = "Negation"
	
	public static let childrenType: LogicNodeChildrenType = .rightOnly
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)? {
		willSet {
			fatalError("[NegationNode left] Can’t set the left child of a negation node")
		}
	}
	
	public fileprivate(set) var right: (any LogicNode)?
	
}

/// A node that represents a conjunction in a formal-logic expression.
public class ConjunctionNode: WritableLogicNode {
	
	public static let name = "Conjunction"
	
	public static let childrenType: LogicNodeChildrenType = .leftAndRight
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)?
	
	public fileprivate(set) var right: (any LogicNode)?
	
}

/// A node that represents a disjunction in a formal-logic expression.
public class DisjunctionNode: WritableLogicNode {
	
	public static let name = "Disjunction"
	
	public static let childrenType: LogicNodeChildrenType = .leftAndRight
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)?
	
	public fileprivate(set) var right: (any LogicNode)?
	
}

/// A node that represents a conditional in a formal-logic expression.
public class ConditionalNode: WritableLogicNode {
	
	public static let name = "Conditional"
	
	public static let childrenType: LogicNodeChildrenType = .leftAndRight
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)?
	
	public fileprivate(set) var right: (any LogicNode)?
	
}

/// A node that represents a biconditional in a formal-logic expression.
public class BiconditionalNode: WritableLogicNode {
	
	public static let name = "Biconditional"
	
	public static let childrenType: LogicNodeChildrenType = .leftAndRight
	
	public fileprivate(set) var parent: (any LogicNode)!
	
	public fileprivate(set) var left: (any LogicNode)?
	
	public fileprivate(set) var right: (any LogicNode)?
	
}
