//
//  ContentView.swift
//  ProCal
//
//  Created by Sophia Yan on 8/9/22.
//

import SwiftUI
import GoogleSignIn

var days = ["S", "M", "T", "W", "T", "F", "S"]
var fulday = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
var month_names = [
    "January","February","March","April",
    "May","June","July","August",
    "September","October","November","December"]

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

func date(_ current_month: Int, _ current_day: Int) -> Date {
    var dateComponent = DateComponents()
    dateComponent.year = 0
    dateComponent.month = current_month
    dateComponent.day = current_day
    dateComponent.hour = 0
    dateComponent.minute = 0
    dateComponent.second = 0

    return Calendar.current.date(byAdding: dateComponent, to: Date())!
}

let calendar = Calendar.current

func getYear(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.year, from: date(current_month, current_day))
}

func getMonth(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.month, from: date(current_month, current_day))
}

func getWeekday(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.weekday, from: date(current_month, current_day))
}

func getDay(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.day, from: date(current_month, current_day))
}

func getHour(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.hour, from: date(current_month, current_day))
}

func getMinutes(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.component(.minute, from: date(current_month, current_day))
}

func getStartMonthPos(_ current_month: Int, _ current_day: Int) -> Int {
    return mod(getWeekday(current_month, current_day)-1-mod(getDay(current_month, current_day)-1,7), 7)
}

func month_days(_ current_month: Int, _ current_day: Int) -> Int {
    return calendar.range(of: .day, in: .month, for: date(current_month, current_day))!.count
}

struct NetworkImage: View {
    let url: URL?
    
    var body: some View {
        if let url = url, let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fit).clipShape(Circle())
        } else {
            Image(systemName:"person.circle.fill").resizable().aspectRatio(contentMode: .fit).clipShape(Circle())
        }
    }
}

struct GoogleSignInButton: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private var button = GIDSignInButton()
    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = colorScheme == .dark ? .dark : .light
        return button
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        button.colorScheme = colorScheme == .dark ? .dark : .light
    }
}

struct StartView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Text("ProCal").font(.largeTitle).fontWeight(.thin).padding(.top, UIScreen.main.bounds.height/4)
            Text("log in").font(.title2).fontWeight(.ultraLight)
            GoogleSignInButton().padding().onTapGesture {
                viewModel.signIn()
            }
            Spacer()
        }
    }
}

extension UIPickerView {
    open override var intrinsicContentSize: CGSize { return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height) }
}

struct AddAssignment: View {
    @State var id: String?
    @Binding var current_month: Int
    @Binding var current_day: Int
    @Binding var special: Bool
    @Binding var assignment_add_button: Bool
    @State var pressed: Bool = false
    @State var inval: String = ""
    @ObservedObject var modelControllerAssignments: AssignmentController

    @State private var selections: [Int] = [0, 0]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {self.special = false; self.assignment_add_button = false}) {
                    ZStack{
                        Text("<").font(.title2).fontWeight(.ultraLight).padding(.leading, (UIScreen.main.bounds.width-300)/2)
                    }
                }.padding(.leading, (UIScreen.main.bounds.width-300)/2)
                Spacer()
            }
            
            if (special) {
                Text("edit assignment").font(.title).fontWeight(.thin)
            } else {
                Text("add assignment").font(.title).fontWeight(.thin)
            }
            Divider()
            
            if !self.inval.isEmpty {
                Text(inval).fontWeight(.ultraLight).multilineTextAlignment(.center).background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width-10, height: 25).foregroundColor(Color(hue: 1.0, saturation: 0.641, brightness: 0.973)))
            }
            
            HStack {
                Text("assignment:").fontWeight(.thin)
                Spacer()
                TextField("", text: $modelControllerAssignments.assignment_name).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            HStack {
                Text("starts:").fontWeight(.thin)
                Spacer()
                DatePicker("", selection: $modelControllerAssignments.st_date)
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            HStack {
                Text("due:").fontWeight(.thin)
                Spacer()
                DatePicker("", selection: $modelControllerAssignments.end_date)
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            HStack {
                Text("est. time to complete:").fontWeight(.thin)
                Spacer()
                if !self.pressed {
                    Button (action: {self.pressed=(!self.pressed);}) {
                        RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.941)).frame(width: 90, height: 32).overlay(Text("\(self.selections[0])h \(self.selections[1])min").fontWeight(.ultraLight).foregroundColor(Color.black))
                    }
                }
                if self.pressed {
                    VStack {
                        HStack(spacing: 0) {
                            Picker(selection: self.$selections[0], label: Text("")) {
                                ForEach(0 ..< 21) { index in
                                    Text("\(index) h").fontWeight(.ultraLight).tag(index)
                                }
                            }.pickerStyle(.wheel).frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/8, alignment: .center).clipped().compositingGroup()
                            Picker(selection: self.$selections[1], label: Text("")) {
                                ForEach(0 ..< 60) { index in
                                    Text("\(index) min").fontWeight(.ultraLight).tag(index)
                                }
                            }.pickerStyle(.wheel).frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/8, alignment: .center).clipped().compositingGroup()
                        }
                        Button(action: {self.pressed=(!self.pressed);}) {
                            Text("collape").fontWeight(.ultraLight).foregroundColor(Color.blue)
                        }
                    }
                }
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            Button(action: {
                if (self.modelControllerAssignments.assignment_name.isEmpty) {
                    self.inval = "assignment doesn't have a name"
                } else if (modelControllerAssignments.st_date > modelControllerAssignments.end_date) {
                    self.inval = "start date is after the due date"
                } else if (modelControllerAssignments.end_date < Date()) {
                    self.inval = "due date has already passed"
                } else if (self.selections[0] == 0 && self.selections[1] == 0) {
                    self.inval = "est. time can't be 0h0m"
                } else {
                    modelControllerAssignments.time_worked_on = 0
                    modelControllerAssignments.estim_time = self.selections[0]*60+self.selections[1]; modelControllerAssignments.AddAssignment(); self.special = false; self.assignment_add_button = false;
                    if (!(id?.isEmpty ?? true)) {
                        modelControllerAssignments.del(assign:modelControllerAssignments.assignments.first(where: {$0.id == id})!)
                    }
                }
            }) {
                ZStack{
                    Text("post").fontWeight(.thin).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 0.5).frame(width:50, height:25))
                }
            }
        }.padding(.top).onAppear {
            if special {
                modelControllerAssignments.assignment_name = modelControllerAssignments.assignments.first(where: {$0.id == id})!.assignment_name
                modelControllerAssignments.st_date = modelControllerAssignments.assignments.first(where: {$0.id == id})!.start_date
                modelControllerAssignments.end_date = modelControllerAssignments.assignments.first(where: {$0.id == id})!.end_date
                modelControllerAssignments.estim_time = modelControllerAssignments.assignments.first(where: {$0.id == id})!.estimated_time
                self.selections[0] = modelControllerAssignments.estim_time/60
                self.selections[1] = modelControllerAssignments.estim_time-(modelControllerAssignments.estim_time/60)*60
            } else {
                modelControllerAssignments.assignment_name = ""
                modelControllerAssignments.st_date = date(current_month, current_day)
                modelControllerAssignments.end_date = date(current_month, current_day)
                modelControllerAssignments.estim_time = 0
            }
        }
    }
}

