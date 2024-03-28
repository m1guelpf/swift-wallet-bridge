import Vapor
import Foundation

struct ServerInfo: Content {
	var repo_url = URL(string: "https://github.com/worldcoin/wallet-bridge")!
}
