
#import "headers.h"




#pragma mark -
#pragma mark Settings


static BOOL GlareAppsEnable = YES;
static NSArray *GlareAppsWhiteList = nil;


static void LoadSettings() {
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/User/Library/Preferences/kr.slak.GlareApps.plist"];
	
	GlareAppsEnable = [dict[@"GlareAppsEnable"] boolValue];
	if (dict[@"GlareAppsEnable"] == nil)
		GlareAppsEnable = YES;
	
	if (!GlareAppsWhiteList){
		[GlareAppsWhiteList release];
		GlareAppsWhiteList = nil;
	}
	if (dict[@"WhiteList"] != nil)
		GlareAppsWhiteList = [dict[@"WhiteList"] retain];
	
	isWhiteness = [dict[@"GlareAppsUseWhiteTheme"] boolValue];
	if (dict[@"GlareAppsUseWhiteTheme"] == nil)
		isWhiteness = NO;
	
	[dict release];
}

void reloadPrefsNotification(CFNotificationCenterRef center,
							void *observer,
							CFStringRef name,
							const void *object,
							CFDictionaryRef userInfo) {
	LoadSettings();
}

BOOL isThisAppUIServiceProcess() {
	NSString *executablePath = [[NSBundle mainBundle] executablePath];
	
	if ([executablePath hasSuffix:@"/MessagesViewService"]
			|| [executablePath hasSuffix:@"/MailCompositionService"]
			|| [executablePath hasSuffix:@"/SocialUIService"]
			|| [executablePath hasSuffix:@"/CompassCalibrationViewService"]
			|| [executablePath hasSuffix:@"/GameCenterUIService"]
			|| [executablePath hasSuffix:@"/MusicUIService"]
			|| [executablePath hasSuffix:@"/PassbookUIService"]
			|| [executablePath hasSuffix:@"/StoreKitUIService"]
			|| [executablePath hasSuffix:@"/WebViewService"])
		return YES;
	
	return NO;
}

BOOL isTheAppUIServiceProcess(NSString *bundleIdentifier) {
	if ([bundleIdentifier isEqualToString:@"com.apple.mobilesms.compose"]
			|| [bundleIdentifier isEqualToString:@"com.apple.MailCompositionService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.social.remoteui.SocialUIService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.CompassCalibrationViewService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.gamecenter.GameCenterUIService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.MusicUIService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.PassbookUIService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.ios.StoreKitUIService"]
			|| [bundleIdentifier isEqualToString:@"com.apple.WebViewService"])
		return YES;
	
	return NO;
}

BOOL isThisAppEnabled() {
	if (!GlareAppsEnable) return NO;
	
	if (isThisAppUIServiceProcess()) return YES;
	
	if (GlareAppsWhiteList) {
		if (![GlareAppsWhiteList containsObject:[[NSBundle mainBundle] bundleIdentifier]])
			return NO;
	} else return NO;
	
	return YES;
}

BOOL isTheAppEnabled(NSString *bundleIdentifier) {
	if (!GlareAppsEnable) return NO;
	
	if (isTheAppUIServiceProcess(bundleIdentifier)) return YES;
	
	if (GlareAppsWhiteList) {
		if (![GlareAppsWhiteList containsObject:bundleIdentifier])
			return NO;
	} else return NO;
	
	return YES;
}

void setLabelTextColorIfHasBlackColor(UILabel *label) {
	if (label.attributedText) return;
	
	if ([label.textColor isEqual:[colorHelper blackColor]] 
			|| [label.textColor isEqual:colorHelper.color_0_0__1_0] 
			|| [label.textColor isEqual:colorHelper.rgbBlackColor]) {
		label.textColor = [colorHelper commonTextColor];
		return;
	}
	
	if ([[label.textColor description] hasPrefix:@"UIDeviceWhiteColorSpace"]) {
		CGFloat white = 0.0f, alpha = 0.0f;
		[label.textColor getWhite:&white alpha:&alpha];
		
		if (white != kLightColorWithWhiteForWhiteness && white < 0.4f) {
			label.textColor = [colorHelper commonTextColorWithAlpha:fabs(1.0f-white)*alpha];
		}
	}
}

NSMutableAttributedString *colorReplacedAttributedString(NSAttributedString *text) {
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
	[attributedString enumerateAttributesInRange:(NSRange){0,[attributedString length]} 
										 options:NSAttributedStringEnumerationReverse 
									  usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
		NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
		UIColor *color = mutableAttributes[@"NSColor"];
		if ([[color description] hasPrefix:@"UIDeviceWhiteColorSpace"]) {
			CGFloat white = 0.0f, alpha = 0.0f;
			[color getWhite:&white alpha:&alpha];
			mutableAttributes[@"NSColor"] = [colorHelper commonTextColorWithAlpha:alpha];
		}
		[attributedString setAttributes:mutableAttributes range:range];
	}];
	
	return [attributedString autorelease];
}



#pragma mark -
#pragma mark Global


BOOL isWhiteness							= NO;
BOOL isFirmware70							= YES;
BOOL isFirmware71							= NO;

UIKBRenderConfig *kbRenderConfig			= nil;

GlareAppsColorHelper *colorHelper			= nil;




@implementation UIApplication (GlareApps)

- (void)__glareapps_applicationDidFinishLaunching {
	[[UIApplication sharedApplication] _setApplicationBackdropStyle:kBackdropStyleForWhiteness];
	[[UIApplication sharedApplication] setStatusBarStyle:kBarStyleForWhiteness];
	[[UIApplication sharedApplication] keyWindow].backgroundColor = nil;
}

@end



%group Launching_1

%hook AppDelegate

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	
	[[UIApplication sharedApplication] __glareapps_applicationDidFinishLaunching];
}

%end

%end

%group Launching_2

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL rtn = %orig;
	
	[[UIApplication sharedApplication] __glareapps_applicationDidFinishLaunching];
	
	return rtn;
}

%end

%end

%group Launching_3

%hook AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL rtn = %orig;
	
	[[UIApplication sharedApplication] __glareapps_applicationDidFinishLaunching];
	
	return rtn;
}

%end

%end


%group Rotate_1

%hook AppDelegate

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
	%orig;
	
	[[UIApplication sharedApplication] keyWindow].backgroundColor = [colorHelper keyWindowBackgroundColor];
}

%end

%end

%group Rotate_2

%hook AppDelegate

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
	%orig;
	
	[[UIApplication sharedApplication] keyWindow].backgroundColor = nil;
}

%end

%end


%group Rotate_New_1

%hook AppDelegate

%new
- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
	[[UIApplication sharedApplication] keyWindow].backgroundColor = [colorHelper keyWindowBackgroundColor];
}

%end

%end

%group Rotate_New_2

%hook AppDelegate

%new
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
	[[UIApplication sharedApplication] keyWindow].backgroundColor = nil;
}

%end

%end


%hook UIApplication