struct AddEvent: View {
    @State var id: String?
    @Binding var current_month: Int
    @Binding var current_day: Int
    @Binding var special: Bool
    @Binding var event_add_button: Bool
    @State var inval: String = ""
    @ObservedObject var modelControllerEvents: EventsController
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {self.special = false; self.event_add_button = false}) {
                    ZStack{
                        Text("<").font(.title2).fontWeight(.ultraLight).padding(.leading, (UIScreen.main.bounds.width-300)/2)
                    }
                }
                Spacer()
            }

            if (special) {
                Text("edit event").font(.title).fontWeight(.thin)
            } else {
                Text("add event").font(.title).fontWeight(.thin)
            }
            Divider()
            
            if !self.inval.isEmpty {
                Text(inval).fontWeight(.ultraLight).multilineTextAlignment(.center).background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width-10, height: 25).foregroundColor(Color(hue: 1.0, saturation: 0.641, brightness: 0.973)))
            }
            
            HStack {
                Text("event:").fontWeight(.thin)
                Spacer()
                TextField("", text: $modelControllerEvents.event_title).textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            HStack {
                Text("date:").fontWeight(.thin)
                Spacer()
                DatePicker("", selection: $modelControllerEvents.giv_date, displayedComponents: .date)
            }.padding(.horizontal, UIScreen.main.bounds.width/30)
            HStack {
                Text("from").fontWeight(.thin).padding(.leading, UIScreen.main.bounds.width/30)
                DatePicker("", selection: $modelControllerEvents.st_time, displayedComponents: .hourAndMinute)
                Spacer()
                Text("  to").fontWeight(.thin)
                DatePicker("", selection: $modelControllerEvents.end_time, displayedComponents: .hourAndMinute).padding(.trailing, UIScreen.main.bounds.width/30)
            }
            Button(action: {
                if (self.modelControllerEvents.event_title.isEmpty) {
                    self.inval = "event doesn't have a name"
                } else if (modelControllerEvents.st_time > modelControllerEvents.end_time) {
                    self.inval = "corrupted time range"
                } else {
                    modelControllerEvents.AddEvent()
                    if (!(id?.isEmpty ?? true)) {
                        modelControllerEvents.del(event:modelControllerEvents.events.first(where: {$0.id == id})!)
                    }
                    self.special = false
                    self.event_add_button = false
                }
            }) {
                ZStack{
                    Text("post").fontWeight(.thin).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 0.5).frame(width:50, height:25))
                }
            }
        }.padding(.top).onAppear {
            if special {
                modelControllerEvents.event_title = modelControllerEvents.events.first(where: {$0.id == id})!.event_name
                modelControllerEvents.giv_date = modelControllerEvents.events.first(where: {$0.id! == id})!.date
                modelControllerEvents.st_time = modelControllerEvents.events.first(where: {$0.id! == id})!.st_time
                modelControllerEvents.end_time = modelControllerEvents.events.first(where: {$0.id! == id})!.end_time
            } else {
                modelControllerEvents.event_title = ""
                modelControllerEvents.giv_date = date(current_month, current_day)
                modelControllerEvents.st_time = date(current_month, current_day)
                modelControllerEvents.end_time = date(current_month, current_day)
            }
        }
    }
}

struct WorkView: View {
    @Binding var current_month: Int
    @Binding var current_day: Int
    @Binding var button_pressed: Bool
    @Binding var event_add_button: Bool
    @Binding var assignment_add_button: Bool
    @Binding var special: Bool
    @Binding var id: String
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var modelControllerEvents: EventsController
    @ObservedObject var modelControllerAssignments: AssignmentController
    @ObservedObject var modelControllerWork: WorkPreferencesController
    @ObservedObject var modelControllerPrefTimes: PrefTimePreferencesController
    @ObservedObject var modelControllerUnavailTimes: UnavailTimePreferencesController
    
    @Binding var checkListData: [Check]
    @State var times: [timerange]
    
