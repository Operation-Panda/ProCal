//
//  ProCalApp.swift
//  ProCal
//
//  Created by Sophia Yan on 8/9/22.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)          {
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}

class AuthenticationViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut
    
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in authenticateUser(for: user, with: error)}
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let configuration = GIDConfiguration(clientID: clientID)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in authenticateUser(for: user, with: error)}
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                state = .signedIn
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try Auth.auth().signOut()
            state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct timerange: Identifiable, Codable {
    var id: String?
    var start_time: Date
    var end_time: Date
}

struct Settings: Identifiable, Codable {
    var id: String?
    var num_work_sess: Int = 0
    var time_work_sess: Int = 0
    var sleeping_hours: timerange?
}

final class PrefTimePreferencesController: ObservableObject {
    @Published var pref_work_times: [timerange] = []
    
    private lazy var databasePath: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        let ref = Database.database().reference().child("users/\(uid)/pref_times")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listenForTimes() {
        guard let databasePath = databasePath else {
            return
        }
        databasePath.observe(.childAdded) {
            [weak self] snapshot in guard let self = self, var json = snapshot.value as? [String: Any]
            else {
                return
            }
            json["id"] = snapshot.key
            do {
                let timeData = try JSONSerialization.data(withJSONObject: json)
                let time = try self.decoder.decode(timerange.self, from: timeData)
                if !self.pref_work_times.contains(where: {$0.id == time.id}) {
                    self.pref_work_times.append(time)
                }
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
    func AddTime() {
        guard let databasePath = databasePath else {
            return
        }
        
        do {
            databasePath.removeValue()
            for pref in 0..<self.pref_work_times.count {
                let data = try encoder.encode(self.pref_work_times[pref])
                let json = try JSONSerialization.jsonObject(with: data)
                
                let reference = databasePath.childByAutoId()

                reference.setValue(json)
                self.pref_work_times[pref].id = reference.key
            }
        } catch {
            print("an error occurred", error)
        }
    }
    
    func stopListeningTimes() {
        databasePath?.removeAllObservers()
    }
}

final class UnavailTimePreferencesController: ObservableObject {
    @Published var unavailable: [timerange] = []
    
    private lazy var databasePath: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        let ref = Database.database().reference().child("users/\(uid)/unavail")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listenForUn() {
        guard let databasePath = databasePath else {
            return
        }
        databasePath.observe(.childAdded) {
            [weak self] snapshot in guard let self = self, var json = snapshot.value as? [String: Any]
            else {
                return
            }
            json["id"] = snapshot.key
            do {
                let timeData = try JSONSerialization.data(withJSONObject: json)
                let time = try self.decoder.decode(timerange.self, from: timeData)
                
                if !self.unavailable.contains(where: {$0.id == time.id}) {
                    self.unavailable.append(time)
                }
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
    func stopListeningUn() {
        databasePath?.removeAllObservers()
    }
    
    func AddUn() {
        guard let databasePath = databasePath else {
            return
        }
        
        do {
            databasePath.removeValue()
            for pref in 0..<self.unavailable.count {
                let data = try encoder.encode(self.unavailable[pref])
                let json = try JSONSerialization.jsonObject(with: data)
                
                let reference = databasePath.childByAutoId()

                reference.setValue(json)
                self.unavailable[pref].id = reference.key
            }
        } catch {
            print("an error occurred", error)
        }
    }
}

final class WorkPreferencesController: ObservableObject {
    @Published var num_work_sess: Int = 1
    @Published var hours: Int = 1
    @Published var minutes: Int = 0
    @Published var time_work_sess: Int = 60
    @Published var sleeping_hours: timerange = timerange(start_time: Date(), end_time: Date())
    @Published var sleep_yes: Bool = false
    
    private lazy var databasePath: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        let ref = Database.database().reference().child("users/\(uid)/settings")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listenForChange() {
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.observe(.childAdded) {
            [weak self] snapshot in guard let self = self, var json = snapshot.value as? [String: Any]
            else {
                return
            }
            json["id"] = snapshot.key
            do {
                let settingData = try JSONSerialization.data(withJSONObject: json)
                let newsetting = try self.decoder.decode(Settings.self, from: settingData)
                self.num_work_sess = newsetting.num_work_sess
                self.time_work_sess = newsetting.time_work_sess
                self.hours = self.time_work_sess/60
                self.minutes = self.time_work_sess-self.hours*60
                if newsetting.sleeping_hours != nil {
                    self.sleep_yes = true
                    self.sleeping_hours = newsetting.sleeping_hours!
                }
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
    func stopListeningChange() {
        databasePath?.removeAllObservers()
    }
    
    func Change() {
        guard let databasePath = databasePath else {
            return
        }
        
        do {
            databasePath.removeValue()
            
            var set = Settings()
            self.time_work_sess = self.hours*60+self.minutes
            if self.sleep_yes {
                set = Settings(num_work_sess: self.num_work_sess, time_work_sess: self.time_work_sess, sleeping_hours: self.sleeping_hours)
            } else {
                set = Settings(num_work_sess: self.num_work_sess, time_work_sess: self.time_work_sess)
            }
            
            let data = try encoder.encode(set)
            let json = try JSONSerialization.jsonObject(with: data)
            
            let reference = databasePath.childByAutoId()

            reference.setValue(json)
            set.id = reference.key
        } catch {
            print("an error occurred", error)
        }
    }
    
}

struct Check: Identifiable, Codable {
    var id: String?
    var title: String
    var isChecked: Bool
    var time: timerange
    var assignm: Assignment
}

struct CheckView: View {
    @State var chec: Int
    @Binding var data: [Check]
    @ObservedObject var modelAssignmentController: AssignmentController
    @ObservedObject var settings: WorkPreferencesController
    var body: some View {
        HStack {
           Button(action: {
               var a: Assignment
               if (data[chec].isChecked == true) {
                   a = Assignment(assignment_name: data[chec].assignm.assignment_name, start_date: data[chec].assignm.start_date, end_date: data[chec].assignm.end_date, estimated_time: data[chec].assignm.estimated_time, time_worked_on: data[chec].assignm.time_worked_on - settings.time_work_sess)
               } else {
                   a = Assignment(assignment_name: data[chec].assignm.assignment_name, start_date: data[chec].assignm.start_date, end_date: data[chec].assignm.end_date, estimated_time: data[chec].assignm.estimated_time, time_worked_on: data[chec].assignm.time_worked_on + settings.time_work_sess)
               }
               
               let temp2 = modelAssignmentController.AddAssignment(a: a)

               var d: [Check] = []
               for i in 0..<data.count {
                   if data[i].assignm.id! == data[chec].assignm.id! {
                       if i == chec {
                           d.append(Check(title: data[i].title, isChecked: !data[i].isChecked, time: data[i].time, assignm: temp2))
                       } else {
                           d.append(Check(title: data[i].title, isChecked: data[i].isChecked, time: data[i].time, assignm: temp2))
                       }
                   } else {
                       d.append(data[i])
                   }
               }
               data = d
               modelAssignmentController.del(assign: data[chec].assignm)
           }) {
               ZStack {
                   Circle().stroke(Color.blue, lineWidth: 0.5).frame(width: 20, height: 20)
                   if chec < data.count {
                       if data[chec].isChecked {
                           Circle().fill(Color.blue).frame(width: 18, height: 18)
                       }
                   }
               }
           }
           if chec < data.count {
               Text("work on: \(data[chec].title)").fontWeight(.thin)
           }
        }
    }
}

final class ScheduleController: ObservableObject {
    @Published var times: [timerange] = []
    
    func innit(settings: WorkPreferencesController, un: UnavailTimePreferencesController, pre: PrefTimePreferencesController) {
        
    }
}

struct Assignment: Identifiable, Codable, Hashable {
    var id: String?
    var assignment_name: String
    var start_date: Date
    var end_date: Date
    var estimated_time: Int
    var time_worked_on: Int
}

final class AssignmentController: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var assignment_name: String = ""
    @Published var st_date: Date = Date()
    @Published var end_date: Date = Date()
    @Published var estim_time: Int = 0
    @Published var time_worked_on: Int = 0
    
    private lazy var databasePath: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        let ref = Database.database().reference().child("users/\(uid)/assignments")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listenForAssignments() {
        guard let databasePath = databasePath else {
            return
        }
        databasePath.observe(.childAdded) {
            [weak self] snapshot in guard let self = self, var json = snapshot.value as? [String: Any]
            else {
                return
            }
            json["id"] = snapshot.key
            do {
                let assignmentData = try JSONSerialization.data(withJSONObject: json)
                let assignment = try self.decoder.decode(Assignment.self, from: assignmentData)
                if !self.assignments.contains(where: {$0.id == assignment.id}) {
                    self.assignments.append(assignment)
                }
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
    
    func AddAssignment(a: Assignment) -> Assignment {
        guard let databasePath = databasePath else {
            return a
        }
        
        if a.assignment_name.isEmpty {
            return a
        }
        
        do {
            var aa = Assignment(assignment_name: a.assignment_name, start_date: a.start_date, end_date: a.end_date, estimated_time: a.estimated_time, time_worked_on: a.time_worked_on)
            let data = try encoder.encode(aa)
            let json = try JSONSerialization.jsonObject(with: data)
            
            let reference = databasePath.childByAutoId()

            reference.setValue(json)
            aa.id = reference.key
            self.assignments.append(aa)
            return aa
        } catch {
            print("an error occurred", error)
            return a
        }
    }
    
    func AddAssignment() {
        guard let databasePath = databasePath else {
            return
        }
        
        if assignment_name.isEmpty {
            return
        }
        
        do {
            var assignment = Assignment(assignment_name: assignment_name, start_date: st_date, end_date: end_date, estimated_time: estim_time, time_worked_on: time_worked_on)
            let data = try encoder.encode(assignment)
            let json = try JSONSerialization.jsonObject(with: data)
            
            let reference = databasePath.childByAutoId()

            reference.setValue(json)
            assignment.id = reference.key
            self.assignments.append(assignment)
            
        } catch {
            print("an error occurred", error)
        }
    }
    
    func del(assign: Assignment) {
        guard let databasePath = databasePath else {
            return
        }
        
        self.assignments.removeAll(where: {$0.id == assign.id})
        databasePath.child(assign.id!).removeValue()
    }
}

struct Event: Identifiable, Codable {
    var id: String?
    var event_name: String
    var date: Date
    var st_time: Date
    var end_time: Date
}

final class EventsController: ObservableObject {
    @Published var events: [Event] = []
    @Published var event_title: String = ""
    @Published var giv_date: Date = Date()
    @Published var st_time: Date = Date()
    @Published var end_time: Date = Date()
    
    private lazy var databasePath: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        let ref = Database.database().reference().child("users/\(uid)/events")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listenForEvents() {
        guard let databasePath = databasePath else {
            return
        }
        
        databasePath.observe(.childAdded) {
            [weak self] snapshot in guard let self = self, var json = snapshot.value as? [String: Any]
            else {
                return
            }
            json["id"] = snapshot.key
            do {
                let eventData = try JSONSerialization.data(withJSONObject: json)
                let event = try self.decoder.decode(Event.self, from: eventData)
                if !self.events.contains(where: {$0.id == event.id}) {
                    self.events.append(event)
                }
            } catch {
                print("an error occurred", error)
            }
        }
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
    
    func AddEvent() {
        guard let databasePath = databasePath else {
            return
        }

        if event_title.isEmpty {
            return
        }
        
        do {
            var event = Event(event_name: self.event_title, date: self.giv_date, st_time: self.st_time, end_time: self.end_time)
            let data = try self.encoder.encode(event)
            let json = try JSONSerialization.jsonObject(with: data)
            
            let reference = databasePath.childByAutoId()

            reference.setValue(json)
            event.id = reference.key
            self.events.append(event)
        } catch {
            print("an error occurred", error)
        }
    }
    
    func del(event: Event) {
        guard let databasePath = databasePath else {
            return
        }
        
        self.events.removeAll(where: {$0.id == event.id})
        databasePath.child(event.id!).removeValue()
    }
}

@main
struct calendarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var viewModel = AuthenticationViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
