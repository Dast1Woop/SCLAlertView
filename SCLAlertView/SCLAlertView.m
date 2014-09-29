//
//  SCLAlertView.m
//  SCLAlertView
//
//  Created by Diogo Autilio on 9/26/14.
//  Copyright (c) 2014 AnyKey Entertainment. All rights reserved.
//

#import "SCLAlertView.h"
#import "SCLButton.h"
#import "SCLAlertViewResponder.h"
#import "SCLAlertViewStyleKit.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SCLAlertView ()

@property NSMutableArray *inputs;
@property NSMutableArray *buttons;
@property UIView *circleView;
@property UIImageView *circleIconImageView;
@property UIView *shadowView;
@property UIViewController *rootViewController;

@end

@implementation SCLAlertView

CGFloat kDefaultShadowOpacity = 0.7f;
CGFloat kCircleHeight = 56.0f;
CGFloat kCircleTopPosition = -12.0f;
CGFloat kCircleBackgroundTopPosition = -15.0f;
CGFloat kCircleHeightBackground = 62.0f;
CGFloat kCircleIconHeight = 20.0f;
CGFloat kWindowWidth = 240.0f;
CGFloat kWindowHeight = 178.0f;
CGFloat kTextHeight = 90.0f;

// Font
NSString *kDefaultFont = @"HelveticaNeue";
NSString *kButtonFont = @"HelveticaNeue-Bold";

// Members declaration
UIView *contentView;
UIView *circleViewBackground;

NSTimer *durationTimer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"NSCoding not supported"
                                 userInfo:nil];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Init
        _labelTitle = [[UILabel alloc] init];
        _viewText = [[UITextView alloc] init];
        _shadowView = [[UIView alloc] init];
        contentView = [[UIView alloc] init];
        _circleView = [[UIView alloc] init];
        circleViewBackground = [[UIView alloc] init];
        _circleIconImageView = [[UIImageView alloc] init];
        _buttons = [[NSMutableArray alloc] init];
        _inputs = [[NSMutableArray alloc] init];
        
		// Add Subvies
        [self.view addSubview:contentView];
        [self.view addSubview:circleViewBackground];
        [self.view addSubview:self.circleView];

        [self.circleView addSubview:self.circleIconImageView];
        [contentView addSubview:_labelTitle];
        [contentView addSubview:_viewText];
        
		// Content View
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 5.0f;
        contentView.layer.masksToBounds = YES;
        contentView.layer.borderWidth = 0.5f;
        
		// Circle View Background
		circleViewBackground.backgroundColor = [UIColor whiteColor];
        
        // Title
        _labelTitle.numberOfLines = 1;
        _labelTitle.textAlignment = NSTextAlignmentCenter;
        _labelTitle.font = [UIFont fontWithName:kDefaultFont size:20.0f];
        
        // View text
        _viewText.editable = NO;
        _viewText.textAlignment = NSTextAlignmentCenter;
        _viewText.font = [UIFont fontWithName:kDefaultFont size:14.0f];
        
        // Shadow View
        self.shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.shadowView.backgroundColor = [UIColor blackColor];
        
        // Colors
        contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _labelTitle.textColor = UIColorFromRGB(0x4D4D4D);
        _viewText.textColor = UIColorFromRGB(0x4D4D4D);
        contentView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    }
    return self;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize sz = [UIScreen mainScreen].bounds.size;
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] < 8.0)
    {
        // iOS versions before 7.0 did not switch the width and height on device roration
        if UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
        {
            CGSize ssz = sz;
            sz = CGSizeMake(ssz.height, ssz.width);
        }
    }
    
    // Set background frame
    CGRect newFrame = self.shadowView.frame;
    newFrame.size = sz;
    self.shadowView.frame = newFrame;
    
    // Set frames
    CGRect r;
    if (self.view.superview != nil)
    {
        // View is showing, position at center of screen
        r = CGRectMake((sz.width-kWindowWidth)/2, (sz.height-kWindowHeight)/2, kWindowWidth, kWindowHeight);
    }
    else
    {
        // View is not visible, position outside screen bounds
        r = CGRectMake((sz.width-kWindowWidth)/2, -kWindowHeight, kWindowWidth, kWindowHeight);
    }
    
    self.view.frame = r;
    contentView.frame = CGRectMake(0.0f, kCircleHeight / 4, kWindowWidth, kWindowHeight);
    circleViewBackground.frame = CGRectMake(kWindowWidth / 2 - kCircleHeightBackground / 2, kCircleBackgroundTopPosition, kCircleHeightBackground, kCircleHeightBackground);
    circleViewBackground.layer.cornerRadius = circleViewBackground.frame.size.height / 2;
    self.circleView.frame = CGRectMake(kWindowWidth / 2 - kCircleHeight / 2, kCircleTopPosition, kCircleHeight, kCircleHeight);
    self.circleView.layer.cornerRadius = self.circleView.frame.size.height / 2;
    self.circleIconImageView.frame = CGRectMake(kCircleHeight / 2 - kCircleIconHeight / 2, kCircleHeight / 2 - kCircleIconHeight / 2, kCircleIconHeight, kCircleIconHeight);
    _labelTitle.frame = CGRectMake(12, kCircleHeight / 2 + 12, kWindowWidth - 24, 40.0f);
    _viewText.frame = CGRectMake(12, 74, kWindowWidth - 24, kTextHeight);
    
    // Text fields
    CGFloat y = 74.0 + kTextHeight + 14.0;
    for (UITextField *textField in _inputs)
    {
        textField.frame = CGRectMake(12.0f, y, kWindowWidth - 24, 30.0f);
        textField.layer.cornerRadius = 3;
        y += 40;
    }
    
    // Buttons
    for (SCLButton *btn in _buttons)
    {
        btn.frame = CGRectMake(12.0f, y, kWindowWidth - 24, 35.0f);
        btn.layer.cornerRadius = 3;
        y += 45.0;
    }
}


