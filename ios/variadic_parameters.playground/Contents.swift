import UIKit

struct Message {
    let content: String
    let date: Date
}

struct Attachment {
    let type: String
    let content: Data?
}

func send(_ message: Message, attaching attachments: Attachment...) {
    print("sending message...")
}

let message = Message(content: "How are you today?", date: Date())
let imageAttachment = Attachment(type: "image", content: UIImage().pngData())
let documentAttachment = Attachment(type: "document", content: UIImage().pngData())

send(message)
print("------------------------")
send(message, attaching: imageAttachment, documentAttachment)
