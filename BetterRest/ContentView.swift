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
    @State private var alertShowing = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    static var defaultWakeTime : Date
    {
        var components = DateComponents()
        let hour = components.hour
        let minutes = components.minute
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView
        {
            Form
            {
                VStack(alignment: .leading, spacing: 0)
                {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time.", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 0)
                {
                    Text("Desired amount of sleep:")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 0)
                {
                    Text("Daily coffee intake:")
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...12, step: 1)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar
            {
                Button("Calculate", action: calculateBedtime)
            }
        }
        .alert(alertTitle, isPresented: $alertShowing)
        {
            Button("OK")
            {
                
            }
        } message: {
            Text(alertMessage)
        }
        
    }
    func calculateBedtime()
    {
        //we are creating the ML model and attach it to our ML trained model, also we are checking for errors below.
        do
        {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour+minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch
        {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time."
        }
        alertShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
