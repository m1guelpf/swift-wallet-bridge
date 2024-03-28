import Vapor
import Redis

public func configure(_ app: Application) async throws {
	let redis_url = {
		if let url = Environment.get("REDIS_URL") {
			return url
		}

		guard let host = Environment.get("REDIS_HOST"),
		      let port = Environment.get("REDIS_PORT"),
		      let username = Environment.get("REDIS_USERNAME"),
		      let password = Environment.get("REDIS_PASSWORD") else
		{
			fatalError("REDIS_URL or REDIS_HOST, REDIS_PORT, REDIS_USERNAME and REDIS_PASSWORD is required.")
		}

		let connectionType = Environment.get("REDIS_USE_TLS")?.lowercased() == "true" ? "rediss" : "redis"

		return "\(connectionType)://\(username):\(password)@\(host):\(port)"
	}()

	app.redis.configuration = try RedisConfiguration(url: redis_url)

	app.middleware.use(CORSMiddleware(configuration: .init(
		allowedOrigin: .all,
		allowedMethods: [.HEAD, .GET, .POST],
		allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
	)), at: .beginning)

	try routes(app)
}
