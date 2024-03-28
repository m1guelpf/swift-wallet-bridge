import Vapor

func routes(_ app: Application) throws {
	app.get { _ in ServerInfo() }

	app.group("request") { request in
		request.post(use: RequestController().create)

		request.group(":request_id") { group in
			group.get(use: RequestController().show)
			group.on(.HEAD, use: RequestController().exists)
		}
	}

	app.group("response", ":request_id") { group in
		group.get(use: ResponseController().show)
		group.put(use: ResponseController().create)
	}
}
