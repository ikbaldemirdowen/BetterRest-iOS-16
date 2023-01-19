//
//  ContentView.swift
//  BetterRest
//
//  Created by Ikbal Demirdoven on 2023-01-18.
//
import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    static var defaultWakeTime : Date
    {
        var components = DateComponents()
        let hour = components.hour
        let minutes = components.minute
        return Calendar.current.date(from: components) ?? Date.now
    }
    var sleepResults : String
    {
        do
        {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return "Your ideal bed time is " + sleepTime.formatted(date : .omitted, time: .shortened)
        }
        catch
        {
            return "There was an error."
        }
    }
    var body: some View {
        NavigationView
        {
            Form
            {
                Section("When do you want to wake up?")
                {
                    DatePicker("Please enter a time.", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep:")
                {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake:")
                {
                    //                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...12, step: 1)
                    Picker("Number of cups", selection: $coffeeAmount)
                    {
                        ForEach(0..<13)
                        {
                            Text("\($0)")
                        }
                    }
                }
                Section
                {
                    Text(sleepResults)
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
