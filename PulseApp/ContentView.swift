import SwiftUI
import HealthKit

class HeartRateManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRate: Double = 0.0
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit unavailable")
            return
        }
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
            if success {
                self.startHeartRateQuery()
            }
            else {
                print("error")
            }
        }
    }
    
    func startHeartRateQuery() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) {
            _, completionHandler, _ in
            self.fetchLatestHeartRate()
            completionHandler()
        }
        healthStore.execute(query)
    }
    
    func fetchLatestHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: nil) {
            _, results, _ in
            if let sample = results?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        healthStore.execute(query)
    }
    
}

struct ContentView: View {
    @StateObject private var heartRateManager = HeartRateManager()
    var body: some View {
            VStack {
                Text("Pulse:")
                    .font(.title)
                    .padding(.top, 10)
                Text("\(Int(heartRateManager.heartRate))")
                    .font(.system(size: 70))
                    .bold()
                    .foregroundColor(.red)
            }
            .frame(width: 150, height: 150)
        }
}
