import UIKit

class UserSession {
    static let shared = UserSession()
    var userID: UUID?
    var username: String?
    
    private init() {}
}
