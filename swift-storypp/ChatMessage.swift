import Foundation

class ChatMessage
{
    var username: String
    var message: String
    
    init(username: String, message: String)
    {
        self.username = username
        self.message = message
    }
}
