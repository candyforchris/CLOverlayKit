//
//  ViewController.m
//  ContextualMenu
//
//  Created by Christopher Cohen on 1/30/15.
//

#import "ViewController.h"
#import "CLOverlayKit.h"

#define CORNER_RADIUS 10
#define PRIMARY_COLOR [UIColor colorWithRed:0.043 green:0.349 blue:0.624 alpha:1]

@interface ViewController () <CLOverlayKitDelegate>
@property (nonatomic, strong) CLOverlayAppearance *appearance;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appearance = [CLOverlayAppearance new];
    if (_appearance) {
        _appearance.contextualOverayWidth = self.view.bounds.size.width*.6;
    }
    
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
                                                  bodyString:@"Bacon ipsum dolor amet kielbasa tail salami shankle picanha bresaola brisket pancetta. Bresaola filet mignon meatloaf pastrami. Tenderloin venison bresaola shoulder. Spare ribs pancetta pork loin swine, picanha capicola doner alcatra rump hamburger cupim meatball. Ham short loin fatback, ham hock prosciutto ground round swine beef ribs strip steak cow turkey t-bone alcatra. Frankfurter flank pork loin ball tip pork short loin, ribeye boudin landjaeger leberkas biltong salami hamburger shankle sirloin. Ribeye t-bone shank pork belly turkey rump. Shoulder meatloaf t-bone kielbasa, pancetta shankle corned beef sausage drumstick. Chicken turducken shoulder, corned beef chuck sausage kielbasa rump ham hock short loin andouille tenderloin pancetta sirloin. Meatloaf beef ball tip turkey meatball rump."
                                                headerString:@"Privacy Policy"
                                                  appearance:_appearance];
            
            break;
            
        case 2:
            [CLOverlayKit presentContextualMenuInView:self.view delegate:self touchPoint:touchPoint strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Items for my menu"] appearance: _appearance];
            break;
            
        case 3:
            [CLOverlayKit presentSideMenuInView:self.view delegate:self touchPoint:touchPoint strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Menu's have things!", @"It's sweet to be a menu", @"Menus Schmenus"] appearance:_appearance];
            
            break;
    }
}

#pragma mark - CLOverlayKit Delegate
-(void)overlayKit:(CLOverlayKit *)overlay itemSelectedAtIndex:(NSInteger)index {
    [CLOverlayKit presentNotificationPopupInView:self.view delegate:self bodyString:@"Bacon ipsum dolor amet kielbasa tail salami shankle picanha bresaola brisket pancetta. Bresaola filet mignon meatloaf pastrami. Tenderloin venison bresaola shoulder. Spare ribs pancetta pork loin swine, picanha capicola doner alcatra rump hamburger cupim meatball. Ham short loin fatback, ham hock prosciutto ground round swine beef ribs strip steak cow turkey t-bone alcatra. Frankfurter flank pork loin ball tip pork short loin, ribeye boudin landjaeger leberkas biltong salami hamburger shankle sirloin. Ribeye t-bone shank pork belly turkey rump. Shoulder meatloaf t-bone kielbasa, pancetta shankle corned beef sausage drumstick. Chicken turducken shoulder, corned beef chuck sausage kielbasa rump ham hock short loin andouille tenderloin pancetta sirloin. Meatloaf beef ball tip turkey meatball rump." headerString:@"Selection" appearance:_appearance];
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
    
    [self addGradientLayerToView:self.view atIndex:0 color1:[UIColor darkGrayColor] color2:[UIColor lightGrayColor]];
    
    CGSize navigationBarSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*.075);
    CGSize buttonSize = CGSizeMake(navigationBarSize.width*.3, navigationBarSize.height);
    
    //Compose the top navigtion bar
    UIView *topNavigationBar; {
        topNavigationBar = [[UIView alloc] initWithFrame:(CGRect){0, 0, navigationBarSize}];
        topNavigationBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
        [self.view addSubview:topNavigationBar];
        
        UIButton *sideMenuButton; {
            sideMenuButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Side Menu"];
            sideMenuButton.tag = 3;
            [topNavigationBar addSubview:sideMenuButton];
        }
    }
    
    //Compose the bottom navigtion bar
    UIView *bottomNavigationBar; {
        bottomNavigationBar = [[UIView alloc] initWithFrame:(CGRect){0, self.view.bounds.size.height-navigationBarSize.height, navigationBarSize}];
        bottomNavigationBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
        [self.view addSubview:bottomNavigationBar];
        
        UIButton *policyButton; {
            policyButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Privacy"];
            policyButton.tag = 1;
            [bottomNavigationBar addSubview:policyButton];
        }
        
        UIButton *aboutUsButton; {
            aboutUsButton = [self styledButtonWithFrame:(CGRect){bottomNavigationBar.bounds.size.width-buttonSize.width,0, buttonSize} andTitle:@"About Us"];
            aboutUsButton.tag = 2;
            [bottomNavigationBar addSubview:aboutUsButton];
        }
    }
    
    //Compose middle button
    UIButton *middleButton; {
        middleButton = [self styledButtonWithFrame:(CGRect){0,0, buttonSize} andTitle:@"Middle"];
        middleButton.tag = 2;
        middleButton.center = self.view.center;
        [self.view addSubview:middleButton];
    }
}

-(UIButton *)styledButtonWithFrame:(CGRect)frame andTitle:(NSString *)title {
    
    //Compose new button
    UIButton *styledButton; {
        styledButton = [[UIButton  alloc] initWithFrame:frame];
        styledButton.titleLabel.font = [UIFont systemFontOfSize:frame.size.height*.4];
        [styledButton setTitle:title forState:UIControlStateNormal];
        [styledButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        styledButton.transform = CGAffineTransformMakeScale(.8, .8);
        
    }
    
    //Add a target to the new button
    [styledButton addTarget:self action:@selector(onTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return styledButton;
}

-(void)addGradientLayerToView:(UIView *)view atIndex:(int)index color1:(UIColor *)color1 color2:(UIColor *)color2{
    //Create grey gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:index];
}
@end
