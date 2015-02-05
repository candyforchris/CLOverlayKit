//
//  CCOverlayMenu
//  A Contextual Menu UI Element
//
//  Created by Christopher Cohen on 1/29/15.
//  Copyright (c) 2015 YES. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
#define MAX_CHAR 128
#define TINT_COLOR [[UIColor blackColor] colorWithAlphaComponent:.5]
#define SIDE_MENU_ANIMATION_SPEED .25
#define OVERLAY_ANIMATION_SPEED .5

///Protocol Definition
@protocol CLOverlayKitDelegate <NSObject>
@required - (void)didSelectMenuItemAtIndex:(NSInteger)index;

@end

@interface CLOverlayKit : UIView

@property (nonatomic, weak) id<CLOverlayKitDelegate>delegate;

/// Type Definitions

typedef NS_ENUM(BOOL, EquatorPosition) {AboveEquator, BelowEquator};
typedef NS_ENUM(BOOL, HorizontalPosition) {LeftOfCenter, RightOfCenter};
typedef NS_ENUM(NSInteger, OverlayFormat) {SideMenu, MenuOverlay, DescriptionOverlay};

typedef struct
{
    CGColorRef panelColor, textColor, tintColor;
    CGFloat panelWidth, contentHeight;
    CGFloat cornerRadius, borderWidth, partitionLineThickness, arrowWidth;
} CLOverlayAppearance;

/// API Method(s)
+(void)presentContextualMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings appearance:(CLOverlayAppearance)appearance;

+(void)presentContextualDescriptionInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint text:(NSString*)text appearance:(CLOverlayAppearance)appearance;

+(void)presentSideMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings appearance:(CLOverlayAppearance)appearance;

@end
