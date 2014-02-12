#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <IconSupport/ISIconSupport.h>
#import <SpringBoard/SpringBoard.h>
#import <Search/SPSearchResultSection.h>
#import "STKConstants.h"

/*

static void STKWelcomeAlertCallback(CFUserNotificationRef userNotification, CFOptionFlags responseFlags);

#pragma mark - SpringBoard Hook
- (void)_reportAppLaunchFinished
{
    %orig;
    if (![STKPreferences sharedPreferences].welcomeAlertShown) {
        NSDictionary *fields = @{(id)kCFUserNotificationAlertHeaderKey: @"Apex",
                                 (id)kCFUserNotificationAlertMessageKey: @"Thanks for purchasing!\nSwipe down on any app icon and tap the \"+\" to get started.",
                                 (id)kCFUserNotificationDefaultButtonTitleKey: @"OK",
                                 (id)kCFUserNotificationAlternateButtonTitleKey: @"Settings"};

        SInt32 error = 0;
        CFUserNotificationRef notificationRef = CFUserNotificationCreate(kCFAllocatorDefault, 0, kCFUserNotificationNoteAlertLevel, &error, (CFDictionaryRef)fields);
        // Get and add a run loop source to the current run loop to get notified when the alert is dismissed
        CFRunLoopSourceRef runLoopSource = CFUserNotificationCreateRunLoopSource(kCFAllocatorDefault, notificationRef, STKWelcomeAlertCallback, 0);
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
        CFRelease(runLoopSource);
        if (error == 0) {
            [STKPreferences sharedPreferences].welcomeAlertShown = YES;
        }
    }
}
%end

static void STKWelcomeAlertCallback(CFUserNotificationRef userNotification, CFOptionFlags responseFlags)
{
    if ((responseFlags & 0x3) == kCFUserNotificationAlternateResponse) {
        // Open settings to custom bundle
        [(SpringBoard *)[UIApplication sharedApplication] applicationOpenURL:[NSURL URLWithString:@"prefs:root="kSTKTweakName] publicURLsOnly:NO];
    }
    CFRelease(userNotification);
}

*/

#pragma mark - SBIconController
%hook SBIconController
%new
- (id)youWat
{
    SBFolderZoomSettings *settings = [[(SBPrototypeController *)[%c(SBPrototypeController) sharedInstance] rootSettings] rootAnimationSettings].folderOpenSettings;
    SBRootFolderController *rfc = [self _rootFolderController];
    SBFolderIcon *folderIcon = [[self currentRootIconList] icons][16];
    SBFolder *folder = [%c(STKSelectionFolder) sharedInstance];
    SBFolderController *fc = [(SBFolderController *)[%c(SBFolderController) alloc] initWithFolder:folder orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    SBFolderIconZoomAnimator *animator = [[%c(SBFolderIconZoomAnimator) alloc] initWithOuterController:rfc innerController:fc folderIcon:folderIcon];
    animator.settings = settings;
    rfc.innerFolderController = fc;

    SBFAnimationFactory *factoryWhat = [animator centralAnimationFactory];
    [factoryWhat animateWithDelay:0 animations:^{
        SBFolderView *folderView = [fc contentView];
        [self.contentView pushFolderContentView:folderView];
        [folderView prepareToOpen];
        folderView.folder.isOpen = YES;
    } completion:nil];

    return animator;
}
%end

%hook SBIconView
- (void)setLocation:(SBIconLocation)location
{
    %orig(location);
    if ([[%c(SBIconViewMap) homescreenMap] mappedIconViewForIcon:self.icon]
        && [self.superview isKindOfClass:%c(SBIconListView)]
        && STKListViewForIcon(self.icon)) {
        [[STKGroupController sharedController] addGroupViewToIconView:self];
    }
}

%end

#pragma mark - SBIconViewMap
%hook SBIconViewMap
- (void)_recycleIconView:(SBIconView *)iconView
{
    [[STKGroupController sharedController] removeGroupViewFromIconView:iconView];
    %orig();
}

- (SBIconView *)mappedIconViewForIcon:(SBIcon *)icon
{
    SBIconView *mappedView = %orig(icon);
    if (!mappedView && [STKGroupController sharedController].openGroupView) {
        mappedView = [[STKGroupController sharedController].openGroupView subappIconViewForIcon:icon];
    }
    return mappedView;
}
%end

#pragma mark - SBRootFolderView
%hook SBFolderView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[STKGroupController sharedController].openGroupView close];
    %orig();
}
%end

#pragma mark - Constructor
%ctor
{
    @autoreleasepool {
        STKLog(@"Initializing");
        %init();
        dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
        [[%c(ISIconSupport) sharedInstance] addExtension:kSTKTweakName];
    }
}
