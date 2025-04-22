//
//  ContentView.swift
//  ZeroScreen
//
//  Created by Cristian Matache on 12/16/24.
//

import SwiftUI
import Lottie

class TimerViewModel: ObservableObject {
    @Published var selectedHoursAmount = 10
    @Published var selectedMinutesAmount = 10

    let hoursRange = 0...23
    let minutesRange = 0...59
}

class AppData: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("screenTimeGoal") var screenTimeGoal: TimeInterval = 0
    @AppStorage("points") var points: Int = 0

    var debugEnabled: Bool = true

    func debugPrintState() {
        if debugEnabled {
            print("DEBUG MODE")
            
            print("Screen Time Goal: \(screenTimeGoal) seconds")
            print("Points: \(points) points")
            print("Onboarding: \(hasSeenOnboarding)")
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var progress: Double = 0.00

    var body: some View {
        if hasSeenOnboarding {
            // Show the main content if onboarding is complete
            mainContent
        } else {
            // Show the onboarding if the user hasn't completed it
            OnboardingView1()
        }
    }

    var mainContent: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 30)
                Text("ZeroScreen")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.white)
                Spacer(minLength: 10)
                VStack(spacing: 8) {
                    Text("POINTS")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(appData.points)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    LevelProgressView()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 120)
                Spacer()
                Text("Current Goal: \(formattedGoal())")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                HStack(spacing: 16) {
                    LogTimeButton()
                    ShareButton(points: appData.points)
                    SettingsButton()
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .ignoresSafeArea()
        }
    }

    func formattedGoal() -> String {
        let hours = Int(appData.screenTimeGoal) / 3600
        let minutes = (Int(appData.screenTimeGoal) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct LevelProgressView: View {
    @EnvironmentObject var appData: AppData
    

    var body: some View {
        let level = appData.points / 4000
        let progress = Double(appData.points % 4000) / 4000.0

        VStack(spacing: 4) {
            HStack {
                Text("\(level)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.green)
                        .frame(width: CGFloat(progress) * 240, height: 12)
                }
                .frame(width: 240, height: 12)

                Text("\(level + 1)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("\(Int(progress * 100))% To Level \(level + 1)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: {
            print("\(appData.points)")
        })
    }
}

struct LogTimeButton: View {
    var body: some View {
        NavigationLink(destination: LogView()) {
            Text("LOG TIME")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 140, height: 50)
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct ShareButton: View {
    @AppStorage("points") var points: Int = 0

    var body: some View {
        Button(action: {
            shareImage()
        }) {
            Text("SHARE")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 120, height: 50)
                .background(Color.blue.opacity(0.5))
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    func shareImage() {
        let image = createImageWithScore(points)
        let message = "Download ZeroScreen from example.com to compete now!"
        
        let activityController = UIActivityViewController(activityItems: [image, message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }

    func createImageWithScore(_ score: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 300))
        return renderer.image { context in
            let cgContext = context.cgContext
                
                    let colors = [UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 1).cgColor,
                                  UIColor(red: 0/255, green: 0/255, blue: 100/255, alpha: 1).cgColor]
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!

                    // Draw vertical gradient
                    cgContext.drawLinearGradient(
                        gradient,
                        start: CGPoint(x: 0, y: 0),
                        end: CGPoint(x: 0, y: 300),
                        options: []
                    )
            
            let topText = "My Score Is"
            let bottomText = "Think you can beat me?"

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]

            let topTextSize = topText.size(withAttributes: attributes)
            topText.draw(
                in: CGRect(
                    x: (300 - topTextSize.width) / 2,
                    y: 20,
                    width: topTextSize.width,
                    height: topTextSize.height
                ),
                withAttributes: attributes
            )

            let bottomTextSize = bottomText.size(withAttributes: attributes)
            bottomText.draw(
                in: CGRect(
                    x: (300 - bottomTextSize.width) / 2,
                    y: 250,
                    width: bottomTextSize.width,
                    height: bottomTextSize.height
                ),
                withAttributes: attributes
            )

            let scoreText = "\(score)"
            let scoreAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 50),
                .foregroundColor: UIColor.white
            ]

            let scoreTextSize = scoreText.size(withAttributes: scoreAttributes)
            scoreText.draw(
                in: CGRect(
                    x: (300 - scoreTextSize.width) / 2,
                    y: (300 - scoreTextSize.height) / 2,
                    width: scoreTextSize.width,
                    height: scoreTextSize.height
                ),
                withAttributes: scoreAttributes
            )
        }
    }
}

struct SettingsButton: View {
    var body: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appData: AppData // This line ensures that appData is available
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Setting")) {
                    NavigationLink(destination: SetGoalView()) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Set Goal")
                        }.foregroundColor(Color.blue)
                    }
                    
                    Button(action: {
                        // Navigate to My Progress view
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.right.circle")
                            Text("My Progress")
                        }
                    }
                }
                
                Section(header: Text("My Data")) {
                    Button(action: {
                        // Show confirmation alert before clearing app data
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                            Text("Erase All App Data")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Clear all data?"),
                    message: Text("This will clear all your settings, including goal and level data."),
                    primaryButton: .destructive(Text("Clear Data")) {
                        appData.screenTimeGoal = 0
                        appData.points = 0
                        appData.hasSeenOnboarding = false
                        appData.objectWillChange.send()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct LogView: View {
    @EnvironmentObject var appData: AppData
    @StateObject private var model = TimerViewModel()
    @State private var scoreDelta: Int = 0

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Text("Done with\nscreens?")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .frame(width: 300, height: 380)

                Text("Log your screen time here at the end of the day when you are done using your device. Be honest!")
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .fontWeight(.medium)
                    .padding(.top, -100)
                    .padding(.bottom, -140)

                HStack {
                    TimePickerView(title: "hours", range: model.hoursRange, binding: $model.selectedHoursAmount)
                    TimePickerView(title: "min", range: model.minutesRange, binding: $model.selectedMinutesAmount)
                }
                .frame(maxWidth: 320, maxHeight: 400)
                .padding(.bottom, 30)
                .foregroundColor(.white)

                NavigationLink(destination: DoneLoggingView(scoreChange: scoreDelta)) {
                    Text("Log Time")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 180, height: 50)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    let previousScore = appData.points
                    let loggedSeconds = TimeInterval(model.selectedHoursAmount * 3600 + model.selectedMinutesAmount * 60)
                    calculateAndApplyScore(loggedSeconds: loggedSeconds)
                    scoreDelta = appData.points - previousScore
                })

                Spacer(minLength: 170)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(1.0), Color.blue]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(.white)
        }
    }

    func calculateAndApplyScore(loggedSeconds: TimeInterval) {
        let rawScore = (appData.screenTimeGoal - loggedSeconds + 2400) / 10
        let roundedPoints = Int(round(rawScore))

        // Debug: Check points before updating
        print("🧪 Points before update: \(appData.points)")
        
        // Correctly add points
        appData.points = appData.points + roundedPoints
        
        appData.objectWillChange.send() // Trigger a manual update to ensure changes are reflected

        // Debug: Check points after updating
        print("🧪 Points after update: \(appData.points)")
    }
}

