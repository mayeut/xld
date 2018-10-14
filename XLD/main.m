//
//  main.m
//  XLD @ sourceforge
//
//  Created by tmkk on 06/06/08.
//  Copyright tmkk 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XLDCustomClasses.h"
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
#import <objc/runtime.h>
#endif

extern int cmdline_main(int argc, char *argv[]);
int XLDDarkModeSupportEnabled;

int main(int argc, char *argv[])
{
	if(argc > 1 && !strncmp(argv[1],"--cmdline",9)) {
#if MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_5
		[XLDBundle poseAsClass:[NSBundle class]];
#else
		Method fromMethod = class_getInstanceMethod([NSBundle class],@selector(infoDictionary));
		Method toMethod   = class_getInstanceMethod([NSBundle class],@selector(mod_infoDictionary));
		method_exchangeImplementations(fromMethod, toMethod);
#endif
		return cmdline_main(argc,argv);
	}
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
	if(floor(NSAppKitVersionNumber) > 1561) {
		NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
		BOOL darkModeEnabled = [pref boolForKey:@"DarkModeSupport"];
		id modeSpecifiedByLocalPlist = [pref objectForKey:@"NSRequiresAquaSystemAppearance"];
		if(modeSpecifiedByLocalPlist) {
			if([modeSpecifiedByLocalPlist boolValue] == NO) {
				/* force enabled by local preference .plist */
				[pref setBool:YES forKey:@"DarkModeSupport"];
				darkModeEnabled = YES;
			}
			[pref removeObjectForKey:@"NSRequiresAquaSystemAppearance"];
		}
		if(darkModeEnabled) {
			Method fromMethod = class_getInstanceMethod([NSBundle class],@selector(infoDictionary));
			Method toMethod   = class_getInstanceMethod([NSBundle class],@selector(mod_infoDictionary2));
			method_exchangeImplementations(fromMethod, toMethod);
			XLDDarkModeSupportEnabled = 1;
			[pref registerDefaults:@{@"NSLayerPerformanceUpdates": @(YES)}];
		}
	}
#endif
    return NSApplicationMain(argc,  (const char **) argv);
}
