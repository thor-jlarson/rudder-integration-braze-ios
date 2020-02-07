//
//  RudderBrazeIntegration.h
//
//  Created by Raj
//

#import <Foundation/Foundation.h>
#import "RudderIntegration.h"
#import "RudderClient.h"
#if defined(__has_include) && __has_include(<Appboy_iOS_SDK/AppboyKit.h>)
#import <Appboy_iOS_SDK/AppboyKit.h>
#import <Appboy_iOS_SDK/ABKUser.h>
#import <Appboy_iOS_SDK/ABKAttributionData.h>
#else
#import "Appboy-iOS-SDK/AppboyKit.h"
#import "Appboy-iOS-SDK/ABKUser.h"
#import "Appboy-iOS-SDK/ABKAttributionData.h"
#endif
#import <RudderSDKCore/RudderLogger.h>
 
NS_ASSUME_NONNULL_BEGIN

@interface RudderBrazeIntegration : NSObject<RudderIntegration>

@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) RudderClient *client; 

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RudderClient *)client rudderConfig:(nonnull RudderConfig *)rudderConfig ;

@end

NS_ASSUME_NONNULL_END