- (NSInteger)_loadMainInterfaceFile {
	NSInteger rtn = %orig;
	
	id delegate = [self delegate];
	Class $AppDelegate = delegate ? [delegate class] : [self class];
	
	if ([$AppDelegate instancesRespondToSelector:@selector(applicationDidFinishLaunching:)]) {
		%init(Launching_1, AppDelegate = $AppDelegate);
	}
	else if ([$AppDelegate instancesRespondToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
		%init(Launching_2, AppDelegate = $AppDelegate);
	}
	else if ([$AppDelegate instancesRespondToSelector:@selector(application:willFinishLaunchingWithOptions:)]) {
		%init(Launching_3, AppDelegate = $AppDelegate);
	}
	
	//[[UIApplication sharedApplication] _setApplicationBackdropStyle:kBackdropStyleForWhiteness];
	//[[UIApplication sharedApplication] setStatusBarStyle:kBarStyleForWhiteness];
	//[[UIApplication sharedApplication] keyWindow].backgroundColor = nil;
	
	if ([$AppDelegate instancesRespondToSelector:@selector(application:willChangeStatusBarOrientation:)]) {
		%init(Rotate_1, AppDelegate = $AppDelegate);
	}
	else {
		%init(Rotate_New_1, AppDelegate = $AppDelegate);
	}
	
	if ([$AppDelegate instancesRespondToSelector:@selector(application:didChangeStatusBarOrientation:)]) {
		%init(Rotate_2, AppDelegate = $AppDelegate);
	}
	else {
		%init(Rotate_New_2, AppDelegate = $AppDelegate);
	}
	
	return rtn;
}

%end


%hook UINavigationController

- (BOOL)_clipUnderlapWhileTransitioning {
	return YES;
}

%end

%hook _UINavigationParallaxTransition

- (BOOL)clipUnderlapWhileTransitioning {
	return YES;
}

- (void)setClipUnderlapWhileTransitioning:(BOOL)flag {
	%orig(YES);
}

%end


void clearBar(UIView *view) {
	if (![view respondsToSelector:@selector(setBarTintColor:)] || ![view respondsToSelector:@selector(setTranslucent:)]) return;
	
	UINavigationBar *bar = (UINavigationBar *)view;
	
	bar.barStyle = kBarStyleForWhiteness;
	
	bar.barTintColor = nil;
	bar.backgroundColor = [colorHelper clearColor];
	bar.translucent = YES;
	
	[bar setNeedsLayout];
}

%hook UIViewController

- (void)viewWillAppear:(BOOL)animated {
	//clearBar(self.navigationController.navigationBar);
	//clearBar(self.navigationController.toolbar);
	//clearBar(self.tabBarController.tabBar);
	
	%orig;
	
	[[UIApplication sharedApplication] setStatusBarStyle:kBarStyleForWhiteness];
	self.view.backgroundColor = [colorHelper themedFakeClearColor];
	self.dropShadowView.backgroundColor = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	%orig;
	
	[[UIApplication sharedApplication] setStatusBarStyle:kBarStyleForWhiteness];
}

%end


@implementation UIView (GlareApps)

- (void)__glareapps_backgroundTest {
	UIColor *color = self.backgroundColor;
	
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Music"])
		return;
	
	if ([self isKindOfClass:[UITableViewCell class]]) {
		return;
	}
	
	if ([self respondsToSelector:@selector(setTransparentBackground:)]) {
		[self performSelector:@selector(setTransparentBackground:) withObject:@(YES)];
	}
	
	NSString *selfclass = NSStringFromClass(self.class);
	NSString *superviewclass = NSStringFromClass(self.superview.class);
	
	if ([selfclass hasPrefix:@"_UIModalItem"]) {
		return;
	}
	if ([selfclass hasPrefix:@"_UI"] || [superviewclass hasPrefix:@"_UI"]) {
		return;
	}
	if ([selfclass hasPrefix:@"UISearch"] || [superviewclass hasPrefix:@"UISearch"]) {
		return;
	}
	if ([selfclass hasPrefix:@"UIAction"] || [superviewclass hasPrefix:@"UIAction"]) {
		return;
	}
	if ([selfclass hasPrefix:@"UIAlert"] || [superviewclass hasPrefix:@"UIAlert"]) {
		return;
	}
	if ([superviewclass isEqualToString:@"UIPageControl"]) {
		return;
	}
	if (self.window != nil && self.window != [UIApplication sharedApplication].keyWindow) {
		return;
	}
	
	if ([color isEqual:[colorHelper clearColor]]) {
		return;
	}
	if ([color isEqual:[colorHelper blackColor]] || [color isEqual:[colorHelper whiteColor]]) {
		self.backgroundColor = [colorHelper clearColor];
		return;
	}
	if (color != nil && ![color isEqual:[colorHelper clearColor]]
			&& [[color description] hasPrefix:@"UIDeviceWhiteColorSpace"]
			&& ![color isEqual:[colorHelper keyWindowBackgroundColor]]
			&& ![color isEqual:[colorHelper preferencesUITableViewBackgroundColor]]
			&& ![color isEqual:[colorHelper themedFakeClearColor]]
			&& ![color isEqual:[colorHelper defaultTableViewCellBackgroundColor]]) {
		//self.backgroundColor = [colorHelper clearColor];
		return;
	}
}

@end

%hook UIView

- (id)initWithFrame:(CGRect)frame {
	id rtn = %orig;
	
	if (rtn) {
		[self __glareapps_backgroundTest];
	}
	
	return rtn;
}

- (id)init {
	id rtn = %orig;
	
	if (rtn) {
		[self __glareapps_backgroundTest];
	}
	
	return rtn;
}

- (id)initWithCoder:(id)zone {
	id rtn = %orig;
	
	if (rtn) {
		[self __glareapps_backgroundTest];
	}
	
	return rtn;
}

- (void)layoutSubviews {
	[self __glareapps_backgroundTest];
	
	%orig;
}

- (void)setBackgroundColor:(UIColor *)color {
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Music"]) {
		%orig;
		return;
	}
	
	if ([self isKindOfClass:[UITableViewCell class]]) {
		%orig;
		return;
	}
	
	NSString *selfclass = NSStringFromClass(self.class);
	NSString *superviewclass = NSStringFromClass(self.superview.class);
	
	if ([selfclass hasPrefix:@"_UIModalItem"]) {
		%orig;
		return;
	}
	if ([selfclass hasPrefix:@"_UI"] || [superviewclass hasPrefix:@"_UI"]) {
		%orig;
		return;
	}
	if ([selfclass hasPrefix:@"UISearch"] || [superviewclass hasPrefix:@"UISearch"]) {
		%orig;
		return;
	}
	if ([selfclass hasPrefix:@"UIAction"] || [superviewclass hasPrefix:@"UIAction"]) {
		%orig;
		return;
	}
	if ([selfclass hasPrefix:@"UIAlert"] || [superviewclass hasPrefix:@"UIAlert"]) {
		%orig;
		return;
	}
	if ([superviewclass isEqualToString:@"UIPageControl"]) {
		%orig;
		return;
	}
	if (self.window != nil && self.window != [UIApplication sharedApplication].keyWindow) {
		%orig;
		return;
	}
	
	if ([color isEqual:[colorHelper clearColor]]) {
		%orig;
		return;
	}
	if ([color isEqual:[colorHelper whiteColor]]) {
		%orig([colorHelper clearColor]);
		return;
	}
	if (color != nil && ![color isEqual:[colorHelper clearColor]]
			&& [[color description] hasPrefix:@"UIDeviceWhiteColorSpace"]
			&& ![color isEqual:[colorHelper keyWindowBackgroundColor]]
			&& ![color isEqual:[colorHelper preferencesUITableViewBackgroundColor]]
			&& ![color isEqual:[colorHelper themedFakeClearColor]]
			&& ![color isEqual:[colorHelper defaultTableViewCellBackgroundColor]]) {
		//%orig([colorHelper clearColor]);
		//return;
	}
	
	%orig;
}

