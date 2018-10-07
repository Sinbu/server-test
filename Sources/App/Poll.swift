//
//  Poll.swift
//  App
//
//  Created by Sina Yeganeh on 10/7/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct Poll: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var password: String?
    var title: String
    var option1: String
    var option2: String
    var votes1: Int
    var votes2: Int
}
