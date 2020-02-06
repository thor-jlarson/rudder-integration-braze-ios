[![Version](https://img.shields.io/cocoapods/v/Rudder-Braze.svg?style=flat)](https://cocoapods.org/pods/Rudder-Braze)
[![Platform](https://img.shields.io/cocoapods/p/Rudder-Braze.svg?style=flat)](https://cocoapods.org/pods/Rudder-Braze)

# What is Rudder?

**Short answer:** 
Rudder is an open-source Segment alternative written in Go, built for the enterprise. .

**Long answer:** 
Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.

Released under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

## Getting Started with Braze Integration of Android SDK
1. Add [Braze](https://www.adjust.com) as a destination in the [Dashboard](https://app.rudderlabs.com/) and define ```apiToken``` and ```eventMapping```

2. Rudder-Braze is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Rudder-Braze'
```

## Initialize ```RudderClient```
Put this code in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```
```
RudderConfigBuilder *builder = [[RudderConfigBuilder alloc] init];
[builder withEndPointUrl:YOUR_DATA_PLANE_URL];
[builder withFactory:[RudderBrazeFactory instance]];
[RudderClient getInstance:YOUR_WRITE_KEY config:[builder build]];
```

## Send Events
Follow the steps from [Rudder iOS SDK](https://github.com/rudderlabs/rudder-sdk-ios)

# Coming Soon
1. Native platform SDK integration support
2. More documentation
3. More destination support
