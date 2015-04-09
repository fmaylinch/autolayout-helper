
#import "AutolayoutHelper.h"


@interface AutolayoutHelper ()

@property(nonatomic, strong) NSMutableDictionary* temporalConstraints;

@end

@implementation AutolayoutHelper

BOOL displayBackgroundColorsForDebugging = NO;

+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColors {
    displayBackgroundColorsForDebugging = displayColors;
}

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints
{
    return [AutolayoutHelper configureView:view subViews:subViews metrics:nil constraints:constraints];
}

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints
{
    AutolayoutHelper* helper = [[AutolayoutHelper alloc] initWithView:view];

    helper.metrics = metrics;

    [helper addViews:subViews constraints:constraints];

    return helper;
}

- (id)initWithView:(UIView*)view
{
    self = [super init];

    self.view = view;
    self.subViews = [[NSMutableDictionary alloc] init];
    self.temporalConstraints = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)addViews:(NSDictionary*)subViews {

    for (NSString* subViewKey in subViews.allKeys) {

        UIView* subView = subViews[subViewKey];

        subView.translatesAutoresizingMaskIntoConstraints = NO;

        self.subViews[subViewKey] = subView;

        [self.view addSubview:subView];

        if (displayBackgroundColorsForDebugging) {
            u_int32_t red = arc4random_uniform(256);
            u_int32_t green = arc4random_uniform(256);
            u_int32_t blue = arc4random_uniform(256);
            subView.backgroundColor = [UIColor colorWithRed:red/255.0f
                                                      green:green/255.0f
                                                       blue:blue/255.0f
                                                      alpha:0.4];
        }
    }
}

- (void)addViews:(NSDictionary*)subViews constraints:(NSArray*)constraints {

    [self addViews:subViews];

    [self addConstraints:constraints];
}

- (void)removeViews:(NSDictionary*)subViews {

    for (NSString* viewKey in subViews.allKeys) {
        [self.subViews removeObjectForKey:viewKey];
        UIView* subView = subViews[viewKey];
        [subView removeFromSuperview];
    }
}

- (void)addConstraints:(NSArray*)constraints
{
    for (NSString* constraint in constraints) {
        [self addConstraint:constraint];
    }
}
- (NSArray*)addConstraint:(NSString*)constraint
{
    NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:constraint
                                                                      options:(NSLayoutFormatOptions) 0
                                                                      metrics:self.metrics
                                                                        views:self.subViews];

    [self.view addConstraints:constraints];
    
    return constraints;
}

+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView {

    [AutolayoutHelper configureView:scrollView
                           subViews:NSDictionaryOfVariableBindings(contentView)
                        constraints:@[ @"H:|[contentView]|", @"V:|[contentView]|" ]];

    NSDictionary* viewDict = NSDictionaryOfVariableBindings(contentView, mainView);
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]"
                                                                      options:0 metrics:0 views:viewDict]];
}

- (void)addConstraints:(NSArray*)constraints forKey:(NSString*)key {

    // Remove previously added constraints for that key

    NSArray* constraintsToRemove = self.temporalConstraints[key];

    if (constraintsToRemove.count > 0) {
        [self.view removeConstraints:constraintsToRemove];
        [self.temporalConstraints removeObjectForKey:key];
    }

    // Add new constraints and store them

    NSMutableArray* addedConstraints = [[NSMutableArray alloc] init];

    for (NSString* constraint in constraints) {
        NSArray* resultingConstraints = [self addConstraint:constraint];
        [addedConstraints addObjectsFromArray:resultingConstraints];
    }
    
    self.temporalConstraints[key] = addedConstraints;
}

@end