//
//  OverlayMenu.m
//  ContextualMenu
//
//  Created by Christopher Cohen on 1/29/15.
//  Copyright (c) 2015 YES. All rights reserved.
//

#import "CLOverlayKit.h"

@class CLOverlayAppearance;

@interface CLOverlayKit()

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, readwrite) CGPoint touchPoint;
@property (nonatomic, readwrite) CLEquatorPosition equatorPosition;
@property (nonatomic, readwrite) CLHorizontalPosition horizontalPosition;
@property (nonatomic, readwrite) CLOverlayFormat format;
@end

///CLOverlayKit Class implementation

@implementation CLOverlayKit

#pragma mark - API Methods

+(void)presentContextualMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings {
    
    CLOverlayKit *menuOverlay = [CLOverlayKit newOverlayObjectWithFrame:view.frame Delegate:delegate touchPoint:touchPoint];
    [view addSubview:menuOverlay];
    menuOverlay.format = MenuOverlay;
    [menuOverlay applyTintToSuperview];
    [menuOverlay composeMenuPanelWithStrings:strings];
    [menuOverlay animateOverlayAppearance];
}

+(void)presentContextualDescriptionInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint bodyString:(NSString*)bodyString headerString:(NSString *)headerString {
    
    CLOverlayKit *descriptionOverlay = [CLOverlayKit newOverlayObjectWithFrame:view.frame Delegate:delegate touchPoint:touchPoint];
    [view addSubview:descriptionOverlay];
    descriptionOverlay.format = DescriptionOverlay;
    [descriptionOverlay applyTintToSuperview];
    [descriptionOverlay composeDescriptionPanelWithBodyString:bodyString andHeaderString:headerString];
    [descriptionOverlay animateOverlayAppearance];
}

+(void)presentSideMenuInView:(UIView *)view delegate:(id)delegate touchPoint:(CGPoint)touchPoint strings:(NSArray*)strings {
    
    CLOverlayKit *sideMenu = [CLOverlayKit newOverlayObjectWithFrame:view.frame Delegate:delegate touchPoint:touchPoint];
    [view addSubview:sideMenu];
    sideMenu.format = SideMenu;
    [sideMenu composeSideMenuPanelWithStrings:strings];
    [sideMenu animateSideMenuAppearance];
}

+(void)presentNotificationPopupInView:(UIView *)view delegate:(id)delegate bodyString:(NSString*)bodyString headerString:(NSString *)headerString {
    
    CLOverlayKit *descriptionOverlay = [CLOverlayKit newOverlayObjectWithFrame:view.frame Delegate:delegate touchPoint:CGPointZero];
    [view addSubview:descriptionOverlay];
    descriptionOverlay.format = PopupOverlay;
    [descriptionOverlay applyTintToSuperview];
    [descriptionOverlay composeDescriptionPanelWithBodyString:bodyString andHeaderString:headerString];
    descriptionOverlay.panelView.center = view.center;
    [descriptionOverlay animateOverlayAppearance];
}

#pragma mark - Custom Initializer

+(CLOverlayKit *)newOverlayObjectWithFrame:(CGRect)frame Delegate:(id)delegate touchPoint:(CGPoint)touchPoint {
    
    //Alloc/init new 'CLOverlayKit' object
    CLOverlayKit *overlay = [[CLOverlayKit alloc] initWithFrame:frame];
    
    if (overlay) {
        overlay.delegate = delegate;
        overlay.backgroundColor = [UIColor clearColor];
        overlay.touchPoint = touchPoint;
        overlay.equatorPosition = (touchPoint.y > frame.size.height/2) ? AboveEquator : BelowEquator;
    }
    
    return overlay;
}

#pragma mark - UI Composition

- (void)composeButtonListFromStrings:(NSArray *)strings inPanelView:(UIView *)panelView {
    //Calculate button size
    CGSize buttonSize = CGSizeMake(panelView.frame.size.width, panelView.frame.size.height/strings.count);
    CGFloat verticalOffset = 0;
    
    //Create a button representing each string in the 'strings' array
    for (NSInteger index = 0; index < strings.count; index++) {
        
        //Compose UIButton
        UIButton *button = [[UIButton alloc] initWithFrame:(CGRect){0,verticalOffset, buttonSize}];
        
        if (button) {
            [button setTitle:[strings objectAtIndex:index] forState:UIControlStateNormal];
            [button setTitleColor:[CLOverlayAppearance sharedOverlayAppearance].textColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onTapMenuItem:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont systemFontOfSize:button.frame.size.height*.35];
            button.tag = index;
            [panelView addSubview:button];
            
            //Add a partition line to all buttons excluding the last item
            if (index != strings.count-1) [self addPartitionLineToBottonOfView:button];
        }
        
        //Update vertical offset
        verticalOffset += buttonSize.height;
    }
}

