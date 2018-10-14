//
//  XLDPluginManager.m
//  XLD
//
//  Created by tmkk on 11/08/18.
//  Copyright 2011 tmkk. All rights reserved.
//

#import "XLDPluginManager.h"
#import "XLDCustomClasses.h"

@implementation XLDPluginManager

- (id)init
{
	[super init];
	plugins = [[NSMutableArray alloc] init];
	NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *bundleArr = [fm directoryContentsAt:[@"~/Library/Application Support/XLD/PlugIns" stringByExpandingTildeInPath]];
	int i;
	NSBundle *bundle = nil;
	
	for(i=0;i<[bundleArr count];i++) {
		BOOL isDir = NO;
		NSString *bundlePath = [[@"~/Library/Application Support/XLD/PlugIns" stringByExpandingTildeInPath] stringByAppendingPathComponent:[bundleArr objectAtIndex:i]];
		if([fm fileExistsAtPath:bundlePath isDirectory:&isDir] && isDir && [[bundlePath pathExtension] isEqualToString:@"bundle"]) {
			bundle = [NSBundle bundleWithPath:bundlePath];
			if(bundle) {
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
				NSArray *archArray = [bundle executableArchitectures];
#if defined(__x86_64__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitectureX86_64)] == NSNotFound) continue;
#elif defined(__i386__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitectureI386)] == NSNotFound) continue;
#elif defined(__ppc__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitecturePPC)] == NSNotFound) continue;
#endif
#endif
				if(![[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]) continue;
				[dic setObject:bundlePath forKey:[[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]];
				//NSLog(@"%@",[[bundle infoDictionary] description]);
				//NSLog(@"loaded:%d",[bundle isLoaded]);
			}
		}
	}
	
	bundleArr = [fm directoryContentsAt:[[NSBundle mainBundle] builtInPlugInsPath]];
	for(i=0;i<[bundleArr count];i++) {
		BOOL isDir = NO;
		NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:[bundleArr objectAtIndex:i]];
		if([fm fileExistsAtPath:bundlePath isDirectory:&isDir] && isDir && [[bundlePath pathExtension] isEqualToString:@"bundle"]) {
			bundle = [NSBundle bundleWithPath:bundlePath];
			if(bundle) {
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
				NSArray *archArray = [bundle executableArchitectures];
#if defined(__x86_64__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitectureX86_64)] == NSNotFound) continue;
#elif defined(__i386__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitectureI386)] == NSNotFound) continue;
#elif defined(__ppc__)
				if([archArray indexOfObject:@(NSBundleExecutableArchitecturePPC)] == NSNotFound) continue;
#endif
#endif
				if(![[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]) continue;
				if([dic objectForKey:[[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]]) continue;
				[dic setObject:bundlePath forKey:[[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]];
				//NSLog(@"%@",[[bundle infoDictionary] objectForKey:@"NSPrincipalClass"]);
				//NSLog(@"loaded:%d",[bundle isLoaded]);
			}
		}
	}
	
	[plugins addObjectsFromArray:[[dic allValues]sortedArrayUsingSelector:@selector(compare:)]];
	
	//NSLog(@"%@",[plugins description]);
	
	return self;
}

- (void)dealloc
{
	[plugins release];
	[super dealloc];
}

- (NSArray *)plugins
{
	return plugins;
}

@end