%end


@implementation UILabel (GlareApps)

- (BOOL)__glareapps_isActionSheetOrActivityGroup {
	BOOL isActionSheetOrActivityGroup = NO;
	
	NSString *superviewName = NSStringFromClass([self.superview class]);
	NSString *supersuperviewName = NSStringFromClass([self.superview.superview class]);
	
	isActionSheetOrActivityGroup = [superviewName hasPrefix:@"UIActionSheet"];
	if (!isActionSheetOrActivityGroup && [superviewName hasPrefix:@"UIAlert"]) {
		isActionSheetOrActivityGroup = [supersuperviewName hasPrefix:@"UIActionSheet"];
	}
	if (!isActionSheetOrActivityGroup)
		isActionSheetOrActivityGroup = [superviewName hasPrefix:@"UIActivityGroup"];
	if (!isActionSheetOrActivityGroup)
		isActionSheetOrActivityGroup = [superviewName hasPrefix:@"_UIToolbar"];
	
	return isActionSheetOrActivityGroup;
}

@end


%hook UILabel

- (void)setTextColor:(UIColor *)textColor {
	CGFloat white = 0.0f, alpha = 0.0f;
	
	if (![self.superview isKindOfClass:%c(UITableViewCellContentView)] 
			&& [[textColor description] hasPrefix:@"UIDeviceWhiteColorSpace"] && [textColor getWhite:&white alpha:&alpha]) {
		if (white == 0.5f && alpha == 1.0f)
			textColor = [colorHelper systemGrayColor];
	}
	
	NSString *selfText = nil;
	if ([self isKindOfClass:%c(UIDateLabel)])
		selfText = ((UIDateLabel *)self)._dateString;
	else
		selfText = self.text;
	
	if (!isWhiteness && selfText && ![self __glareapps_isActionSheetOrActivityGroup]
			&& [[textColor description] hasPrefix:@"UIDeviceWhiteColorSpace"] && [textColor getWhite:&white alpha:&alpha]) {
		if (white != kLightColorWithWhiteForWhiteness)
			textColor = [UIColor colorWithWhite:fabs(kLightColorWithWhiteForWhiteness - white) alpha:alpha];
	}
	
	%orig;
}

- (void)setText:(NSString *)text {
	%orig;
	
	self.textColor = self.textColor;
}

- (void)setAttributedText:(NSAttributedString *)text {
	%orig(colorReplacedAttributedString(text));
}

%end


%hook UITextView

- (void)setTextColor:(UIColor *)textColor {
	CGFloat white = 0.0f, alpha = 0.0f;
	
	if (![self.superview isKindOfClass:%c(UITableViewCellContentView)] 
			&& [[textColor description] hasPrefix:@"UIDeviceWhiteColorSpace"] && [textColor getWhite:&white alpha:&alpha]) {
		if (white == 0.5f && alpha == 1.0f)
			textColor = [colorHelper systemGrayColor];
		else if ((!isWhiteness && white < 0.5f) || (isWhiteness && white > 0.5f))
			textColor = [UIColor colorWithWhite:fabs(1.0f-white) alpha:alpha];
	}
	
	%orig;
}

- (UIKeyboardAppearance)keyboardAppearance {
	return (isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark);
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)appearance {
	%orig((isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark));
}

- (void)layoutSubviews {
	%orig;
	
	if (!isWhiteness && [self.textColor isEqual:[colorHelper blackColor]])
		self.textColor = [colorHelper commonTextColor];
	if ([self respondsToSelector:@selector(setKeyboardAppearance:)] && ![self isKindOfClass:%c(CKBalloonTextView)])
		self.keyboardAppearance = (isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark);
}

%end

%hook UITextField

- (UIKeyboardAppearance)keyboardAppearance {
	return (isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark);
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)appearance {
	%orig((isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark));
}

- (void)layoutSubviews {
	%orig;
	
	NSString *superviewName = NSStringFromClass([self.superview class]);
	
	if (!isWhiteness && [self.textColor isEqual:[colorHelper blackColor]] && ![superviewName hasPrefix:@"_UIModalItem"])
		self.textColor = [colorHelper commonTextColor];
	if ([self respondsToSelector:@selector(setKeyboardAppearance:)])
		self.keyboardAppearance = (isWhiteness ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark);
}

- (id)_placeholderColor {
	return [colorHelper systemGrayColor];
}

- (void)setTextColor:(UIColor *)textColor {
	CGFloat white = 0.0f, alpha = 0.0f;
	
	if ([[textColor description] hasPrefix:@"UIDeviceWhiteColorSpace"] && [textColor getWhite:&white alpha:&alpha]) {
		if ((!isWhiteness && white < 0.5f) || (isWhiteness && white > 0.5f))
			textColor = [UIColor colorWithWhite:fabs(1.0f-white) alpha:alpha];
	}
	
	%orig;
}

%end


%hook UIKBRenderConfig

+ (id)darkConfig {
	return kbRenderConfig;
}
+ (id)defaultConfig {
	return kbRenderConfig;
}

%end


%hook _UIModalItemContentView

- (void)layout {
	%orig;
	
	self.backgroundColor = nil;
	self.buttonTable.backgroundColor = nil;
	self.titleLabel.textColor = [colorHelper commonTextColor];
	self.subtitleLabel.textColor = [colorHelper commonTextColor];
	self.messageLabel.textColor = [colorHelper commonTextColor];
}

%end

%hook _UIModalItemAlertContentView

- (void)layout {
	%orig;
	
	self.backgroundColor = nil;
	self.buttonTable.backgroundColor = nil;
	self.titleLabel.textColor = [colorHelper commonTextColor];
	self.subtitleLabel.textColor = [colorHelper commonTextColor];
	self.messageLabel.textColor = [colorHelper commonTextColor];
}

%end

%hook _UIModalItemRepresentationView

- (void)setUseFakeEffectSource:(BOOL)useFakeEffectSource animated:(BOOL)animated {
	%orig;//(NO, animated);
	
	UIView *_fakeEffectSourceView = MSHookIvar<UIView *>(self, "_fakeEffectSourceView");
	_fakeEffectSourceView.backgroundColor = [colorHelper defaultAlertViewRepresentationViewBackgroundColor];
}

%end


%hook UIColor

