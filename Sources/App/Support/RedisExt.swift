import Redis
import Foundation

public extension RedisClient {
	/// Gets the provided key as a decodable type and deletes it from Redis.
	func getdel<D: Decodable>(_ key: RedisKey, asJSON _: D.Type) async throws -> D? {
		let data = try await send(command: "GETDEL", with: [RESPValue(from: key)]).map { Data(fromRESP: $0) }.get()

		return try data.flatMap { try JSONDecoder().decode(D.self, from: $0) }
	}

	func exists(_ key: RedisKey) async throws -> Bool {
		return try await exists(key).get() == 1
	}
}
