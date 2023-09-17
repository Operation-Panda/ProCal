//
//  trackerView.swift
//  ProCal
//
//  Created by Roaa on 4/21/24.
//

import SwiftUI
import Charts

enum QuizCase {
    case social
    case sleep
}

struct QuestionCard: View {
    @EnvironmentObject var sleepManager: SleepDataPointsManager
    @EnvironmentObject var socialManager: SocialDataPointsManager
    @Environment(\.dismiss) var dismiss
    
    let quizCase: QuizCase
    
    var description: String {
        if quizCase == .social {return "Social"}
        return "Sleep"
    }
    
    @State var hoursAnswer: Int = -1
    @State var feelingAnswer: Int = -1
    @State var productivityAnswer: Int = -1
    
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 60) {
                Text("\(description.uppercased()) DATA")
                    .font(.largeTitle.bold())
                    .padding(.vertical)
                
                VStack(spacing: 30) {
                        Stepper(value: $hoursAnswer, in: 0...24, step: 1) {
                            Text(hoursAnswer >= 0 ? "\(description) Hours: \(hoursAnswer) " : "\(description) Hours:")
                        }
                        Divider()
                        Stepper(value: $feelingAnswer, in: 0...10, step: 1) {
                            Text(feelingAnswer >= 0 ? "Feeling: \(feelingAnswer) " : "Feeling:")
                        }
                        Divider()
                        Stepper(value: $productivityAnswer, in: 0...10, step: 1) {
                            Text(productivityAnswer >= 0 ? "Productivity: \(productivityAnswer) " : "Productivity:")
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                        .stroke(.black)
                    )
                    
                    
            
                Button {
                    if hoursAnswer >= 0, feelingAnswer >= 0, productivityAnswer >= 0 {
                        if quizCase == .sleep {
                            Task {
                                sleepManager.AddSleepPoint(date: Date(), SleepHours: hoursAnswer, feeling: feelingAnswer, productivity: productivityAnswer)
                            }
                            dismiss()
                        } else {
                            Task {
                                socialManager.AddSocialPoint(date: Date(), socialHours: hoursAnswer, feeling: feelingAnswer, productivity: productivityAnswer)
                            }
                            dismiss()
                        }
                        
                    }
                } label: {
                    Text("Submit")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.mint))
                }
            }
            .padding()
        }
        .onAppear {
            socialManager.listenForSocialPoints()
            sleepManager.listenForSleepPoints()
        }
    }
}



struct trackerView: View {
    @ObservedObject var sleepManager: SleepDataPointsManager
    @ObservedObject var socialManager: SocialDataPointsManager
    
    var emoSleepState: (max: SleepDataPoints?, min: SleepDataPoints?) {
        let max = sleepManager.sleepDataPoints.max{$0.feeling < $1.feeling}
        let min = sleepManager.sleepDataPoints.max{$0.feeling > $1.feeling}
        return (max, min == max ? nil : min)
    }
    
    var proSleepState: (max: SleepDataPoints?, min: SleepDataPoints?) {
        let max = sleepManager.sleepDataPoints.max{$0.productivity < $1.productivity}
        let min = sleepManager.sleepDataPoints.max{$0.productivity > $1.productivity}
        return (max, min == max ? nil : min)
    }
    
    var emoSocialState: (max: SocialDataPoints?, min: SocialDataPoints?) {
        let max = socialManager.socialDataPoints.max{$0.feeling < $1.feeling}
        let min = socialManager.socialDataPoints.max{$0.feeling > $1.feeling}
        return (max, min == max ? nil : min)
    }
     
    var proSocialState: (max: SocialDataPoints?, min: SocialDataPoints?) {
        let max = socialManager.socialDataPoints.max{$0.productivity < $1.productivity}
        let min = socialManager.socialDataPoints.max{$0.productivity > $1.productivity}
        return (max, min == max ? nil : min)
    }
    
    var SlDP: [SleepDataPoints] {
        if sleepManager.sleepDataPoints.count <= 10 {
            return sleepManager.sleepDataPoints
        } else {
            let c = sleepManager.sleepDataPoints.count - 10
            return Array(sleepManager.sleepDataPoints[c...])
        }
    }
    
