#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#import "Globals.h"
#import "PrefsHelper.h"
#import "STKProfileController.h"

@interface STKPrefsController : PSListController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
- (void)showHeartDialog;
- (void)showMailDialog;
@end