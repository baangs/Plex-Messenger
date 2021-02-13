//
//  DatabaseManager.swift
//  Plex
//
//  Created by RD on 2/12/21.
//

import Foundation
import FirebaseDatabase
//insert data(user) to a database, firebase
final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
}

//MARK: - Account Management

extension DatabaseManager {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        database.child(email).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue(["first_name": user.firstName, "last_name": user.lastName])
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//    let profilePicture: String
}
