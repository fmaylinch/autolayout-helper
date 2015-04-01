
#import "AutolayoutHelper.h"


@interface AutolayoutHelper ()

@property(nonatomic, weak) UIView* view;
@property(nonatomic, weak) NSDictionary* subViews;
@property(nonatomic, strong) NSDictionary* metrics;

@end

@implementation AutolayoutHelper

BOOL displayBackgroundColorsForDebugging = NO;

- (id)initWithView:(UIView*)view subViews:(NSDictionary*)subViews
{
    self = [super init];
    
    self.view = view;
    self.subViews = subViews;

    return self;
}

- (void)addConstraint:(NSString*)constraint
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraint
                                                                      options:(NSLayoutFormatOptions) 0
                                                                      metrics:self.metrics
                                                                        views:self.subViews]];
}

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints
{
    [AutolayoutHelper configureView:view subViews:subViews metrics:nil constraints:constraints];
}

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints
{
    AutolayoutHelper* autolayoutHelper = [[AutolayoutHelper alloc] initWithView:view subViews:subViews];

    [autolayoutHelper prepareSubViews];
    [autolayoutHelper addSubViewsToParentView];
    autolayoutHelper.metrics = metrics;

    for (NSString* constraint in constraints) {
        [autolayoutHelper addConstraint:constraint];
    }
}

- (void)addSubViewsToParentView {

    for (UIView* subView in self.subViews.allValues) {
        [self.view addSubview:subView];

        if (displayBackgroundColorsForDebugging) {
            u_int32_t red = arc4random_uniform(256);
            u_int32_t green = arc4random_uniform(256);
            u_int32_t blue = arc4random_uniform(256);
            subView.backgroundColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue /255.0f alpha:0.4];
        }
    }
}

+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColors {
    displayBackgroundColorsForDebugging = displayColors;
}

- (void)prepareSubViews
{
    for (UIView* subView in self.subViews.allValues) {
        subView.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

@end