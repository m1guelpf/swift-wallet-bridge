import Vapor

struct RequestController {
	struct CreateResponse: Content {
		var request_id: UUID
	}

	func create(req: Request) async throws -> CreateResponse {
		let request_id = UUID()
		req.logger.info("Processing /request")

		try await req.redis.setex(
			"\(REQ_STATUS_PREFIX)\(request_id)",
			toJSON: BridgeRequest.Status.initialized,
			expirationInSeconds: EXPIRE_AFTER_SECONDS
		).get()

		try await req.redis.setex(
			"\(REQ_PREFIX)\(request_id)",
			toJSON: req.content.decode(BridgeRequest.self),
			expirationInSeconds: EXPIRE_AFTER_SECONDS
		).get()

		req.logger.info("Successfully processed /request")

		return CreateResponse(request_id: request_id)
	}

	func show(req: Request) async throws -> BridgeRequest {
		let request_id = req.parameters.get("request_id")!

		guard let bridge_data = try await req.redis.getdel("\(REQ_PREFIX)\(request_id)", asJSON: BridgeRequest.self) else {
			throw Abort(.notFound)
		}

		try await req.redis.setex(
			"\(REQ_STATUS_PREFIX)\(request_id)",
			toJSON: BridgeRequest.Status.retrieved,
			expirationInSeconds: EXPIRE_AFTER_SECONDS
		).get()

		return bridge_data
	}

	func exists(req: Request) async throws -> Response {
		let request_id = req.parameters.get("request_id")!
		let exists = try await req.redis.exists("\(REQ_STATUS_PREFIX)\(request_id)")

		return Response(status: exists ? .ok : .notFound)
	}
}
