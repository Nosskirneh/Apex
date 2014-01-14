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

SBFolderZoomSettings *settings = [[(SBPrototypeController *)[%c(SBPrototypeController) sharedInstance] rootSettings] rootAnimationSettings].folderOpenSettings;
SBRootFolderController *rfc = [self _rootFolderController];
SBFolderIcon *folderIcon = [[self currentRootIconList] icons][16];
SBFolder *folder = folderIcon.folder;
SBFolderController *fc = [[%c(SBFolderController) alloc] initWithFolder:folder orientation:[[UIApplication sharedApplication] statusBarOrientation]];
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

*/
static STKGroup *_group;
%hook SBIconController 
%new 
- (id)setUpStackOnWeather
{
    SBRootIconListView *listView = [self rootIconListAtIndex:1];
    NSArray *icons = [listView icons];
    SBIcon *centralIcon = [[self model] expectedIconForDisplayIdentifier:@"com.apple.AppStore"];
    STKGroupLayout *layout = [STKGroupLayoutHandler layoutForIcons:@[icons[12], icons[13], icons[14], icons[15]] aroundIconAtLocation:[STKGroupLayoutHandler locationForIconView:[listView viewForIcon:centralIcon]]];
    STKGroup *group = [[STKGroup alloc] initWithCentralIcon:centralIcon layout:layout];
    _group = group;
    return group;
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