-(void)addPartitionLineToBottonOfView:(UIView *)view {

    NSInteger contentMargin = [CLOverlayAppearance sharedOverlayAppearance].contentMargin.integerValue;
    NSInteger lineThickness = [CLOverlayAppearance sharedOverlayAppearance].partitionLineThickness.integerValue;
    
    UIView *partitionLine = [[UIView alloc] initWithFrame:CGRectMake(contentMargin, view.frame.size.height-lineThickness, view.frame.size.width-contentMargin*2, lineThickness)];
    
    if (partitionLine) {
        partitionLine.center = CGPointMake(view.center.x, partitionLine.center.y);
        partitionLine.backgroundColor = [CLOverlayAppearance sharedOverlayAppearance].accentColor;
        partitionLine.layer.cornerRadius = partitionLine.bounds.size.height/2;
        partitionLine.clipsToBounds = YES;
        [view addSubview:partitionLine];
    }
}

-(UIVisualEffectView *)composePanelViewWithSize:(CGSize)size {

    UIVisualEffectView *panelView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    panelView.frame = (CGRect){0,0,size};
    
    if (panelView) {
        panelView.center = _touchPoint;
        panelView.frame = [self adjustFrameForPosition:panelView.frame];
//        panelView.backgroundColor = [CLOverlayAppearance sharedOverlayAppearance].primaryColor;
        panelView.layer.cornerRadius = [CLOverlayAppearance sharedOverlayAppearance].cornerRadius.floatValue;
        panelView.layer.borderWidth = [CLOverlayAppearance sharedOverlayAppearance].borderWidth.integerValue;
        panelView.layer.borderColor = [CLOverlayAppearance sharedOverlayAppearance].accentColor.CGColor;
        panelView.clipsToBounds = YES;
    }
        
    return panelView;
}

-(void)composeMenuPanelWithStrings:(NSArray *)strings {
    
    //Compose panel view
    UIVisualEffectView *panelView = [self composePanelViewWithSize:CGSizeMake([CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue, [CLOverlayAppearance sharedOverlayAppearance].contextualOverlayItemHeight.floatValue*strings.count)];
    [self.superview addSubview:panelView];
    
    //Retain strong reference to panel view object
    _panelView = panelView;
    
    [self composeButtonListFromStrings:strings inPanelView:panelView];
}

-(void)composeDescriptionPanelWithBodyString:(NSString*)text andHeaderString:(NSString *)headerString{
    
    //Determine panel width
    CGFloat panelWidth = [CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue;
    if (_format == PopupOverlay) panelWidth = self.frame.size.width*.95;
    
    //Compose Panel View
    _panelView = [self composePanelViewWithSize:CGSizeMake(panelWidth, [CLOverlayAppearance sharedOverlayAppearance].contextualOverlayItemHeight.integerValue*7)];
    [self.superview addSubview:_panelView];
    
    //Compose Header Label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _panelView.frame.size.width, [CLOverlayAppearance sharedOverlayAppearance].contextualOverlayItemHeight.integerValue)];
    if (headerLabel) {
        headerLabel.text = headerString;
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.textColor = [CLOverlayAppearance sharedOverlayAppearance].textColor;
        headerLabel.font = [UIFont systemFontOfSize:headerLabel.bounds.size.height*.45];
        [_panelView addSubview:headerLabel];
        [self addPartitionLineToBottonOfView:headerLabel];
    }

    //Compose Description Label
    NSInteger contentMargin = [CLOverlayAppearance sharedOverlayAppearance].contentMargin.integerValue;
    NSInteger headerMargin = headerLabel.bounds.size.height*1.25;
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentMargin, headerMargin, _panelView.bounds.size.width-contentMargin*2, _panelView.bounds.size.height-headerMargin-contentMargin)];
    if (descriptionLabel) {
        descriptionLabel.text = text;
        descriptionLabel.textColor = [CLOverlayAppearance sharedOverlayAppearance].textColor;
        descriptionLabel.numberOfLines = 0;
        [descriptionLabel sizeThatFits:descriptionLabel.frame.size];
        [descriptionLabel setAdjustsFontSizeToFitWidth:YES];
        [_panelView addSubview:descriptionLabel];
    }
}

