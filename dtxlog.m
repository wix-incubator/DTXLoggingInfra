//
//  main.m
//  dtxlog
//
//  Created by Leo Natan (Wix) on 11/5/18.
//  Copyright © 2018 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DTX_LOG_SUBSYSTEM ""
#import "DTXLogging.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
//		if(argc != 3)
//		{
//			return -1;
//		}
		
		os_log_t __current_file_log = os_log_create("ZZZ", "AAA");
		NSString* __current_log_prefix = @"";
		dtx_log_info(@"test");
		dtx_log_fault(@"test2");
	}
	return 0;
}