- (UITextField *)addTextField:(NSString *)title
{
    // Update view height
    kWindowHeight += 40.0;
    
    // Add text field
    UITextField *txt = [[UITextField alloc] init];
    txt.borderStyle = UITextBorderStyleRoundedRect;
    txt.font = [UIFont fontWithName:kDefaultFont size:14.0f];
    txt.autocapitalizationType = UITextAutocapitalizationTypeWords;
    txt.clearButtonMode = UITextFieldViewModeWhileEditing;
    txt.layer.masksToBounds = YES;
    txt.layer.borderWidth = 1.0f;
    
    if (title != nil)
    {
        txt.placeholder = title;
    }
    
    [contentView addSubview:txt];
    [_inputs addObject:txt];
    
    return txt;
}

//private
- (SCLButton *)addButton:(NSString *)title
{
    // Update view height
    kWindowHeight += 45.0;
    
    // Add button
    SCLButton *btn = [[SCLButton alloc] init];
    btn.layer.masksToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:kButtonFont size:14.0f];

    [contentView addSubview:btn];
    [_buttons addObject:btn];
    
    return btn;
}

- (SCLButton *)addButton:(NSString *)title action:(SEL)action
{
    SCLButton *btn = [self addButton:title];
    btn.actionType = Closure;
    btn.action = action;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}


- (SCLButton *)addButton:(NSString *)title target:(id)target selector:(SEL)selector
{
    SCLButton *btn = [self addButton:title];
    btn.actionType = Selector;
    btn.target = target;
    btn.selector = selector;
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)buttonTapped:(SCLButton *)btn
{
    if (btn.actionType == Closure)
    {
        [btn action];
    }
    else if (btn.actionType == Selector)
    {
        UIControl *ctrl = [[UIControl alloc] init];
        [ctrl sendAction:btn.selector to:btn.target forEvent:nil];
    }
    else
    {
        NSLog(@"Unknow action type for button");
    }
    [self hideView];
}

