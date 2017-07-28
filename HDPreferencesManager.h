#import <Cephei/HBPreferences.h>

@interface HDPreferencesManager : NSObject

@property (nonatomic, readonly) CGFloat currentTemp;

+ (instancetype)sharedInstance;

-(void)setCurrentTemp:(CGFloat)temp;

@end