
//  GoogleAnalytics.h
//  InstabeeConsumer
//  Created by Saroj on 11/20/15.
//  Copyright © 2015 Instabee. All rights reserved.


#import <Foundation/Foundation.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
//client
static NSString *const kTrackingId    = @"UA-84679209-1";
//dev
//static NSString *const kTrackingId    = @"UA-57079343-1";
static NSString *const kAllowTracking = @"allowTracking";

@interface GoogleAnalytics : NSObject

@property (nonatomic, strong) id<GAITracker>            tracker;
// Used for sending Google Analytics traffic in the background.
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);
+ (GoogleAnalytics *)sharedGoogleAnalytics;
- (void)setUpGoogleAnalytics;
- (void)sendHitsInBackground;
-(void)createEventWithCategory:(NSString*)categoryType action:(NSString*)category label:(NSString*)lable onScreen:(NSString*)screen;

@end
GoogleAnalytics *googleAnalytics();