+ (id)darkTextColor {
	UIColor *color = %orig;
	return [colorHelper commonTextColorWithAlpha:color.alphaComponent];
}
+ (id)lightTextColor {
	UIColor *color = %orig;
	return [colorHelper lightTextColorWithAlpha:color.alphaComponent];
}
+ (id)systemGrayColor {
	return [colorHelper systemGrayColor];
}
+ (UIColor *)darkGrayColor {
	return [colorHelper systemDarkGrayColor];
}
+ (UIColor *)lightGrayColor {
	return [colorHelper systemLightGrayColor];
}
+ (id)tableCellDefaultSelectionTintColor {
	return [colorHelper systemLightGrayColor];
}
+ (id)tableSelectionGradientEndColor {
	return [colorHelper systemLightGrayColor];
}
+ (id)tableSelectionGradientStartColor {
	return [colorHelper systemDarkGrayColor];
}
+ (id)tableSelectionColor {
	return [colorHelper systemLightGrayColor];
}
+ (id)tablePlainHeaderFooterFloatingBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)tablePlainHeaderFooterBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)tableCellbackgroundColorPigglyWiggly {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)tableCellBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)tableCellGroupedBackgroundColorLegacyWhite {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)tableCellPlainBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)tableBackgroundColor {
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"])
		return [colorHelper preferencesUITableViewBackgroundColor];
	
	return [colorHelper clearColor];
}
+ (id)sectionHeaderOpaqueBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)sectionHeaderBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)tableCellGrayTextColor {
	return [colorHelper systemGrayColor];
}
+ (id)noContentDarkGradientBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)noContentLightGradientBackgroundColor {
	return [colorHelper clearColor];
}
+ (id)tableGroupedSeparatorLightColor {
	return [colorHelper defaultTableViewSeparatorColor];
}
+ (id)tableSeparatorLightColor {
	return [colorHelper defaultTableViewSeparatorColor];
}
+ (id)tableSeparatorDarkColor {
	return [colorHelper defaultTableViewSeparatorColor];
}
+ (id)tableCellGroupedBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)groupTableViewBackgroundColor {
	return [colorHelper clearColor];
}

%end



#pragma mark -
#pragma mark UICollectionView


%hook UICollectionView

- (void)layoutSubviews {
	%orig;
	
	self.backgroundView = nil;
	self.backgroundColor = nil;
}

- (void)_updateBackgroundView {
	//%orig;
	
	self.backgroundView = nil;
	self.backgroundColor = nil;
}

%end


%hook UICollectionViewCell

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [colorHelper clearColor];
	self.backgroundView.alpha = 0.0f;
	self.contentView.backgroundColor = [colorHelper clearColor];
}

- (void)_updateBackgroundView {
	%orig;
	
	self.backgroundView = nil;
	self.backgroundColor = [colorHelper clearColor];
}

%end



#pragma mark -
#pragma mark UITableView (basic)


%hook UITableView

- (void)layoutSubviews {
	%orig;

	if (self.superview) {
		self.sectionIndexBackgroundColor = [colorHelper defaultTableViewCellBackgroundColor];
	}
}

- (UIColor *)backgroundColor {
	return [colorHelper clearColor];
}

- (void)setBackgroundColor:(id)color {
	%orig([colorHelper clearColor]);
}

- (void)_setBackgroundColor:(id)color animated:(BOOL)animated {
	%orig([colorHelper clearColor], animated);
}

- (UIColor *)sectionIndexBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}

- (void)setSectionIndexBackgroundColor:(UIColor *)color {
	%orig([colorHelper defaultTableViewCellBackgroundColor]);
}

- (id)_defaultSeparatorColor {
	return [colorHelper defaultTableViewSeparatorColor];
}

- (UIColor *)separatorColor {
	return [colorHelper defaultTableViewSeparatorColor];
}

- (void)setSeparatorColor:(UIColor *)color {
	%orig([colorHelper defaultTableViewSeparatorColor]);
}

- (id)tableHeaderBackgroundColor {
	return [colorHelper clearColor];
}

- (void)setTableHeaderBackgroundColor:(id)color {
	%orig([colorHelper clearColor]);
}

//- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style {
//	%orig(UITableViewCellSeparatorStyleSingleLine);
//}

%end


@implementation UITableViewHeaderFooterView (GlareApps)

- (void)__glareapps_setBackground {
	if ([self isKindOfClass:%c(ABGroupHeaderFooterView)]) return;
	
	if (self.tableView && ![self.backgroundView isKindOfClass:%c(_UIBackdropView)]) {
		self.backgroundColor = nil;
		self.contentView.backgroundColor = [colorHelper clearColor];
		self.tintColor = nil;
		if ([self respondsToSelector:@selector(setBackgroundImage:)])
			self.backgroundImage = nil;
		
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleSystemDefaultSemiLight graphicsQuality:kBackdropGraphicQualitySystemDefault];
		settings.grayscaleTintLevel = (isWhiteness ? 1.0f : 0.0f);
		
		if (![self.backgroundView isKindOfClass:[_UIBackdropView class]]) {
			_UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
			self.backgroundView = backdropView;
			[backdropView release];
		}
	}
}

@end

%hook UITableViewHeaderFooterView

- (void)layoutSubviews {
	%orig;
	
	self.textLabel.textColor = [colorHelper systemGrayColor];
	
	if (self.tableView != nil && self.tableView.style == UITableViewStyleGrouped) return;
	if ([self.class requiresConstraintBasedLayout]) return;
	
	[self __glareapps_setBackground];
}

- (void)updateConstraints {
	%orig;
	
	self.textLabel.textColor = [colorHelper systemGrayColor];
	
	if (self.tableView != nil && self.tableView.style == UITableViewStyleGrouped) return;
	if (![self.class requiresConstraintBasedLayout]) return;
	
	[self __glareapps_setBackground];
}

%end


UIImage *disclosureImage = nil;
UIImage *disclosureImageWhite = nil;
UIImage *disclosureImageBlack = nil;

void setDisclosureImage(UIImageView *iv) {
	if (disclosureImageBlack == nil) {
		disclosureImageBlack = [iv.image _flatImageWithColor:colorHelper.color_0_0__0_4];
		disclosureImageWhite = [iv.image _flatImageWithColor:colorHelper.color_1_0__0_4];
		[disclosureImageBlack retain];
		[disclosureImageWhite retain];
	}
	if (disclosureImage == nil) {
		if (isWhiteness)
			disclosureImage = disclosureImageBlack;
		else
			disclosureImage = disclosureImageWhite;
	}
	
	if (iv.image != disclosureImage)
		iv.image = disclosureImage;
}

@implementation UITableViewCell (GlareApps)

- (BOOL)__glareapps_isNeedsToSetJustClearBackground {
	return NO;
}

@end

%hook UITableViewCell

- (void)layoutSubviews {
	%orig;
	
	if ([self __glareapps_isNeedsToSetJustClearBackground])
		self.backgroundColor = [colorHelper defaultTableViewCellBackgroundColor];
	
	self.textLabel.backgroundColor = [colorHelper clearColor];
	self.detailTextLabel.backgroundColor = [colorHelper clearColor];
	self.detailTextLabel.textColor = [colorHelper systemGrayColor];
	
	setLabelTextColorIfHasBlackColor(self.textLabel);
	
	for (UILabel *label in self.contentView.subviews) {
		if ([label isKindOfClass:[UILabel class]]) {
			label.backgroundColor = [colorHelper clearColor];
			
			setLabelTextColorIfHasBlackColor(label);
		}
	}
	
	if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
		UIView *accessoryView = [self _currentAccessoryView:YES];
		
		for (UIView *v in accessoryView.subviews) {
			if (v.alpha == 0.0f) continue;
			
			if ([v isKindOfClass:[UIImageView class]]) {
				setDisclosureImage((UIImageView *)v);
				
				break;
			}
		}
	}
}

%end

%hook UITableViewCellDetailDisclosureView

- (CGSize)sizeThatFits:(CGSize)fitSize {
	CGSize rtn = %orig;
	
	UIImageView *_disclosureView = MSHookIvar<UIImageView *>(self, "_disclosureView");
	
	setDisclosureImage(_disclosureView);
	
	return rtn;
}

%end


UIImage *reorderImage = nil;
UIImage *reorderImageWhite = nil;
UIImage *reorderImageBlack = nil;

%hook UITableViewCellReorderControl