struct DoneLoggingView: View {
    @EnvironmentObject var appData: AppData
    var scoreChange: Int

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text(scoreMessage())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30.0)

                    NavigationLink(destination: ContentView()) {
                        Text("Return to home")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 180, height: 50)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }.simultaneousGesture(TapGesture().onEnded {
                        print("Now points are \(appData.points)")
                        appData.objectWillChange.send()
                        
                    })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func scoreMessage() -> String {
        if scoreChange > 0 {
            return "Thanks for logging, check your score! And don't use your phone for the rest of the day!"
        } else if scoreChange == 0 {
            return "No changes to your score this time. Try setting a better goal tomorrow!"
        } else {
            appData.points = 0
            return "Uh oh! Your screen time went over. Try better next time!"
        }
    }
}

struct SetGoalView: View {
    @EnvironmentObject var appData: AppData
    @State private var showAnimation = false
    @State private var goalSet = false
    @State private var selectedHoursAmount = 2
    @State private var selectedMinutesAmount = 30
    
    let hoursRange = 0...23
    let minutesRange = 0...59
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(goalSet ? "Goal Set!" : "Set Your Goal")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
                .padding()
            
            Text("Set your goal to something achievable, and we'll help you get there!")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            HStack {
                TimePickerView(title: "hours", range: hoursRange, binding: $selectedHoursAmount)
                TimePickerView(title: "min", range: minutesRange, binding: $selectedMinutesAmount)
            }
            .frame(maxWidth: 320, maxHeight: 400)
            .padding(.bottom, 30)
            .foregroundColor(.white)

