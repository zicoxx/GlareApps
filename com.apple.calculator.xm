
#import "headers.h"


@interface CalcDisplayView : UIView @end



%hook CalcDisplayView

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [UIColor clearColor];
}

%end



%ctor {
	if (!isThisAppEnabled()) return;
	
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.calculator"]) {
		%init;
	}
}