+ (id)grabberImage {
	if (reorderImageBlack == nil) {
		UIImage *rtn = %orig;
		
		reorderImageBlack = [rtn _flatImageWithColor:colorHelper.color_0_0__0_4];
		reorderImageWhite = [rtn _flatImageWithColor:colorHelper.color_1_0__0_4];
		[reorderImageBlack retain];
		[reorderImageWhite retain];
	}
	if (reorderImage == nil) {
		if (isWhiteness)
			reorderImage = reorderImageBlack;
		else
			reorderImage = reorderImageWhite;
	}
	
	return reorderImage;
}

%end


%hook UIGroupTableViewCellBackground

- (id)backgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
- (void)setBackgroundColor:(id)color {
	%orig([colorHelper defaultTableViewCellBackgroundColor]);
}
- (UIColor *)selectionTintColor {
	return %orig;
}
- (void)setSelectionTintColor:(id)color {
	%orig;
}
- (void)setSelectionTintColor:(id)color layoutSubviews:(BOOL)arg2 {
	%orig;
}

%end



#pragma mark -
#pragma mark UITabBar


%hook UITabBarButton

- (void)_setUnselectedTintColor:(UIColor *)tintColor forceLabelToConform:(BOOL)labelConform {
	tintColor = [colorHelper systemGrayColor];
	labelConform = YES;
	
	%orig;
}

// >= 7.1
- (void)_setContentTintColor:(UIColor *)color forState:(UIControlState)state {
	if (state == UIControlStateNormal) {
		%orig([colorHelper systemGrayColor], state);
		return;
	}
	
	%orig;
}

%end



#pragma mark -
#pragma mark UIPickerView


%hook UIPickerView

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [colorHelper clearColor];
}

%end



#pragma mark -
#pragma mark BackdropView Control


%hook UISearchBar

- (UIImage *)backgroundImage {
	return nil;
}

- (void)setBackgroundImage:(UIImage *)image {
	%orig(nil);
}

- (UIBarStyle)barStyle {
	return kBarStyleForWhiteness;
}

- (void)setBarStyle:(UIBarStyle)style {
	%orig(kBarStyleForWhiteness);
}

- (UIColor *)barTintColor {
	return nil;
}

- (void)setBarTintColor:(UIColor *)color {
	%orig(nil);
}

- (UIColor *)backgroundColor {
	return [colorHelper clearColor];
}

- (void)setBackgroundColor:(UIColor *)color {
	%orig([colorHelper clearColor]);
}

- (BOOL)isTranslucent {
	return YES;
}

- (void)setTranslucent:(BOOL)translucent {
	%orig(YES);
}

- (void)layoutSubviews {
	self.searchBarStyle = UISearchBarStyleMinimal;
	self.barStyle = kBarStyleForWhiteness;
	
	%orig;
	
	self.barTintColor = nil;
	self.backgroundColor = [colorHelper clearColor];
	self.backgroundImage = nil;
}

- (void)_setStatusBarTintColor:(UIColor *)color {
	
}

- (void)_updateNeedForBackdrop {
	[self _setBackdropStyle:kBackdropStyleForWhiteness];
	
	%orig;
	
	_UIBackdropView *backdropView = MSHookIvar<_UIBackdropView *>(self, "_backdrop");
	
	if (backdropView != nil) {
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleSystemDefaultSemiLight graphicsQuality:kBackdropGraphicQualitySystemDefault];
		settings.grayscaleTintLevel = (isWhiteness ? 1.0f : 0.0f);
		settings.grayscaleTintAlpha = (([self.controller respondsToSelector:@selector(isActive)] && self.controller.isActive) ? kTintColorAlphaFactor : 0.0f);
		if (isWhiteness)
			settings.grayscaleTintAlpha *= 1.5f;
		//settings.blurRadius = 30.0f;
		
		[backdropView transitionToSettings:settings];
	}
}

- (id)_glyphAndTextColor:(BOOL)unknown {
	// placeholder
	if (!unknown) {
		return [colorHelper systemGrayColor];
	}
	
	return %orig;
}

%end


%hook UISearchDisplayController

- (void)showHideAnimationDidFinish {
	%orig;
	
	if (!self.isActive) {
		UINavigationBar *navBar = self.navigationItem.navigationBar;
		
		if (!navBar) {
			id _navigationControllerBookkeeper = MSHookIvar<id>(self, "_navigationControllerBookkeeper");
			
			if ([_navigationControllerBookkeeper isKindOfClass:[UINavigationController class]]) {
				UINavigationController *nc = (UINavigationController *)_navigationControllerBookkeeper;
				navBar = nc.navigationBar;
			}
		}
		
		[navBar setNeedsLayout];
	}
}

%end


%hook _UIContentUnavailableView

- (void)_updateViewHierarchy {
	%orig;
	
	self.backgroundColor = [colorHelper clearColor];
	
	_UIBackdropView *_backdrop = MSHookIvar<_UIBackdropView *>(self, "_backdrop");
	
	if (_backdrop.style != kBackdropStyleSystemDefaultClear)
		[_backdrop transitionToStyle:kBackdropStyleSystemDefaultClear];
}

%end


%hook _UIModalItemAlertBackgroundView

- (void)layoutSubviews {
	%orig;
	
	_UIBackdropView *_effectView = MSHookIvar<_UIBackdropView *>(self, "_effectView");
	
	NSInteger style = (isWhiteness ? kBackdropStyleSystemDefaultUltraLight : kBackdropStyleSystemDefaultDark);
	if (_effectView.style != style)
		[_effectView transitionToStyle:style];
	
	UIImageView *_fillingView = MSHookIvar<UIImageView *>(self, "_fillingView");
	_fillingView.alpha = (isWhiteness ? 1.0f : 0.0f);
}

%end


%hook _UIModalItemActionSheetContentView

- (void)layout {
	%orig;
	
	_UIBackdropView *_effectView = MSHookIvar<_UIBackdropView *>(self, "_effectView");
	
	NSInteger style = (isWhiteness ? kBackdropStyleSystemDefaultUltraLight : kBackdropStyleSystemDefaultDark);
	if (_effectView.style != style)
		[_effectView transitionToStyle:style];
}

%end


%hook UIActionSheet

- (void)layout {
	%orig;
	
	_UIBackdropView *_backdropView = nil;
	if (isFirmware71) {
		_backdropView = MSHookIvar<_UIBackdropView *>(self, "_backgroundView");
	}
	else {
		_backdropView = MSHookIvar<_UIBackdropView *>(self, "_backdropView");
	}
	
	if (![_backdropView isKindOfClass:[_UIBackdropView class]]) return;
	
	UIImage *grayscaleTintMaskImage = [_backdropView.inputSettings.grayscaleTintMaskImage retain];
	UIImage *colorTintMaskImage = [_backdropView.inputSettings.colorTintMaskImage retain];
	UIImage *filterMaskImage = [_backdropView.inputSettings.filterMaskImage retain];
	
	NSInteger style = (isWhiteness ? kBackdropStyleSystemDefaultUltraLight : kBackdropStyleSystemDefaultUltraDark);
	if (_backdropView.style != style) {
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:style];
		settings.blurRadius = 7.0f;
		settings.grayscaleTintMaskImage = grayscaleTintMaskImage;
		settings.colorTintMaskImage = colorTintMaskImage;
		settings.filterMaskImage = filterMaskImage;
		
		[_backdropView transitionToSettings:settings];
	}
	
	[grayscaleTintMaskImage release];
	[colorTintMaskImage release];
	[filterMaskImage release];
}

