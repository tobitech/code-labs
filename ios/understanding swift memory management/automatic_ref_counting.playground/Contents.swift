import UIKit

// Automatic Reference Cycle
class Device {
    let model: String
    let manufacturer: String
    
    init(model: String, manufacturer: String) {
        self.model = model
        self.manufacturer = manufacturer
    }
    
    deinit {
        print("The device is about to be deallocated")
    }
}

var deviceJim: Device?
var deviceJane: Device?

deviceJim = Device(model: "iPhone", manufacturer: "Apple")
deviceJane = deviceJim

deviceJim = nil
// deviceJane = nil
