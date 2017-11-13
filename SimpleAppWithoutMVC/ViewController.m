//
//  ViewController.m
//  SimpleAppWithoutMVC
//
//  Created by Vladimir Khabarov on 25.09.17.
//  Copyright © 2017 vs-khabarov. All rights reserved.
//

#import "ViewController.h"

const double DEFAULT_TIME_INTERVAL = 0.05;
const int DEFAULT_COUNT_OF_IMAGES = 1;
const int RADIUS = 100;

@interface ViewController ()
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UITextField *timeIntervalTextField;
@property (retain, nonatomic) IBOutlet UITextField *countOfImagesTextField;

@property (retain, nonatomic) NSTimer *myTimer;
@property (retain, nonatomic) NSMutableArray *myImageViews;

@property (nonatomic) double degrees;
@property (nonatomic) double timeInterval;
@property (nonatomic) int countOfImages;
@property (nonatomic) BOOL countOfImagesDidChange;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _degrees = -90;
    _timeInterval = DEFAULT_TIME_INTERVAL;
    _countOfImages = DEFAULT_COUNT_OF_IMAGES;
    _countOfImagesDidChange = NO;
    [self updateMyImageViews];
    [self showImages];
}

- (NSMutableArray *)myImageViews {
    if (!_myImageViews)
        _myImageViews = [[NSMutableArray alloc] init];
    return _myImageViews;
}

- (void)setTimeInterval:(double)timeInterval {
    if (timeInterval == 0)
        _timeInterval = DEFAULT_TIME_INTERVAL;
    else
        _timeInterval = timeInterval;
}

- (void)setCountOfImages:(int)countOfImages
{
    if (countOfImages == 0) {
        _countOfImages = DEFAULT_COUNT_OF_IMAGES;
        return;
    }
    if (countOfImages != _countOfImages)
    {
        self.degrees = -90;
        self.countOfImagesDidChange = YES;
        _countOfImages = countOfImages;
    }
}

#pragma mark IBActions
- (IBAction)timeIntervalTextField:(UITextField *)sender {
    self.timeInterval = sender.text.doubleValue;
}

- (IBAction)countOfImagesTextField:(UITextField *)sender {
    self.countOfImages = sender.text.intValue;
}

- (IBAction)startStopButton:(UIButton *)sender
{
    [self.timeIntervalTextField resignFirstResponder];
    [self.countOfImagesTextField resignFirstResponder];
    
    if ([self.timeIntervalTextField.text isEqualToString:@""] || self.timeIntervalTextField.text.doubleValue == 0)
        self.timeIntervalTextField.text = [NSString stringWithFormat: @"%.2f", DEFAULT_TIME_INTERVAL];
    
    if ([self.countOfImagesTextField.text isEqualToString:@""])
        self.countOfImagesTextField.text = [NSString stringWithFormat: @"%d", DEFAULT_COUNT_OF_IMAGES];
    
    if (self.countOfImagesDidChange) {
        [self showImages];
        self.countOfImagesDidChange = NO;
    }
    
    if(!self.myTimer.isValid)
    {
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                        target:self
                                                      selector:@selector(moveAllImages)
                                                      userInfo:nil
                                                       repeats:YES];
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else
    {
        [self.myTimer invalidate];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }
}
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;

    if (textField == self.timeIntervalTextField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^\\d+[.,]?\\d*$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0 || newString.length > 5)
            return NO;
    }

    if (textField == self.countOfImagesTextField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newString.intValue == 0 || newString.intValue > 10)
            return NO;
    }

    return YES;
}

- (void)showImages
{
    for (UIImageView *imageView in self.myImageViews)
        [imageView removeFromSuperview];
    
    [self updateMyImageViews];
    
    double degrees = (360 / self.countOfImages) - 90;
    for (UIImageView* imageView in self.myImageViews)
    {
        imageView.frame = CGRectMake(0, 0, 96, 128);
        imageView.center = self.view.center;
        [self moveImage:imageView degrees:degrees radius:RADIUS];
        [self.view addSubview:imageView];
        degrees += 360 / self.countOfImages;
    }
}

- (void)updateMyImageViews
{
    if (self.countOfImages >= self.myImageViews.count)
    {
        u_long countOfImages = self.countOfImages - self.myImageViews.count;
        UIImage *image = [UIImage imageNamed:@"stanford-tree"];
        
        for (u_long i = 0; i < countOfImages; ++i)
        {
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
            [self.myImageViews addObject:imageView];
        }
    }
    else
    {
        u_long countOfImages = self.myImageViews.count - self.countOfImages;
        for (u_long i = 0; i < countOfImages; ++i)
            [self.myImageViews removeLastObject];
    }
}

- (void)moveImage:(UIImageView *)imageView degrees:(double)degrees radius:(int)radius
{
    double rad = (degrees * M_PI) / 180;
    imageView.center = CGPointMake(self.view.center.x + cos(rad) * radius,
                                   self.view.center.y + sin(rad) * radius);
}

- (void)moveAllImages
{
    for (int i = 0; i < self.myImageViews.count; ++i)
    {
        double degrees = self.degrees + (i) * (360 / self.countOfImages);
        [self moveImage:self.myImageViews[i] degrees:degrees radius:RADIUS];
    }
    self.degrees += 2;
}

- (void)dealloc
{
    [_startButton release];
    [_countOfImagesTextField release];
    [_timeIntervalTextField release];
    [_myImageViews release];
    if ([self.myTimer isValid]) {
        [self.myTimer invalidate];
    }
    [super dealloc];
}

// ???: Who should be delegate of UITextField
//TODO: iPad landscape mode
@end
