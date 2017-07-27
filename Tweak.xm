#import <objc/runtime.h>
#import "Headers.h"


static LSStatusBarItem *datTempBro;

static float getTemp() {
	WeatherPreferences* prefs = [objc_getClass("WeatherPreferences") sharedPreferences];
	if (!prefs){
		return 875;
	}
	City* city = [prefs loadSavedCities][0];
	[city update];
	NSArray* hours = city.hourlyForecasts;
	HourlyForecast *hourly = hours[0];
	if ([prefs isCelsius]){
		return [hourly.detail floatValue];
	} else {
		return ([hourly.detail floatValue]*9/5 + 32);
	}
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

	[datTempBro setTitleString:[NSString stringWithFormat:@"%.0f°", getTemp()]];
}

%end
%end

%group iOS7plus
%hook SBLockScreenManager

-(BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2{
	BOOL result = %orig;
	[self updateTempBrah];
	[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTempBrah) userInfo:nil repeats:YES];
	return result;
}

%new(@:@)
-(void)updateTempBrah{
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
	return [self imageWithText:[NSString stringWithFormat:@"%.0f°", getTemp()]];
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