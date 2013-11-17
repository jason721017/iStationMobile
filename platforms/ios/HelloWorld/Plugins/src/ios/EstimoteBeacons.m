#import <Cordova/CDV.h>
#import "EstimoteBeacons.h"
#import "ESTBeaconManager.h"
#import "AppDelegate.h"

@interface EstimoteBeacons () <ESTBeaconManagerDelegate,ESTBeaconDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;


@end


@implementation EstimoteBeacons

- (EstimoteBeacons*)pluginInitialize
{
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // create sample region object (you can additionaly pass major / minor values)
   // self.currentRegion = [[ESTBeaconRegion alloc] initRegionWithMajor:30 minor:10 identifier: @"EstimoteSampleRegion"];
    self.currentRegion = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    self.currentRegion.notifyEntryStateOnDisplay=true;
    self.currentRegion.notifyOnEntry=true;
    self.currentRegion.notifyOnExit=true;
    // region watchers
    self.regionWatchers = [[NSMutableDictionary alloc] init];
    
    
    [self.beaconManager startMonitoringForRegion:self.currentRegion];
    
    [self.beaconManager requestStateForRegion:self.currentRegion];
    NSLog(@"Initialize");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"Initialize %@",appDelegate.deviceToken);
    
    
    return self;
}
#pragma mark - Get beacons methods
- (void)getMyDeviceToken:(CDVInvokedUrlCommand*)command
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:appDelegate.deviceToken];
    


   [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}
#pragma mark - Start monitoring methods

- (void)startEstimoteBeaconsDiscoveryForRegion:(CDVInvokedUrlCommand*)command {
    // stop existing discovery/ranging
    [self.beaconManager stopEstimoteBeaconDiscovery];
    [self.beaconManager stopRangingBeaconsInRegion:self.currentRegion];
    
    // start discovery
    [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.currentRegion];
    
    // respond to JS with OK
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}


- (void)startRangingBeaconsInRegion:(CDVInvokedUrlCommand*)command {
    
    self.beaconManager.avoidUnknownStateBeacons = YES;
    // stop existing discovery/ranging
    [self.beaconManager stopEstimoteBeaconDiscovery];
    [self.beaconManager stopRangingBeaconsInRegion:self.currentRegion];
    
    // start ranging
    [self.beaconManager startRangingBeaconsInRegion:self.currentRegion];
    
    // respond to JS with OK
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)startMonitoringForRegion:(CDVInvokedUrlCommand*)command
{

    NSInteger major = [[command.arguments objectAtIndex:0] intValue];
    NSInteger minor = [[command.arguments objectAtIndex:1] intValue];
    NSString* regionid = [command.arguments objectAtIndex:2];
   // NSString* regionid=@"EstimoteSampleRegion";
    
    if([self.regionWatchers objectForKey:regionid] != nil) {
          NSLog(@"startMonitoringForRegion1");
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Region with given ID is already monitored."] callbackId:command.callbackId];
    } else {
          NSLog(@"startMonitoringForRegion2");
        //ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithMajor:1 minor:1 identifier: regionid];
       // ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithMajor:30 minor:10 identifier: @"EstimoteSampleRegion"];
        ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithMajor:major minor:minor identifier:regionid];
        
        [self.beaconManager startMonitoringForRegion:region];
        [self.beaconManager requestStateForRegion:region];
        
        [self.regionWatchers setObject:command.callbackId  forKey:@"EstimoteSampleRegion"];
    }

}

#pragma mark - Stop monitoring methods

- (void)stopEsimoteBeaconsDiscoveryForRegion:(CDVInvokedUrlCommand*)command {
    // stop existing discovery/ranging
    [self.beaconManager stopEstimoteBeaconDiscovery];
    
    // respond to JS with OK
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)stopRangingBeaconsInRegion:(CDVInvokedUrlCommand*)command {
    // stop existing discovery/ranging
    [self.beaconManager stopRangingBeaconsInRegion:self.currentRegion];
    
    // respond to JS with OK
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}


- (void)stopMonitoringForRegion:(CDVInvokedUrlCommand*)command
{
    NSString* regionid = [command.arguments objectAtIndex:0];
    ESTBeaconRegion* regionFound = nil;
    
    //    for(ESTBeaconRegion* region in self.regionWatchers) {
    //        if([region.identifier compare:regionid]) {
    //            regionFound = region;
    //            break;
    //        }
    //    }
    //
    //    if(regionFound != nil) {
    //        [self.beaconManager stopMonitoringForRegion:regionFound];
    //
    //        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    //    } else {
    //        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Region with given ID not found."] callbackId:command.callbackId];
    //    }
}

