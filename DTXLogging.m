//
//  DTLogging.m
//  DTXLoggingInfra
//
//  Created by Leo Natan (Wix) on 19/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

@import Foundation;
#import "DTXLogging.h"

#ifdef DTX_LOG_SUBSYSTEM
NSString* __dtx_log_get_subsystem(void)
{
	return @DTX_LOG_SUBSYSTEM;
}
#endif

void __dtx_log(os_log_t log, os_log_type_t logType, NSString* prefix, NSString* format, ...)
{
	if(os_log_type_enabled(log, logType) == false)
	{
		return;
	}
	
	va_list argumentList;
	va_start(argumentList, format);
	__dtx_logv(log, logType, prefix, format, argumentList);
	va_end(argumentList);
}

void __dtx_logv(os_log_t log, os_log_type_t logType, NSString* prefix, NSString* format, va_list args)
{
	if(os_log_type_enabled(log, logType) == false)
	{
		return;
	}
	
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

	// Split the message into parts if it's longer than this threshold
	const NSUInteger maxLength = 512; // based on truncation behavior
	if (message.length > maxLength) {
		NSMutableArray *parts = [NSMutableArray array];

		for (NSUInteger startIndex = 0; startIndex < message.length; startIndex += maxLength) {
			NSRange range = NSMakeRange(startIndex, MIN(maxLength, message.length - startIndex));
			NSString *part = [message substringWithRange:range];
			[parts addObject:part];
		}

		// Message about splitting the message
		os_log_with_type(
			log,
			logType,
			"Message was too long and was split into %{public}lu parts",
			(unsigned long)parts.count
		);

		[parts enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
			os_log_with_type(
				log,
				logType,
				"Part %{public}lu/%{public}lu: %{public}s%{public}s",
				(unsigned long)(idx + 1),
				(unsigned long)parts.count,
				[prefix UTF8String],
				[part UTF8String]
			);
		}];
	} else {
		os_log_with_type(log, logType, "%{public}s%{public}s", [prefix UTF8String], [message UTF8String]);
	}
}
