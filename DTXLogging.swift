//
//  DTXLogging.swift
//  DTXLoggingInfra
//
//  Created by Leo Natan (Wix) on 5/3/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

import os.log
import Darwin

public class DetoxLog {
	private let prefix : String
	public let osLog : OSLog

	public convenience init(category: String, prefix: String = "") {
		self.init(_subsystem: nil, category: category, prefix: prefix)
	}

	public convenience init(subsystem: String, category: String, prefix: String = "") {
		self.init(_subsystem: subsystem, category: category, prefix: prefix)
	}

	fileprivate init(_subsystem subsystem: String?, category: String, prefix: String) {
		var _subsystem = subsystem
		if _subsystem == nil {
			//Try to read the subsystem from ObjC
			let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
			guard let sym = dlsym(RTLD_DEFAULT, "__dtx_log_get_subsystem") else {
				fatalError("No subsystem provided and no Objective C subsystem exists")
			}
			typealias ff = @convention(c) () -> String
			let f = unsafeBitCast(sym, to: ff.self)
			_subsystem = f()
		}

		self.prefix = prefix
		if _subsystem == nil {
			osLog = OSLog.default
		} else {
			osLog = OSLog(subsystem: _subsystem!, category: category)
		}
	}

	public func debug(_ message: @autoclosure () -> String) {
		log(message(), type: .debug)
	}

	public func info(_ message: @autoclosure () -> String) {
		log(message(), type: .info)
	}

	public func error(_ message: @autoclosure () -> String) {
		log(message(), type: .error)
	}

	public func fault(_ message: @autoclosure () -> String) {
		log(message(), type: .fault)
	}

	private func log(_ message: @autoclosure () -> String, type: OSLogType) {
		guard osLog.isEnabled(type: type) else {
			return
		}

		let message = message()

		// Split the message into parts if it's longer than a certain threshold
		let maxLength = 512 // based on truncation behavior
		if message.count > maxLength {
			let parts = stride(from: 0, to: message.count, by: maxLength).map { startIndex -> Substring in
				let start = message.index(message.startIndex, offsetBy: startIndex)
				let endOffset = min(startIndex + maxLength, message.count)
				let end = message.index(message.startIndex, offsetBy: endOffset)
				return message[start..<end]
			}

			// Message about splitting the message
			os_log("Message was too long and was split into %{public}d parts", 
						 log: osLog, type: type, parts.count)

			for (index, part) in parts.enumerated() {
				os_log("Part %{public}d/%{public}d: %{public}s%{public}s",
							 log: osLog, type: type, index + 1, parts.count, prefix, String(part))
			}
		} else {
			os_log("%{public}s%{public}s", log: osLog, type: type, prefix, message)
		}
	}
}