#pragma mark - Get beacons methods
- (void)getBeacons:(CDVInvokedUrlCommand*)command
{

   
    [self.commandDelegate runInBackground:^{
        NSMutableArray* output = [NSMutableArray array];
      
        if([self.beacons count] > 0)
        {
           
            //convert list of beacons to a an array of simple property-value objects
            for (id beacon in self.beacons) {
                [output addObject:[self beaconToDictionary:beacon]];
            }
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:output];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)getBeaconByIdx:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSInteger idx = [[command.arguments objectAtIndex:0] intValue];
    
    if (idx < [self.beacons count] && idx >= 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:[self beaconToDictionary:[self.beacons objectAtIndex:idx]]];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid index."];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getClosestBeacon:(CDVInvokedUrlCommand*)command
{
    if ([self.beacons count] > 0) {
        [self.commandDelegate runInBackground:^{
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                 messageAsDictionary:[self beaconToDictionary:[self.beacons objectAtIndex:0]]]
                                        callbackId:command.callbackId];
        }];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
}

- (void)getConnectedBeacon:(CDVInvokedUrlCommand*)command
{
    if(self.connectedBeacon != nil) {
        [self.commandDelegate runInBackground:^{
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                 messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]] callbackId:command.callbackId];
        }];
    } else {
        //no connected beacons
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There are no connected beacons."] callbackId:command.callbackId];
    }
}
#pragma mark - Virtual Beacon methods

- (void)startVirtualBeacon:(CDVInvokedUrlCommand*)command
{
    NSInteger major = [[command.arguments objectAtIndex:0] intValue];
    NSInteger minor = [[command.arguments objectAtIndex:1] intValue];
    NSString* beaconid = [command.arguments objectAtIndex:2];
    
    [self.beaconManager startAdvertisingWithMajor:major withMinor:minor withIdentifier:beaconid];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)stopVirtualBeacon:(CDVInvokedUrlCommand*)command
{
    [self.beaconManager stopAdvertising];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

#pragma mark - Connecto to methods
- (void)connectToBeacon:(CDVInvokedUrlCommand*)command
{
    NSInteger major = [[command.arguments objectAtIndex:0] intValue];
    NSInteger minor = [[command.arguments objectAtIndex:1] intValue];
    ESTBeacon* foundBeacon = nil;
    
    if([self.beacons count] > 0)
    {
        //convert list of beacons to a an array of simple property-value objects
        for (id beacon in self.beacons) {
            ESTBeacon* currentBeacon = beacon;
            NSNumber* currentMajor = currentBeacon.major;
            NSNumber* currentMinor = currentBeacon.minor;
            
            if(currentMajor == nil) {
                currentMajor = currentBeacon.ibeacon.major;
            }
            if(currentMinor == nil) {
                currentMinor = currentBeacon.ibeacon.minor;
            }
            
            if(currentMajor == nil || currentMajor == nil) {
                continue;
            }
            
            if(minor == [currentMinor intValue] && major == [currentMajor intValue]) {
                foundBeacon = beacon;
            }
        }
    }
    
    if(foundBeacon) {
        if([foundBeacon isConnected]) {
            //beacon is already connected
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Beacon is already connected."] callbackId:command.callbackId];
        } else if(self.connectionCallbackId != nil) {
            //some callback is already waiting for connection
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"App is already waiting for connection."] callbackId:command.callbackId];
        } else {
            //everything OK - try connecting
            self.connectionCallbackId = command.callbackId;
            self.connectedBeacon = foundBeacon;
            foundBeacon.delegate = self;
            [foundBeacon connectToBeacon];
        }
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Beacon not found."] callbackId:command.callbackId];
    }
}

- (void)connectToBeaconByMacAddress:(CDVInvokedUrlCommand*)command
{
    NSString* macAddress = [command.arguments objectAtIndex:0];
    ESTBeacon* foundBeacon = nil;
    
    if([self.beacons count] > 0)
    {
        //convert list of beacons to a an array of simple property-value objects
        for (id beacon in self.beacons) {
            ESTBeacon* currentBeacon = beacon;
            NSString* currentMac = currentBeacon.macAddress;
            
            if(currentMac == nil) {
                continue;
            }
            
            if([currentMac isEqualToString:macAddress]) {
                foundBeacon = beacon;
            }
        }
    }
    
    if(foundBeacon) {
        if([foundBeacon isConnected]) {
            //beacon is already connected
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Beacon is already connected."] callbackId:command.callbackId];
        } else if(self.connectionCallbackId != nil) {
            //some callback is already waiting for connection
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"App is already waiting for connection."] callbackId:command.callbackId];
        } else {
            //everything OK - try connecting
            self.connectionCallbackId = command.callbackId;
            self.connectedBeacon = foundBeacon;
            foundBeacon.delegate = self;
            [foundBeacon connectToBeacon];
        }
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Beacon not found."] callbackId:command.callbackId];
    }
}

