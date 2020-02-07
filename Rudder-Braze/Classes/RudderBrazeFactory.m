//
//  RudderBrazeFactory.m 
//
//  Created by Raj.
//

#import "RudderBrazeFactory.h"

@implementation RudderBrazeFactory

static RudderBrazeFactory *sharedInstance;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return @"BRAZE";
}

- (id <RudderIntegration>) initiate: (NSDictionary*) config client:(RudderClient*) client{
    return [[RudderBrazeIntegration alloc] initWithConfig:config withAnalytics:client ];
}

- (void) putLaunchOptions:(NSDictionary *)launchOpts {
  NSDictionary *payload = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey];
  if (payload != nil && payload.count > 0) {
    self.pushPayload = [payload copy];
  }
}

- (void) putRemoteNotification:(NSDictionary *)userInfo {
  self.pushPayload = [userInfo copy];
}
 

- (NSDictionary *) getPushPayload {
  return self.pushPayload;
}
@end
