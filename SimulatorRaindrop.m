//
//  SVSimulatorRaindrop.m
//  iOS Simulator Raindrop
//
//  Created by Sam Vermette on 31.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SimulatorRaindrop.h"

#define kWindowSizePhone CGSizeMake(396,744)
#define kWindowSizePhoneLandscape CGSizeMake(744,396)
#define kWindowSizePhoneRetina CGSizeMake(752,1072)
#define kWindowSizePhoneRetinaLandscape CGSizeMake(1072,752)
#define kWindowSizePhoneRetina50 CGSizeMake(434,616)
#define kWindowSizeTablet CGSizeMake(880,1136)
#define kWindowSizeTabletLandscape CGSizeMake(1136,880)

#define kViewRectPhone CGRectMake(38,126,320,480)
#define kViewRectPhoneLandscape CGRectMake(132,32,480,320)
#define kViewRectPhoneRetina CGRectMake(56,50,640,960)
#define kViewRectPhoneRetinaLandscape CGRectMake(56,50,960,640)
#define kViewRectPhoneRetina50 CGRectMake(57,57,320,480)
#define kViewRectTablet CGRectMake(56,50,768,1024)
#define kViewRectTabletLandscape CGRectMake(56,50,1024,768)

@implementation SimulatorRaindrop

- (NSString *)pasteboardNameForTriggeredRaindrop {
	
	CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
	
	for(NSDictionary *entry in (NSArray*)windowList) {
		
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
		
		if(applicationName != NULL && [applicationName isEqualToString:@"iOS Simulator"]) {
			
			CGWindowID windowID = [[entry objectForKey:(id)kCGWindowNumber] unsignedIntValue];
			NSLog(@"%@ (%i)", applicationName, windowID);
			
			CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowID, kCGWindowImageDefault);
			CGSize windowSize = CGSizeMake(CGImageGetWidth(windowImage), CGImageGetHeight(windowImage));
			CGRect cropRect = CGRectNull;
            
            NSLog(@"windowSize = %@", NSStringFromSize(windowSize));
			
			if(CGSizeEqualToSize(windowSize, kWindowSizePhone))
				cropRect = kViewRectPhone;
			else if(CGSizeEqualToSize(windowSize, kWindowSizePhoneLandscape))
				cropRect = kViewRectPhoneLandscape;
			else if(CGSizeEqualToSize(windowSize, kWindowSizePhoneRetina))
				cropRect = kViewRectPhoneRetina;
			else if(CGSizeEqualToSize(windowSize, kWindowSizePhoneRetinaLandscape))
				cropRect = kViewRectPhoneRetinaLandscape;
			else if(CGSizeEqualToSize(windowSize, kWindowSizeTablet))
				cropRect = kViewRectTablet;
			else if(CGSizeEqualToSize(windowSize, kWindowSizeTabletLandscape))
				cropRect = kViewRectTabletLandscape;
            else if(CGSizeEqualToSize(windowSize, kWindowSizePhoneRetina50))
				cropRect = kViewRectPhoneRetina50;
            
            //NSLog(@"cropRect = %@", NSStringFromRect(cropRect));
			
			if(!CGRectIsNull(cropRect)) {
				
				NSString *plistPath = [NSString stringWithFormat:@"%@/Library/Preferences/com.apple.screencapture.plist", NSHomeDirectory()];
				NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
                NSString *savePath = [plistData valueForKeyPath:@"location"];
                
                if(!savePath) {
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
                    savePath = [paths objectAtIndex:0];
                }

				NSString *screenshotPath = [NSString stringWithFormat:@"%@/iOS Screenshot %@.png", savePath, [NSDate date]];
				
				NSURL *tempURL = [NSURL fileURLWithPath:screenshotPath];
				CGImageRef croppedImage = CGImageCreateWithImageInRect(windowImage, cropRect);
				CGImageRelease(windowImage);
				
				CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)tempURL, kUTTypePNG, 1, NULL);
				CGImageDestinationAddImage(imageDestination, croppedImage, NULL);
				CGImageDestinationFinalize(imageDestination);
				CGImageRelease(croppedImage);
                
                //NSLog(@"savePath = %@", screenshotPath);
				
				NSData *imageData = [NSData dataWithContentsOfFile:screenshotPath];
				
				NSPasteboard *pasteboard = [NSPasteboard pasteboardWithUniqueName];
				NSPasteboardItem *item = [[[NSPasteboardItem alloc] init] autorelease];
				[item setData:imageData forType:(NSString *)kUTTypePNG];
				[item setString:@"simulator.png" forType:@"public.url-name"];
				[pasteboard writeObjects:[NSArray arrayWithObject:item]];
				
				return [pasteboard name];
			}
		}
	}
	
	return nil;
}

@end