%end

%hook _UIActionSheetBlendingHighlightView

- (id)initWithFrame:(CGRect)frame colorBurnColor:(id)burnColor plusDColor:(id)plusDColor {
	if (isWhiteness) return %orig;
	
	burnColor = colorHelper.color_0_9__0_2;
	
	return %orig;
}

%end

%hook _UIActionSheetBlendingSeparatorView

- (id)initWithFrame:(CGRect)frame {
	_UIActionSheetBlendingSeparatorView *rtn = %orig;
	
	if (rtn && !isWhiteness) {
		UIView *_colorBurnView = MSHookIvar<UIView *>(rtn, "_colorBurnView");
		
		[_colorBurnView.layer setCompositingFilter:nil];
	}
	
	return rtn;
}

%end

%hook UIAlertButton

- (void)setHighlightImage:(UIImage *)image {
	if (!isWhiteness)
		image = [image _flatImageWithColor:[colorHelper commonTextColor]];
	
	%orig;
}

%end


%hook UIActivityGroupListViewController

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	
	if (self.backdropView.style != kBackdropStyleForWhiteness)
		[self.backdropView transitionToStyle:kBackdropStyleForWhiteness];
}

%end


%hook _UIPopoverStandardChromeView

- (void)layoutSubviews {
	%orig;
	
	_UIBackdropView *_blurView = MSHookIvar<_UIBackdropView *>(self, "_blurView");
	
	if (_blurView.style != kBackdropStyleForWhiteness)
		[_blurView transitionToStyle:kBackdropStyleForWhiteness];
}

%end

%hook _UIPopoverView

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [colorHelper clearColor];
	self.standardChromeView.backgroundColor = [colorHelper clearColor];
	self.backgroundView.backgroundColor = [colorHelper clearColor];
	self.contentView.backgroundColor = [colorHelper clearColor];
	self.toolbarShine.alpha = 0.0f;
}

%end


%hook _UIBackdropView

- (void)transitionToSettings:(_UIBackdropViewSettings *)newSettings {
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:newSettings.style];
	if (settings.blurRadius == newSettings.blurRadius 
			&& settings.grayscaleTintAlpha == newSettings.grayscaleTintAlpha
			&& settings.grayscaleTintLevel == newSettings.grayscaleTintLevel) {
		if (isWhiteness && newSettings.style == kBackdropStyleSystemDefaultSemiLight) {
			%orig;
			return;
		}
		if (self.inputSettings.style != kBackdropStyleForWhiteness && self.inputSettings.style != newSettings.style) {
			%orig;
			return;
		}
		if (self.inputSettings != nil)
			return;
	}
	
	%orig;
}

- (id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)fitSuperview settings:(_UIBackdropViewSettings *)newSettings {
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:newSettings.style];
	if (settings.blurRadius == newSettings.blurRadius 
			&& settings.grayscaleTintAlpha == newSettings.grayscaleTintAlpha
			&& settings.grayscaleTintLevel == newSettings.grayscaleTintLevel) {
		if (newSettings.style != kBackdropStyleForWhiteness 
				&& (newSettings.style == kBackdropStyleSystemDefaultUltraLight || newSettings.style == kBackdropStyleSystemDefaultLight 
						|| newSettings.style == kBackdropStyleSystemDefaultDark || newSettings.style == kBackdropStyleSystemDefaultAdaptiveLight)) {
			_UIBackdropViewSettings *styledSettings = [_UIBackdropViewSettings settingsForPrivateStyle:kBackdropStyleForWhiteness];
			
			return %orig(frame, fitSuperview, styledSettings);
		}
		if (newSettings.style != kBackdropStyleForWhiteness 
				&& (newSettings.style == kBackdropStyleSystemDefaultLightLow || newSettings.style == kBackdropStyleSystemDefaultDarkLow)) {
			_UIBackdropViewSettings *styledSettings = [_UIBackdropViewSettings settingsForPrivateStyle:kBackdropStyleForWhiteness+9];
			
			return %orig(frame, fitSuperview, styledSettings);
		}
	}
	if (newSettings == nil) {
		newSettings = [_UIBackdropViewSettings settingsForPrivateStyle:kBackdropStyleForWhiteness];
	}
	
	return %orig;
}

%end



#pragma mark -
#pragma mark Additional BackdropView


@implementation UIViewController (GlareApps)

- (BOOL)__glareapps_isNeedsToHasBackdrop {
	if ([self isKindOfClass:%c(_UIModalItemsPresentingViewController)]) return NO;
	if ([self isKindOfClass:[UIActivityViewController class]]) return NO;
	if ([self isKindOfClass:%c(SLComposeViewController)]) return NO;
	//MFMessageComposeViewController
	//MFMailComposeViewController
	//SKComposeReviewViewController
	
	return YES;
}

@end


%hook UIViewController

- (void)presentViewController:(UIViewController *)viewController withTransition:(UIViewAnimationTransition)transition completion:(id)fp_ {
	if ([viewController __glareapps_isNeedsToHasBackdrop]) {
		BOOL alreadyExists = NO;
		if (viewController.view.subviews.count > 0 && [viewController.view.subviews[0] isKindOfClass:[_UIBackdropView class]]) {
			_UIBackdropView *view = viewController.view.subviews[0];
			if (view.tag != 0xc001) {
				view.alpha = 0.0f;
				alreadyExists = YES;
			}
		}
		
		if ([viewController.view isKindOfClass:[_UIBackdropView class]]) {
			_UIBackdropView *backdropView = (_UIBackdropView *)viewController.view;
			
			_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleForWhiteness graphicsQuality:kBackdropGraphicQualitySystemDefault];
			
			[backdropView transitionToSettings:settings];
		}
		else {
			_UIBackdropView *backdropView = (_UIBackdropView *)[viewController.view viewWithTag:0xc001];
			[backdropView retain];
			
			if (backdropView == nil) {
				CGRect frame = viewController.view.frame;
				frame.origin.x = 0;
				
				_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleForWhiteness graphicsQuality:kBackdropGraphicQualitySystemDefault];
				if (!alreadyExists)
					settings.grayscaleTintAlpha = 0.3f;
				
				backdropView = [[_UIBackdropView alloc] initWithFrame:frame autosizesToFitSuperview:YES settings:settings];
				backdropView.tag = 0xc001;
				
				[viewController.view insertSubview:backdropView atIndex:0];
				
				backdropView.frame = frame;
			}
			
			[backdropView release];
		}
	}
	
	%orig;
}

%end


%hook UIPrintPanelViewController

- (void)_presentWindow {
	%orig;
	
	UIWindow *_window = MSHookIvar<UIWindow *>(self, "_window");
	
	_UIBackdropView *backdropView = (_UIBackdropView *)[_window viewWithTag:0xc001];
	[backdropView retain];
	
	if (backdropView == nil) {
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleForWhiteness graphicsQuality:kBackdropGraphicQualitySystemDefault];
		settings.grayscaleTintAlpha = 0.3f;
		
		backdropView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
		backdropView.tag = 0xc001;
		
		[_window insertSubview:backdropView atIndex:0];
	}
	
	[backdropView release];
}

%end




#pragma mark -
#pragma mark AddressBook