-(void)composeSideMenuPanelWithStrings:(NSArray*)strings {
        
    //Determine horizontal position
    if (_touchPoint.x > self.frame.size.width/2) _horizontalPosition = RightOfCenter;
    else _horizontalPosition = LeftOfCenter;
    
    //Capture screenshot of the superview
    CGFloat xPosition = (_horizontalPosition) ? -[CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue : [CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue;
    UIImageView *screenshot = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition, 0, self.bounds.size.width, self.bounds.size.height)];
    if (screenshot) {
        screenshot.image = [self snapshot:self.superview];
        [self addSubview:screenshot];
        
        //Add tint to screenshot
        UIView *screenshotTintView = [[UIView alloc] initWithFrame:screenshot.bounds];
        if (screenshotTintView) {
            screenshotTintView.backgroundColor = [CLOverlayAppearance sharedOverlayAppearance].tintColor;
            [screenshot addSubview:screenshotTintView];
        }
    }

    //Compose panel view
    UIView *panelView; {
        CGFloat xPosition = (_horizontalPosition) ? self.frame.size.width-[CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue : 0;
        panelView = [[UIView alloc] initWithFrame:CGRectMake(xPosition, 0, [CLOverlayAppearance sharedOverlayAppearance].contextualOverayWidth.integerValue, self.bounds.size.height)];
        panelView.backgroundColor = [CLOverlayAppearance sharedOverlayAppearance].primaryColor;
        [self addSubview:panelView];
        
        //Retain strong reference to panel view object
        _panelView = panelView;
    }
    
    [self composeButtonListFromStrings:strings inPanelView:panelView];
    
    //Change the font size of all button objects
    for (NSObject *object in panelView.subviews) if ([object isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)object;
        button.titleLabel.font = [UIFont systemFontOfSize:self.bounds.size.height*.025];
    }
}

-(void)applyTintToSuperview {
    _tintView = [[UIView alloc] initWithFrame:self.superview.frame];
    _tintView.backgroundColor = [CLOverlayAppearance sharedOverlayAppearance].tintColor;
    [self.superview insertSubview:_tintView belowSubview:self];
}

#pragma mark - Animation

-(void)animateSideMenuAppearance {
    
    //Get reference to screenshot view
    UIImageView *screenShot;
    for (screenShot in self.subviews) if ([screenShot isKindOfClass:[UIImageView class]]) break;
    
    //Get reference to the screenshot's tint-view
    UIView *screenshotTintView;
    for (screenshotTintView in screenShot.subviews) if ([screenshotTintView isKindOfClass:[UIView class]]) break;
    
    //Set destination points
    CGPoint screenShotDestination = screenShot.center;
    CGPoint sideMenuDestination = _panelView.center;
    
    //Set starting states for menu elements
    screenShot.frame = self.frame;
    screenshotTintView.alpha = 0;
    CGFloat panelStartingX = (_horizontalPosition) ? self.bounds.size.width : -_panelView.bounds.size.width;
    _panelView.frame = CGRectMake(panelStartingX, 0, _panelView.bounds.size.width, _panelView.bounds.size.height);
    
    // Animate Menu Appearance
    self.hidden = NO;
    [UIView animateWithDuration:SIDE_MENU_ANIMATION_SPEED animations:^{
        screenShot.center = screenShotDestination;
        _panelView.center = sideMenuDestination;
        screenshotTintView.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.delegate) [self.delegate overlayKit:self didFinishPresentingWithFormat:_format];
    }];
}

-(void)animateSideMenuDismissal {
    
    //Get reference to screenshot view
    UIImageView *screenShot;
    for (screenShot in self.subviews) if ([screenShot isKindOfClass:[UIImageView class]]) break;
    
    //Get reference to the screenshot's tint-view
    UIView *screenshotTintView;
    for (screenshotTintView in screenShot.subviews) if ([screenshotTintView isKindOfClass:[UIView class]]) break;
    
    CGFloat panelDestinationX = (_horizontalPosition) ? self.bounds.size.width : -_panelView.bounds.size.width;
    
    [UIView animateWithDuration:SIDE_MENU_ANIMATION_SPEED animations:^{
        screenShot.frame = self.frame;
        _panelView.frame = CGRectMake(panelDestinationX, 0, _panelView.bounds.size.width, _panelView.bounds.size.height);
        screenshotTintView.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.delegate) [self.delegate overlayDidDismissWithFormat:_format];
        [self removeFromSuperview];
    }];
}

-(void)animateOverlayAppearance
{
    // Animate Menu Appearance
    self.alpha = 0;
    self.hidden = NO;
    _panelView.alpha = 0;
    _tintView.alpha = 0;
    
    [UIView animateWithDuration:OVERLAY_ANIMATION_SPEED animations:^{
        self.alpha = 1;
        _tintView.alpha = 1;
        _panelView.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.delegate) [self.delegate overlayKit:self didFinishPresentingWithFormat:_format];
    }];
}

