#import "HDPreferencesManager.h"
#import <Cephei/HBPreferences.h>

static NSString *const kHDTempKey = @"currentTemp";


@implementation HDPreferencesManager {
	HBPreferences *_preferences;
}

+ (instancetype)sharedInstance {
	static HDPreferencesManager *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"com.wizages.hotdog"];

		[_preferences registerFloat:&_currentTemp default:0.0 forKey:kHDTempKey];
	}

	return self;
}


-(void)setCurrentTemp:(CGFloat)temp{
	HBLogDebug(@"%f", temp);
	[_preferences setFloat:temp forKey:kHDTempKey];
}

#pragma mark - Memory management

- (void)dealloc {
	[_preferences release];

	[super dealloc];
}

@end