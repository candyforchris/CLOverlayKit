//
//  ViewController.m
//  ContextualMenu
//
//  Created by Christopher Cohen on 1/30/15.
//

#import "ViewController.h"
#import "CLOverlayKit.h"

@interface ViewController () <CLOverlayKitDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addGradientLayerToView:self.view atIndex:0 color1:[UIColor darkGrayColor] color2:[UIColor lightGrayColor]];
}

- (IBAction)onTapButton:(id)sender {
    UIButton *button = sender;

    CLOverlayAppearance appearance; {
        appearance.borderWidth              = 0;
        appearance.cornerRadius             = 0;
        appearance.contentHeight            = self.view.bounds.size.height*.08;
        appearance.panelColor               = [UIColor yellowColor].CGColor;
        appearance.panelWidth               = self.view.bounds.size.width*.65;
        appearance.textColor                = [UIColor blackColor].CGColor;
        appearance.arrowWidth               = self.view.bounds.size.width*.1;
        appearance.partitionLineThickness   = 1;
        appearance.tintColor                = [[UIColor blackColor] colorWithAlphaComponent:.75].CGColor;
    }
    
    CGPoint touchPoint = [self.view convertPoint:button.center fromView:button.superview];
    
    switch (button.tag) {
        case 1:
            appearance.panelWidth = self.view.frame.size.width*.8;
            
            [CLOverlayKit presentContextualDescriptionInView:self.view
                                               delegate:self
                                             touchPoint:touchPoint
                                                   text:@"Bacon ipsum dolor amet kielbasa tail salami shankle picanha bresaola brisket pancetta. Bresaola filet mignon meatloaf pastrami. Tenderloin venison bresaola shoulder. Spare ribs pancetta pork loin swine, picanha capicola doner alcatra rump hamburger cupim meatball. Ham short loin fatback, ham hock prosciutto ground round swine beef ribs strip steak cow turkey t-bone alcatra. Frankfurter flank pork loin ball tip pork short loin, ribeye boudin landjaeger leberkas biltong salami hamburger shankle sirloin. Ribeye t-bone shank pork belly turkey rump. Shoulder meatloaf t-bone kielbasa, pancetta shankle corned beef sausage drumstick. Chicken turducken shoulder, corned beef chuck sausage kielbasa rump ham hock short loin andouille tenderloin pancetta sirloin. Meatloaf beef ball tip turkey meatball rump."
                                             appearance:appearance];
            
            break;
            
        case 2:
            
            [CLOverlayKit presentContextualMenuInView:self.view delegate:self touchPoint:touchPoint strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Items for my menu"] appearance: appearance];
            break;
            
        case 3:
            [CLOverlayKit presentSideMenuInView:self.view delegate:self touchPoint:touchPoint strings:@[@"Items for my menu", @"\"Etu menu?\"", @"Menus are clicky lists", @"\"I think, therfore I menu\"", @"Menu's have things!", @"It's sweet to be a menu", @"Menus Schmenus"] appearance:appearance];
            
            break;
    }
}

-(void)didSelectMenuItemAtIndex:(NSInteger)index {
    NSLog(@"SELECTED ITEM AT INDEX: %ld", (long)index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addGradientLayerToView:(UIView *)view atIndex:(int)index color1:(UIColor *)color1 color2:(UIColor *)color2{
    //Create grey gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:index];
}
@end
