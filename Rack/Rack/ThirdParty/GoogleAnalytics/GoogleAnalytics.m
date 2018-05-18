
//  GoogleAnalytics.m
//  InstabeeConsumer
//  Created by Saroj on 11/20/15.
//  Copyright © 2015 Instabee. All rights reserved.


#import "GoogleAnalytics.h"

@implementation GoogleAnalytics


#pragma mark -
#pragma mark -
+ (GoogleAnalytics *)sharedGoogleAnalytics
{
    static GoogleAnalytics *sharedGoogleAnalytics = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGoogleAnalytics = [[GoogleAnalytics alloc] init];
    });
    return sharedGoogleAnalytics;
}
// This method sends hits in the background until either we're told to stop background processing,
// we run into an error, or we run out of hits.  We use this to send any pending Google Analytics
// data since the app won't get a chance once it's in the background.
- (void)sendHitsInBackground {
    self.okToWait = YES;
    __weak GoogleAnalytics *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

- (void)setUpGoogleAnalytics{
    
     NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    // If your app runs for long periods of time in the foreground, you might consider turning
    // on periodic dispatching.  This app doesn't, so it'll dispatch all traffic when it goes
    // into the background instead.  If you wish to dispatch periodically, we recommend a 120
    // second dispatch interval.
    // [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].dispatchInterval = 300;
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].logger.logLevel = kGAILogLevelVerbose;
     self.tracker = [[GAI sharedInstance] trackerWithName:@"Rack" trackingId:kTrackingId];
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [googleAnalytics().tracker set:kGAISessionControl value:@"start"];
     });

}


-(void)createEventWithCategory:(NSString*)categoryType action:(NSString*)action label:(NSString*)lable onScreen:(NSString*)screen{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        /* Set the screen name on the tracker */
        if (screen.length) {
            GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
            [tracker set:kGAIScreenName value:screen];
            [tracker send:[builder build]];
        }
        /********** Measuring Events**********/
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryType action:action label:@"dispatch"  value:nil] build]];
        [[GAI sharedInstance] dispatch];
        // Clear the screen name field when we're done.
        [tracker set:kGAIScreenName value:nil];
        
    });
}


@end
GoogleAnalytics *googleAnalytics(){
    return [GoogleAnalytics sharedGoogleAnalytics];
}
