//
//  Cohen/Lesko OverlayKit
//
//  Created by Christopher Cohen and Ivan Lesko on 2/4/15.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define MAX_CHAR 128
#define TINT_ALPHA .5
#define SIDE_MENU_ANIMATION_SPEED .25
#define OVERLAY_ANIMATION_SPEED .5

@class CLOverlayKit;
@class CLOverlayAppearance;

///Type Definitions

typedef NS_ENUM(BOOL, CLEquatorPosition) {AboveEquator, BelowEquator};
typedef NS_ENUM(BOOL, CLHorizontalPosition) {LeftOfCenter, RightOfCenter};
typedef NS_ENUM(NSInteger, CLOverlayFormat) {SideMenu, MenuOverlay, DescriptionOverlay, PopupOverlay};

///Protocol Definition

@protocol CLOverlayKitDelegate <NSObject>
@required
- (void)overlayKit:(CLOverlayKit *)overlay itemSelectedAtIndex:(NSInteger)index;
- (void)overlayKit:(CLOverlayKit *)overlay didFinishPresentingWithFormat:(CLOverlayFormat)format;
- (void)overlayDidDismissWithFormat:(CLOverlayFormat)format;
@end

///CLOverlayKit Class Interface

@interface CLOverlayKit : UIView

@property (nonatomic, weak) id<CLOverlayKitDelegate>delegate;

+(void)presentContextualMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings;
+(void)presentContextualDescriptionInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint bodyString:(NSString*)bodyString headerString:(NSString *)headerString;
+(void)presentSideMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings;
+(void)presentNotificationPopupInView:(UIView *)view delegate:(id)delegate bodyString:(NSString*)bodyString headerString:(NSString *)headerString;

@end

///CLOverlayAppearance Class Interface

@interface CLOverlayAppearance : NSObject
+ (CLOverlayAppearance *)sharedOverlayAppearance;
@property (nonatomic, strong) NSNumber *contextualOverayWidth, *contextualOverlayItemHeight, *cornerRadius, *borderWidth, *partitionLineThickness, *contextualOverlayArrowWidth, *contentMargin;
@property (nonatomic, strong) UIColor *primaryColor, *textColor, *tintColor, *accentColor;
@property (nonatomic, readwrite) CGSize popUpSize;

@end
