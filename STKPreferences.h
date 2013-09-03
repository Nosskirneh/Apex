#import <Foundation/Foundation.h>

@class SBIcon;
@interface STKPreferences : NSObject

+ (NSString *)layoutsDirectory;

+ (instancetype)sharedPreferences;

- (void)reloadPreferences;

@property (nonatomic, readonly) NSArray *identifiersForIconsInStacks;

- (NSSet *)identifiersForIconsWithStack;
- (NSArray *)stackIconsForIcon:(SBIcon *)icon;

- (NSString *)layoutPathForIconID:(NSString *)iconID;
- (NSString *)layoutPathForIcon:(SBIcon *)icon;

- (BOOL)iconHasStack:(SBIcon *)icon;
- (BOOL)iconIsInStack:(SBIcon *)icon;

- (BOOL)removeLayoutForIcon:(SBIcon *)icon;
- (BOOL)removeLayoutForIconID:(NSString *)iconID;

@end
