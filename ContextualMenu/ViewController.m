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
    
    _appearance = [CLOverlayAppearance new];
    if (_appearance) {
        _appearance.contextualOverayWidth = [NSNumber numberWithFloat:self.view.bounds.size.width*.6];
        _appearance.cornerRadius = [NSNumber numberWithInt:5];
    }
    
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"json"]] options:NSJSONReadingAllowFragments error:&error];
    
    if ([dictionary isKindOfClass:[NSDictionary class]] && !error) {
        _resources = [NSDictionary new];
        _resources = dictionary;
    }
    
    //Set background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Autumn.jpg"]];
    backgroundImage.frame = self.view.frame;
    [self.view addSubview: backgroundImage];
    
    [self composeInterface];
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
                                                headerString:@"Privacy Policy"
                                                  appearance:_appearance];
            break;
            
        case 2:
            [CLOverlayKit presentContextualMenuInView:self.view
                                             delegate:self
                                           touchPoint:touchPoint
                                              strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Items for my menu"]
                                           appearance: _appearance];
            break;
            
        case 3:
            [CLOverlayKit presentSideMenuInView:self.view
                                       delegate:self
                                     touchPoint:touchPoint
                                        strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Menu's have things!", @"It's sweet to be a menu", @"Menus Schmenus"]
                                     appearance:_appearance];
            break;
    }
}

#pragma mark - CLOverlayKit Delegate
-(void)overlayKit:(CLOverlayKit *)overlay itemSelectedAtIndex:(NSInteger)index {
    [CLOverlayKit presentNotificationPopupInView:self.view
                                        delegate:self
                                      bodyString:[_resources objectForKey:@"Lorem Ipsum"]
                                    headerString:@"Selection"
                                      appearance:_appearance];
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
    
    [self addGradientLayerToView:self.view atIndex:0 color1:[UIColor grayColor] color2:[UIColor darkGrayColor]];
    
    CGSize navigationBarSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*.075);
    CGSize buttonSize = CGSizeMake(navigationBarSize.width*.3, navigationBarSize.height);
    
    //Compose the top navigtion bar
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

    return blurView;
}

-(UIButton *)styledButtonWithFrame:(CGRect)frame andTitle:(NSString *)title {
    
    //Compose new button
    UIButton *styledButton = [[UIButton  alloc] initWithFrame:frame];
    
    if (styledButton) {
        styledButton.titleLabel.font = [UIFont systemFontOfSize:frame.size.height*.4];
        [styledButton setTitle:title forState:UIControlStateNormal];
        [styledButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        styledButton.transform = CGAffineTransformMakeScale(.7, .7);
        styledButton.layer.cornerRadius = styledButton.frame.size.height/2;
        styledButton.clipsToBounds = YES;
        styledButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
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
