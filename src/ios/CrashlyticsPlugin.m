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

-(NSDictionary*)flatDict:(NSDictionary*)dict withPrefix:(NSString*)prefix
{
    if(!prefix) prefix = @"";
    NSMutableDictionary *res = [NSMutableDictionary new];
    for (NSString* key in dict.allKeys) {
        id val = dict[key];
        NSString *pkey = prefix.length > 0 ? [NSString stringWithFormat:@"%@.%@", prefix, key] : key;
        if([val isKindOfClass:NSString.class]) {
            res[pkey] = val;
        } else if([val isKindOfClass:NSDictionary.class]) {
            [res addEntriesFromDictionary:[self flatDict:val withPrefix:pkey]];
        } else {
            res[pkey] = [NSString stringWithFormat:@"%@", val];
        }
    }
    return res;
}

-(void)logEvent:(CDVInvokedUrlCommand *)command {
    NSString *event = nil;
    if(command.arguments.count > 0 && command.arguments[0]) event = command.arguments[0];
    NSDictionary *attrs = nil;
    if(command.arguments.count > 1 && command.arguments[1]) {
        NSError *err = nil;
        attrs = [NSJSONSerialization JSONObjectWithData:[command.arguments[1] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
        if(err) NSLog(@"JSON Error: %@", err);
        if(![attrs isKindOfClass:NSDictionary.class]) attrs = nil;
        else attrs = [self flatDict:attrs withPrefix:nil];
    }
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
