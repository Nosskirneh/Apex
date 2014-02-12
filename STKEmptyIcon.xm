#import "STKEmptyIcon.h"
#import "STKConstants.h"

%subclass STKEmptyIcon : SBFolderIcon

- (id)getIconImage:(NSInteger)imgType
{
    return [[[UIImage alloc] init] autorelease];
}

- (BOOL)isEmptyPlaceholder
{
    return YES;
}

- (id)nodeIdentifier
{
	return self;
}

%end

