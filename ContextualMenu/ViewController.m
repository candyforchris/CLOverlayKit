//
//  ViewController.m
//  ContextualMenu
//
//  Created by Christopher Cohen on 1/30/15.
//

#import "ViewController.h"
#import "CLOverlayKit.h"

@interface ViewController () <CLOverlayKitDelegate>
@property (nonatomic, strong) CLOverlayAppearance *appearance;
@property (nonatomic, strong) NSDictionary *resources;
@end


@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customizeCLOverlayAppearance];
    
    [self populateResourcesDictionary];
    
    [self composeInterface];
}


- (void)customizeCLOverlayAppearance {
    
    /*
     The look and feel of an overlay presented by 'CLOverlayKit' is determined by the values encapsulated in the 'CLOverlayAppearance' signleton. This model contains default values; overide them to change the appearance of your overlays. Consider the following example:
     */
    
    //Aquire a reference to the 'CLOverlayAppearance' signleton
    CLOverlayAppearance *overlayAppearance = [CLOverlayAppearance sharedOverlayAppearance];
    
    //Override some of the model's default values
    overlayAppearance.textColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    overlayAppearance.tintColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
    overlayAppearance.accentColor = [[UIColor blackColor] colorWithAlphaComponent:.1];
    overlayAppearance.primaryColor = [UIColor colorWithRed:0.898 green:0.459 blue:0.027 alpha:1];
    overlayAppearance.contextualOverayWidth = [NSNumber numberWithFloat:self.view.bounds.size.width*.6];
}

-(void)populateResourcesDictionary {
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"json"]] options:NSJSONReadingAllowFragments error:&error];
    
    if ([dictionary isKindOfClass:[NSDictionary class]] && !error) _resources = dictionary;
}

#pragma mark - User Interaction

- (void)onTapButton:(id)sender {
    UIButton *button = sender;
    
    CGPoint touchPoint = [self.view convertPoint:button.center fromView:button.superview];
    
    switch (button.tag) {
        case 1:
            [CLOverlayKit presentContextualDescriptionInView:self.view
                                                    delegate:self
                                                  touchPoint:touchPoint
                                                  bodyString:[_resources objectForKey:@"Lorem Ipsum"]
                                                headerString:@"Privacy Policy"];
            break;
            
        case 2:
            [CLOverlayKit presentContextualMenuInView:self.view
                                             delegate:self
                                           touchPoint:touchPoint
                                              strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Items for my menu"]];
            break;
            
        case 3:
            [CLOverlayKit presentSideMenuInView:self.view
                                       delegate:self
                                     touchPoint:touchPoint
                                        strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Menu's have things!", @"It's sweet to be a menu", @"Menus Schmenus"]];
            break;
    }
}

#pragma mark - CLOverlayKit Delegate
-(void)overlayKit:(CLOverlayKit *)overlay itemSelectedAtIndex:(NSInteger)index {
    [CLOverlayKit presentNotificationPopupInView:self.view
                                        delegate:self
                                      bodyString:[_resources objectForKey:@"Lorem Ipsum"]
                                    headerString:@"Selection"];
}

-(void)overlayKit:(CLOverlayKit *)overlay didFinishPresentingWithFormat:(CLOverlayFormat)format {
    //...
}

-(void)overlayDidDismissWithFormat:(CLOverlayFormat)format {
    //...
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Composition

-(void)composeInterface {
    
    //Set background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.jpg"]];
    backgroundImage.frame = self.view.frame;
    [self.view addSubview: backgroundImage];
    
    //Compose the top navigtion bar
    CGSize navigationBarSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*.09);
    CGSize buttonSize = CGSizeMake(navigationBarSize.width*.3, navigationBarSize.height);
    UIVisualEffectView *topNavigationBar = [self styledNaviationBarWithFrame:(CGRect){0, 0, navigationBarSize}];
    if (topNavigationBar) {
        
        [self.view addSubview:topNavigationBar];
        
        //Add side Menu button to navigation bar
        UIButton *sideMenuButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Side Menu"];
        if (sideMenuButton) {
            sideMenuButton.tag = 3;
            [topNavigationBar addSubview:sideMenuButton];
        }
    }
    
    //Compose the bottom navigtion bar
    UIVisualEffectView *bottomNavigationBar = [self styledNaviationBarWithFrame:(CGRect){0, self.view.bounds.size.height-navigationBarSize.height, navigationBarSize}];
    if (bottomNavigationBar) {
        
        [self.view addSubview:bottomNavigationBar];
        
        UIButton *policyButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Privacy"];
        if (policyButton) {
            policyButton.tag = 1;
            [bottomNavigationBar addSubview:policyButton];
        }
        
        UIButton *aboutUsButton = [self styledButtonWithFrame:(CGRect){bottomNavigationBar.bounds.size.width-buttonSize.width,0, buttonSize} andTitle:@"About Us"];
        if (aboutUsButton) {
            aboutUsButton.tag = 2;
            [bottomNavigationBar addSubview:aboutUsButton];
        }
    }
    
    //Compose middle button
    UIButton *middleButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Middle"];
    if (middleButton) {
        middleButton.tag = 2;
        middleButton.center = self.view.center;
        [self.view addSubview:middleButton];
    }
    
}

-(UIVisualEffectView *)styledNaviationBarWithFrame:(CGRect)frame {
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurView.frame = frame;
    blurView.alpha = .95;
    
    return blurView;
}

-(UIButton *)styledButtonWithFrame:(CGRect)frame andTitle:(NSString *)title {
    
    //Compose new button
    UIButton *styledButton = [[UIButton  alloc] initWithFrame:frame];
    
    if (styledButton) {
        styledButton.titleLabel.font = [UIFont systemFontOfSize:frame.size.height*.3];
        [styledButton setTitle:title forState:UIControlStateNormal];
        [styledButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    //Add a target to the new button
    [styledButton addTarget:self action:@selector(onTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return styledButton;
}

-(void)addGradientLayerToView:(UIView *)view atIndex:(int)index color1:(UIColor *)color1 color2:(UIColor *)color2 {
    //Create grey gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:index];
}
@end
