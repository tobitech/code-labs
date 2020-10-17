import Foundation

guard let url = Bundle.main.url(forResource: "darksky", withExtension: "json") else { fatalError() }

guard let data = try? Data(contentsOf: url) else { fatalError() }

let decoder = JSONDecoder()

do {
    let response = try decoder.decode(DarkSkyResponse.self, from: data)
    
    print(response.currently)
    print(response.daily.data.count)
    
} catch let err {
    print(err)
}
