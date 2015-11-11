//
//  main.swift
//  ulc
//
//  Created by Greg Titus on 11/10/15.
//

import Foundation

let parser = Parser()

while let line = readLine() {
    let tokens: [Token]
    let definition: String
    var name: String? = nil
    
    if let range = line.rangeOfString(":") {
        definition = line.substringFromIndex(range.endIndex)
        name = line.substringToIndex(range.startIndex)
    } else {
        definition = line
    }

    tokens = tokenize(definition)
    do {
        let term = try parser.parse(tokens)
        let result = term.fullyEvaluate(trace: true)
        
        if let name = name {
            parser.definitions[name] = result
            print("\(name) := \(result)")
        } else {
            print("\(result)")
        }
    } catch ParseError.UnexpectedToken(let i) {
        print("ERROR: unexpected token at char=\(i.char)")
    } catch ParseError.UnexpectedEnd {
        print("ERROR: unexpected end of line")
    }
}