-(void)animateOverlayDismissal
{
    
    [UIView animateWithDuration:OVERLAY_ANIMATION_SPEED animations:^{
        self.panelView.alpha = 0;
        self.alpha = 0;
        _tintView.alpha = 0;
    } completion:^(BOOL finished) {
        [_tintView removeFromSuperview];
        if (self.delegate) [self.delegate overlayDidDismissWithFormat:_format];
        [self removeFromSuperview];
    }];
}

-(void)animateDismissal
{
    if (_format == SideMenu) [self animateSideMenuDismissal];
    
    else [self animateOverlayDismissal];
}

#pragma mark - Target Method(s)

-(void)onTapMenuItem:(id)sender {
    if (self.delegate) [self.delegate overlayKit:self itemSelectedAtIndex:[(UIView *)sender tag]];
}

#pragma mark - User Interaction

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self animateDismissal];
}

#pragma mark - Convenience Method(s)

-(CGRect)adjustFrameForPosition:(CGRect)frame
{
    CGFloat adjustedX = frame.origin.x;
    CGFloat adjustedY = frame.origin.y;
    
    // Add origin.y content offset
    CGFloat verticalOffset = (frame.size.height/2)+self.frame.size.height*.025;
    adjustedY = (self.equatorPosition) ? adjustedY+verticalOffset : adjustedY-verticalOffset;
    
    // Adjust the x origin to fit within the visible bounds
    CGFloat edgeBuffer = self.bounds.size.width*.01;
    if (frame.origin.x < 0) adjustedX = edgeBuffer;
    else if (frame.origin.x > self.bounds.size.width-frame.size.width) adjustedX = self.bounds.size.width-frame.size.width-edgeBuffer;
    
    return (CGRect){adjustedX, adjustedY, frame.size};
}

- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    //Do not draw arrow if overlay is a side menu
    if (_format == SideMenu || _format == PopupOverlay) return;
    
    //Calulate points to be used in the triangle drawing
    CGFloat verticalOffset = (_equatorPosition) ? 1 : self.panelView.bounds.size.height-1;
    CGPoint leftPoint = CGPointMake(self.panelView.center.x+[CLOverlayAppearance sharedOverlayAppearance].contextualOverlayArrowWidth.integerValue, self.panelView.frame.origin.y+verticalOffset);
    CGPoint rightPoint = CGPointMake(self.panelView.center.x-[CLOverlayAppearance sharedOverlayAppearance].contextualOverlayArrowWidth.integerValue, self.panelView.frame.origin.y+verticalOffset);
    
    /*
    //Adjust points for excessive angle cases
    if (_touchPoint.x > leftPoint.x) leftPoint.y = _panelView.center.y;
    else if (_touchPoint.x < rightPoint.x) rightPoint.y = _panelView.center.y;
    */
    
    //Draw arrow Bezier Path
    UIBezierPath* arrowPath = UIBezierPath.bezierPath;
    [arrowPath moveToPoint: leftPoint];
    [arrowPath addLineToPoint: _touchPoint];
    [arrowPath addLineToPoint: rightPoint];
    [([CLOverlayAppearance sharedOverlayAppearance].borderWidth.integerValue) ? [CLOverlayAppearance sharedOverlayAppearance].accentColor : [CLOverlayAppearance sharedOverlayAppearance].primaryColor setFill];
    [arrowPath fill];
}

@end

///CLOverlayAppearance Class implementation

@implementation CLOverlayAppearance

+ (CLOverlayAppearance *)sharedOverlayAppearance {
    static CLOverlayAppearance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CLOverlayAppearance alloc] init];
        if (sharedInstance) {
            sharedInstance.contextualOverayWidth = [NSNumber numberWithInteger:200];
            sharedInstance.contextualOverlayItemHeight = [NSNumber numberWithInteger:40];
            sharedInstance.contextualOverlayArrowWidth = [NSNumber numberWithInteger:15];
            sharedInstance.cornerRadius = [NSNumber numberWithInteger:3];
            sharedInstance.borderWidth = [NSNumber numberWithInteger:0];;
            sharedInstance.partitionLineThickness = [NSNumber numberWithInteger:1];
            sharedInstance.primaryColor = [UIColor darkGrayColor];
            sharedInstance.accentColor = [UIColor whiteColor];
            sharedInstance.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
            sharedInstance.tintColor = [UIColor clearColor];
            sharedInstance.contentMargin = [NSNumber numberWithInteger:10];
            sharedInstance.popUpSize = CGSizeMake(300, 200);
        }
    });
    return sharedInstance;
}

@end
