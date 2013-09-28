#import "NSOperationQueue+STKMainQueueDispatch.h"

@implementation NSOperationQueue (STKMainQueueDispatch)

- (void)stk_addOperationToRunOnMainThreadWithBlock:(void(^)(void))block;
{
	NSAssert((block != nil), @"-[NSOperationQueue(STKMainQueueDispatch) stk_addOperationToRunOnMainThreaadWithBlock:] must have a non-nil block");
	[self addOperationWithBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	}];
}

@end
