//
//  Lexer.swift
//  ulc
//
//  Created by Greg Titus on 11/10/15.
//

import Foundation

struct LocationInfo {
    let line: Int
    let char: Int
    
    init(_ line: Int, _ char: Int) {
        self.line = line
        self.char = char
    }
}

let lambda: Character = "λ"

enum Token : CustomStringConvertible {
    case Lambda(LocationInfo)
    case Dot(LocationInfo)
    case OpenParen(LocationInfo)
    case CloseParen(LocationInfo)
    case Identifier(LocationInfo, String)
    
    var locationInfo: LocationInfo {
        switch self {
        case .Lambda(let i): return i
        case .Dot(let i): return i
        case .OpenParen(let i): return i
        case .CloseParen(let i): return i
        case .Identifier(let i, _): return i
        }
    }
    
    var description: String {
        switch (self) {
        case .Lambda(_): return String(lambda)
        case .Dot(_): return "."
        case .OpenParen(_): return "("
        case .CloseParen(_): return ")"
        case .Identifier(_, let s): return s
        }
    }    
}

func tokenize(string: String) -> [Token] {
    var currentIdentifier: String = ""
    var identifierFirstChar: Int = 0
    var result: [Token] = []
    var line: Int = 1
    var char: Int = 0
    
    for c in string.characters {
        var token: Token? = nil
        var end: Bool = false
        var newline: Bool = false
      
        switch c {
        case lambda:
            token = .Lambda(LocationInfo(line, char))
        case ".":
            token = .Dot(LocationInfo(line, char))
        case "(":
            token = .OpenParen(LocationInfo(line, char))
        case ")":
            token = .CloseParen(LocationInfo(line, char))
        case " ":
            end = true
        case "\n":
            end = true
            newline = true
        default:
            if currentIdentifier.characters.count == 0 {
                identifierFirstChar = char
            }
            currentIdentifier.append(c)
        }

        if (end || token != nil) && currentIdentifier.characters.count > 0 {
            result.append(.Identifier(LocationInfo(line, identifierFirstChar), currentIdentifier))
            currentIdentifier = ""
        }
        if let token = token {
            result.append(token)
        }
        if newline {
            line++
            char = 0
        } else {
            char++
        }
    }
    
    if currentIdentifier.characters.count > 0 {
        result.append(.Identifier(LocationInfo(line, identifierFirstChar), currentIdentifier))
    }
    return result
}