-(SCLAlertViewResponder *)showTitle:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle duration:(NSTimeInterval)duration completeText:(NSString *)completeText style:(SCLAlertViewStyle)style
{
    self.view.alpha = 0;
    self.rootViewController = vc;
    
    // Add subviews
    [self.rootViewController addChildViewController:self];
    self.shadowView.frame = vc.view.bounds;
    [self.rootViewController.view addSubview:self.shadowView];
    [self.rootViewController.view addSubview:self.view];

    // Alert colour/icon
    UIColor *viewColor;
    UIImage *iconImage;

    // Icon style
    switch (style)
    {
        case Success:
            viewColor = UIColorFromRGB(0x22B573);
            iconImage = SCLAlertViewStyleKit.imageOfCheckmark;
            break;

        case Error:
            viewColor = UIColorFromRGB(0xC1272D);
            iconImage = SCLAlertViewStyleKit.imageOfCross;
            break;

        case Notice:
            viewColor = UIColorFromRGB(0x727375);
            iconImage = SCLAlertViewStyleKit.imageOfNotice;
            break;

        case Warning:
            viewColor = UIColorFromRGB(0xFFD110);
            iconImage = SCLAlertViewStyleKit.imageOfWarning;
            break;

        case Info:
            viewColor = UIColorFromRGB(0x2866BF);
            iconImage = SCLAlertViewStyleKit.imageOfInfo;
            break;

        case Edit:
            viewColor = UIColorFromRGB(0xA429FF);
            iconImage = SCLAlertViewStyleKit.imageOfEdit;
            break;
    }

    // Title
    if([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        self.labelTitle.text = title;
    }

    // Subtitle
    if([subTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        _viewText.text = subTitle;
        
        // Adjust text view size, if necessary
        NSString *str = subTitle;
        CGSize sz = CGSizeMake(kWindowWidth - 24.0f, 90.0f);
        NSDictionary *attr = @{NSFontAttributeName:self.viewText.font};
        CGRect r = [str boundingRectWithSize:sz options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
        CGFloat ht = ceil(r.size.height) + 10;
        if (ht < kTextHeight)
        {
            kWindowHeight -= (kTextHeight - ht);
            kTextHeight = ht;
        }
    }

    // Done button
    NSString *txt = completeText != nil ? completeText : @"Done";
    [self addButton:txt target:self selector:@selector(hideView)];

    // Alert view colour and images
    self.circleView.backgroundColor = viewColor;
    self.circleIconImageView.image  = iconImage;
    
    for (UITextField *textField in _inputs)
    {
        textField.layer.borderColor = viewColor.CGColor;
    }
    
    for (SCLButton *btn in _buttons)
    {
        btn.backgroundColor = viewColor;
        
        if (style == Warning)
        {
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    // Adding duration
    if (duration > 0)
    {
        [durationTimer invalidate];
        durationTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                          target:self
                                                        selector:@selector(hideView)
                                                        userInfo:nil
                                                         repeats:NO];
    }

    // Animate in the alert view
    [UIView animateWithDuration:0.2f animations:^{
        self.shadowView.alpha = kDefaultShadowOpacity;
        
        //New Frame
        CGRect frame = self.view.frame;
        frame.origin.y = self.rootViewController.view.center.y - 100.0f;
        self.view.frame = frame;
    
        self.view.alpha = 1.0f;
    } completion:^(BOOL completed) {
        [UIView animateWithDuration:0.2f animations:^{
            self.view.center = self.rootViewController.view.center;
        }];
    }];


    // Chainable objects
    return [[SCLAlertViewResponder alloc] init:self];
}

// showSuccess(view, title, subTitle)
- (void)showSuccess:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Success];
}

// showError(view, title, subTitle)
- (void)showError:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Error];
}

// showNotice(view, title, subTitle)
- (void)showNotice:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Notice];
}

// showWarning(view, title, subTitle)
- (void)showWarning:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Warning];
}

// showInfo(view, title, subTitle)
- (void)showInfo:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Info];
}

- (void)showEdit:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:Edit];
}

// showTitle(view, title, subTitle, style)
- (void)showTitle:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle style:(SCLAlertViewStyle)style closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration
{
    [self showTitle:vc title:title subTitle:subTitle duration:duration completeText:closeButtonTitle style:style];
}

// Close SCLAlertView
- (void)hideView
{
    [UIView animateWithDuration:0.2f animations:^{
        self.shadowView.alpha = 0;
        self.view.alpha = 0;
    } completion:^(BOOL completed) {
        [self.shadowView removeFromSuperview];
        [self.view removeFromSuperview];
    }];
}

@end