    var SoDP: [SocialDataPoints] {
        if socialManager.socialDataPoints.count <= 10 {
            return socialManager.socialDataPoints
        } else {
            let c = socialManager.socialDataPoints.count - 10
            return Array(socialManager.socialDataPoints[c...])
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 40) {
                    Text("GENERAL TRENDS")
                        .font(.largeTitle).fontWeight(.thin)
                        .padding(.top, 30)
                    
                    Divider()
                        .padding(30) 
                    
                    Text("SLEEP")
                        .font(.title).fontWeight(.thin)
                     
                    //hours vs feeling
                    Text("SLEEP VS. EMOTIONAL STATE")
                    if SlDP.count > 0 {
                        Chart {
                            ForEach(SlDP) { data in
                                BarMark(x: .value("HOURS", data.SleepHours),
                                        y: .value("FEELS", data.feeling))
                                .foregroundStyle (
                                    emoSleepState.max?.feeling == data.feeling ? .blue : (emoSleepState.min?.feeling == data.feeling ? .cyan : .gray)
                                )
                            }
                        }
                    } else {
                        emptyChart
                    }
                    VStack(spacing: 10) {
                        if let maxEmoSleepState = emoSleepState.max {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                                Text("The hightest productive state was \(maxEmoSleepState.productivity) on \(maxEmoSleepState.createdAt.toString()) after \(maxEmoSleepState.SleepHours) \(maxEmoSleepState.SleepHours == 1 ? "hour" : "hours") of sleep.")
                                    .foregroundColor(.gray)
                            }
                        }
                        if let minEmoSleepState = emoSleepState.min {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.cyan)
                                    .opacity(0.7)
                                Text("The lowest productive state was \(minEmoSleepState.productivity) on \(minEmoSleepState.createdAt.toString()) after \(minEmoSleepState.SleepHours) \(minEmoSleepState.SleepHours == 1 ? "hour" : "hours") of sleep.")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    
                    //hours vs productivity
                    Text("SLEEP VS. PRODUCTIVITY")
                    if SlDP.count > 0 {
                        Chart {
                            ForEach(SlDP) { data in
                                BarMark(x: .value("HOURS", data.SleepHours),
                                        y: .value("RESULT", data.productivity))
                                .foregroundStyle (
                                    emoSleepState.max?.productivity == data.productivity ? .blue : (emoSleepState.min?.productivity == data.productivity ? .cyan : .gray)
                                )
                            }
                        }
                        
                    } else {
                        emptyChart
                    }
                    
                    VStack(spacing: 10) {
                        if let maxProSleepState = proSleepState.max {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                                Text("The hightest productive state was \(maxProSleepState.productivity) on \(maxProSleepState.createdAt.toString()) after \(maxProSleepState.SleepHours) \(maxProSleepState.SleepHours == 1 ? "hour" : "hours") of sleep.")
                            }
                        }
                        if let minProSleepState = proSleepState.min {
                                HStack(alignment: .top) {
                                    Image(systemName: "asterisk")
                                        .foregroundColor(.cyan)
                                        .opacity(0.7)
                                    Text("The lowest productive state was \(minProSleepState.productivity) on \(minProSleepState.createdAt.toString()) after \(minProSleepState.SleepHours) \(minProSleepState.SleepHours == 1 ? "hour" : "hours") of sleep.")
                                }
                        }
                        
                        HStack {
                            NavigationLink(destination: QuestionCard(quizCase: .sleep).environmentObject(sleepManager).environmentObject(socialManager)) {
                                Text("ADD DATA")
                                    .foregroundColor(.white)
                                    .font(.title.bold())
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.mint))
                            }
                            Button("UNDO") {
                                if let last = sleepManager.sleepDataPoints.last {
                                    sleepManager.del(data: last)
                                }
                            }
                            .foregroundColor(.white)
                            .font(.title.bold())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("LightGrayC")))
                        }
                        .padding(.top, 50)
                    }
                    .foregroundColor(.gray)
                    .padding(.bottom)

                    Divider()
                        .padding(30)
                    
                    Text("SOCIAL")
                        .font(.largeTitle).fontWeight(.thin)
                     
                    //hours vs feeling
                    Text("SOCIAL VS. EMOTIONAL STATE")
                    if SoDP.count > 0 {
                        Chart {
                            ForEach(SoDP) { data in
                                BarMark(x: .value("HOURS", data.SocialHours),
                                        y: .value("FEELS", data.feeling))
                                .foregroundStyle (
                                    emoSocialState.max?.feeling == data.feeling ? .blue : (emoSocialState.min?.feeling == data.feeling ? .cyan : .gray)
                                )
                            }
                        }
                    } else {
                        emptyChart
                    }
                     
                    VStack(spacing: 10) {
                        if let maxEmoSocialState = emoSocialState.max {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                                Text("The hightest productive state was \(maxEmoSocialState.productivity) on \(maxEmoSocialState.createdAt.toString()) after \(maxEmoSocialState.SocialHours) \(maxEmoSocialState.SocialHours == 1 ? "hour" : "hours") of social engagement.")
                            }
                        }
                        if let minEmoSocialState = emoSocialState.min {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.cyan)
                                    .opacity(0.7)
                                Text("The lowest productive state was \(minEmoSocialState.productivity) on \(minEmoSocialState.createdAt.toString()) after \(minEmoSocialState.SocialHours) \(minEmoSocialState.SocialHours == 1 ? "hour" : "hours") of social engagement.")
                            }
                        }
                    }
                    .foregroundColor(.gray)
                    .padding(.bottom)
                     
                    
                    //hours vs productivity
                    Text("SOCIAL VS. PRODUCTIVITY")
                    if SoDP.count > 0 {
                        Chart {
                            ForEach(SoDP) { data in
                                BarMark(x: .value("HOURS", data.SocialHours),
                                        y: .value("RESULT", data.productivity))
                                .foregroundStyle (
                                    emoSocialState.max?.productivity == data.productivity ? .blue : (emoSocialState.min?.productivity == data.productivity ? .cyan : .gray)
                                )
                            }
                        }
                    } else {
                        emptyChart
                    }
                    
                    VStack(spacing: 10) {
                        if let maxProSocialState = proSocialState.max {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.blue)
                                    .opacity(0.7)
                                Text("The hightest productive state was \(maxProSocialState.productivity) on \(maxProSocialState.createdAt.toString()) after \(maxProSocialState.SocialHours) \(maxProSocialState.SocialHours == 1 ? "hour" : "hours") of social engagement.")
                            }
                        }
                        
                        if let minProSocialState = proSocialState.min {
                            HStack(alignment: .top) {
                                Image(systemName: "asterisk")
                                    .foregroundColor(.cyan)
                                    .opacity(0.7)
                                Text("The lowest productive state was \(minProSocialState.productivity) on \(minProSocialState.createdAt.toString()) after \(minProSocialState.SocialHours) \(minProSocialState.SocialHours == 1 ? "hour" : "hours") of social engagement.")
                            }
                        }
                        
                        HStack {
                            NavigationLink(destination: QuestionCard(quizCase: .social).environmentObject(sleepManager).environmentObject(socialManager)) {
                                Text("ADD DATA")
                                    .foregroundColor(.white)
                                    .font(.title.bold())
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.mint))
                            }

                            Button("UNDO") {
                                if let last = socialManager.socialDataPoints.last {
                                    socialManager.del(data: last)
                                }
                            }
                            .foregroundColor(.white)
                            .font(.title.bold())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("LightGrayC")))
                        }
                        .padding(.top, 50)
                    }
                    .foregroundColor(.gray)
                    .padding(.bottom)
                }
                .onAppear {
                        socialManager.listenForSocialPoints()
                        sleepManager.listenForSleepPoints()
                }
                .padding()
            }
        }
    }
        
    
    var emptyChart: some View {
        HStack(alignment: .top) {
            Image(systemName: "asterisk")
            Text("***Please input data to see results***")
            Image(systemName: "asterisk")
        }
    }
}

/*#Preview {
    trackerView()
}*/

