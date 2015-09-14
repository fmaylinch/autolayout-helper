
#import "AutolayoutHelper.h"

#define XT_CONSTRAINT_ERROR @"Invalid extended constraint"


@interface AutolayoutHelper ()

@property(nonatomic, strong) NSMutableDictionary* temporalConstraints;
@property(nonatomic, strong) UIView* strongPointerToView;

@end


@implementation AutolayoutHelper

BOOL displayBackgroundColorsForDebugging = NO;

NSRegularExpression * xtConstraintRegex;
NSDictionary* attributes;
NSDictionary* relations;


+ (void) initialize
{
    [self initializeXtConstraintLogic];
}

+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColors {
    displayBackgroundColorsForDebugging = displayColors;
}


+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints
{
    return [AutolayoutHelper configureView:view subViews:subViews metrics:nil constraints:constraints];
}

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints
{
    return [self configureView:view subViews:subViews metrics:metrics constraints:constraints keepViewStrongly:NO];
}

+ (AutolayoutHelper*)configureView:(UIView*)view subViewLayers:(NSArray*)subViewLayers metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints
{
    return [AutolayoutHelper configureView:view subViewLayers:subViewLayers metrics:metrics constraints:constraints keepViewStrongly:NO];
}

+ (AutolayoutHelper*)configureView:(UIView*)view fillWithSubView:(UIView*)v
{
    return [self configureView:view subViews:VarBindings(v) constraints:@[@"H:|[v]|", @"V:|[v]|"]];
}

+ (AutolayoutHelper*)configureViewController:(UIViewController*)controller fillWithSubView:(UIView*)v
{
    id <UILayoutSupport> top = controller.topLayoutGuide;
    id <UILayoutSupport> bottom = controller.bottomLayoutGuide;

    return [self configureView:controller.view
                      subViews:VarBindings(top, v, bottom)
                   constraints:@[@"H:|[v]|", @"V:[top][v][bottom]"]];
}

+ (AutolayoutHelper*)subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints
{
    return [AutolayoutHelper subViews:subViews metrics:nil constraints:constraints];
}

+ (AutolayoutHelper*)subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints
{
    // Here we want to keep the view strongly, because the AutolayoutHelper.view property is weak
    return [self configureView:[[UIView alloc] init] subViews:subViews metrics:metrics constraints:constraints keepViewStrongly:YES];
}

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints keepViewStrongly:(BOOL)keepViewStrongly
{
    return [AutolayoutHelper configureView:view subViewLayers:@[subViews] metrics:metrics constraints:constraints keepViewStrongly:keepViewStrongly];
}

+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView {

    [AutolayoutHelper configureView:scrollView fillWithSubView:contentView];

    [mainView addConstraints:[NSLayoutConstraint
            constraintsWithVisualFormat:@"H:[contentView(==mainView)]"
                                options:(NSLayoutFormatOptions)0
                                metrics:nil
                                  views:VarBindings(contentView, mainView)]];
}

/**
*  The methods above end up calling this one
*/
+ (AutolayoutHelper*)configureView:(UIView*)view subViewLayers:(NSArray*)subViewLayers metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints keepViewStrongly:(BOOL)keepViewStrongly
{
    AutolayoutHelper* helper = [[AutolayoutHelper alloc] initWithView:view];

    if (keepViewStrongly) {
        helper.strongPointerToView = view;
    }

    helper.metrics = metrics;

    for (NSDictionary* subViews in subViewLayers) {
        [helper addViews:subViews];
    }

    [helper addConstraints:constraints];

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
        [self addView:subView withKey:subViewKey];
    }
}

- (void)addView:(UIView*)subView withKey:(NSString *)subViewKey
{
    self.subViews[subViewKey] = subView;

    // Ignore layout guides, just keep then in subViews dictionary
    if ([subView conformsToProtocol:@protocol(UILayoutSupport)]) {
        return;
    }

    subView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:subView];

    if (displayBackgroundColorsForDebugging) {
        subView.backgroundColor = [AutolayoutHelper getRandomColorWithAlpha:0.4];
    }
}

