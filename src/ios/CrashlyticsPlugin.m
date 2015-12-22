#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Crashlytics/Answers.h>
#import "CrashlyticsPlugin.h"

@interface CrashlyticsPlugin ()

@property (nonatomic, strong) Crashlytics* crashlytics;

@end

@implementation CrashlyticsPlugin

#pragma mark - Initializers

- (void)pluginInitialize {
    [super pluginInitialize];

    [Fabric with:@[Crashlytics.class]];

    self.crashlytics = [Crashlytics sharedInstance];
}

- (void)logException:(CDVInvokedUrlCommand *)command {
    [self log:command];
}

- (void)log:(CDVInvokedUrlCommand *)command {
    CLSLog(@"%@", command.arguments[0]);

    [self resultOK:command];
}

- (void)setApplicationInstallationIdentifier:(CDVInvokedUrlCommand *)command {
    // no-op

    [self resultOK:command];
}

- (void)setBool:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setBoolValue:((NSNumber*)command.arguments[1]).boolValue forKey:command.arguments[0]];

    [self resultOK:command];
}

- (void)setDouble:(CDVInvokedUrlCommand *)command {
    [self setFloat:command];
}

- (void)setFloat:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setFloatValue:((NSNumber*)command.arguments[1]).floatValue forKey:command.arguments[0]];

    [self resultOK:command];
}

- (void)setInt:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setIntValue:((NSNumber*)command.arguments[1]).intValue forKey:command.arguments[0]];

    [self resultOK:command];
}

- (void)setLong:(CDVInvokedUrlCommand *)command {
    [self setInt:command];
}

- (void)setString:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setObjectValue:command.arguments[1] forKey:command.arguments[0]];

    [self resultOK:command];
}

- (void)setUserEmail:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setUserEmail:command.arguments[0]];

    [self resultOK:command];
}

- (void)setUserIdentifier:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setUserIdentifier:command.arguments[0]];

    [self resultOK:command];
}

- (void)setUserName:(CDVInvokedUrlCommand *)command {
    [self.crashlytics setUserName:command.arguments[0]];

    [self resultOK:command];
}

- (void)simulateCrash:(CDVInvokedUrlCommand *)command {
    if (command.arguments.count == 0) {
        [self.crashlytics crash];
    } else {
        [NSException raise:@"Simulated Crash" format:@"%@", command.arguments[0]];
    }

    [self resultOK:command];
}

- (void)resultOK:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

-(void)logEvent:(CDVInvokedUrlCommand *)command {
    NSString *event = nil;
    if(command.arguments.count > 0 && command.arguments[0]) event = command.arguments[0];
    NSDictionary *attrs = nil;
    if(command.arguments.count > 1 && command.arguments[1]) attrs = command.arguments[1];
    if(event && attrs)
        [Answers logCustomEventWithName:event customAttributes:attrs];
    else if(event)
        [Answers logCustomEventWithName:event customAttributes:nil];
    else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
        return;
    }
    [self resultOK:command];
}

@end
