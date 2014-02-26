#import "STKGroupController.h"
#import "STKConstants.h"

#define kFullDimStrength 0.2f

@implementation STKGroupController
{
    STKGroupView *_openGroupView;
    UIView *_dimmingView;
    UISwipeGestureRecognizer *_closeSwipeRecognizer;
    UITapGestureRecognizer *_closeTapRecognizer;
    
    STKGroupSelectionAnimator *_selectionAnimator;
    STKSelectionView *_selectionView;
    STKGroupSlot _selectionSlot;

    NSMutableArray *_iconsToShow;
    NSMutableArray *_iconsToHide;
}

+ (instancetype)sharedController
{
    static dispatch_once_t pred;
    static id _si;
    dispatch_once(&pred, ^{
        _si = [[self alloc] init];
    });
    return _si;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _closeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_closeOpenGroupOrSelectionView)];
        _closeSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_closeOpenGroupOrSelectionView)];
        _closeSwipeRecognizer.direction = (UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown);
        _closeSwipeRecognizer.delegate = self;
        _closeTapRecognizer.delegate = self;
    }
    return self;
}

- (void)addGroupViewToIconView:(SBIconView *)iconView
{
    if (iconView.icon == [[CLASS(SBIconController) sharedInstance] grabbedIcon]) {
        return;
    }
    STKGroupView *groupView = nil;
    if ((groupView = [iconView groupView])) {
        SBIconCoordinate currentCoordinate = [STKGroupLayoutHandler coordinateForIcon:iconView.icon];
        [groupView.group relayoutForNewCoordinate:currentCoordinate];
    }
    else {
        STKGroup *group = [[STKPreferences sharedPreferences] groupForCentralIcon:iconView.icon];
        if (!group) {
            group = [self _groupWithEmptySlotsForIcon:iconView.icon];
        }
        group.lastKnownCoordinate = [STKGroupLayoutHandler coordinateForIcon:group.centralIcon];
        groupView = [[[STKGroupView alloc] initWithGroup:group] autorelease];
        groupView.delegate = self;
        [iconView setGroupView:groupView];
    }
}

- (void)removeGroupViewFromIconView:(SBIconView *)iconView
{
    iconView.groupView = nil;
}

- (void)handleHomeButtonPress
{
    [self _closeOpenGroupOrSelectionView];
}

- (STKGroup *)_groupWithEmptySlotsForIcon:(SBIcon *)icon
{
    STKGroupLayout *slotLayout = [STKGroupLayoutHandler emptyLayoutForIconAtLocation:[STKGroupLayoutHandler locationForIcon:icon]];
    STKGroup *group = [[STKGroup alloc] initWithCentralIcon:icon layout:slotLayout];
    group.state = STKGroupStateEmpty;
    [group addObserver:[STKPreferences sharedPreferences]];
    return [group autorelease];
}

- (UIScrollView *)_currentScrollView
{
    SBFolderController *currentFolderController = [[CLASS(SBIconController) sharedInstance] _currentFolderController];
    return [currentFolderController.contentView scrollView];
}

- (void)_setDimStrength:(CGFloat)strength
{
    if (!_dimmingView) {
        SBWallpaperController *controller = [CLASS(SBWallpaperController) sharedInstance];
        UIView *homescreenWallpaperView = [controller valueForKey:@"_homescreenWallpaperView"];
        _dimmingView = [[UIView alloc] initWithFrame:homescreenWallpaperView.bounds];
        _dimmingView.backgroundColor = [UIColor colorWithWhite:0.f alpha:1.f];
        _dimmingView.alpha = 0.f;
        [homescreenWallpaperView addSubview:_dimmingView];
    }
    _dimmingView.alpha = strength;
}

- (void)_removeDimmingView
{
    [_dimmingView removeFromSuperview];
    [_dimmingView release];
    _dimmingView = nil;
}

