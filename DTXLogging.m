//
//  DTLogging.m
//  DTXLoggingInfra
//
//  Created by Leo Natan (Wix) on 19/07/2017.
//  Copyright © 2017 Wix. All rights reserved.
//

@import Foundation;
#import "DTXLogging.h"

void __dtx_log(os_log_t log, os_log_type_t logType, NSString* prefix, NSString* format, ...)
{
	va_list argumentList;
	va_start(argumentList, format);
	__dtx_logv(log, logType, prefix, format, argumentList);
	va_end(argumentList);
}

void __dtx_logv(os_log_t log, os_log_type_t logType, NSString* prefix, NSString* format, va_list args)
{
	NSString* message = [[NSString alloc] initWithFormat:format arguments:args];
	
	os_log_with_type(log, logType, "%{public}s%{public}s", prefix.UTF8String, message.UTF8String);
}
