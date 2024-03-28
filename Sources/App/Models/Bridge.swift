import Vapor

struct BridgeRequest: Content {
	enum Status: String, Codable {
		/// The request has been initiated by the client
		case initialized
		/// The request has been retrieved by World App
		case retrieved
		/// The request has received a response from World App
		case completed
	}

	/// The initialization vector for the encrypted payload
	var iv: String
	/// The encrypted payload
	var payload: String
}
