//
//  tracker.swift
//  ProCal
//
//  Created by Roaa on 4/21/24.
//

import Foundation
import Supabase

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter.string(from: self)
    }
}

struct SleepDataPoints: Identifiable, Codable, Equatable {
    var id: String? //to not have to init id when creating a SDP instance, declare it as var so that the manager could handle it
    let createdAt: Date
    let SleepHours: Int
    let feeling: Int
    let productivity: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case SleepHours, feeling, productivity
    }
}

struct SocialDataPoints: Identifiable, Codable, Equatable {
    var id: String? //to not have to init id when creating a SDP instance, declare it as var so that the manager could handle it
    let createdAt: Date
    let SocialHours: Int
    let feeling: Int
    let productivity: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case feeling, productivity, SocialHours
    }
}




