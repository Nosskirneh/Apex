#import "STKGroupView.h"
#import "STKSelectionView.h"

typedef NS_ENUM(NSUInteger, STKClosingEvent) {
    STKClosingEventHomeButtonPress = 1,
    STKClosingEventListViewScroll,
    STKClosingEventSwitcherActivation,
    STKClosingEventLock,
};

FOUNDATION_EXTERN NSString * NSStringFromSTKClosingEvent(STKClosingEvent);

@class STKIconViewRecycler;

@interface STKGroupController : NSObject <STKGroupViewDelegate, UIGestureRecognizerDelegate>

+ (instancetype)sharedController;

@property (nonatomic, readonly) STKGroupView *openGroupView;
@property (nonatomic, readonly) STKGroupView *openingGroupView;
@property (nonatomic, readonly) STKGroupView *closingGroupView;
@property (nonatomic, readonly) STKGroupView *activeGroupView;
@property (nonatomic, readonly) STKIconViewRecycler *iconViewRecycler;

- (void)addOrUpdateGroupViewForIconView:(SBIconView *)iconView;
- (void)removeGroupViewFromIconView:(SBIconView *)iconView;

- (void)performRotationWithDuration:(NSTimeInterval)duration;

// returns YES if we reacted to the event, NO if ignored
- (BOOL)handleClosingEvent:(STKClosingEvent)event;

- (void)handleStatusBarTap;
- (void)handleIconRemoval:(SBIcon *)removedIcon;

@end
