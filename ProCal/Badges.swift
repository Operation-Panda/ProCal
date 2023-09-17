//
//  Badges.swift
//  ProCal
//
//  Created by Roaa on 4/21/24.
//

import Foundation

// badges types

enum BadgeType: Codable {
    case special
    case month
}

enum RewardType: Codable {
    case event
    case assignment
}

struct ChallengeBadge: Identifiable, Equatable, Codable {
    var id: String?
    var stillAChallenge = true
    let badgeType: BadgeType
    let rewardType: RewardType
    let imageName: String
    var completeImageName: String {
        imageName + "Challenge"
    }
    var degrees = Double.zero
    
    enum CodingKeys: String, CodingKey {
        case id, stillAChallenge, badgeType, rewardType, imageName
    }
}

struct AchievementBadge: Identifiable, Equatable, Codable {
    var id: String?
    var stillAnAchievement = false
    let badgeType: BadgeType
    let rewardType: RewardType
    let imageName: String
    var completeImageName: String {
        imageName + "Achievement"
    }
    var degrees = Double.zero
    
    enum CodingKeys: String, CodingKey {
        case id, stillAnAchievement, badgeType, rewardType, imageName
    }
}


//events and assignments

struct EventBadge {
    static var eventCount = 0
    
    static func increaseEventCount() {
        defer { eventCount += 1 }
        EventBadge.eventCount = eventCount
    }
}

struct AssignmentBadge {
    static var assignCount = 0
    
    static func increaseAssignCount() {
        defer { assignCount += 1 }
        AssignmentBadge.assignCount = assignCount
    }
}

class EventsAndAssignViewModel: ObservableObject {
    
    @Published var monthToAssignCount =  [
        "January" : 0,
        "February" : 0,
        "March" : 0,
        "April" : 0,
        "May" : 0,
        "June" : 0,
        "July" : 0,
        "August" : 0,
        "September" : 0,
        "October" : 0,
        "November" : 0,
        "December" : 0
    ]
    
    func addNewEvent() {
        EventBadge.increaseEventCount()
    }
    
    func addNewAssignment() {
        AssignmentBadge.increaseAssignCount()
    }
    
    func resetEventCount() {
        EventBadge.eventCount = 0
    }
    
    func resetAssignCount() {
        AssignmentBadge.assignCount = 0
    }
    
    func addAssignForSpecificMonth(month: String) {
        addNewAssignment()
        monthToAssignCount[month]! += 1
    }
    /*
    func removeAssignForSpecificMonth(month: String) {
        monthToAssignCount[month]! = 0
    }
    
    func removeEventsForSpecificMonth(month: String) {
        monthToAssignCount[month]! = 0
    }
    */
    func checkIfMonthHasTenAssignments(month: String) -> Bool {
        return monthToAssignCount[month]! >= 10
    }
    
    func checkIfEventCountGreaterThanGivenNumber(num: Int) -> Bool {
        return EventBadge.eventCount >= num
    }
    
    func checkIfAssignmentCountGreaterThanGivenNumber(num: Int) -> Bool {
        return AssignmentBadge.assignCount >= num
    }
    
}

//badges view model

class BadgeViewModel: ObservableObject {
    @Published var challenges: [ChallengeBadge]
    @Published var achievements: [AchievementBadge]
    
    init() {
        self.challenges = [
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "January"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "February"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "March"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "April"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "May"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "June"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "July"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "August"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "September"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "October"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "November"),
            ChallengeBadge(badgeType: .month, rewardType: .assignment, imageName: "December"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "firstAssignmentAdded"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "firstEventAdded"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "firstAssignmentCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "firstEventCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "10AssignmentsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "10EventsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "25AssignmentsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "25EventsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "50AssignmentsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "50EventsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "75AssignmentsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "75EventsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .assignment, imageName: "100AssignmentsCompleted"),
            ChallengeBadge(badgeType: .special, rewardType: .event, imageName: "100EventsCompleted")
        ]
        
        self.achievements = [
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "January"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "February"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "March"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "April"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "May"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "June"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "July"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "August"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "September"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "October"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "November"),
            AchievementBadge(badgeType: .month, rewardType: .assignment, imageName: "December"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "firstAssignmentAdded"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "firstEventAdded"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "firstAssignmentCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "firstEventCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "10AssignmentsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "10EventsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "25AssignmentsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "25EventsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "50AssignmentsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "50EventsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "75AssignmentsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "75EventsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .assignment, imageName: "100AssignmentsCompleted"),
            AchievementBadge(badgeType: .special, rewardType: .event, imageName: "100EventsCompleted")
        ]
    }
    
    func achieveByImageName(name: String) {
        for index in challenges.indices {
            if challenges[index].imageName == name {
                challengeIsAchieved(CB: challenges[index])
            }
        }
    }
    
    func challengeIsAchieved(CB: ChallengeBadge) {
        let index = challenges.firstIndex(of: CB)!
        challenges[index].stillAChallenge = false
        achievements[index].stillAnAchievement = true
    }
    
    func achievementIsUnAchieved(AB: AchievementBadge) {
        let index = achievements.firstIndex(of: AB)!
        challenges[index].stillAChallenge = true
        achievements[index].stillAnAchievement = false
    }
    
}
