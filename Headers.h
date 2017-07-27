enum StatusBarAlignment
{
	StatusBarAlignmentLeft = 1,
	StatusBarAlignmentRight = 2,
	StatusBarAlignmentCenter = 4
};


// only LSStatusBarItem (API) methods are considered public.

@interface LSStatusBarItem : NSObject
{
@public
	NSMutableDictionary* _properties;
@private
	NSString* _identifier;
	NSMutableSet* _delegates;
	BOOL _manualUpdate;
}

@end


// Supported API

@interface LSStatusBarItem (API)

- (id) initWithIdentifier: (NSString*) identifier alignment: (StatusBarAlignment) alignment;

// bitmasks (e.g. left or right) are not supported yet
@property (nonatomic, readonly) StatusBarAlignment alignment;

@property (nonatomic, assign) NSMutableDictionary *properties;

@property (nonatomic, getter=isVisible) BOOL visible;

// useful only with left/right alignment - will throw error for center alignment
@property (nonatomic, assign) NSString* imageName;

// useful only with center alignment - will throw error otherwise
// will not be visible on the lockscreen
@property (nonatomic, assign) NSString* titleString;

// useful if you want to override the UIStatusBarCustomItemView drawing.  Your class must exist in EVERY UIKit process.
@property (nonatomic, assign) NSString* customViewClass;

// set to NO and manually call update if you need to make multiple changes
@property (nonatomic, getter=isManualUpdate) BOOL manualUpdate;

// manually call if manualUpdate = YES
- (void) update;

@end

@interface LSStatusBarItem (Private)

-(void)_setProperties:(NSDictionary *)dict;

@end

@interface WeatherPreferences

+(id)sharedPreferences;

-(NSArray *)loadSavedCities;
-(BOOL)isCelsius;

@end



@interface City : NSObject
@property (nonatomic, retain) NSArray* hourlyForecasts;
-(void)update;
@end

@interface HourlyForecast : NSObject 
@property (nonatomic,copy) NSString * detail;                           //@synthesize detail=_detail - In the implementation block
@end

@interface SBLockScreenManager
-(void)updateTempBrah;
@end

@interface SBAwayController
-(void)updateTempBrah;
@end



@interface UIStatusBarItemView
-(id)imageWithText:(id)arg1;
@end