%hook ABMemberCell

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [colorHelper clearColor];
	self.contactNameView.backgroundColor = [colorHelper clearColor];
	
	if (!isFirmware71) {
		self.contactNameView.meLabel.backgroundColor = [colorHelper clearColor];
		self.contactNameView.meLabel.textColor = [colorHelper systemGrayColor];
		self.contactNameView.nameLabel.backgroundColor = [colorHelper clearColor];
	}
}

%end


%hook ABMemberNameView

- (BOOL)isUserInteractionEnabled {
	return %orig;//YES;
}

- (void)drawRect:(CGRect)rect {
	self.backgroundColor = [colorHelper clearColor];
	
	BOOL isHighlighted = self.highlighted;
	self.highlighted = YES;
	
	%orig;
	
	self.highlighted = isHighlighted;
}

%end


%hook ABMembersController

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	
	self.currentTableView.backgroundColor = [colorHelper clearColor];
	self.currentTableView.sectionIndexBackgroundColor = [colorHelper defaultTableViewCellBackgroundColor];
}

%end



%hook ABStyleProvider

- (UIColor *)groupCellTextColor {
	return [colorHelper commonTextColor];
}

- (BOOL)groupsTableShouldRemoveBackgroundView {
	return YES;
}

- (BOOL)peoplePickerBarStyleIsTranslucent {
	return YES;
}

- (UIBarStyle)peoplePickerBarStyle {
	return kBarStyleForWhiteness;
}

- (BOOL)shouldUsePeoplePickerBarStyle {
	return YES;
}

- (id)cardCellBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}

- (UIColor *)cardLabelBackgroundColor {
	return [colorHelper clearColor];
}

- (id)cardCellDividerColorVertical:(BOOL)vertical {
	return [colorHelper lightTextColor];
}

- (UIColor *)memberNameTextColor {
	return [colorHelper commonTextColor];
}

- (UIColor *)cardValueTextColor {
	return [colorHelper commonTextColor];
}

%end


%hook ABMembersDataSource

- (void)tableView:(UIView *)tableView willDisplayHeaderView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section {
	%orig;
	
	if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
		if (![view.backgroundView isKindOfClass:%c(_UIBackdropView)]) {
			view.contentView.backgroundColor = [colorHelper clearColor];
			view.tintColor = nil;
			if ([view respondsToSelector:@selector(setBackgroundImage:)])
				view.backgroundImage = nil;
			
			_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleSystemDefaultSemiLight graphicsQuality:kBackdropGraphicQualitySystemDefault];
			settings.grayscaleTintLevel = (isWhiteness ? 1.0f : 0.0f);
			
			_UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
			view.backgroundView = backdropView;
			[backdropView release];
		}
	}
}

%end


%hook ABMembersController

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	%orig;
	
	tableView.backgroundColor = [colorHelper clearColor];
	
	UIView *superview = controller._containerView.behindView;
	
	_UIBackdropView *backdropView = (_UIBackdropView *)[superview viewWithTag:0xc001];
	[backdropView retain];
	
	if (backdropView == nil) {
		CGRect frame = tableView.frame;
		frame.origin.x = 0;
		
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleForWhiteness graphicsQuality:kBackdropGraphicQualitySystemDefault];
		settings.grayscaleTintAlpha = 0.3f;
		
		backdropView = [[_UIBackdropView alloc] initWithFrame:frame autosizesToFitSuperview:YES settings:settings];
		backdropView.tag = 0xc001;
		
		[superview insertSubview:backdropView atIndex:0];
	}
	
	[backdropView release];
}

%new
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
	UIView *superview = controller._containerView.behindView;
	
	_UIBackdropView *backdropView = (_UIBackdropView *)[superview viewWithTag:0xc001];
	
	[backdropView removeFromSuperview];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	%orig;
	
	UIView *superview = controller._containerView.behindView;
	
	_UIBackdropView *backdropView = (_UIBackdropView *)[superview viewWithTag:0xc001];
	
	[backdropView removeFromSuperview];
}

%end


%hook ABPropertyCell

- (void)layoutSubviews {
	%orig;
	
	self.valueLabel.backgroundColor = [colorHelper clearColor];
	self.labelLabel.backgroundColor = [colorHelper clearColor];
}

%end


%hook ABPropertyNameCell

- (void)setBackgroundColor:(UIColor *)color {
	//%orig([colorHelper clearColor]);
	
	objc_super $super = {self, [UITableViewCell class]};
	objc_msgSendSuper(&$super, @selector(setBackgroundColor:), color);
}

%end


@interface UILabel (TextAttributes)
- (id)textAttributes;
- (void)setTextAttributes:(id)arg1;
@end

%hook ABPropertyNoteCell

- (void)setBackgroundColor:(UIColor *)color {
	//%orig([colorHelper clearColor]);
	
	objc_super $super = {self, [UITableViewCell class]};
	objc_msgSendSuper(&$super, @selector(setBackgroundColor:), color);
}

- (void)setLabelTextAttributes:(NSDictionary *)attributes {
	%orig;
	
	NSDictionary *&labelTextAttributes = MSHookIvar<NSDictionary *>(self, "_labelTextAttributes");
	NSDictionary *privDict = self.labelTextAttributes;
	[privDict retain];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:privDict];
	
	dict[@"NSColor"] = [colorHelper systemGrayColor];
	
	[self.labelLabel setTextAttributes:dict];
	
	labelTextAttributes = [dict copy];
	
	[privDict release];
}

%end


%hook ABContactCell

- (void)setSeparatorColor:(UIColor *)color {
	%orig([colorHelper defaultTableViewSeparatorColor]);
}

- (void)setContactSeparatorColor:(UIColor *)color {
	%orig([colorHelper defaultTableViewSeparatorColor]);
}

- (void)layoutSubviews {
	%orig;
	
	self.backgroundColor = [colorHelper defaultTableViewCellBackgroundColor];
	self.textLabel.backgroundColor = [colorHelper clearColor];
}

- (void)setBackgroundColor:(UIColor *)color {
	//%orig([colorHelper clearColor]);
	
	objc_super $super = {self, [UITableViewCell class]};
	objc_msgSendSuper(&$super, @selector(setBackgroundColor:), color);
}

%end


%hook ABContactHeaderView

- (void)layoutSubviews {
	%orig;
	
	UILabel *_nameLabel = MSHookIvar<UILabel *>(self, "_nameLabel");
	UILabel *_taglineLabel = MSHookIvar<UILabel *>(self, "_taglineLabel");
	
	_nameLabel.backgroundColor = [colorHelper clearColor];
	_taglineLabel.backgroundColor = [colorHelper clearColor];
}

%end


%hook ABGroupHeaderFooterView

- (void)updateConstraints {
	%orig;
	
	self.backgroundColor = nil;
	self.contentView.backgroundColor = [colorHelper clearColor];
	self.tintColor = nil;
	if ([self respondsToSelector:@selector(setBackgroundImage:)])
		self.backgroundImage = nil;
	
	self.backgroundView.alpha = 0.0f;
}

%end


%hook ABBannerView

- (void)_updateLabel {
	%orig;
	
	self.textLabel.textColor = [colorHelper commonTextColor];
}

%end


%hook ABContactView

- (void)setBackgroundColor:(UIColor *)color {
	%orig([colorHelper clearColor]);
}

%end


%hook UIColor