- (void)_addCloseGestureRecognizers
{
    UIView *view = [[CLASS(SBIconController) sharedInstance] contentView];
    [view addGestureRecognizer:_closeSwipeRecognizer];
    [view addGestureRecognizer:_closeTapRecognizer];
}

- (void)_removeCloseGestureRecognizers
{
    [_closeTapRecognizer.view removeGestureRecognizer:_closeTapRecognizer];
    [_closeSwipeRecognizer.view removeGestureRecognizer:_closeSwipeRecognizer];
}

- (void)_closeOpenGroupOrSelectionView
{
    if (_selectionView) {
        [self _closeSelectionView];
    }
    else if ([_openGroupView.group hasPlaceholders]) {
        [_openGroupView.group removePlaceholders];
    }
    else {
        [_openGroupView close];
    }
}

- (void)_showSelectionViewForIconView:(SBIconView *)selectedIconView
{
    _selectionSlot = [_openGroupView.subappLayout slotForIcon:selectedIconView];
    _selectionView = [[[STKSelectionView alloc] initWithFrame:CGRectZero selectedIcon:[selectedIconView.icon isLeafIcon] ? selectedIconView.icon : nil] autorelease];
    SBIconModel *model = [(SBIconController *)[CLASS(SBIconController) sharedInstance] model];
    NSMutableArray *visibleIconIdentifiers = [[[[[model visibleIconIdentifiers] objectEnumerator] allObjects] mutableCopy] autorelease];
    [visibleIconIdentifiers addObjectsFromArray:[STKPreferences sharedPreferences].identifiersForSubappIcons];
    NSMutableArray *availableIcons = [NSMutableArray array];
    for (NSString *identifier in visibleIconIdentifiers) {
        [availableIcons addObject:[model expectedIconForDisplayIdentifier:identifier]];
    }
    _selectionView.iconsForSelection = availableIcons;
    _selectionAnimator = [[STKGroupSelectionAnimator alloc] initWithSelectionView:_selectionView iconView:selectedIconView];
    [_selectionAnimator openSelectionViewAnimatedWithCompletion:nil];
}

- (void)_closeSelectionView
{
    SBIcon *iconInSelectedSlot = [_openGroupView.group.layout iconInSlot:_selectionSlot];
    if (_selectionView.selectedIcon && (iconInSelectedSlot != _selectionView.selectedIcon)) {
        if ([iconInSelectedSlot isLeafIcon]) {
            if (!_iconsToShow) _iconsToShow = [NSMutableArray new];
            [_iconsToShow addObject:iconInSelectedSlot];
        }
        if ([_selectionView.selectedIcon isLeafIcon]) {
            if (!_iconsToHide) _iconsToHide = [NSMutableArray new];
            [_iconsToHide addObject:_selectionView.selectedIcon];
        }
        [_openGroupView.group replaceIconInSlot:_selectionSlot withIcon:_selectionView.selectedIcon];
    }
    else if ([iconInSelectedSlot isLeafIcon] && !_selectionView.selectedIcon) {
        [_openGroupView.group replaceIconInSlot:_selectionSlot withIcon:[[CLASS(STKEmptyIcon) new] autorelease]];
    }
    if (_openGroupView.group.state != STKGroupStateEmpty) {
        [_openGroupView.group addPlaceholders];
    }

    [_selectionAnimator closeSelectionViewAnimatedWithCompletion:^{
        [_selectionView removeFromSuperview];
        [_selectionView release];
        _selectionView = nil;
        [_selectionAnimator release];
        _selectionAnimator = nil;
    }];
}

#pragma mark - Group View Delegate
- (BOOL)shouldGroupViewOpen:(STKGroupView *)groupView
{
    return !_openGroupView;
}

- (BOOL)groupView:(STKGroupView *)groupView shouldRecognizeGesturesSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    BOOL allow = YES;
    if ([recognizer isKindOfClass:[UISwipeGestureRecognizer class]] || [recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (recognizer == _closeSwipeRecognizer || recognizer == _closeTapRecognizer) {
            allow = NO;
        }
        else {
            NSArray *targets = [recognizer valueForKey:@"_targets"];
            id target = ((targets.count > 0) ? targets[0] : nil);
            target = [target valueForKey:@"_target"];
            allow = (![target isKindOfClass:CLASS(SBSearchScrollView)] && [recognizer.view isKindOfClass:[UIScrollView class]]);
        }
    }
    return allow;
}

