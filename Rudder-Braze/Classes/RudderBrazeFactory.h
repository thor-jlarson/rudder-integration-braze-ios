//
//  RudderBrazeFactory.h 
//
//  Created by Raj
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import "RudderBrazeIntegration.h"
NS_ASSUME_NONNULL_BEGIN

@interface RudderBrazeFactory : NSObject<RSIntegrationFactory>

+ (instancetype) instance;

- (void) putLaunchOptions:(NSDictionary *)launchOpts;
- (void) putRemoteNotification:(NSDictionary *)remoteNotif;
- (void)resetRemoteNotification;

- (NSDictionary *) getPushPayload ;
@property NSDictionary *pushPayload;
@end

NS_ASSUME_NONNULL_END