    var body: some View {
        VStack (spacing: 3) {
            HStack {
                Button(action: {self.button_pressed = false}) {
                    ZStack{
                        Text("<<").font(.title2).fontWeight(.ultraLight).padding(.leading, (UIScreen.main.bounds.width-300)/2)
                    }
                }.padding(.leading, (UIScreen.main.bounds.width-300)/2)
                Spacer()
                Menu {
                    Button("add event", action: {self.event_add_button = true})
                    Button("add assignment", action: {self.assignment_add_button = true})
                } label: {
                    Text("+").font(.largeTitle).fontWeight(.ultraLight)
                }.padding(.trailing, (UIScreen.main.bounds.width-300)/2)
            }
            
            HStack {
                Button(action: {
                    self.current_day -= 1;
                    let dd = DateFormatter()
                    dd.dateStyle = .medium
                    dd.timeStyle = .medium
                    
                    checkListData = []
                    
                    let temp_assign = modelControllerAssignments.assignments.filter{ $0.end_date > date(current_month, current_day) && Calendar.current.component(.day, from: $0.end_date) != getDay(current_month, current_day)}.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending})
                    
                    var current_sess = 0
                    var min_left = modelControllerWork.time_work_sess
                    var components_st1 = DateComponents()
                    components_st1.year = getYear(current_month, current_day)
                    components_st1.month = getMonth(current_month, current_day)
                    components_st1.day = getDay(current_month, current_day)
                    
                    var components_st2 = DateComponents()
                    components_st2.year = getYear(current_month, current_day)
                    components_st2.month = getMonth(current_month, current_day)
                    components_st2.day = getDay(current_month, current_day)
                    
                    for t in temp_assign {
                        var gt = 0
                        
                        if t.time_worked_on >= t.estimated_time {
                            continue
                        }
                        
                        while (min_left < t.estimated_time-gt) {
                            gt += min_left
                            min_left = modelControllerWork.time_work_sess
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            if (current_sess >= modelControllerWork.num_work_sess) {
                                break
                            }
                        }
                        
                        if (current_sess >= modelControllerWork.num_work_sess) {
                            break
                        }
                        
                        if (min_left > t.estimated_time-gt) {
                            min_left -= t.estimated_time-gt
                            gt = t.estimated_time
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            continue
                        } else {
                            min_left = modelControllerWork.time_work_sess
                            
                            gt = t.estimated_time
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            continue
                        }
                    }
                    checkListData = checkListData.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                }) {
                    ZStack{
                        Text("<").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
                Text("\(getMonth(current_month, current_day))/\(getDay(current_month, current_day))/\(String(getYear(current_month, current_day)))").font(.largeTitle).fontWeight(.thin)
                Button(action: {
                    self.current_day += 1;
                    let dd = DateFormatter()
                    dd.dateStyle = .medium
                    dd.timeStyle = .medium
                    
                    checkListData = []
                    
                    let temp_assign = modelControllerAssignments.assignments.filter{ $0.end_date > date(current_month, current_day) && Calendar.current.component(.day, from: $0.end_date) != getDay(current_month, current_day)}.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending})
                    
                    var current_sess = 0
                    var min_left = modelControllerWork.time_work_sess
                    var components_st1 = DateComponents()
                    components_st1.year = getYear(current_month, current_day)
                    components_st1.month = getMonth(current_month, current_day)
                    components_st1.day = getDay(current_month, current_day)
                    
                    var components_st2 = DateComponents()
                    components_st2.year = getYear(current_month, current_day)
                    components_st2.month = getMonth(current_month, current_day)
                    components_st2.day = getDay(current_month, current_day)
                    
                    for t in temp_assign {
                        var gt = 0
                        
                        if t.time_worked_on >= t.estimated_time {
                            continue
                        }
                        
                        while (min_left < t.estimated_time-gt) {
                            gt += min_left
                            min_left = modelControllerWork.time_work_sess
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            if (current_sess >= modelControllerWork.num_work_sess) {
                                break
                            }
                        }
                        
                        if (current_sess >= modelControllerWork.num_work_sess) {
                            break
                        }
                        
                        if (min_left > t.estimated_time-gt) {
                            min_left -= t.estimated_time-gt
                            gt = t.estimated_time
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            continue
                        } else {
                            min_left = modelControllerWork.time_work_sess
                            
                            gt = t.estimated_time
                            
                            components_st1.hour = Calendar.current.component(.hour, from: times[current_sess].start_time)
                            components_st1.minute = Calendar.current.component(.minute, from: times[current_sess].start_time)
                            
                            components_st2.hour = Calendar.current.component(.hour, from: times[current_sess].end_time)
                            components_st2.minute = Calendar.current.component(.minute, from: times[current_sess].end_time)
                            
                            checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(from: components_st1)!, end_time: Calendar.current.date(from: components_st2)!), assignm: t))
                            current_sess += 1
                            continue
                        }
                    }
                    checkListData = checkListData.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                }) {
                    ZStack{
                        Text(">").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
            }
            
            List {
                Section(header: Button(action: {self.event_add_button = true}){Text("events +").font(.footnote).fontWeight(.ultraLight).foregroundColor(Color.blue)}) {
                    let result = modelControllerEvents.events.filter { calendar.dateComponents([.month], from: $0.date) == calendar.dateComponents([.month], from: date(current_month, current_day)) && calendar.dateComponents([.day], from: $0.date) == calendar.dateComponents([.day], from: date(current_month, current_day)) && calendar.dateComponents([.year], from: $0.date) == calendar.dateComponents([.year], from: date(current_month, current_day)) }
                    if result.isEmpty {
                        VStack (alignment: .leading, spacing: 1) {
                            Text("no events for today").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        }
                    } else {
                        ForEach(result.sorted(by: {$0.date.compare($1.date) == .orderedAscending})) { event in
                            HStack {
                                VStack (alignment: .leading, spacing: 1) {
                                    HStack(spacing:0) {
                                        Text(event.st_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                        Text("-").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                        Text(event.end_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                    }
                                    Text("\(event.event_name)").fontWeight(.thin)
                                }
                                Spacer()
                                Button(action: {}, label: {Image(systemName: "pencil").foregroundColor(Color(.systemGray)).imageScale(.large)}).onTapGesture {
                                    self.id = event.id!;
                                    self.special = true;
                                    self.event_add_button = true;
                                }

                                Button(action: {}, label: {Label("", systemImage: "trash").foregroundColor(Color(.systemGray)).imageScale(.medium)}).onTapGesture {
                                    modelControllerEvents.del(event: event);
                                }
                            }
                        }
                    }
                }
                
                Section(header: Button(action: {self.assignment_add_button = true}){Text("assignments +").font(.footnote).fontWeight(.ultraLight).foregroundColor(Color.blue)}) {
                    let resultend = modelControllerAssignments.assignments.filter { calendar.dateComponents([.month], from: $0.end_date) == calendar.dateComponents([.month], from: date(current_month, current_day)) && calendar.dateComponents([.day], from: $0.end_date) == calendar.dateComponents([.day], from: date(current_month, current_day)) && calendar.dateComponents([.year], from: $0.end_date) == calendar.dateComponents([.year], from: date(current_month, current_day)) }
                    
                    if resultend.isEmpty {
                        VStack (alignment: .leading, spacing: 1) {
                            Text("no assignments due today").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        }
                    } else {
                        ForEach(resultend.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending})) { assign in
                            HStack {
                                VStack (alignment: .leading, spacing: 1) {
                                    Text(assign.end_date, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                    Text("due today: \(assign.assignment_name)").fontWeight(.thin)
                                }
                                Spacer()
                                Button(action: {}, label: {Image(systemName: "pencil").foregroundColor(Color(.systemGray)).imageScale(.large)}).onTapGesture {
                                    self.id = assign.id!;
                                    self.special = true;
                                    self.assignment_add_button = true;
                                }
                                Button(action: {}, label: {Label("", systemImage: "trash").foregroundColor(Color(.systemGray)).imageScale(.medium)}).onTapGesture {
                                    modelControllerAssignments.del(assign: assign);
                                }
                            }
                        }
                    }
                }
                Section (header: Text("to-do").font(.footnote).fontWeight(.ultraLight).foregroundColor(Color.blue)) {
                    if checkListData.count == 0 {
                        Text("nothing to do yet 🥱").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                    } else {
                        ForEach(0..<checkListData.count, id: \.self){ item in
                            HStack {
                                VStack (alignment: .leading, spacing: 1) {
                                    HStack(spacing:0) {
                                        Text("recommended time: ").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                        Text(checkListData[item].time.start_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                        Text("-").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                        Text(checkListData[item].time.end_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                                    }
                                    CheckView(chec: item, data: $checkListData, modelAssignmentController: modelControllerAssignments, settings: modelControllerWork)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }.padding(.top).onAppear{
            modelControllerEvents.listenForEvents();
            modelControllerAssignments.listenForAssignments();
            modelControllerWork.listenForChange()
            modelControllerPrefTimes.listenForTimes()
            modelControllerUnavailTimes.listenForUn()
        }.onDisappear{
            modelControllerEvents.stopListening();
            modelControllerAssignments.stopListening();
            modelControllerWork.stopListeningChange();
            modelControllerPrefTimes.stopListeningTimes();
            modelControllerUnavailTimes.stopListeningUn();
        }
    }
}

struct SettingsView: View {
    @State var pressed: Bool = false
    @State var pressed1: Bool = false
    @State var inval: String = ""
    @State var mess: String = ""
    @ObservedObject var modelControllerWorkPreferences: WorkPreferencesController
    @ObservedObject var modelControllerPrefTimes: PrefTimePreferencesController
    @ObservedObject var modelControllerUnavailTimes: UnavailTimePreferencesController
    
    var body: some View {
        VStack {
            Text("work preferences").fontWeight(.thin).font(.title)
            Divider()
            
            if !self.inval.isEmpty {
                Text(inval).fontWeight(.ultraLight).multilineTextAlignment(.center).background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width-10, height: 25).foregroundColor(Color(hue: 1.0, saturation: 0.641, brightness: 0.973)))
            } else if !self.mess.isEmpty {
                Text(mess).fontWeight(.ultraLight).multilineTextAlignment(.center).background(RoundedRectangle(cornerRadius: 20).frame(width: UIScreen.main.bounds.width-10, height: 25).foregroundColor(Color(hue: 0.39, saturation: 0.93, brightness: 0.791))).task(delayText)
            }
            
            ScrollView {
                VStack(spacing: 15) {
                    HStack {
                        Text("# of work sessions per day:").fontWeight(.thin)//.padding(.leading)
                        Spacer()
                        if !self.pressed {
                            Button (action: {self.pressed=(!self.pressed);}) {
                                RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.941)).frame(width: 90, height: 32).overlay(Text("\(modelControllerWorkPreferences.num_work_sess) sess.").fontWeight(.ultraLight).foregroundColor(Color.black))
                            }
                        }
                        if self.pressed {
                            VStack(spacing: 0) {
                                Picker(selection: self.$modelControllerWorkPreferences.num_work_sess, label: Text("")) {
                                    ForEach(1 ..< 6) { index in
                                        Text("\(index) sess.").fontWeight(.ultraLight).tag(index)
                                    }
                                }.pickerStyle(.wheel).frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/8, alignment: .center).clipped().compositingGroup()
                                Button(action: {self.pressed=(!self.pressed);}) {
                                    Text("collapse").fontWeight(.ultraLight).foregroundColor(Color.blue)
                                }
                            }.onAppear{self.pressed1 = false;}
                        }
                    }.padding(.horizontal, UIScreen.main.bounds.width/30)
                    HStack {
                        Text("average work session length:").fontWeight(.thin)
                        Spacer()
                        if !self.pressed1 {
                            Button (action: {self.pressed1=(!self.pressed1);}) {
                                RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.941)).frame(width: 90, height: 32).overlay(Text("\(self.modelControllerWorkPreferences.hours)h \(self.modelControllerWorkPreferences.minutes)min").fontWeight(.ultraLight).foregroundColor(Color.black))
                            }
                        }
                        if self.pressed1 {
                            VStack {
                                HStack(spacing: 0) {
                                    Picker(selection: $modelControllerWorkPreferences.hours, label: Text("")) {
                                        ForEach(0 ..< 4) { index in
                                            Text("\(index) h").fontWeight(.ultraLight).tag(index)
                                        }
                                    }.pickerStyle(.wheel).frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/8, alignment: .center).clipped().compositingGroup()
                                    Picker(selection: $modelControllerWorkPreferences.minutes, label: Text("")) {
                                        ForEach(0 ..< 60) { index in
                                            Text("\(index) min").fontWeight(.ultraLight).tag(index)
                                        }
                                    }.pickerStyle(.wheel).frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/8, alignment: .center).clipped().compositingGroup()
                                }
                                Button(action: {self.pressed1=(!self.pressed1);}) {
                                    Text("collapse").fontWeight(.ultraLight).foregroundColor(Color.blue)
                                }
                            }.onAppear{self.pressed = false;}
                        }
                    }.padding(.horizontal, UIScreen.main.bounds.width/30)
                    
                    if !self.modelControllerWorkPreferences.sleep_yes {
                        HStack {
                            Text("sleeping hours (opt.)").fontWeight(.thin)
                            Spacer()
                            Button(action: {self.modelControllerWorkPreferences.sleep_yes = true}) {
                                Text("+").fontWeight(.thin).font(.title)
                            }
                        }.padding(.horizontal, UIScreen.main.bounds.width/30)
                    } else {
                        VStack {
                            HStack {
                                Text("sleeping hours: ").fontWeight(.thin)
                                Spacer()
                                Button(action: {self.modelControllerWorkPreferences.sleep_yes = false}) {
                                    Text("-").fontWeight(.thin).font(.title)
                                }
                            }.padding(.horizontal, UIScreen.main.bounds.width/30)
                            HStack {
                                Text("from").fontWeight(.thin)
                                Spacer()
                                DatePicker("", selection: $modelControllerWorkPreferences.sleeping_hours.start_time, displayedComponents: .hourAndMinute)
                                Text("  to").fontWeight(.thin)
                                DatePicker("", selection: $modelControllerWorkPreferences.sleeping_hours.end_time, displayedComponents: .hourAndMinute)
                            }.padding(.horizontal, UIScreen.main.bounds.width/15)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if self.modelControllerPrefTimes.pref_work_times.count == 0 {
                            HStack {
                                Text("pref. working times (opt.)").fontWeight(.thin)
                                Spacer()
                                Button(action: {self.modelControllerPrefTimes.pref_work_times.append(timerange(start_time: Date(), end_time: Date()))}) {
                                    Text("+").fontWeight(.thin).font(.title)
                                }
                            }
                        } else {
                            HStack {
                                Text("pref. working times (up to three): ").fontWeight(.thin)
                                Spacer()
                                Button(action: {
                                    if self.modelControllerPrefTimes.pref_work_times.count < 3 {
                                        self.modelControllerPrefTimes.pref_work_times.append(timerange(start_time: Date(), end_time: Date()))
                                    }
                                    }) {
                                    if self.modelControllerPrefTimes.pref_work_times.count < 3 {
                                        Text("+").fontWeight(.thin).font(.title).foregroundColor(Color.blue)
                                    } else {
                                        Text("+").fontWeight(.thin).font(.title).foregroundColor(Color.gray)
                                    }
                                }
                            }
                            ForEach(0...self.modelControllerPrefTimes.pref_work_times.count-1, id: \.self) { pref in
                                HStack {
                                    Text("from").fontWeight(.thin)
                                    DatePicker("", selection: $modelControllerPrefTimes.pref_work_times[pref].start_time, displayedComponents: .hourAndMinute)
                                    Text("  to").fontWeight(.thin)
                                    DatePicker("", selection: $modelControllerPrefTimes.pref_work_times[pref].end_time, displayedComponents: .hourAndMinute)
                                    Spacer()
                                    Button(action: {
                                        self.modelControllerPrefTimes.pref_work_times.remove(at: pref)
                                    }) {
                                        Text("-").fontWeight(.thin).font(.title)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, UIScreen.main.bounds.width/30)
                    
                    VStack(alignment: .leading) {
                        if self.modelControllerUnavailTimes.unavailable.count == 0 {
                            HStack {
                                Text("daily unavaliable times (opt.)").fontWeight(.thin)
                                Spacer()
                                Button(action: {self.modelControllerUnavailTimes.unavailable.append(timerange(start_time: Date(), end_time: Date()))}) {
                                    Text("+").fontWeight(.thin).font(.title)
                                }
                            }
                        } else {
                            HStack {
                                Text("daily unavaliable times (up to five): ").fontWeight(.thin)
                                Spacer()
                                Button(action: {
                                    if self.modelControllerUnavailTimes.unavailable.count < 5 {
                                        self.modelControllerUnavailTimes.unavailable.append(timerange(start_time: Date(), end_time: Date()))
                                    }
                                    }) {
                                    if self.modelControllerUnavailTimes.unavailable.count < 5 {
                                        Text("+").fontWeight(.thin).font(.title).foregroundColor(Color.blue)
                                    } else {
                                        Text("+").fontWeight(.thin).font(.title).foregroundColor(Color.gray)
                                    }
                                }
                            }
                            ForEach(0...self.modelControllerUnavailTimes.unavailable.count-1, id: \.self) { pref in
                                HStack {
                                    Text("from").fontWeight(.thin)
                                    DatePicker("", selection: $modelControllerUnavailTimes.unavailable[pref].start_time, displayedComponents: .hourAndMinute)
                                    Text("  to").fontWeight(.thin)
                                    DatePicker("", selection: $modelControllerUnavailTimes.unavailable[pref].end_time, displayedComponents: .hourAndMinute)
                                    Spacer()
                                    Button(action: {
                                        self.modelControllerUnavailTimes.unavailable.remove(at:pref)
                                    }) {
                                        Text("-").fontWeight(.thin).font(.title)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, UIScreen.main.bounds.width/30)
                    
                    Button(action: {
                        self.inval = ""
                        for pref in self.modelControllerUnavailTimes.unavailable {
                            if (pref.start_time > pref.end_time) {
                                self.inval = "corrupted unavaliable work time range"
                            }
                        }
                        for pref in self.modelControllerPrefTimes.pref_work_times {
                            if (pref.start_time > pref.end_time) {
                                self.inval = "corrupted pref. work time range"
                            }
                        }
                        
                        if modelControllerWorkPreferences.hours == 0 && modelControllerWorkPreferences.minutes == 0 {
                            self.inval = "work sess. time can't be 0h0m"
                        }
                        
                        if self.inval.isEmpty {
                            self.modelControllerPrefTimes.AddTime()
                            
                            self.modelControllerUnavailTimes.AddUn()
                            
                            self.modelControllerWorkPreferences.Change()
                            self.mess = "setting preferences successfully updated"
                        }
                    }) {
                        ZStack{
                            Text("update settings").fontWeight(.thin).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 0.5).frame(width:150, height:25))
                        }
                    }
                }
            }
        }.padding(.top).onAppear{modelControllerWorkPreferences.listenForChange();modelControllerUnavailTimes.listenForUn();modelControllerPrefTimes.listenForTimes();}.onDisappear{modelControllerWorkPreferences.stopListeningChange();modelControllerUnavailTimes.stopListeningUn();modelControllerPrefTimes.stopListeningTimes()}
    }
    
    private func delayText() async {
        try? await Task.sleep(nanoseconds: 1_250_000_000)
        self.mess = "";
    }
}

struct helperView: View {
    @Binding var event_add_button: Bool
    @Binding var assignment_add_button: Bool
    @Binding var button_pressed: Bool
    @Binding var special: Bool
    @Binding var id: String
    var i: Int
    var check_dates: [Int: [Check]]
    @Binding var event_dates: [Int: [Event]]
    @Binding var assignment_dates: [Int: [Assignment]]
    
    @ObservedObject var modelControllerEvents: EventsController
    @ObservedObject var modelControllerAssignments: AssignmentController
    @ObservedObject var modelControllerWork: WorkPreferencesController
    @ObservedObject var modelControllerPrefTimes: PrefTimePreferencesController
    @ObservedObject var modelControllerUnavailTimes: UnavailTimePreferencesController
    
    var body: some View {
        Section(header: Text("\(getMonth(0, i))/\(getDay(0, i))/\(String(getYear(0, i)))").font(.footnote).fontWeight(.ultraLight).foregroundColor(Color.blue)) {
            ForEach(0..<(event_dates[i]?.count ?? 0), id: \.self) { eve in
                HStack {
                    VStack (alignment: .leading, spacing: 1) {
                        HStack(spacing:0) {
                            Text("event: ").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                            Text(event_dates[i]![eve].st_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                            Text("-").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                            Text(event_dates[i]![eve].end_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        }
                        Text("\(event_dates[i]![eve].event_name)").fontWeight(.thin)
                    }
                    Spacer()
                    Button(action: {}, label: {Image(systemName: "pencil").foregroundColor(Color(.systemGray)).imageScale(.large)}).onTapGesture {
                        self.id = event_dates[i]![eve].id!;
                        self.special = true;
                        self.event_add_button = true;
                        self.button_pressed = true;
                    }
                    
                    Button(action: {}, label: {Label("", systemImage: "trash").foregroundColor(Color(.systemGray)).imageScale(.medium)}).onTapGesture {
                        modelControllerEvents.del(event: event_dates[i]![eve]);
                        event_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
                        assignment_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
                        let temp_eve = modelControllerEvents.events.sorted(by: {$0.date.compare($1.date) == .orderedAscending}).filter { Calendar.current.isDateInToday($0.date) || ($0.date >= date(0, 0) && $0.date <= date(0, 7)) }
                        
                        for event in temp_eve {
                            let fromDate = Calendar.current.startOfDay(for: date(0, 0))
                            let toDate = Calendar.current.startOfDay(for: event.date)
                            let numberOfDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
                            self.event_dates[numberOfDays.day!]?.append(event)
                        }
                    }
                }
            }
            ForEach(0..<(assignment_dates[i]?.count ?? 0), id: \.self) { assignm in
                HStack {
                    VStack (alignment: .leading, spacing: 1) {
                        HStack(spacing:0) {
                            Text("assignment: due at ").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                            Text(assignment_dates[i]![assignm].end_date, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        }
                        Text("\(assignment_dates[i]![assignm].assignment_name)").fontWeight(.thin)
                    }
                    Spacer()
                    Button(action: {}, label: {Image(systemName: "pencil").foregroundColor(Color(.systemGray)).imageScale(.large)}).onTapGesture {
                        self.id = assignment_dates[i]![assignm].id!;
                        self.special = true;
                        self.assignment_add_button = true;
                        self.button_pressed = true;
                    }
                    Button(action: {}, label: {Label("", systemImage: "trash").foregroundColor(Color(.systemGray)).imageScale(.medium)}).onTapGesture {
                        modelControllerAssignments.del(assign: assignment_dates[i]![assignm]);
                        event_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
                        assignment_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
                        let temp_assign = modelControllerAssignments.assignments.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending}).filter{Calendar.current.isDateInToday($0.end_date) || ($0.end_date >= date(0, 0) && $0.end_date <= date(0, 7))}
                        
                        for assignm in temp_assign {
                            let fromDate = Calendar.current.startOfDay(for: date(0, 0))
                            let toDate = Calendar.current.startOfDay(for: assignm.end_date)
                            let numberOfDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
                            self.assignment_dates[numberOfDays.day!]?.append(assignm)
                        }
                    }
                }
            }

            ForEach (0..<(check_dates[i]?.count ?? 0), id: \.self) { item in
                VStack (alignment: .leading, spacing: 1) {
                    HStack(spacing:0) {
                        Text("recommended time: ").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        Text(check_dates[i]![item].time.start_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        Text("-").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                        Text(check_dates[i]![item].time.end_time, style: .time).font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                    }
                    Text("work on: \(check_dates[i]![item].title)").fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));
                }
            }
        }
    }
}

struct ScheduleView: View {
    @Binding var event_add_button: Bool
    @Binding var assignment_add_button: Bool
    @Binding var button_pressed: Bool
    @Binding var special: Bool
    @Binding var id: String
    @ObservedObject var modelControllerEvents: EventsController
    @ObservedObject var modelControllerAssignments: AssignmentController
    @ObservedObject var modelControllerWork: WorkPreferencesController
    @ObservedObject var modelControllerPrefTimes: PrefTimePreferencesController
    @ObservedObject var modelControllerUnavailTimes: UnavailTimePreferencesController

    @State var event_dates: [Int: [Event]] = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
    @State var assignment_dates: [Int: [Assignment]] = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
    @State var check_dates: [Int: [Check]] = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
    
    var body: some View {
        VStack {
            Text("the daily schedule").font(.largeTitle).fontWeight(.thin)
            Text("upcoming stuff").fontWeight(.ultraLight)
            Divider()
            
            List {
                ForEach(0...7, id: \.self) { i in
                    if (!(event_dates[i]?.isEmpty ?? true) || !(assignment_dates[i]?.isEmpty ?? true) || !(check_dates[i]?.isEmpty ?? true)) {
                        helperView(event_add_button: $event_add_button, assignment_add_button: $assignment_add_button, button_pressed: $button_pressed, special: $special, id: $id, i: i, check_dates: check_dates, event_dates: $event_dates, assignment_dates: $assignment_dates, modelControllerEvents: modelControllerEvents, modelControllerAssignments: modelControllerAssignments, modelControllerWork: modelControllerWork, modelControllerPrefTimes: modelControllerPrefTimes, modelControllerUnavailTimes: modelControllerUnavailTimes)
                    } else {
                        Section(header: Text("\(getMonth(0, i))/\(getDay(0, i))/\(String(getYear(0, i)))").font(.footnote).fontWeight(.ultraLight).foregroundColor(Color.blue)) { Text("nothing for today").font(.footnote).fontWeight(.thin).foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.44));}
                    }
                }
            }
        }.onAppear {
            modelControllerEvents.listenForEvents();
            modelControllerAssignments.listenForAssignments();
            modelControllerWork.listenForChange();
            modelControllerPrefTimes.listenForTimes();
            modelControllerUnavailTimes.listenForUn();
            let c = Calendar.current
            check_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
            let temp_eve = modelControllerEvents.events.sorted(by: {$0.date.compare($1.date) == .orderedAscending}).filter { c.isDateInToday($0.date) || ($0.date >= date(0, 0) && $0.date <= date(0, 7)) }
            
            for event in temp_eve {
                let fromDate = c.startOfDay(for: date(0, 0))
                let toDate = c.startOfDay(for: event.date)
                let numberOfDays = c.dateComponents([.day], from: fromDate, to: toDate)
                self.event_dates[numberOfDays.day!]?.append(event)
            }
            
            let temp_assign = modelControllerAssignments.assignments.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending}).filter{c.isDateInToday($0.end_date) || ($0.end_date >= date(0, 0) && $0.end_date <= date(0, 7))}

            for assignm in temp_assign {
                let fromDate = c.startOfDay(for: date(0, 0))
                let toDate = c.startOfDay(for: assignm.end_date)
                let numberOfDays = c.dateComponents([.day], from: fromDate, to: toDate)
                self.assignment_dates[numberOfDays.day!]?.append(assignm)
            }
            
            var times: [timerange] = []
            var components_st = DateComponents()
            var components_end = DateComponents()
            components_st.year = getYear(0, 0)
            components_st.month = getMonth(0, 0)
            components_st.day = getDay(0, 0)
            if (modelControllerWork.sleep_yes) {
                components_st.hour = c.component(.hour, from: modelControllerWork.sleeping_hours.end_time)
                components_st.minute = c.component(.minute, from: modelControllerWork.sleeping_hours.end_time)
                
                components_end.hour = c.component(.hour, from: modelControllerWork.sleeping_hours.start_time)
                components_end.minute = c.component(.minute, from: modelControllerWork.sleeping_hours.start_time)
            } else {
                components_st.hour = 8
                components_st.minute = 0
                
                components_end.hour = 20
                components_end.minute = 0
            }
            
            if (modelControllerUnavailTimes.unavailable.isEmpty && modelControllerPrefTimes.pref_work_times.isEmpty) {
                while true {
                    var temp = timerange(start_time: c.date(from: components_st)!, end_time: c.date(from: components_st)!)
                    
                    components_st.hour = components_st.hour!+modelControllerWork.hours
                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                    temp.end_time = c.date(from: components_st)!
                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                        break
                    }
                    times.append(temp)
                }
            } else if (!modelControllerUnavailTimes.unavailable.isEmpty && modelControllerPrefTimes.pref_work_times.isEmpty) {
                while true {
                    var temp = timerange(start_time: c.date(from: components_st)!, end_time: c.date(from: components_st)!)
                    components_st.hour = components_st.hour!+modelControllerWork.hours
                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                    
                    temp.end_time = c.date(from: components_st)!
                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                        break
                    }
                    var broke = false
                    for uwu in modelControllerUnavailTimes.unavailable {
                        if c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) > c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) <= c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) >= c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) < c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) <= c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) >= c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            broke = true
                            break
                        }
                    }
                    if broke == false {
                        times.append(temp)
                    }
                }
            } else if (!modelControllerPrefTimes.pref_work_times.isEmpty && modelControllerUnavailTimes.unavailable.isEmpty) {
                while true {
                    var temp = timerange(start_time: c.date(from: components_st)!, end_time: c.date(from: components_st)!)
                    
                    components_st.hour = components_st.hour!+modelControllerWork.hours
                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                    
                    temp.end_time = c.date(from: components_st)!
                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                        break
                    }
                    
                    var broke = false
                    for peep in modelControllerPrefTimes.pref_work_times {
                        if c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) > c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) <= c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) >= c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) < c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) <= c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) >= c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                    }
                    if (broke == false) {
                        times.append(temp)
                    }
                }
            } else {
                while true {
                    var temp = timerange(start_time: c.date(from: components_st)!, end_time: c.date(from: components_st)!)
                    
                    components_st.hour = components_st.hour!+modelControllerWork.hours
                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                    
                    temp.end_time = c.date(from: components_st)!
                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                        break
                    }
                    var broke = false
                    for peep in modelControllerPrefTimes.pref_work_times {
                        if c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) > c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) <= c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) >= c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) < c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) <= c.component(.hour, from: peep.start_time)*60+c.component(.minute, from: peep.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) >= c.component(.hour, from: peep.end_time)*60+c.component(.minute, from: peep.end_time) {
                            times.insert(temp, at: 0)
                            broke = true
                            break
                        }
                    }
                    
                    var brokeii = false
                    for uwu in modelControllerUnavailTimes.unavailable {
                        if c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) > c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) <= c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            brokeii = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) >= c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) < c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            brokeii = true
                            break
                        }
                        
                        if c.component(.hour, from: temp.start_time)*60+c.component(.minute, from: temp.start_time) <= c.component(.hour, from: uwu.start_time)*60+c.component(.minute, from: uwu.start_time) && c.component(.hour, from: temp.end_time)*60+c.component(.minute, from: temp.end_time) >= c.component(.hour, from: uwu.end_time)*60+c.component(.minute, from: uwu.end_time) {
                            brokeii = true
                            break
                        }
                    }
                    if broke == false && brokeii == false {
                        times.append(temp)
                    }
                }
            }
            
            let dd = DateFormatter()
            dd.dateStyle = .medium
            dd.timeStyle = .medium
            
            var completed: [Assignment] = []
            var days = 0
            while days < 8 {
                var temp_assign: [Assignment] = []
                for j in modelControllerAssignments.assignments {
                    if j.end_date > date(0, days) && !completed.contains(where: {$0 == j}) {
                        temp_assign.append(j)
                    }
                }
                if temp_assign.count == 0 {
                    break
                }
                temp_assign = temp_assign.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending})
                var min_left = modelControllerWork.time_work_sess
                
                for t in temp_assign {
                    var gt = 0
                    
                    if t.time_worked_on >= t.estimated_time {
                        continue
                    }
                    
                    while (min_left < t.estimated_time-gt) {
                        gt += min_left
                        min_left = modelControllerWork.time_work_sess
                        
                        var dateComponent = DateComponents()
                        dateComponent.day = days
                        
                        check_dates[days]!.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].end_time)!), assignm: t))
                        
                        completed.append(t)
                        if ((check_dates[days] ?? []).count >= modelControllerWork.num_work_sess) {
                            check_dates[days] = check_dates[days]!.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                            days += 1
                        }
                    }
                    
                    if ((check_dates[days] ?? []).count >= modelControllerWork.num_work_sess) {
                        check_dates[days] = check_dates[days]!.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                        days += 1
                    }
                    if days >= 8 {
                        break
                    }
                    
                    if (min_left > t.estimated_time-gt) {
                        min_left -= t.estimated_time-gt
                        gt = t.estimated_time
                        
                        var dateComponent = DateComponents()
                        dateComponent.day = days
                        
                        check_dates[days]!.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].end_time)!), assignm: t))
                        
                        completed.append(t)
                        continue
                    } else {
                        min_left = modelControllerWork.time_work_sess
                        
                        gt = t.estimated_time
                        
                        var dateComponent = DateComponents()
                        dateComponent.day = days
                        
                        check_dates[days]!.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[(check_dates[days] ?? []).count].end_time)!), assignm: t))
                        
                        completed.append(t)
                        check_dates[days] = check_dates[days]!.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                        continue
                    }
                }
                if days >= 8 {
                    break
                }
            }
        }.onDisappear {
            modelControllerEvents.stopListening();
            modelControllerAssignments.stopListening();
            modelControllerWork.stopListeningChange();
            modelControllerPrefTimes.stopListeningTimes();
            modelControllerUnavailTimes.stopListeningUn();
            
            event_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
            assignment_dates = [0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7:[]]
        }
    }
}