#pragma mark - Disconnect from Beacon
- (void)disconnectFromBeacon:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        
        if(self.connectedBeacon != nil) {
            [self.connectedBeacon disconnectBeacon];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                         messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]];
            
            self.connectedBeacon = nil;
        } else {
            //no connected beacons
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There are no connected beacons."];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - Change attributes of beacon
- (void)setFrequencyOfConnectedBeacon:(CDVInvokedUrlCommand*)command
{
    if(self.connectedBeacon != nil) {
        NSNumber* frequency = [command.arguments objectAtIndex:0];
        
        if(frequency != nil && [frequency intValue] >= 80 && [frequency intValue] <= 3200) {
            [self.connectedBeacon writeBeaconFrequency:[frequency shortValue] withCompletion:^(unsigned int value, NSError *error){
                if(error != nil) {
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription] callbackId:command.callbackId];
                } else {
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                         messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]] callbackId:command.callbackId];
                }
                
            }];
        
        } else {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid frequency value."] callbackId:command.callbackId];
        }
    } else {
        //no connected beacons
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There are no connected beacons."] callbackId:command.callbackId];
    }
}

- (void)setPowerOfConnectedBeacon:(CDVInvokedUrlCommand*)command
{
    if(self.connectedBeacon != nil) {
        NSNumber* power = [command.arguments objectAtIndex:0];
        ESTBeaconPower powerLevel;
        
        switch ([power intValue]) {
            case -40:
                powerLevel = ESTBeaconPowerLevel1;
                break;
            case -20:
                powerLevel = ESTBeaconPowerLevel2;
                break;
            case -16:
                powerLevel = ESTBeaconPowerLevel3;
                break;
            case -12:
                powerLevel = ESTBeaconPowerLevel4;
                break;
            case -8:
                powerLevel = ESTBeaconPowerLevel5;
                break;
            case -4:
                powerLevel = ESTBeaconPowerLevel6;
                break;
            case 0:
                powerLevel = ESTBeaconPowerLevel7;
                break;
            case 4:
                powerLevel = ESTBeaconPowerLevel8;
                break;
        }
        
        if(powerLevel || powerLevel == ESTBeaconPowerLevel7) {
            [self.connectedBeacon writeBeaconPower:powerLevel withCompletion:^(unsigned int value, NSError *error){
                if(error != nil) {
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription] callbackId:command.callbackId];
                } else {
                    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                         messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]] callbackId:command.callbackId];
                }
            }];
        } else {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid power value."] callbackId:command.callbackId];
        }
    } else {
        //no connected beacons
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There are no connected beacons."] callbackId:command.callbackId];
    }
}

- (void)updateFirmwareOfConnectedBeacon:(CDVInvokedUrlCommand*)command
{
    if(self.connectedBeacon != nil) {
        [self.connectedBeacon updateBeaconFirmwareWithProgress:^(NSString *value, NSError *error){
            if(error == nil) {
                self.firmwareUpdateProgress = value;
            }
            
        }andCompletion:^(NSError *error){
            if(error == nil) {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                     messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]] callbackId:command.callbackId];
            } else {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription] callbackId:command.callbackId];
            }
            
            self.firmwareUpdateProgress = nil;
        }];
    } else {
        //no connected beacons
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"There are no connected beacons."] callbackId:command.callbackId];
    }
}

- (void)getFirmwareUpdateProgress:(CDVInvokedUrlCommand*)command
{
    if(self.firmwareUpdateProgress != nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                 messageAsString:self.firmwareUpdateProgress] callbackId:command.callbackId];
    } else {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No beacon is being updated right now."] callbackId:command.callbackId];
    }
}

#pragma mark - Helpers

