//
//  Validator.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import Foundation

    //validation
enum Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    static func isValidPassword (_ password: String) -> Bool {
        return password.count >= 6
    }
}



//custom error object
struct SimpleError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var localizedDescription: String {
        return message
    }
}
