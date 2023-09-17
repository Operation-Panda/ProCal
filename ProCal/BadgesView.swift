//
//  BadgesView.swift
//  ProCal
//
//  Created by Roaa on 4/21/24.
//

import SwiftUI

struct BadgeView: View {
    
    @ObservedObject var viewModel = BadgeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("badge center").font(.largeTitle).fontWeight(.thin)
                Divider()
                
                VStack(spacing: -40) {
                    ZStack {
                        Text("Achievements")
                            .font(.title2)
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color("Navy"))
                                .frame(width: 40, height: 40)
                            Rectangle()
                                .stroke(.black, lineWidth: 2)
                                .frame(height: 40)
                        }
                    }
                    
                    HStack {
                        Rectangle()
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 40)
                        VStack {
                            Rectangle()
                                .frame(height: 40)
                                .opacity(0)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                                ForEach(viewModel.achievements.indices, id: \.self) { index in
                                    if viewModel.achievements[index].stillAnAchievement {
                                        Button {
                                            withAnimation {
                                                viewModel.achievements[index].degrees = (viewModel.achievements[index].degrees == .zero) ? 360 : .zero
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                // Trigger fade-out animation
                                                withAnimation(.easeOut(duration: 0.5)) {
                                                    viewModel.achievementIsUnAchieved(AB:viewModel.achievements[index])
                                                }
                                            }
                                        } label: {
                                            Image(viewModel.achievements[index].completeImageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .shadow(radius: 8)
                                                .rotation3DEffect(.degrees(viewModel.achievements[index].degrees), axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color("LightGrayColor")).border(.black)
                .padding(.vertical)
                
                VStack(spacing: -40) {
                    ZStack {
                        Text("Challenges")
                            .font(.title2)
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color("Steel"))
                                .frame(width: 40, height: 40)
                            Rectangle()
                                .stroke(.black, lineWidth: 2)
                                .frame(height: 40)
                        }
                    }
                    
                    HStack {
                        Rectangle()
                            .stroke(.black, lineWidth: 2)
                            .frame(width: 40)
                        VStack {
                            Rectangle()
                                .frame(height: 40)
                                .opacity(0)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                                
                                ForEach(viewModel.challenges.indices, id: \.self) { index in
                                    if viewModel.challenges[index].stillAChallenge {
                                        Button {
                                            withAnimation {
                                                viewModel.challenges[index].degrees = (viewModel.challenges[index].degrees == .zero) ? 360 : .zero
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                withAnimation(.easeOut(duration: 0.5)) {
                                                    viewModel.challengeIsAchieved(CB: viewModel.challenges[index])
                                                }
                                            }
                                        } label: {
                                            Image(viewModel.challenges[index].completeImageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .shadow(radius: 8)
                                                .rotation3DEffect(.degrees(viewModel.challenges[index].degrees), axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }/*
                                ForEach(viewModel.challenges.indices, id: \.self) { index in
                                    if !viewModel.currentChallenges.contains(viewModel.challenges[index]) {
                                        Button {
                                            withAnimation {
                                                viewModel.challenges[index].degrees = (viewModel.challenges[index].degrees == .zero) ? 360 : .zero
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                withAnimation(.easeOut(duration: 0.5)) {
                                                    viewModel.challengeIsAchieved(CB: viewModel.challenges[index])
                                                }
                                            }
                                        } label: {
                                            Image(viewModel.challenges[index].completeImageName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .shadow(radius: 8)
                                                .rotation3DEffect(.degrees(viewModel.challenges[index].degrees), axis: (x: 0, y: 1, z: 0))
                                        }
                                    }
                                }*/
                            }
                        }
                    }
                }
                .background(Color("LightGrayColor")).border(.black)
                .padding(.vertical)
                
            }
            .padding()
        }/*
        .onAppear {
            viewModel.listenForChallengeBadges()
            viewModel.listenForAchievementBadges()
        }*/
    }
}

#Preview {
    BadgeView()
}