+ (UIColor*)getRandomColorWithAlpha:(CGFloat)alpha
{
    u_int32_t red = arc4random_uniform(256);
    u_int32_t green = arc4random_uniform(256);
    u_int32_t blue = arc4random_uniform(256);

    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

- (void)addViews:(NSDictionary*)subViews constraints:(NSArray*)constraints {

    [self addViews:subViews];

    [self addConstraints:constraints];
}

- (void)removeViews:(NSDictionary*)subViews {

    [self removeViewsWithKeys:subViews.allKeys];
}

- (void)removeViewsWithKeys:(NSArray*)viewKeys {

    for (NSString* viewKey in viewKeys) {
        UIView* subView = self.subViews[viewKey];
        [subView removeFromSuperview];
        [self.subViews removeObjectForKey:viewKey];
    }
}

- (void)addConstraints:(NSArray*)constraints
{
    [self addConstraints:constraints priority:PRIORITY_DEFAULT];
}

- (void)addConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority
{
    for (NSString* constraint in constraints) {
        [self addConstraint:constraint priority:priority];
    }
}

- (NSArray*)addConstraint:(NSString*)constraint
{
    return [self addConstraint:constraint priority:PRIORITY_DEFAULT];
}

- (NSArray*)addConstraint:(NSString*)constraint priority:(UILayoutPriority)priority
{
    NSArray *constraints = [self parseConstraint:constraint];

    if (priority != PRIORITY_DEFAULT) {
        for (NSLayoutConstraint* c in constraints) {
            c.priority = priority;
        }
    }

    [self.view addConstraints:constraints];

    return constraints;
}

- (NSArray*)parseConstraint:(NSString *)constraint
{
    if ([constraint hasPrefix:XT_CONSTRAINT_SYMBOL])
    {
        return [self parseXtConstraint:constraint];

    } else {
        // Normal VFL constraint
        return [NSLayoutConstraint constraintsWithVisualFormat:constraint
                                                       options:(NSLayoutFormatOptions) 0
                                                       metrics:self.metrics
                                                         views:self.subViews];
    }
}

- (void)setConstraints:(NSArray*)constraints forKey:(NSString*)key {
    [self setConstraints:constraints priority:PRIORITY_DEFAULT forKey:key];
}

- (void)setConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority forKey:(NSString*)key {

    // Remove previously added constraints for that key

    NSArray* constraintsToRemove = self.temporalConstraints[key];

    if (constraintsToRemove.count > 0) {
        [self.view removeConstraints:constraintsToRemove];
        [self.temporalConstraints removeObjectForKey:key];
    }

    // Add new constraints and store them

    NSMutableArray* addedConstraints = [[NSMutableArray alloc] init];

    for (NSString* constraint in constraints) {
        NSArray* resultingConstraints = [self addConstraint:constraint priority:priority];
        [addedConstraints addObjectsFromArray:resultingConstraints];
    }

    self.temporalConstraints[key] = addedConstraints;
}


#pragma mark - xt constaints

+ (void)initializeXtConstraintLogic
{
    [self initializeXtConstraintRegex];

    attributes = @{
            @"left" : @(NSLayoutAttributeLeft),
            @"right" : @(NSLayoutAttributeRight),
            @"top" : @(NSLayoutAttributeTop),
            @"bottom" : @(NSLayoutAttributeBottom),
            @"leading" : @(NSLayoutAttributeLeading),
            @"trailing" : @(NSLayoutAttributeTrailing),
            @"width" : @(NSLayoutAttributeWidth),
            @"height" : @(NSLayoutAttributeHeight),
            @"centerX" : @(NSLayoutAttributeCenterX),
            @"centerY" : @(NSLayoutAttributeCenterY),
            @"baseline" : @(NSLayoutAttributeBaseline)
    };

    relations = @{
            @"==" : @(NSLayoutRelationEqual),
            @">=" : @(NSLayoutRelationGreaterThanOrEqual),
            @"<=" : @(NSLayoutRelationLessThanOrEqual)
    };
}

+ (void)initializeXtConstraintRegex
{
    NSError* error = nil;
    // C identifier
    NSString* identifier = @"[_a-zA-Z][_a-zA-Z0-9]{0,30}";
    // VIEW_KEY.ATTR or (use "superview" as VIEW_KEY to refer to superview)
    NSString* attr = [NSString stringWithFormat:@"(%@)\\.(%@)", identifier, identifier];
    // Relations taken from NSLayoutRelation
    NSString* relation = @"([=><]+)";
    // float number e.g. "12", "12.", "2.56"
    NSString* number = @"\\d+\\.?\\d*";
    // Value (indentifier or number)
    NSString* value = [NSString stringWithFormat:@"(?:(?:%@)|(?:%@))", identifier, number];
    // e.g. "*5" or "/ 27.3" or "* 200"
    NSString* multiplier = [NSString stringWithFormat:@"([*/]) *(%@)", value];
    // e.g. "+ 2." or "- 56" or "-7.5"
    NSString* constant = [NSString stringWithFormat:@"([+-]) *(%@)", value];

    NSString* pattern = [NSString stringWithFormat:@"^%@: *%@ *%@ *%@ *(?:%@)? *(?:%@)?$",
                    XT_CONSTRAINT_SYMBOL, attr, relation, attr, multiplier, constant];

    xtConstraintRegex = [NSRegularExpression
            regularExpressionWithPattern:pattern
                                 options:NSRegularExpressionCaseInsensitive
                                   error:&error];
}

- (NSArray*)parseXtConstraint:(NSString*)constraint
{
    NSArray* results = [xtConstraintRegex matchesInString:constraint
                                                  options:0
                                                    range:NSMakeRange(0, constraint.length)];

    if (results.count != 1) {
        [self throwInvalidConstraint:constraint];
    }

    NSTextCheckingResult* match = results[0];

    // I think this won't happen if the regex is right, but check for debugging
    if (match.numberOfRanges != 10) {
        [self dumpMatch:match forString:constraint];
        [self throwInvalidConstraint:constraint];
    }

    // item1.attr1 relation item2.attr2 factor constant
    // e.g. v1.leading == v2.centerX / 2 + 10
    NSString* item1Key = [constraint substringWithRange:[match rangeAtIndex:1]];
    NSString* attr1Str = [constraint substringWithRange:[match rangeAtIndex:2]];
    NSString* relationStr = [constraint substringWithRange:[match rangeAtIndex:3]];
    NSString* item2Key = [constraint substringWithRange:[match rangeAtIndex:4]];
    NSString* attr2Str = [constraint substringWithRange:[match rangeAtIndex:5]];

    id item1 = [self findViewFromKey:item1Key];
    id item2 = [self findViewFromKey:item2Key];

    NSLayoutAttribute attr1 = [self parseAttribute:attr1Str];
    NSLayoutAttribute attr2 = [self parseAttribute:attr2Str];

    NSLayoutRelation relation = [self parseRelation:relationStr];

    // Default multiplier is 1
    CGFloat multiplier = 1;
    if ([match rangeAtIndex:6].location != NSNotFound)
    {
        NSString* operation = [constraint substringWithRange:[match rangeAtIndex:6]];
        NSString* multiplierValue = [constraint substringWithRange:[match rangeAtIndex:7]];
        multiplier = [self getFloatFromValue:multiplierValue];
        // If division, invert factor
        if ([operation isEqualToString:@"/"]) {
            multiplier = 1/multiplier;
        }
    }

    // Default constant is 0
    CGFloat constant = 0;
    if ([match rangeAtIndex:8].location != NSNotFound)
    {
        NSString* operation = [constraint substringWithRange:[match rangeAtIndex:8]];
        NSString* constantValue = [constraint substringWithRange:[match rangeAtIndex:9]];
        constant = [self getFloatFromValue:constantValue];
        // If subtraction, negate constant
        if ([operation isEqualToString:@"-"]) {
            constant = -constant;
        }
    }

    NSLayoutConstraint* c =
            [NSLayoutConstraint constraintWithItem:item1
                                         attribute:attr1
                                         relatedBy:relation
                                            toItem:item2
                                         attribute:attr2
                                        multiplier:multiplier
                                          constant:constant];

    return @[c];
}

- (float)getFloatFromValue:(NSString*)value
{
    if ([self stringStartsWithAlphaOrUnderscore:value]) { // if so, must be a metric identifier
        NSNumber* metric = self.metrics[value];
        if (metric) {
            return [metric floatValue];
        } else {
            NSString* reason = [NSString stringWithFormat:@"Metric `%@` was not provided", value];
            @throw([NSException exceptionWithName:XT_CONSTRAINT_ERROR reason:reason userInfo:nil]);
        }
    } else {
        return [value floatValue];
    }
}

- (BOOL)stringStartsWithAlphaOrUnderscore:(NSString*)value
{
    unichar c = [value characterAtIndex:0];
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

- (id)findViewFromKey:(NSString*)key
{
    if ([key isEqualToString:@"superview"]) {
        return self.view;
    } else {
        id view = self.subViews[key];
        if (view) {
            return view;
        } else {
            NSString* reason = [NSString stringWithFormat:@"No view was added with key `%@`", key];
            @throw([NSException exceptionWithName:XT_CONSTRAINT_ERROR reason:reason userInfo:nil]);
        }
    }
}

- (NSLayoutAttribute)parseAttribute:(NSString*)attrStr
{
    NSNumber* value = attributes[attrStr];

    if (value) {
        return (NSLayoutAttribute) [value intValue];
    } else {
        NSString* reason = [NSString stringWithFormat:@"Attribute `%@` is not valid. Use one of: %@", attrStr, [attributes allKeys]];
        @throw([NSException exceptionWithName:XT_CONSTRAINT_ERROR reason:reason userInfo:nil]);
    }
}

- (NSLayoutRelation)parseRelation:(NSString*)relationStr
{
    NSNumber* value = relations[relationStr];

    if (value) {
        return (NSLayoutRelation) [value intValue];
    } else {
        // This won't happen since the regex only matches if the relation is right
        NSString* reason = [NSString stringWithFormat:@"Relation `%@` is not valid. Use one of: %@", relationStr, [relations allKeys]];
        @throw([NSException exceptionWithName:XT_CONSTRAINT_ERROR reason:reason userInfo:nil]);
    }
}

- (void)throwInvalidConstraint:(NSString*)constraint
{
    [NSException raise:XT_CONSTRAINT_ERROR
                format:@"%@: %@", XT_CONSTRAINT_ERROR, constraint];
}

-(void)dumpMatch:(NSTextCheckingResult*)match forString:(NSString*)str
{
    for (NSUInteger i=0; i<match.numberOfRanges; i++) {
        NSRange range = [match rangeAtIndex:i];
        if (range.location != NSNotFound) {
            NSLog(@"Range %lu: %@", (unsigned long)i, [str substringWithRange:range]);
        } else {
            NSLog(@"Range %lu  NOT FOUND", (unsigned long)i);
        }
    }
}

@end