- (NSMutableDictionary*)beaconToDictionary:(ESTBeacon*)beacon
{
    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithCapacity:16];
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    NSNumber* rssi = beacon.rssi;
    
    if(major == nil) {
        major = beacon.ibeacon.major;
    }
    if(minor == nil) {
        minor = beacon.ibeacon.minor;
    }
    if(rssi == nil) {
        rssi = [NSNumber numberWithInt:beacon.ibeacon.rssi];
    }
    
    [props setValue:beacon.baterryLevel forKey:@"baterryLevel"];
    [props setValue:beacon.firmwareVersion forKey:@"firmwareVersion"];
    [props setValue:beacon.hardwareVersion forKey:@"hardwareVersion"];
    [props setValue:major forKey:@"major"];
    [props setValue:minor forKey:@"minor"];
    [props setValue:beacon.frequency forKey:@"frequency"];
    [props setValue:beacon.description forKey:@"description"];
    [props setValue:rssi forKey:@"rssi"];
    [props setValue:beacon.debugDescription forKey:@"debugDescription"];
    [props setValue:beacon.macAddress forKey:@"macAddress"];
    [props setValue:beacon.measuredPower forKey:@"measuredPower"];
    [props setValue:[NSNumber numberWithBool:beacon.isConnected] forKey:@"isConnected"];
    
    if(beacon.power != nil) {
        [props setValue:[NSNumber numberWithChar:[beacon.power charValue]] forKey:@"power"];
    }
    
    if(beacon.ibeacon != nil) {
        [props setValue:[NSNumber numberWithDouble:beacon.ibeacon.accuracy] forKey:@"accuracy"];
        [props setValue:[NSNumber numberWithInt:beacon.ibeacon.proximity] forKey:@"proximity"];
        
        if(beacon.ibeacon.proximityUUID != nil) {
            [props setValue:beacon.ibeacon.proximityUUID.UUIDString forKey:@"proximityUUID"];
        }
    }
    
    
    return props;
}

#pragma mark - Beacon Manager delegate methods.

- (void)beaconManager:(ESTBeaconManager *)manager
   didDiscoverBeacons:(NSArray *)beacons
             inRegion:(ESTBeaconRegion *)region
{
    self.beacons = beacons;
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
     self.beacons = beacons;
//    if([self.beacons count] > 0){
//     ESTBeacon *beacon = [beacons objectAtIndex:0];
//    
//  
//    switch (beacon.ibeacon.proximity) {
//        case CLProximityImmediate:
//            NSLog(@"You're Sitting on it!");
//            break;
//        case CLProximityNear:
//            NSLog(@"Getting Warmer!");
//            break;
//        default:
//            NSLog(@"It's around here somewhere!");
//            break;
//    }
//    }
}

- (void)beaconConnectionDidFail:(NSError*)error {
    if(self.connectionCallbackId != nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                 messageAsString:error.localizedDescription]
                                    callbackId:self.connectionCallbackId];
    }
    
    self.connectionCallbackId = nil;
    self.connectedBeacon = nil;
}

- (void)beaconConnectionDidSucceeded {
    if(self.connectionCallbackId != nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                             messageAsDictionary:[self beaconToDictionary:self.connectedBeacon]]
                                    callbackId:self.connectionCallbackId];
    }
    
    self.connectionCallbackId = nil;
}

- (void)beaconDidDisconnectWithError:(NSError*)error {
    if(self.connectionCallbackId == nil) {
        self.connectedBeacon = nil;
    }
}
-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {
          NSLog(@"didDetermineState Inside");
    }
    else
    {
           NSLog(@"didDetermineState Outside");
    }
    

}
-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Enter";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    NSString* callbackId = [self.regionWatchers objectForKey:region.identifier];
      NSLog(@"didEnterRegion");
    
//     self.beaconManager.avoidUnknownStateBeacons = YES;
//     // stop existing discovery/ranging
//     [self.beaconManager stopEstimoteBeaconDiscovery];
//     [self.beaconManager stopRangingBeaconsInRegion:self.currentRegion];
//     
//     // start ranging
//     [self.beaconManager startRangingBeaconsInRegion:self.currentRegion];

    
    if(callbackId != nil) {
        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithCapacity:4];
        
        [props setValue:region.identifier forKey:@"id"];
        [props setValue:region.major forKey:@"major"];
        [props setValue:region.minor forKey:@"minor"];
        [props setValue:@"enter" forKey:@"action"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:props];
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        // present local notification
      
    }
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Exit";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

    NSString* callbackId = [self.regionWatchers objectForKey:region.identifier];
  
   // [self.beaconManager stopRangingBeaconsInRegion:self.currentRegion];

    
    NSLog(@"didExitRegion");
    if(callbackId != nil) {
        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithCapacity:4];
        
        [props setValue:region.identifier forKey:@"id"];
        [props setValue:region.major forKey:@"major"];
        [props setValue:region.minor forKey:@"minor"];
        [props setValue:@"exit" forKey:@"action"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:props];
        [result setKeepCallback:[NSNumber numberWithBool:YES]];
        
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        
           }
}
-(void)updateServerUserState:(NSString* )state
{
    NSString *plcp = @"plcp";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/playlists/56D792A831D0C362/?v=2&alt=json&feature=%@",plcp]];
 
    // Create a request object using the URL.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Prepare for the response back from the server
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    // Send a synchronous request to the server (i.e. sit and wait for the response)
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Reponse from web:%@", response);

}
@end