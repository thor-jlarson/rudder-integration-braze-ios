//
//  RudderBrazeIntegration.m
//
//  Created by Raj
//

#import "RudderBrazeIntegration.h"

#import "RudderBrazeFactory.h"
@implementation RudderBrazeIntegration

#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RudderClient *)client  {
    if (self = [super init]) {
        
        self.config = config;
        self.client = client;
                
        NSString *apiToken = [config objectForKey:@"appKey"];
        if ( [apiToken length] == 0) {
          return nil;
        }
        NSMutableDictionary *appboyOptions = [[NSMutableDictionary alloc] init];
        NSString *dataCenter = [config objectForKey:@"dataCenter"];
        if ((dataCenter && [dataCenter length] != 0)) {
            NSString *customEndpoint = [dataCenter stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([@"US-01" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-01.braze.com";
            else  if([@"US-02" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-02.braze.com";
            else  if([@"US-03" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-03.braze.com";
            else  if([@"US-04" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-04.braze.com";
            else  if([@"US-06" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-06.braze.com";
            else  if([@"US-08" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.iad-08.braze.com";
            else  if([@"EU-01" isEqualToString:customEndpoint])
                appboyOptions[ABKEndpointKey] = @"sdk.fra-01.braze.eu";

        }
      
      if ([NSThread isMainThread]) {
        [Appboy startWithApiKey:apiToken
                  inApplication:[UIApplication sharedApplication]
              withLaunchOptions:nil
              withAppboyOptions:appboyOptions];
        [RudderLogger  logInfo:@"[Braze startWithApiKey:inApplication:withLaunchOptions:withAppboyOptions:]"];
      } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
          [Appboy startWithApiKey:apiToken
                    inApplication:[UIApplication sharedApplication]
                withLaunchOptions:nil
                withAppboyOptions:appboyOptions];
          [RudderLogger  logInfo:@"[Braze startWithApiKey:inApplication:withLaunchOptions:withAppboyOptions:]"];
        });
      }
    }
    
    if ([Appboy sharedInstance] != nil) {
      return self;
    } else {
      return nil;
    }
    
    
}

- (void)dump:(nonnull RudderMessage *)message {
    if([message.type isEqualToString:@"identify"]) {
        if (![NSThread isMainThread]) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [self dump:message];
          });
          return;
        }
        
        if ([message.context.traits[@"lastname"] isKindOfClass:[NSString class]]) {
          [Appboy sharedInstance].user.lastName = (NSString *) message.context.traits[@"lastname"];
           [RudderLogger logInfo:@"Identify: Braze user lastname"];
        }
        
        
        if (message.userId != nil && [message.userId length] != 0) {
          [[Appboy sharedInstance] changeUser:message.userId];
            [RudderLogger logInfo:@"Identify: Braze changeUser"];
        }
        
        
        if ([message.context.traits[@"email"] isKindOfClass:[NSString class]]) {
          [Appboy sharedInstance].user.email = (NSString *)message.context.traits[@"email"];
          [RudderLogger logInfo:@"Identify: Braze email"];
        }
        
        if ([message.context.traits[@"firstName"] isKindOfClass:[NSString class]]) {
          [Appboy sharedInstance].user.firstName = (NSString *)message.context.traits[@"firstname"];
          [RudderLogger logInfo: @"Identify: Braze  firstname"];
        }
        
        if ([message.context.traits[@"birthday"] isKindOfClass:[NSString class]]) {
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
          [dateFormatter setLocale:enUSPOSIXLocale];
          [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
          [Appboy sharedInstance].user.dateOfBirth = [dateFormatter dateFromString:(NSString *)message.context.traits[@"birthday"]];
          [RudderLogger logInfo: @"Identify: Braze  date of birth"];
        }
         
        if ([message.context.traits[@"gender"] isKindOfClass:[NSString class]]) {
          NSString *gender = (NSString *)message.context.traits [@"gender"];
          if ([gender.lowercaseString isEqualToString:@"m"] || [gender.lowercaseString isEqualToString:@"male"]) {
            [[Appboy sharedInstance].user setGender:ABKUserGenderMale];
            [RudderLogger logInfo:@"Identify: Braze  gender"];
          } else if ([gender.lowercaseString isEqualToString:@"f"] || [gender.lowercaseString isEqualToString:@"female"]) {
            [[Appboy sharedInstance].user setGender:ABKUserGenderFemale];
            [RudderLogger logInfo:@"Identify: Braze  gender"];
          }
        }
        
        if ([message.context.traits[@"phone"] isKindOfClass:[NSString class]]) {
          [Appboy sharedInstance].user.phone = (NSString *)message.context.traits[@"phone"];
          [RudderLogger logInfo:@"Identify: Braze  phone"];
        }
        
        if ([message.context.traits[@"address"] isKindOfClass:[NSDictionary class]]) {
          NSDictionary *address = (NSDictionary *) message.context.traits[@"address"];
          if ([address[@"city"] isKindOfClass:[NSString class]]) {
            [Appboy sharedInstance].user.homeCity = address[@"city"];
            [RudderLogger logInfo:@"Identify: Braze  homecity"];
          }
          
          if ([address[@"country"] isKindOfClass:[NSString class]]) {
            [Appboy sharedInstance].user.country = address[@"country"];
            [RudderLogger logInfo:@"Identify: Braze  country"];
          }
        }
        
        NSArray *appboyTraits = @[@"birthday", @"anonymousId", @"gender", @"phone", @"address", @"firstname", @"lastname", @"email"  ];
         
            
        //ignore above traits and get others - free key value pairs
        for (NSString *key in message.context.traits.allKeys) {
          if (![appboyTraits containsObject:key]) {
            id traitValue = message.context.traits[key];
            if ([traitValue isKindOfClass:[NSString class]]) {
              [[Appboy sharedInstance].user setCustomAttributeWithKey:key andStringValue:traitValue];
              [RudderLogger logInfo:@"Braze setCustomAttributeWithKey: andStringValue: "];
            } else if ([traitValue isKindOfClass:[NSDate class]]) {
              [[Appboy sharedInstance].user setCustomAttributeWithKey:key andDateValue:traitValue];
              [RudderLogger logInfo: @"Braze setCustomAttributeWithKey: andDateValue: "];
            } else if ([traitValue isKindOfClass:[NSNumber class]]) {
              if (strcmp([traitValue objCType], [@(YES) objCType]) == 0) {
                [[Appboy sharedInstance].user setCustomAttributeWithKey:key andBOOLValue:[(NSNumber *)traitValue boolValue]];
                [RudderLogger logInfo:@"Braze setCustomAttributeWithKey: andBOOLValue:"];
              } else if (strcmp([traitValue objCType], @encode(short)) == 0 ||
                         strcmp([traitValue objCType], @encode(int)) == 0 ||
                         strcmp([traitValue objCType], @encode(long)) == 0) {
                [[Appboy sharedInstance].user setCustomAttributeWithKey:key andIntegerValue:[(NSNumber *)traitValue integerValue]];
                [RudderLogger logInfo:@"Braze setCustomAttributeWithKey: andIntegerValue:"];
              } else if (strcmp([traitValue objCType], @encode(float)) == 0 ||
                         strcmp([traitValue objCType], @encode(double)) == 0) {
                [[Appboy sharedInstance].user setCustomAttributeWithKey:key andDoubleValue:[(NSNumber *)traitValue doubleValue]];
                [RudderLogger logInfo:@"Braze setCustomAttributeWithKey: andDoubleValue:"];
              } else {
                [RudderLogger logInfo:@"NSNumber could not be mapped to customAttribute"];
              }
            } else if ([traitValue isKindOfClass:[NSArray class]]) {
              [[Appboy sharedInstance].user setCustomAttributeArrayWithKey:key array:traitValue];
              [RudderLogger logInfo:@"Braze setCustomAttributeArrayWithKey: array:"];
            }
          }
        }
    } else {
        if ([message.event isEqualToString:@"Install Attributed"]) {
          if ([message.properties[@"campaign"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *attributionDataDictionary = (NSDictionary *)message.properties[@"campaign"];
            ABKAttributionData *attributionData = [[ABKAttributionData alloc]
                                                   initWithNetwork:attributionDataDictionary[@"source"]
                                                          campaign:attributionDataDictionary[@"name"]
                                                           adGroup:attributionDataDictionary[@"ad_group"]
                                                          creative:attributionDataDictionary[@"ad_creative"]];
            [[Appboy sharedInstance].user setAttributionData:attributionData];
            return;
          }
        }
        
        NSDecimalNumber *revenue = [RudderBrazeIntegration revenueDecimal:message.properties withKey:@"revenue"];
        if (revenue) {
          NSString *currency = @"USD";
            //  USD is default
          if ([message.properties[@"currency"] isKindOfClass:[NSString class]] &&
              [(NSString *)message.properties[@"currency"] length] == 3) {
              //   ISO-4217 used for currency code
            currency = (NSString *)message.properties[@"currency"];
          }
          
          if (message.properties != nil) {
            NSMutableDictionary *appboyProperties = [NSMutableDictionary dictionaryWithDictionary:message.properties];
            appboyProperties[@"currency"] = nil;
            appboyProperties[@"revenue"] = nil;
            [[Appboy sharedInstance] logPurchase:message.event inCurrency:currency atPrice:revenue withQuantity:1 andProperties:appboyProperties];
          } else {
            [[Appboy sharedInstance] logPurchase:message.event inCurrency:currency atPrice:revenue withQuantity:1];
          }
          [RudderLogger logInfo:@" Braze logPurchase: inCurrency: atPrice: withQuantity: "];
        } else {
          [[Appboy sharedInstance] logCustomEvent:message.event withProperties:message.properties];
          [RudderLogger logInfo:@"Brze logCustomEvent: withProperties: "];
        }
    }
}


+ (NSDecimalNumber *)revenueDecimal:(NSDictionary *)dictionary withKey:(NSString *)revenueKey
{
  id revenueProp  = dictionary[revenueKey];
  if (revenueProp ) {
    if ([revenueProp  isKindOfClass:[NSString class]]) {
      return [NSDecimalNumber decimalNumberWithString:revenueProp];
    } else if ([revenueProp  isKindOfClass:[NSDecimalNumber class]]) {
      return revenueProp;
    } else if ([revenueProp  isKindOfClass:[NSNumber class]]) {
      return [NSDecimalNumber decimalNumberWithDecimal:[revenueProp  decimalValue]];
    }
  }
  return nil;
}

- (void)flush
{
  [[Appboy sharedInstance] flushDataAndProcessRequestQueue];
  [RudderLogger logInfo: @"Braze flushDataAndProcessRequestQueue]"];
}

- (void)reset {
    [self flush];
    //NO BRAZE EQUIVALENT
    //[Adjust resetSessionPartnerParameters];
}
 
// Forward device token to Braze
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  [[Appboy sharedInstance] registerDeviceToken:deviceToken];
  [RudderLogger logInfo:@"Braze registerDeviceToken:"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (![[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
      [self logPushIfComesInBeforeBrazeInitializedWithIdentifier:nil];
    }
  });
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo {
  if (![self logPushIfComesInBeforeBrazeInitializedWithIdentifier:nil]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[Appboy sharedInstance] registerApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
    });
  }
   [RudderLogger logInfo:@"Braze registerApplication: didReceiveRemoteNotification:"];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
  if (![self logPushIfComesInBeforeBrazeInitializedWithIdentifier:identifier]) {
    [[Appboy sharedInstance] getActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:nil];
  }
   [RudderLogger logInfo:@"Braze getActionWithIdentifier: forRemoteNotification: completionHandler:"];
}

- (BOOL) logPushIfComesInBeforeBrazeInitializedWithIdentifier:(NSString *)identifier {
  NSDictionary *pushDictionary = [[RudderBrazeFactory instance] getPushPayload];
  if (pushDictionary != nil && pushDictionary.count > 0) {
    /*
    MIRATE TO USERNOTIFICATIONS - WHOLE OF THIS IS DEPRECATED
    //handle push before braze is initalised
    if ([[Appboy sharedInstance] respondsToSelector:@selector(handleRemotePushNotification:withIdentifier:completionHandler:applicationState:)]) {
      
        [[Appboy sharedInstance]  handleRemotePushNotification:pushDictionary
                                             withIdentifier:identifier
                                          completionHandler:nil
                                           applicationState:UIApplicationStateInactive];
    }
    */
    [[RudderBrazeFactory instance] putRemoteNotification:nil];
   
      
    return YES;
  }
  return NO;
}

@end
