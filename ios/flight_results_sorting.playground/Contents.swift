import UIKit

struct FlightDetails: Codable {
    var amount: String?
}

var searchResults: [FlightDetails] = [
    FlightDetails(amount: "410"),
    FlightDetails(amount: "910"),
    FlightDetails(amount: "130"),
    FlightDetails(amount: "490"),
    FlightDetails(amount: "10"),
    FlightDetails(amount: "280"),
    FlightDetails(amount: "360"),
    FlightDetails(amount: "540"),
    FlightDetails(amount: "620"),
    FlightDetails(amount: "750"),
    FlightDetails(amount: "870"),
    FlightDetails(amount: "1140"),
    FlightDetails(amount: "115"),
    FlightDetails(amount: "219"),
    FlightDetails(amount: "389"),
    FlightDetails(amount: "465"),
    FlightDetails(amount: "523"),
    FlightDetails(amount: "616"),
    FlightDetails(amount: "723"),
    FlightDetails(amount: "890"),
    FlightDetails(amount: "985"),
    FlightDetails(amount: "1210")
]

var priceRanges: [Range<Double>: CGFloat] = [:]

func sortResults() {
    
    let maxPrice = searchResults.compactMap { Double($0.amount ?? "")}.max()
    guard let max = maxPrice else { return }
    let multiples = Int((max / 100).rounded(.up))
    let wholeMax = Int(max)
    
    for i in 0..<multiples {
        let startIndex = i*100
        var endIndex = (i+1)*100
        
        if endIndex == multiples - 1 {
            if wholeMax > 1 {
                endIndex = endIndex + 1
            }
        }
        
        let range = Double(startIndex)..<Double(endIndex)
        priceRanges[range] = 0
    }
    
    searchResults.forEach { flight in

        if let amount = flight.amount, let price = Double(amount) {
            for (key, _) in priceRanges {
                if key.contains(price) {
                    if let count = priceRanges[key] {
                        priceRanges[key] = count + 1
                    }
                }
            }
        } else {
            print("unable to convert \(flight.amount ?? "") to double value")
        }
    }

}

sortResults()

print(priceRanges.values)