+ (id)cardCellSeparatorColor {
	return [colorHelper defaultTableViewSeparatorColor];
}
+ (id)cardCellReadonlyBackgroundColor {
	return %orig;
}
+ (id)cardBackgroundInPopoverColor {
	return [colorHelper themedFakeClearColor];
}
+ (id)cardCellBackgroundColor {
	return [colorHelper defaultTableViewCellBackgroundColor];
}
+ (id)cardValueReadonlyTextColor {
	return %orig;
}
+ (id)cardValueTextColor {
	return [colorHelper commonTextColor];
}
+ (id)cardLabelReadonlyTextColor {
	return %orig;
}

%end



#pragma mark -
#pragma mark MessageUI


%hook MFComposeRecipientView

- (void)layoutSubviews {
	%orig;
	
	self.textField.textColor = [colorHelper commonTextColor];
	self.textField.backgroundColor = [colorHelper clearColor];
	self.backgroundColor = [colorHelper clearColor];
}

%end


%hook MFRecipientTableViewCellDetailView

- (void)layoutSubviews {
	%orig;
	
	if ([[self.tintColor description] hasPrefix:@"UIDeviceWhiteColorSpace"]) {
		self.detailLabel.textColor = [colorHelper systemGrayColor];
		self.labelLabel.textColor = [colorHelper systemGrayColor];
	}
	
	self.detailLabel.backgroundColor = [colorHelper clearColor];
	self.labelLabel.backgroundColor = [colorHelper clearColor];
	self.backgroundColor = [colorHelper clearColor];
}

%end


%hook MFRecipientTableViewCellTitleView

- (void)layoutSubviews {
	%orig;
	
	if ([[self.tintColor description] hasPrefix:@"UIDeviceWhiteColorSpace"])
		self.titleLabel.textColor = [colorHelper commonTextColor];
	
	self.titleLabel.backgroundColor = [colorHelper clearColor];
	self.backgroundColor = [colorHelper clearColor];
}

%end


%hook MFRecipientTableViewCell

- (void)layoutSubviews {
	%orig;
	
	MFRecipientTableViewCellDetailView *_detailView = MSHookIvar<MFRecipientTableViewCellDetailView *>(self, "_detailView");
	MFRecipientTableViewCellTitleView *_titleView = MSHookIvar<MFRecipientTableViewCellTitleView *>(self, "_titleView");
	_detailView.backgroundColor = [colorHelper clearColor];
	_titleView.backgroundColor = [colorHelper clearColor];
}

%end




#pragma mark -
#pragma mark UIAlert


%hook UIActivityGroupCancelButton

- (void)layoutSubviews {
	%orig;
	
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleForWhiteness graphicsQuality:kBackdropGraphicQualitySystemDefault];
	settings.blurRadius = 10.0f;
	
	[self.backdropView transitionToSettings:settings];
}

%end




#pragma mark -
#pragma mark Camera


%hook PLCameraView

- (void)layoutSubviews {
	%orig;
	
	self._previewMaskingView.backgroundColor = [colorHelper clearColor];
}

%end


%hook PLWallpaperButton

- (void)_setupBackdropView {
	%orig;
	
	[self setTitleColor:[colorHelper commonTextColor] forState:UIControlStateNormal];
}

%end


%hook PLEditPhotoController

// 만약 backdropview를 전체 스타일처럼 변경한다면 툴바 아이콘 색깔도 변경이 필요.
// 그때 쓰면 됨.
/*- (id)_newButtonItemWithIcon:(id)icon title:(id)title target:(id)target action:(SEL)action tag:(NSInteger)tag {
	UIBarButtonItem *item = %orig;
	UIButton *customView = (UIButton *)item.customView;
	UIImage *image = [customView imageForState:UIControlStateNormal];
	
	image = [image _flatImageWithColor:[colorHelper commonTextColor]];
	[customView setImage:image forState:UIControlStateNormal];
	
	return item;
}*/

// 툴바, navbar의 스타일을 원본 스타일(Dark)처럼 적용시킴.
- (void)viewDidAppear:(BOOL)animated {
	%orig;
	
	self.toolbar.barStyle = UIBarStyleBlack;
	self.navigationBar.barStyle = UIBarStyleBlack;
	
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleSystemDefaultDark];
	settings.blurRadius = 22.0f;
	
	_UIBackdropView *_adaptiveBackdrop = MSHookIvar<_UIBackdropView *>(self.toolbar, "_adaptiveBackdrop");
	if ([_adaptiveBackdrop isKindOfClass:[_UIBackdropView class]])
		[_adaptiveBackdrop transitionToSettings:settings];
	
	_adaptiveBackdrop = MSHookIvar<_UIBackdropView *>(self.navigationBar._backgroundView, "_adaptiveBackdrop");
	if ([_adaptiveBackdrop isKindOfClass:[_UIBackdropView class]])
		[_adaptiveBackdrop transitionToSettings:settings];
}

%end

%hook PLEffectSelectionViewControllerView

// effect 배경 스타일을 원본 스타일(Dark)처럼 적용시킴.
- (void)layoutSubviews {
	%orig;
	
	if (self.subviews.count > 0) {
		_UIBackdropView *backdropView = self.subviews[0];
		if ([backdropView isKindOfClass:[_UIBackdropView class]]) {
			_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:kBackdropStyleSystemDefaultDark];
			settings.blurRadius = 22.0f;
			
			[backdropView transitionToSettings:settings];
		}
	}
}

%end




#pragma mark -
#pragma mark ChatKit


%hook CKBalloonView

- (BOOL)canUseOpaqueMask {
	return NO;
}

- (BOOL)isFilled {
	return YES;
}

%end

%hook CKUIBehavior

- (id)gray_balloonTextColor {
	return colorHelper.color_0_0__0_9;
}

%end




#pragma mark -
#pragma mark CommunicationsSetupUI


%hook CNFRegSigninLearnMoreView

- (void)layoutSubviews {
	%orig;
	
	self.titleLabel.textColor = [colorHelper commonTextColor];
	self.verbiageLabel.textColor = [colorHelper commonTextColor];
	
	self.userPassBox.alpha = 0.2f;
}

%end

%hook CNFRegTableLabel

- (void)layoutSubviews {
	%orig;
	
	UILabel *_label = MSHookIvar<UILabel *>(self, "_label");
	_label.textColor = [colorHelper commonTextColor];
}

%end




#pragma mark -
#pragma mark Constructure


%ctor
{
	isFirmware70 = (kCFCoreFoundationVersionNumber < 874.24);
	isFirmware71 = (kCFCoreFoundationVersionNumber >= 847.24);
	
	//CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPrefsNotification, CFSTR("kr.slak.glareapps.prefnoti"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	LoadSettings();
	
	if (!isThisAppEnabled()) return;
	
	colorHelper = [GlareAppsColorHelper sharedInstance];
	
	kbRenderConfig = [[%c(UIKBRenderConfig) alloc] init];
	kbRenderConfig.blurRadius = 20.0f;
	kbRenderConfig.lightKeyboard = (isWhiteness ? YES : NO);
	kbRenderConfig.blurSaturation = isFirmware71 ? 0.5f : 0.9f;
	kbRenderConfig.keycapOpacity = isFirmware71 ? 1.0f : 0.82f;
	if (isFirmware71)
		kbRenderConfig.lightLatinKeycapOpacity = 1.0f;
	else
		kbRenderConfig.keyborderOpacity = 1.0f;
	
	%init;
}


