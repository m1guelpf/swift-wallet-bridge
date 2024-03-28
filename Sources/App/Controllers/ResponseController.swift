import Vapor

struct ResponseController {
	struct BridgeResponse: Content {
		var response: BridgeRequest?
		var status: BridgeRequest.Status
	}

	func create(req: Request) async throws -> Response {
		let request_id = req.parameters.get("request_id")!

		// Check the request is valid
		if try !(await req.redis.exists("\(REQ_STATUS_PREFIX)\(request_id)")) {
			throw Abort(.badRequest)
		}

		// Check the response has not been set already
		if try await req.redis.exists("\(RES_PREFIX)\(request_id)") {
			throw Abort(.conflict)
		}

		// Store the response
		try await req.redis.setex(
			"\(RES_PREFIX)\(request_id)",
			toJSON: req.content.decode(BridgeRequest.self),
			expirationInSeconds: EXPIRE_AFTER_SECONDS
		)

		// We can delete the status at this point as the presence of a response implies the request is complete
		let _ = try await req.redis.delete("\(REQ_STATUS_PREFIX)\(request_id)").get()

		return Response(status: .created)
	}

	func show(req: Request) async throws -> BridgeResponse {
		let request_id = req.parameters.get("request_id")!

		if let bridge_data = try await req.redis.getdel("\(RES_PREFIX)\(request_id)", asJSON: BridgeRequest.self) {
			return BridgeResponse(response: bridge_data, status: .completed)
		}

		guard let req_status = try await req.redis.get("\(REQ_STATUS_PREFIX)\(request_id)", asJSON: BridgeRequest.Status.self) else {
			throw Abort(.notFound)
		}

		return BridgeResponse(response: nil, status: req_status)
	}
}
