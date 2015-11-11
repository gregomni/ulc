//
//  Evaluator.swift
//  ulc
//
//  Created by Greg Titus on 11/10/15.
//

import Foundation

extension Term {
    func evaluate() -> (Bool, Term) {
        switch self {
        case .Application(let i, let a, let b):
            switch a {
            case .Abstraction(_, _, let body):
                let result = body.substitute(b, matching: 0)
                return (true, result)
            default:
                let (success, newA) = a.evaluate()
                if success {
                    return (success, .Application(i, newA, b))
                } else {
                    let (success, newB) = b.evaluate()
                    return (success, .Application(i, a, newB))
                }
            }
        default:
            return (false, self)
        }
    }
    
    func substitute(new: Term, matching: Int) -> Term {
        switch self {
        case .Identifier(_, _, matching):
            return new
        case .Identifier(_, _, _):
            return self
        case .Abstraction(let i, let v, let body):
            return .Abstraction(i, v, body.substitute(new, matching: matching+1))
        case .Application(let i, let a, let b):
            return .Application(i, a.substitute(new, matching: matching), b.substitute(new, matching: matching))
        }
    }
    
    func fullyEvaluate(trace trace: Bool = false) -> Term {
        var result = self
        var progress = true
        
        while progress {
            if trace {
                print("\(result)")
            }
            (progress, result) = result.evaluate()
        }
        return result
    }
}

