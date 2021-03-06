#import <SpringBoard/SBIconListView.h>

@interface SBIconListView (ApexAdditions)

@property (nonatomic, assign) CGFloat stk_realVerticalIconPadding;
@property (nonatomic, assign) CGFloat stk_realHorizontalIconPadding;
@property (nonatomic, assign) BOOL stk_preventRelayout;
@property (nonatomic, assign) BOOL stk_modifyDisplacedIconOrigin;

- (NSUInteger)stk_visibleIconRowsForCurrentOrientation;
- (NSUInteger)stk_visibleIconColumnsForCurrentOrientation;

- (void)stk_makeIconViewsPerformBlock:(void(^)(SBIconView *iv))block;
- (void)stk_reorderIconViews;

@end