- (void)groupViewWillOpen:(STKGroupView *)groupView
{
    if (groupView.activationMode != STKActivationModeDoubleTap) {
        [self _currentScrollView].scrollEnabled = NO;
    }
}

- (void)groupView:(STKGroupView *)groupView didMoveToOffset:(CGFloat)offset
{
    [self _setDimStrength:(offset * kFullDimStrength)];
}

- (void)groupViewDidOpen:(STKGroupView *)groupView
{
    _openGroupView = groupView;
    [self _addCloseGestureRecognizers];
    [[CLASS(SBSearchGesture) sharedInstance] setEnabled:NO];
    [self _currentScrollView].scrollEnabled = YES;
}

- (void)groupViewWillClose:(STKGroupView *)groupView
{
    [groupView.group removePlaceholders];
    [self _currentScrollView].scrollEnabled = YES;
}

- (void)groupViewDidClose:(STKGroupView *)groupView
{
    if (_openGroupView.group.state == STKGroupStateDirty) {
        [_openGroupView.group finalizeState];
        if (_iconsToHide.count > 0 || _iconsToShow.count > 0) {
            SBIconModel *model = [(SBIconController *)[CLASS(SBIconController) sharedInstance] model];
            [model _postIconVisibilityChangedNotificationShowing:_iconsToShow hiding:_iconsToHide];
            [_iconsToShow release];
            [_iconsToHide release];
            _iconsToShow = nil;
            _iconsToHide = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:STKEditingEndedNotificationName object:nil];
            [groupView resetLayouts];
        }
    }
    [self _removeDimmingView];
    [self _removeCloseGestureRecognizers];
    [[CLASS(SBSearchGesture) sharedInstance] setEnabled:YES];
    _openGroupView = nil;
}

- (BOOL)iconShouldAllowTap:(SBIconView *)iconView
{
    return !_selectionView;
}

- (void)groupViewWillBeDestroyed:(STKGroupView *)groupView
{
    if (groupView == _openGroupView){
        _openGroupView = nil;
    }
}

- (void)iconTapped:(SBIconView *)iconView
{
    EXECUTE_BLOCK_AFTER_DELAY(0.2, ^{
        [iconView setHighlighted:NO];
    });
    if (iconView.apexOverlayView) {
        [self _showSelectionViewForIconView:iconView];
    }
    else {
        [iconView.icon launchFromLocation:SBIconLocationHomeScreen];        
    }
}

- (BOOL)iconViewDisplaysCloseBox:(SBIconView *)iconView
{
    return NO;
}

- (BOOL)iconViewDisplaysBadges:(SBIconView *)iconView
{
    return [[CLASS(SBIconController) sharedInstance] iconViewDisplaysBadges:iconView];
}

- (BOOL)icon:(SBIconView *)iconView canReceiveGrabbedIcon:(SBIcon *)grabbedIcon
{
    return NO;
}

- (void)iconHandleLongPress:(SBIconView *)iconView
{
    if ([iconView.icon isEmptyPlaceholder] || [iconView.icon isPlaceholder]) {
        return;
    }
    [iconView setHighlighted:NO];
    [[iconView containerGroupView].group addPlaceholders];
    iconView.userInteractionEnabled = NO;
    iconView.userInteractionEnabled = YES;
}

- (void)iconTouchBegan:(SBIconView *)iconView
{
    [iconView setHighlighted:YES];   
}

- (void)icon:(SBIconView *)iconView touchEnded:(BOOL)ended
{
    [iconView setHighlighted:NO];
}

#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:_openGroupView];
    return !([_openGroupView hitTest:point withEvent:nil]);   
}

@end
