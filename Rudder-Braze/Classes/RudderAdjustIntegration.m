//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderAdjustIntegration.h"

@implementation RudderAdjustIntegration

#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config
                 withAnalytics:(nonnull RudderClient *)client
              withRudderConfig:(nonnull RudderConfig *)rudderConfig{
    self = [super init];
    if (self) {
        self.config = config;
        self.client = client;
        
        NSString *apiToken = [config objectForKey:@"appToken"];
        // create eventmap
        NSArray *eventArray = [config objectForKey:@"customMappings"];
        if (eventArray != nil && eventArray.count > 0) {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            for (NSDictionary *eventDict in eventArray) {
                NSString *from = [eventDict objectForKey:@"from"];
                NSString *to  = [eventDict objectForKey:@"to"];
                
                [tempDict setValue:to forKey:from];
            }
            self.eventMap = tempDict;
        }
        NSNumber *delayTime = [config objectForKey:@"delay"];
        double delay = 0;
        if (delayTime != nil) {
            delay = [delayTime doubleValue];
        }
        if (delay < 0) {
            delay = 0;
        } else if (delay > 10) {
            delay = 10;
        }
        
        if (apiToken != nil && ![apiToken isEqualToString:@""]) {
            NSString *environment = ADJEnvironmentProduction;
            if (rudderConfig.logLevel >= 4) {
                environment = ADJEnvironmentSandbox;
            }
            
            ADJConfig *adjustConfig = [ADJConfig configWithAppToken:apiToken environment:environment];
            [adjustConfig setLogLevel:rudderConfig.logLevel >= 4 ? ADJLogLevelVerbose : ADJLogLevelError];
            [adjustConfig setEventBufferingEnabled:YES];
            [adjustConfig setDelegate:self];
            if (delay > 0) {
                [adjustConfig setDelayStart:delay];
            }
            [Adjust appDidLaunch:adjustConfig];
        }
    }
    return self;
}

- (void)dump:(nonnull RudderMessage *)message {
    if (self.eventMap == nil) {
        return;
    }
    if([message.type isEqualToString:@"identify"]) {
        [self setPartnerParams:message];
    } else if ([message.type isEqualToString:@"track"]) {
        NSString *adjEventToken = [self.eventMap objectForKey:message.event];
        if (adjEventToken != nil) {
            [self setPartnerParams:message];
            ADJEvent *event = [[ADJEvent alloc] initWithEventToken:adjEventToken];
            NSDictionary *eventProperties = message.properties;
            if (eventProperties != nil) {
                for (NSString *key in [eventProperties allKeys]) {
                    [event addCallbackParameter:key value:[NSString stringWithFormat:@"%@", [eventProperties objectForKey:key]]];
                }
                NSNumber *total = [eventProperties objectForKey:@"revenue"];
                NSString *currency = [eventProperties objectForKey:@"currency"];
                if (total != nil && currency != nil) {
                    [event setRevenue:[total doubleValue] currency:currency];
                }
            }
            NSDictionary *userProperties = message.userProperties;
            if (userProperties != nil) {
                for (NSString *key in [userProperties allKeys]) {
                    [event addCallbackParameter:key value:[NSString stringWithFormat:@"%@", [userProperties objectForKey:key]]];
                }
            }
            [Adjust trackEvent:event];
        }
    } else if ([message.type isEqualToString:@"screen"]) {
        [RudderLogger logWarn:@"MessageType is not supported"];
    } else {
        [RudderLogger logWarn:@"MessageType is not specified"];
    }
}

-(void) setPartnerParams:(RudderMessage*) message {
    [Adjust addSessionPartnerParameter:@"anonymousId" value:message.anonymousId];
    if (message.userId != nil && ![message.userId isEqualToString:@""]) {
        [Adjust addSessionPartnerParameter:@"userId" value:message.userId];
    }
}

- (void)reset {
    [Adjust resetSessionPartnerParameters];
}

@end
