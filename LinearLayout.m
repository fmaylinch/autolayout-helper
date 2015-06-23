
#import "LinearLayout.h"
#import "AutolayoutHelper.h"

#define DEFAULT_VIEW_SIZE NSIntegerMax

@interface LinearLayout ()
@property(nonatomic, strong) AutolayoutHelper* layout;
@property(nonatomic) NSUInteger numberOfViews;
@end

@implementation LinearLayout

- (instancetype)initVertical {
    return [self initWithOrientation:UILayoutConstraintAxisVertical];
}

- (instancetype)initHorizontal {
    return [self initWithOrientation:UILayoutConstraintAxisHorizontal];
}

- (instancetype)initWithOrientation:(UILayoutConstraintAxis)orientation
{
    self = [super init];

    _orientation = orientation;
    self.numberOfViews = 0;
    [self setAllMargins:0];
    
    self.layout = [[AutolayoutHelper alloc] initWithView:self];

    return self;
}

- (void)setAllMargins:(CGFloat)margin
{
    self.marginEnds = self.marginBetween = self.marginSides = margin;
}

- (void)appendSubview:(UIView*)view
{
    [self appendSubview:view size:DEFAULT_VIEW_SIZE];
}

- (void)appendSubview:(UIView*)view size:(CGFloat)size
{
    self.layout.metrics = @{
            @"e":@(self.marginEnds),
            @"b":@(self.marginBetween),
            @"l":@(self.marginSides),
            @"s":@(size)
    };

    NSUInteger i = ++self.numberOfViews;

    NSString* viewKey = [self viewKeyForIndex:i];
    
    [self.layout addView:view withKey:viewKey];

    if (size != DEFAULT_VIEW_SIZE) {
        [self.layout addConstraint:[NSString stringWithFormat:@"%@:[%@(s)]", [self mainType], viewKey]];
    }

    if (i == 1) {
        // For first view, align to superview start
        [self.layout addConstraint:[NSString stringWithFormat:@"%@:|-(e)-[%@]", [self mainType], viewKey]];
    } else {
        // Align to previous view
        NSString* previousViewKey = [self viewKeyForIndex:i-1];
        [self.layout addConstraint:[NSString stringWithFormat:@"%@:[%@]-(b)-[%@]", [self mainType], previousViewKey, viewKey]];
    }

    // Now align to superview end (override constraint)
    [self.layout setConstraints:@[[NSString stringWithFormat:@"%@:[%@]-(e)-|", [self mainType], viewKey]] forKey:@"end align"];

    // And align to superview margins in the other orientation
    [self.layout addConstraint:[NSString stringWithFormat:@"%@:|-(l)-[%@]-(l)-|", [self otherType], viewKey]];
}

- (NSString*)viewKeyForIndex:(NSUInteger)i {
    return [NSString stringWithFormat:@"v%lu", (unsigned long)i];
}

- (NSString*)mainType {
    return self.orientation == UILayoutConstraintAxisHorizontal ? @"H" : @"V";
}

- (NSString*)otherType {
    return self.orientation == UILayoutConstraintAxisHorizontal ? @"V" : @"H";
}


@end