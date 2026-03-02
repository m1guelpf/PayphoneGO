import Foundation

fileprivate let dateFormatter = tap(DateFormatter()) { formatter in
	formatter.timeZone = TimeZone(secondsFromGMT: 0)
	formatter.locale = Locale(identifier: "en_US_POSIX")
	formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
}

extension JSONEncoder {
	static let `default`: JSONEncoder = tap(JSONEncoder()) { encoder in
		encoder.dateEncodingStrategy = .formatted(dateFormatter)
	}
}

extension JSONDecoder {
	static let `default` = tap(JSONDecoder()) { decoder in
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
	}
}
