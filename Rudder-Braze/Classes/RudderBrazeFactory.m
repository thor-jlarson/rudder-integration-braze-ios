//
//  RudderBrazeFactory.m 
//
//  Created by Raj.
//

#import "RudderBrazeFactory.h"

@implementation RudderBrazeFactory

static RudderBrazeFactory *sharedInstance;

NSString *const RSBrazeExternalIdKey = @"brazeExternalId";
NSString *const RSBrazeKey = @"Braze";

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return RSBrazeKey;
}

- (id <RSIntegration>) initiate: (NSDictionary*) config client:(RSClient*) client rudderConfig:(nonnull RSConfig *)rudderConfig{
    return [[RudderBrazeIntegration alloc] initWithConfig:config withAnalytics:client rudderConfig: rudderConfig];
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

- (void)resetRemoteNotification{
    self.pushPayload = @{};
}
 

- (NSDictionary *) getPushPayload {
  return self.pushPayload;
}
@end
