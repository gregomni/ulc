//
//  Parser.swift
//  ulc
//
//  Created by Greg Titus on 11/10/15.
//

import Foundation

extension Int {
    func asSubscript() -> String {
        func internalAsSubscript(n: Int) -> String {
            guard n > 0 else { return "" }
            let digits = "₀₁₂₃₄₅₆₇₈₉"
            
            return internalAsSubscript(n/10) + String(digits.characters[digits.characters.startIndex.advancedBy(n%10)])
        }
        
        if self > 0 {
            return internalAsSubscript(self)
        } else if self < 0 {
            return "₋" + internalAsSubscript(-self)
        } else {
            return "₀"
        }
    }
}


indirect enum Term : CustomStringConvertible {
    case Identifier(LocationInfo, String, Int)
    case Abstraction(LocationInfo, Term, Term)
    case Application(LocationInfo, Term, Term)
    
    var locationInfo: LocationInfo {
        switch self {
        case .Identifier(let i, _, _):
            return i
        case .Abstraction(let i, _, _):
            return i
        case .Application(let i, _, _):
            return i
        }
    }
    
    var description: String {
        switch (self) {
        case .Identifier(_, let s, let n):
            return n < 0 ? s : s + n.asSubscript()
            
        case .Abstraction(_, let l, let body):
            guard case .Identifier(_, let s, _) = l else { return "?" }
            return "λ\(s). \(body)"
            
        case .Application(_, let a, let b):
            let aString: String
            if case .Abstraction(_) = a {
                aString = "(\(a))"
            } else {
                aString = a.description
            }
            let bString: String
            if case .Identifier(_) = b {
                bString = b.description
            } else {
                bString = "(\(b))"
            }
            return "\(aString) \(bString)"
        }
    }
}

struct SymbolTable {
    private var free: [String:Int] = [:]
    private var bound: [String] = []
    
    mutating func valueForSymbol(string: String) -> Int {
        if let index = bound.indexOf(string) {
            return index
        } else if let value = free[string] {
            return value
        } else {
            return addFreeSymbol(string)
        }
    }
    
    mutating func addFreeSymbol(string: String) -> Int {
        let newValue = -1 - free.count
        free[string] = newValue
        return newValue
    }
    
    mutating func addBoundSymbol(string: String) -> Int {
        bound.insert(string, atIndex: 0)
        return 0
    }
    
    mutating func popBoundSymbol() {
        bound.removeFirst()
    }
}

enum ParseError: ErrorType {
    case UnexpectedToken(LocationInfo)
    case UnexpectedEnd
}

class Parser {
    var symbolTable = SymbolTable()
    var definitions: [String: Term] = [:]
    

    private func parseLambda(lambdaLocation: LocationInfo, inout tokens: ArraySlice<Token>) throws -> Term {
        guard let first = tokens.first else { throw ParseError.UnexpectedEnd }
        guard case .Identifier(let i, let s) = first else { throw ParseError.UnexpectedToken(first.locationInfo) }
        
        let variable = Term.Identifier(i, s, symbolTable.addBoundSymbol(s))
        tokens.removeFirst()

        guard let second = tokens.first else { throw ParseError.UnexpectedEnd }
        guard case .Dot(_) = second else { throw ParseError.UnexpectedToken(second.locationInfo) }
        tokens.removeFirst()
        
        let body = try parseSubexpression(&tokens)
        symbolTable.popBoundSymbol()
        return .Abstraction(lambdaLocation, variable, body)
    }

    private func parseSubexpression(inout tokens: ArraySlice<Token>) throws -> Term {
        var building: Term? = nil
        
        while let token = tokens.first {
            var rest = tokens
            rest.removeFirst()

            var newTerm: Term? = nil

            switch token {
            case .Lambda(let i):
                newTerm = try parseLambda(i, tokens: &rest)

            case .Dot(let i):
                throw ParseError.UnexpectedToken(i)

            case .OpenParen(_):
                newTerm = try parseSubexpression(&rest)
                guard let next = rest.first else { throw ParseError.UnexpectedEnd }
                guard case .CloseParen(_) = next else { throw ParseError.UnexpectedToken(next.locationInfo) }
                rest.removeFirst()
                
            case .CloseParen(let i):
                guard let result = building else { throw ParseError.UnexpectedToken(i) }
                return result

            case .Identifier(let i, let s):
                if let definition = definitions[s] {
                    newTerm = definition
                } else {
                    newTerm = Term.Identifier(i, s, symbolTable.valueForSymbol(s))
                }
            }
            
            if let newTerm = newTerm {
                if let term = building {
                    building = Term.Application(term.locationInfo, term, newTerm)
                } else {
                    building = newTerm
                }
            }
            tokens = rest
        }
        
        guard let result = building else { throw ParseError.UnexpectedEnd }
        return result
    }

    func parse(tokens: [Token]) throws -> Term {
        var slice = tokens[0..<tokens.count]
        let term = try parseSubexpression(&slice)
        guard slice.count == 0 else { throw ParseError.UnexpectedToken(slice.first!.locationInfo) }
        return term
    }
}

