#ifndef STK_CONSTANTS_H
#define STK_CONSTANTS_H

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFUserNotification.h>
#import <SpringBoard/SpringBoard.h>
#import <objc/runtime.h>
#import <os/log.h>

#import "STKTypes.h"
#import "STKVersion.h"

#import "STKGroup.h"
#import "STKGroupView.h"
#import "STKGroupLayout.h"
#import "STKGroupLayoutHandler.h"
#import "STKIconViewRecycler.h"
#import "STKGroupController.h"

#import "STKOverlayIcons.h"
#import "STKWallpaperBlurView.h"
#import "STKSelectionView.h"
#import "STKGroupSelectionAnimator.h"

#import "SBIconView+Apex.h"
#import "SBIconListView+ApexAdditions.h"

#import "STKStatusBarRecognizerDelegate.h"

#import "STKPreferences.h"

#define kSTKTweakName @"Apex"
#define kSTKPrefsRootName @"Apex 2"

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"[%@] %s [Line %d] " fmt), kSTKTweakName, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
    #define CLog(fmt, ...) NSLog((@"["kSTKTweakName@"] " fmt), ##__VA_ARGS__)
    #define VLog(_formatString, _param) CLog(@"%s = "_formatString, #_param, _param)
#else
    #define DLog(...)
    #define CLog(...)
    #define VLog(...)
#endif

#define LogTimeStart() CFTimeInterval ____start = CACurrentMediaTime()
#define LogTimeEnd() CLog(@"time: %f", CACurrentMediaTime() - ____start)

#define STKLog(fmt, ...) NSLog((@"[" kSTKTweakName @"] " fmt), ##__VA_ARGS__)
#define kPrefPath [NSString stringWithFormat:@"%@/Library/Preferences/com.a3tweaks."kSTKTweakName@".plist", NSHomeDirectory()]
#define PATH_TO_IMAGE(_name) [[NSBundle bundleWithPath:@"/Library/Application Support/Apex.bundle"] pathForResource:_name ofType:@"png"]
#define UIIMAGE_NAMED(_name) [[[UIImage alloc] initWithContentsOfFile:PATH_TO_IMAGE(_name)] autorelease]
#define ISPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define EXECUTE_BLOCK_AFTER_DELAY(delayInSeconds, block) (dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block))

#define IS_7_1()  (STKVersionGreaterThanOrEqualTo(@"7.1"))
#define IS_8_1()  (STKVersionGreaterThanOrEqualTo(@"8.1"))
#define IS_9_0()  (STKVersionGreaterThanOrEqualTo(@"9.0"))
#define IS_10_0() (STKVersionGreaterThanOrEqualTo(@"10.0"))

#undef CLASS
#define CLASS(cls) NSClassFromString(@#cls)

#ifdef __cplusplus
extern "C" {
#endif
    extern NSString * const STKEditingEndedNotificationName;
    extern CFStringRef const STKPrefsChangedNotificationName;

    extern SBIconListView * STKListViewForIcon(SBIcon *icon);
    extern SBIconListView * STKCurrentListView(void);

    extern SBIconCoordinate STKCoordinateFromDictionary(NSDictionary *dict);
    extern NSDictionary * STKDictionaryFromCoordinate(SBIconCoordinate coordinate);

    extern double STKScaleNumber(double numToScale, double prevMin, double prevMax, double newMin, double newMax);

    extern NSString * NSStringFromSTKGroupSlot(STKGroupSlot slot);

    extern BOOL STKVersionGreaterThanOrEqualTo(NSString *version);

    extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
#ifdef __cplusplus
}
#endif


#endif // STK_CONSTANTS_H
