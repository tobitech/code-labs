import NIO
import WebsiteBuilder

/// All idioms the app can respond with
let idioms = [
    "A blessing in disguise",
    "Better late than never",
    "Bite the bullet",
    "Break a leg",
    "Cutting corners",
    "Get your act together",
    "That's the last straw",
    "You can say that again"
]

/// Responds to the request with a random idiom chosen from the list above
struct IdiomResponder: HTTPResponder {
    func respond(to request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        guard let randomIdiom = idioms.randomElement() else {
            return request.eventLoop.newFailedFuture(error: Error.noIdiomsAvailable)
        }
        
        let response = HTTPResponse(status: .ok, body: HTTPBody(text: randomIdiom))
        return request.eventLoop.newSucceededFuture(result: response)
    }
    
    enum Error: Swift.Error {
        /// This error occurs if the idiom list is empty
        case noIdiomsAvailable
    }
}

/// Creates a new website responding with the IdiomResponder
let website = Website(responder: IdiomResponder())

/// Runs the website at the default port
try website.run(port: 8123)