struct CalendarView: View {
    @Binding var current_month: Int
    @Binding var current_day: Int
    @Binding var button_pressed: Bool
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    private let user = GIDSignIn.sharedInstance.currentUser
    
    @ObservedObject var modelControllerEvents: EventsController
    @ObservedObject var modelControllerAssignments: AssignmentController
    @ObservedObject var modelControllerWork: WorkPreferencesController
    @ObservedObject var modelControllerPrefTimes: PrefTimePreferencesController
    @ObservedObject var modelControllerUnavailTimes: UnavailTimePreferencesController
    
    @Binding var times: [timerange]
    @Binding var checkListData: [Check]
    var columns: [GridItem] = [.init(.adaptive(minimum: UIScreen.main.bounds.width/8.46, maximum: UIScreen.main.bounds.width/8.46))]
    
    var body: some View {
        VStack (spacing: 15) {
            HStack {
                Button(action: {viewModel.signOut()}) {
                    ZStack{
                        Text("log out").fontWeight(.thin).padding(.leading, (UIScreen.main.bounds.width-300)/2)
                    }
                }
                Spacer()
                NetworkImage(url: user?.profile?.imageURL(withDimension: 100)).padding(.trailing, (UIScreen.main.bounds.width-300)/3).frame(width: 55, height: 55, alignment: .center).cornerRadius(100)
            }
            HStack {
                Button(action: {self.current_month -= 12;}) {
                    ZStack{
                        Text("<<").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
                Text("\(String(getYear(current_month, current_day)))").font(.largeTitle).fontWeight(.thin)
                Button(action: {self.current_month += 12;}) {
                    ZStack{
                        Text(">>").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
            }
            HStack {
                Button(action: {self.current_month -= 1;}) {
                    ZStack{
                        Text("<").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
                Text("\(month_names[mod(getMonth(current_month, current_day)-1, 12)])").font(.title).fontWeight(.ultraLight)
                Button(action: {self.current_month += 1;}) {
                    ZStack{
                        Text(">").fontWeight(.ultraLight).foregroundColor(.black)
                    }
                }
            }
            
            LazyVGrid(columns: columns, spacing: UIScreen.main.bounds.width/30) {
                ForEach((0...6), id: \.self) {
                    i in Text("\(days[i])").font(.title2).fontWeight(.thin)
                }
 
                ForEach((7...month_days(current_month, current_day)+getStartMonthPos(current_month, current_day)+6), id: \.self) { i in
                    if (i < 7+getStartMonthPos(current_month, current_day)) {
                        Button(action: {}) {
                            ZStack{
                                Circle().frame(width: UIScreen.main.bounds.width/10, height:   UIScreen.main.bounds.width/10).foregroundColor(.white)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            times = []
                            self.button_pressed=true;
                            self.current_day = (i-6-getStartMonthPos(current_month, current_day))-getDay(current_month, 0);
                            self.current_month = current_month
                            
                            var components_st = DateComponents()
                            var components_end = DateComponents()
                            components_st.year = getYear(0, 0)
                            components_st.month = getMonth(0, 0)
                            components_st.day = getDay(0, 0)
                            if (modelControllerWork.sleep_yes) {
                                components_end.hour = Calendar.current.component(.hour, from: modelControllerWork.sleeping_hours.start_time)
                                components_end.minute = Calendar.current.component(.minute, from: modelControllerWork.sleeping_hours.start_time)
                                components_st.hour = Calendar.current.component(.hour, from: modelControllerWork.sleeping_hours.end_time)
                                components_st.minute = Calendar.current.component(.minute, from: modelControllerWork.sleeping_hours.end_time)
                            } else {
                                components_st.hour = 8
                                components_st.minute = 0
                                
                                components_end.hour = 20
                                components_end.minute = 0
                            }
                            
                            if (modelControllerUnavailTimes.unavailable.isEmpty && modelControllerPrefTimes.pref_work_times.isEmpty) {
                                while true {
                                    var temp = timerange(start_time: Calendar.current.date(from: components_st)!, end_time: Calendar.current.date(from: components_st)!)
                                    
                                    components_st.hour = components_st.hour!+modelControllerWork.hours
                                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                                    temp.end_time = Calendar.current.date(from: components_st)!
                                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                                        break
                                    }
                                    times.append(temp)
                                }
                            } else if (!modelControllerUnavailTimes.unavailable.isEmpty && modelControllerPrefTimes.pref_work_times.isEmpty) {
                                while true {
                                    var temp = timerange(start_time: Calendar.current.date(from: components_st)!, end_time: Calendar.current.date(from: components_st)!)
                                    components_st.hour = components_st.hour!+modelControllerWork.hours
                                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                                    
                                    temp.end_time = Calendar.current.date(from: components_st)!
                                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                                        break
                                    }
                                    var broke = false
                                    for uwu in modelControllerUnavailTimes.unavailable {
                                        if Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) > Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) <= Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) >= Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) < Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) <= Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) >= Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            broke = true
                                            break
                                        }
                                    }
                                    if broke == false {
                                        times.append(temp)
                                    }
                                }
                            } else if (!modelControllerPrefTimes.pref_work_times.isEmpty && modelControllerUnavailTimes.unavailable.isEmpty) {
                                while true {
                                    var temp = timerange(start_time: Calendar.current.date(from: components_st)!, end_time: Calendar.current.date(from: components_st)!)
                                    
                                    components_st.hour = components_st.hour!+modelControllerWork.hours
                                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                                    
                                    temp.end_time = Calendar.current.date(from: components_st)!
                                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                                        break
                                    }
                                    
                                    var broke = false
                                    for peep in modelControllerPrefTimes.pref_work_times {
                                        if Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) > Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) <= Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) >= Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) < Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) <= Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) >= Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                    }
                                    if (broke == false) {
                                        times.append(temp)
                                    }
                                }
                            } else {
                                while true {
                                    var temp = timerange(start_time: Calendar.current.date(from: components_st)!, end_time: Calendar.current.date(from: components_st)!)
                                    
                                    components_st.hour = components_st.hour!+modelControllerWork.hours
                                    components_st.minute = components_st.minute!+modelControllerWork.minutes
                                    temp.end_time = Calendar.current.date(from: components_st)!
                                    
                                    if components_st.hour! > components_end.hour! || (components_st.hour! == components_end.hour! && components_st.minute! > components_end.minute!) {
                                        break
                                    }
                                    
                                    var broke = false
                                    for peep in modelControllerPrefTimes.pref_work_times {
                                        if Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) > Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) <= Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) >= Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) < Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) <= Calendar.current.component(.hour, from: peep.start_time)*60+Calendar.current.component(.minute, from: peep.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) >= Calendar.current.component(.hour, from: peep.end_time)*60+Calendar.current.component(.minute, from: peep.end_time) {
                                            times.insert(temp, at: 0)
                                            broke = true
                                            break
                                        }
                                    }
                                    
                                    var brokeii = false
                                    for uwu in modelControllerUnavailTimes.unavailable {
                                        if Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) > Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) <= Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            brokeii = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) >= Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) < Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            brokeii = true
                                            break
                                        }
                                        
                                        if Calendar.current.component(.hour, from: temp.start_time)*60+Calendar.current.component(.minute, from: temp.start_time) <= Calendar.current.component(.hour, from: uwu.start_time)*60+Calendar.current.component(.minute, from: uwu.start_time) && Calendar.current.component(.hour, from: temp.end_time)*60+Calendar.current.component(.minute, from: temp.end_time) >= Calendar.current.component(.hour, from: uwu.end_time)*60+Calendar.current.component(.minute, from: uwu.end_time) {
                                            brokeii = true
                                            break
                                        }
                                    }
                                    if broke == false && brokeii == false {
                                        times.append(temp)
                                    }
                                }
                            }
                            let dd = DateFormatter()
                            dd.dateStyle = .medium
                            dd.timeStyle = .medium
                            
                            checkListData = []
                            
                            let temp_assign = modelControllerAssignments.assignments.filter{ $0.end_date >= date(current_month, current_day) }.sorted(by: {$0.end_date.compare($1.end_date) == .orderedAscending})
                            
                            var current_sess = 0
                            var min_left = modelControllerWork.time_work_sess
                            
                            for t in temp_assign {
                                var gt = 0
                                
                                if t.time_worked_on >= t.estimated_time {
                                    continue
                                }
                                
                                while (min_left < t.estimated_time-gt) {
                                    gt += min_left
                                    min_left = modelControllerWork.time_work_sess
                                    
                                    var dateComponent = DateComponents()
                                    dateComponent.day = current_day
                                    
                                    checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].end_time)!), assignm: t))
                                    current_sess += 1
                                    if (current_sess >= modelControllerWork.num_work_sess) {
                                        break
                                    }
                                }
                                
                                if (current_sess >= modelControllerWork.num_work_sess) {
                                    break
                                }
                                
                                if (min_left > t.estimated_time-gt) {
                                    min_left -= t.estimated_time-gt
                                    gt = t.estimated_time
                                    
                                    var dateComponent = DateComponents()
                                    dateComponent.day = current_day
                                    
                                    checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].end_time)!), assignm: t))
                                    
                                    current_sess += 1
                                    continue
                                } else {
                                    min_left = modelControllerWork.time_work_sess
                                    
                                    gt = t.estimated_time
                                    
                                    var dateComponent = DateComponents()
                                    dateComponent.day = current_day
                                    
                                    checkListData.append(Check(title:t.assignment_name, isChecked: false, time: timerange(start_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].start_time)!, end_time: Calendar.current.date(byAdding: dateComponent, to: times[current_sess].end_time)!), assignm: t))
                                    
                                    current_sess += 1
                                    continue
                                }
                            }
                            checkListData = checkListData.sorted(by: {$0.time.end_time.compare($1.time.end_time) == .orderedAscending})
                        }) {
                            ZStack{
                                if i-6-getStartMonthPos(current_month, current_day) == getDay(0, 0) && getMonth(current_month, current_day) == getMonth(0, 0) && getYear(current_month, current_day) == getYear(0, 0) {
                                    Circle().frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10).foregroundColor(.blue).overlay(Circle().stroke(.black, lineWidth: 0.5)
                                    )
                                } else {
                                    Circle().frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10).foregroundColor(.white).overlay(Circle().stroke(.black, lineWidth: 0.5))
                                }
                                Text("\(i-6-getStartMonthPos(current_month, current_day))").fontWeight(.ultraLight)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }.padding(.top).onAppear{
            modelControllerEvents.listenForEvents();
            modelControllerAssignments.listenForAssignments();
            modelControllerWork.listenForChange()
            modelControllerPrefTimes.listenForTimes()
            modelControllerUnavailTimes.listenForUn()
            
        }.onDisappear{
            modelControllerEvents.stopListening();
            modelControllerAssignments.stopListening();
            modelControllerWork.stopListeningChange();
            modelControllerPrefTimes.stopListeningTimes();
            modelControllerUnavailTimes.stopListeningUn();
        }
    }
}

