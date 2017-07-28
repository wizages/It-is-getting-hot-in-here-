#import <objc/runtime.h>
#import "HDPreferencesManager.h"
#import "Headers.h"


static LSStatusBarItem *datTempBro;

static void getUpdatedTemp(){
	WeatherPreferences* prefs = [objc_getClass("WeatherPreferences") sharedPreferences];
	City* city;
	if ([prefs localWeatherCity]){
		city = [prefs localWeatherCity];
		if([[NSDate date] compare:[[city updateTime] dateByAddingTimeInterval:1800]] == NSOrderedDescending)
	    	{
			    WeatherLocationManager *weatherLocationManager = [objc_getClass("WeatherLocationManager") sharedWeatherLocationManager];

				CLLocationManager *locationManager = [[CLLocationManager alloc]init];
				[weatherLocationManager setDelegate:locationManager];

				if(![weatherLocationManager locationTrackingIsReady]) {
					[weatherLocationManager setLocationTrackingReady:YES activelyTracking:NO watchKitExtension:nil];
				}
			
				[[objc_getClass("WeatherPreferences") sharedPreferences] setLocalWeatherEnabled:YES];
				[weatherLocationManager setLocationTrackingActive:YES];

				[[objc_getClass("TWCLocationUpdater") sharedLocationUpdater] updateWeatherForLocation:[weatherLocationManager location] city:city];

				[weatherLocationManager setLocationTrackingActive:NO];
				[locationManager release];
			}
	}
	if ([[prefs loadSavedCities] count] != 0 ){
		city = [prefs loadSavedCities][0];
	}
	[city update];
	HBLogDebug(@"%@", city.temperature);
	if ([city.temperature isKindOfClass:NSClassFromString(@"WFTemperature")]) {
         if ([prefs isCelsius])
         	[[HDPreferencesManager sharedInstance] setCurrentTemp:(float)((WFTemperature *)city.temperature).celsius];
        else
            [[HDPreferencesManager sharedInstance] setCurrentTemp:(float)((WFTemperature *)city.temperature).fahrenheit];
    } else {
        if ([prefs isCelsius]) 
        	[[HDPreferencesManager sharedInstance] setCurrentTemp:[city.temperature floatValue]];
        else
            [[HDPreferencesManager sharedInstance] setCurrentTemp:(([city.temperature floatValue]*9)/5) + 32];
    }
    [datTempBro update];
}

static void getTemp() {
	WeatherPreferences* prefs = [objc_getClass("WeatherPreferences") sharedPreferences];

	City* city;
	if ([prefs localWeatherCity]){
		HBLogDebug(@"Local");
		city = [prefs localWeatherCity];
		if([[NSDate date] compare:[[city updateTime] dateByAddingTimeInterval:1800]] == NSOrderedDescending)
	    	{
			    WeatherLocationManager *weatherLocationManager = [objc_getClass("WeatherLocationManager") sharedWeatherLocationManager];

				CLLocationManager *locationManager = [[CLLocationManager alloc]init];
				[weatherLocationManager setDelegate:locationManager];

				if(![weatherLocationManager locationTrackingIsReady]) {
					[weatherLocationManager setLocationTrackingReady:YES activelyTracking:NO watchKitExtension:nil];
				}
			
				[[objc_getClass("WeatherPreferences") sharedPreferences] setLocalWeatherEnabled:YES];
				[weatherLocationManager setLocationTrackingActive:YES];

				[[objc_getClass("TWCLocationUpdater") sharedLocationUpdater] updateWeatherForLocation:[weatherLocationManager location] city:city];

				[weatherLocationManager setLocationTrackingActive:NO];
				[locationManager release];
			}
	}
	else if ([[prefs loadSavedCities] count] != 0 ){
		HBLogDebug(@"We have count")
		city = [prefs loadSavedCities][0];
	} else {
		HBLogDebug(@"Returning");
		return;
	}
	//dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[[%c(TWCCityUpdater) sharedCityUpdater] updateWeatherForCities:@[city] withCompletionHandler:^{
		//dispatch_semaphore_signal(semaphore);
		HBLogDebug(@"We updated");
		getUpdatedTemp();
	}];
	//dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	[city update];

}

%group iOS6
%hook SBAwayController
- (void)unlockWithSound:(BOOL)sound
{
	%orig;
	[self updateTempBrah];
	[NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(updateTempBrah) userInfo:nil repeats:YES];
	return;
}

%new(@:@)
-(void)updateTempBrah{
	if(!datTempBro)
		datTempBro = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"com.wizages.tempitem" alignment:StatusBarAlignmentCenter];

	//[datTempBro setTitleString:[NSString stringWithFormat:@"%.0f°", getTemp()]];
}

%end
%end

%group iOS7plus
%hook SBLockScreenManager

-(BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2{
	BOOL result = %orig;
	[self updateTempBrah];
	[NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(updateTempBrah) userInfo:nil repeats:YES];
	return result;
}

%new(@:@)
-(void)updateTempBrah{
		HBLogDebug(@"Timer triggers");
	getTemp();

	if(!datTempBro)
		datTempBro = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"com.wizages.tempitem" alignment:StatusBarAlignmentRight];
	datTempBro.imageName = @"bullshit";
	datTempBro.visible = YES;
	if (datTempBro.customViewClass == nil )
		[datTempBro  setCustomViewClass:@"ShitTempItemView"];
}

%end

%subclass ShitTempItemView : UIStatusBarItemView

-(id) contentsImage{

	return [self imageWithText:[NSString stringWithFormat:@"%.0f°", [[HDPreferencesManager sharedInstance] currentTemp]]];
}


-(CGFloat)standardPadding{
	return 4;
}

%end
%end


%ctor {
	if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 ){
		%init(iOS7plus)
	} else {
		%init(iOS6)
	}
}