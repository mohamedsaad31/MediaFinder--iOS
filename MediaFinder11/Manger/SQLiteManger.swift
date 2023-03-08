//
//  SQLiteManger.swift
//  MediaFinder11
//
//  Created by mohamed saad on 8/02/2023.
//
import UIKit
import SQLite
import CryptoKit
class SQLiteManager {
    //Singleton
    private static let sharedInstance = SQLiteManager()
    internal let db: Connection?
    static let usersTable = Table("users")
    static let name = Expression<String>("name")
    static let email = Expression<String>("email")
    static let password = Expression<String>("password")
    static let address = Expression<String>("address")
    static let phone = Expression<Int64>("phone")
    static let image = Expression<Data?>("image")
    static let gender = Expression<String>("gender")
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
          //deleteTable()
       createTable()
    }
    //Encapsulation
    static func shared() -> SQLiteManager {
        return self.sharedInstance
       }
    func deleteTable() {
        do {
            try db?.run(SQLiteManager.usersTable.drop(ifExists: true))
            print("Table deleted successfully.")
        } catch {
            print("Error: \(error)")
        }
    }
    func createTable() {
        do {
            try db?.run(SQLiteManager.usersTable.create { table in
                table.column(SQLiteManager.name)
                table.column(SQLiteManager.email, unique: true)
                table.column(SQLiteManager.password)
                table.column(SQLiteManager.address)
                table.column(SQLiteManager.phone, unique: true)
                table.column(SQLiteManager.image)
                table.column(SQLiteManager.gender)
            })
        } catch {
            print("Error: \(error)")
        }
    }
    func saveUser(_ user: User) {
        guard let db = db else {
            print("Error: Cannot get connection to database.")
            return
        }
        guard let imageData = user.image.pngData() else {
            print("Error: Could not convert user image to Data.")
            return
        }
        let insert = SQLiteManager.usersTable.insert(SQLiteManager.name <- user.name,
                                                     SQLiteManager.email <- user.email,
                                                     SQLiteManager.password <- user.password,
                                                     SQLiteManager.address <- user.address,
                                                     SQLiteManager.gender <- user.gender,
                                                     SQLiteManager.phone <- user.phone,
                                                     SQLiteManager.image <- imageData)
        do {
            try db.run(insert)
            print("User data saved successfully.")
        } catch {
            print("Error: \(error)")
        }
    }
}
