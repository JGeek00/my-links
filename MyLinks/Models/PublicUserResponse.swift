import Foundation

enum PublicUserResponseValue: Codable, Hashable {
    case string(String)
    case user(PublicUserInfo)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }

        if let user = try? container.decode(PublicUserInfo.self) {
            self = .user(user)
            return
        }

        throw DecodingError.typeMismatch(
            PublicUserResponseValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported type"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)

        case .user(let value):
            try container.encode(value)
        }
    }
}

// MARK: - PublicUserResponse
struct PublicUserResponse: Codable, Hashable {
    let response: PublicUserResponseValue
}

// MARK: - PublicUserInfo
struct PublicUserInfo: Codable, Hashable {
    let id: Int
    let name: String?
    let username: String
    let image: String?
    let archiveAsScreenshot: Bool
    let archiveAsMonolith: Bool
    let archiveAsPDF: Bool
}