struct ContentView: View {
    @State var button_pressed = false
    @State var event_add_button = false
    @State var assignment_add_button = false
    @State var current_day = 0
    @State var current_month = 0
    @State var edit_event = false
    @State var edit_assignment = false
    @State var special = false
    @State var id = ""
    @State var times: [timerange] = []
    @State var checkListData: [Check] = []
    @State private var showingAlert = false
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @ObservedObject var modelControllerEvents = EventsController()
    @ObservedObject var modelControllerAssignments = AssignmentController()
    @ObservedObject var modelControllerWorkPreferences = WorkPreferencesController()
    @ObservedObject var modelControllerPrefTimes = PrefTimePreferencesController()
    @ObservedObject var modelControllerUnavailTimes = UnavailTimePreferencesController()
    @ObservedObject var modelScheduleController = ScheduleController()
    
    var body: some View {
        switch viewModel.state {
        case .signedIn:
            if (button_pressed) {
                if (event_add_button && !special) {
                    AddEvent(current_month: $current_month, current_day: $current_day, special: $special, event_add_button: $event_add_button, modelControllerEvents: modelControllerEvents)
                } else if (assignment_add_button && !special) {
                    AddAssignment(current_month: $current_month, current_day: $current_day, special: $special, assignment_add_button: $assignment_add_button, modelControllerAssignments: modelControllerAssignments)
                } else if (event_add_button && special) {
                    AddEvent(id: id, current_month: $current_month, current_day: $current_day, special: $special, event_add_button: $event_add_button, modelControllerEvents: modelControllerEvents)
                } else if (assignment_add_button && special) {
                    AddAssignment(id: id, current_month: $current_month, current_day: $current_day, special: $special, assignment_add_button: $assignment_add_button, modelControllerAssignments: modelControllerAssignments)
                } else {
                    WorkView(current_month: $current_month, current_day: $current_day, button_pressed: $button_pressed, event_add_button: $event_add_button, assignment_add_button: $assignment_add_button, special: $special, id: $id, viewModel: _viewModel, modelControllerEvents: modelControllerEvents, modelControllerAssignments: modelControllerAssignments, modelControllerWork: modelControllerWorkPreferences, modelControllerPrefTimes: modelControllerPrefTimes, modelControllerUnavailTimes: modelControllerUnavailTimes, checkListData: $checkListData, times: times)
                }
            } else {
                TabView {
                    CalendarView(current_month: $current_month, current_day: $current_day, button_pressed: $button_pressed, viewModel: _viewModel, modelControllerEvents: modelControllerEvents, modelControllerAssignments: modelControllerAssignments, modelControllerWork: modelControllerWorkPreferences, modelControllerPrefTimes: modelControllerPrefTimes, modelControllerUnavailTimes: modelControllerUnavailTimes, times: $times, checkListData: $checkListData).tabItem {
                        Label("calendar", systemImage: "calendar")
                    }
                    
                    ScheduleView(event_add_button: $event_add_button, assignment_add_button: $assignment_add_button, button_pressed: $button_pressed, special: $special, id: $id, modelControllerEvents: modelControllerEvents, modelControllerAssignments: modelControllerAssignments, modelControllerWork: modelControllerWorkPreferences, modelControllerPrefTimes: modelControllerPrefTimes, modelControllerUnavailTimes: modelControllerUnavailTimes).tabItem {
                        Label("to-do", systemImage: "list.bullet")
                    }
                    
                    SettingsView(modelControllerWorkPreferences: modelControllerWorkPreferences, modelControllerPrefTimes: modelControllerPrefTimes, modelControllerUnavailTimes: modelControllerUnavailTimes).tabItem {
                        Label("settings", systemImage: "gearshape")
                    }
                }
            }
        case .signedOut: StartView()
        }
    }
}