            if showAnimation {
                Text("Nice Goal!")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.top, 20)
            }

            Button(action: {
                // Update goal in appData
                appData.screenTimeGoal = TimeInterval(selectedHoursAmount * 3600 + selectedMinutesAmount * 60)
                goalSet = true
                showAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showAnimation = false
                }
            }) {
                Text("Set Goal")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 180, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.black]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }
}

struct TimerView: View {
    @StateObject private var model = TimerViewModel()

    var body: some View {
        HStack(spacing: 20) {
            TimePickerView(title: "hours",
                range: model.hoursRange,
                binding: $model.selectedHoursAmount)
            TimePickerView(title: "min",
                range: model.minutesRange,
                binding: $model.selectedMinutesAmount)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .foregroundColor(.white)
    }
}

struct TimePickerView: View {
    let title: String
    let range: ClosedRange<Int>
    let binding: Binding<Int>

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker(selection: binding, label: Text(title).fontWeight(.bold)) {
                ForEach(range, id: \.self) { timeIncrement in
                    Text("\(timeIncrement)")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30, weight: .semibold))
                        .frame(height: 100)
                        .contentShape(Rectangle())
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90, height: 180)
            .clipped()

            Text(title)
                .fontWeight(.bold)
                .frame(width: 90, alignment: .center)
        }
    }
}

struct OnboardingView1: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 30)
                
                Text("Welcome to ZeroScreen!")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.white)
                
                Spacer(minLength: 10)
                
                VStack(spacing: 8) {
                    Text("Your screen relief journey begins here. Our app will guide you through reducing your screen time in a fun, competitive way! To get started, tap the button below.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 120)
                
                NavigationLink(destination: OnboardingView2()) {
                    Text("Continue to goal setting")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 300, height: 60)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Spacer()
            
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .ignoresSafeArea()
        }.navigationBarBackButtonHidden(true)
    }
}

struct OnboardingView2: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @EnvironmentObject var appData: AppData // Access the shared app data
    @State private var selectedHoursAmount = 2
    @State private var selectedMinutesAmount = 30

    let hoursRange = 0...23
    let minutesRange = 0...59

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Set Your First Goal")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Setting your first goal is important, so take it seriously! Use your Settings app to see your screen time trends, and set your goal to something a little lower than that to start.")
                .font(.system(size: 19))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 25)
                .padding(.bottom, 30)

            HStack(spacing: 20) {
                TimePickerView(title: "hours", range: hoursRange, binding: $selectedHoursAmount)
                    .frame(maxWidth: 120, maxHeight: 150)
                TimePickerView(title: "min", range: minutesRange, binding: $selectedMinutesAmount)
                    .frame(maxWidth: 120, maxHeight: 150)
            }
            .foregroundColor(.white)
            .padding(.bottom, 30)

            NavigationLink(destination: OnboardingView3()) {
                Text("Set Goal")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 160, height: 45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .simultaneousGesture(TapGesture().onEnded {
                appData.screenTimeGoal = TimeInterval(selectedHoursAmount * 3600 + selectedMinutesAmount * 60)
            })

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.gray]),
            startPoint: .top,
            endPoint: .bottom
        ))
        .ignoresSafeArea()
    }
}

struct OnboardingView3: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 30)
                Text("Good Job!")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundColor(.white)
                Spacer(minLength: 10)
                VStack(spacing: 8) {
                    Text("You're doing great. Now, you can start using the app. Once you are done using screens for the day, just log your time here and your score will update. Be competitive, reduce your screen usage, and have fun!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 120)
                Button(action: {
                    // Mark onboarding as complete and navigate to the main content
                    hasSeenOnboarding = true
                }) {
                    Text("Continue to main menu")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 300, height: 60)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingView1()
}
