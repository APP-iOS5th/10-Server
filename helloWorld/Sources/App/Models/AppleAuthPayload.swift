import Vapor

struct AppleAuthPayload: Content {
    let code: String
    let id_token: String
    let user: AppleUser?
}

struct AppleUser: Content {
    let name: AppleUserName?
    let email: String?
}

struct AppleUserName: Content {
    let firstName: String?
    let lastName: String?
}
