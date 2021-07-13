//
//  AppDelegate.m
//  CourtFinder
//
//  Created by Sebastian Saldana Cardenas on 12/07/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *parseConfig = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        configuration.applicationId = @"7LPddIsUoywmDmiFTrKkNDltMtcGdXUiFET3wsRm";
        configuration.clientKey = @"11qSuPOvj3zChC6n9rz8KBONpCmtDvMz7qy8E3rR";
        configuration.server = @"https://parseapi.back4app.com";
    }];
    [Parse initializeWithConfiguration:parseConfig];
    [GMSPlacesClient provideAPIKey:@"AIzaSyDulKwf5yAA5noc_qcyoUA06MmF5OtPntQ"];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
