import SwiftUI
import EventKit
import StoreKit
import RevenueCat

struct AAIplannerContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedEventName = "Architecting on AWS"
    @State private var startDate = Date()
    @State private var selectedTimeZone = TimeZone.current.identifier
    @State private var accessGranted = false
   @ObservedObject var userModel = UserViewModel.shared
   @State private var showAlert = false
   @State var displayPaywall: Bool = false
    
    let eventNames = AAIEventData.eventNames
    let eventSequences = AAIEventData.eventSequences
    let timeZones = AAIEventData.timeZones
    
    var body: some View {
        VStack {
           Spacer()
            Text("AAI Planner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.bottom)
            
            Text("If you are an AWS Authorized Instructor (AAI), you can easily add to your calendar the plans for your training deliverability. Select the training, the start time, and the time zone, and press Add Events.\n\nRecommended Modules plans and breaks will be added to your calendar.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing, .bottom])
            
            if accessGranted {
                Picker("Event Name", selection: $selectedEventName) {
                    ForEach(eventNames, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                DatePicker("Start Date and Time", selection: $startDate)
                    .padding()
                
                Picker("Time Zone", selection: $selectedTimeZone) {
                    ForEach(timeZones) { timeZone in
                        Text(timeZone.displayName).tag(timeZone.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
               
                if self.userModel.subscriptionActive || selectedEventName == "Architecting on AWS" || selectedEventName == "Developing on AWS" {
                    Button("Add Events to Calendar") {
                        if let sequence = eventSequences[selectedEventName] {
                            if let timeZone = TimeZone(identifier: selectedTimeZone) {
                                viewModel.addEvents(sequence: sequence, startDate: startDate, timeZone: timeZone)
                               showAlert = true
                            }
                        }
                    }.padding()
                      .alert(isPresented: $showAlert) {
                           Alert(
                               title: Text("Events Added"),
                               message: Text("All your events added scucessfully. 🥳" +
                                               "Enjoy your training day")
                           )
                       }
                } else {
                   Button("Unlock Premium to Add Event") {
                      self.displayPaywall.toggle()
                   }.padding()
                }
               Spacer()
               Label {
                  VStack(alignment: .leading){
                     Text("Send Feedback")
                     Text("Feedback emails are lovely to read!\nMissing a training? Email me and I will prioritize it.").font(.footnote).opacity(0.6)
                  }
               } icon:{
                  Image(systemName: "envelope")
               }.onTapGesture {
                  let address = "mail@tig.pt"
                  let subject = "Feedback on AWSary"

                  // Example email body with useful info for bug reports
                  let body = "\n\n--\nAWSary Version: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))\n\nScreen: AAI Planner"

                  // Build the URL from its components
                  var components = URLComponents()
                  components.scheme = "mailto"
                  components.path = address
                  components.queryItems = [
                        URLQueryItem(name: "subject", value: subject),
                        URLQueryItem(name: "body", value: body)
                  ]

                  guard let email_url = components.url else {
                      NSLog("Failed to create mailto URL")
                      return
                  }
                  UIApplication.shared.open(email_url) { success in
                    // handle success or failure
                  }
               }
            } else {
               Spacer()
                Text("Requesting Calendar Access...")
                    .onAppear {
                        viewModel.requestAccess { granted in
                            accessGranted = granted
                        }
                    }
               Spacer()
            }
        }
        .sheet(isPresented: $displayPaywall) {
           PaywallView(isPresented: .constant(true))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AAIplannerContentView()
    }
}

