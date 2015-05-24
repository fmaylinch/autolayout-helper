#import "AutolayoutHelper.h"

#define XT_CONSTRAINT_ERROR @"Invalid extended constraint"


@interface AutolayoutHelper ()

@property(nonatomic, strong) NSMutableDictionary* temporalConstraints;

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

+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView {
    
    [AutolayoutHelper configureView:scrollView
                           subViews:NSDictionaryOfVariableBindings(contentView)
                        constraints:@[ @"H:|[contentView]|", @"V:|[contentView]|" ]];
    
    NSDictionary* viewDict = NSDictionaryOfVariableBindings(contentView, mainView);
    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(==mainView)]"
                                                                     options:0 metrics:0 views:viewDict]];
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
    NSString* identifier = @"[_a-zA-Z][_a-zA-Z0-9]{0,30}";
    // VIEW_KEY.ATTR or (use "superview" as VIEW_KEY to refer to superview)
    NSString* attr = [NSString stringWithFormat:@"(%@)\\.(%@)", identifier, identifier];
    NSString* relation = @"*(==|>=|<=)";
    NSString* number = @"\\d+\\.?\\d*";              // float number e.g. "12", "12.", "2.56"
    NSString* multiplier = [NSString stringWithFormat:@"([*/]) *(%@)", number];  // e.g. "*5" or "/ 27.3" or "* 200"
    NSString* constant = [NSString stringWithFormat:@"([+-]) *(%@)", number];    // e.g. "+ 2." or "- 56" or "-7.5"
    
    NSString* pattern = [NSString stringWithFormat:@"^%@:%@ %@ *%@ *(%@)? *(%@)?$",
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
    
    if (match.numberOfRanges != 12) {
        // I think this can't happen, but check anyway
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
        NSString* operation = [constraint substringWithRange:[match rangeAtIndex:7]];
        NSString* multiplierStr = [constraint substringWithRange:[match rangeAtIndex:8]];
        multiplier = [multiplierStr floatValue];
        // If division, invert factor
        if ([operation isEqualToString:@"/"]) {
            multiplier = 1/multiplier;
        }
    }
    
    // Default constant is 0
    CGFloat constant = 0;
    if ([match rangeAtIndex:9].location != NSNotFound)
    {
        NSString* operation = [constraint substringWithRange:[match rangeAtIndex:10]];
        NSString* constantStr = [constraint substringWithRange:[match rangeAtIndex:11]];
        constant = [constantStr floatValue];
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

- (void)throwInvalidConstraint:(NSString*)constraint
{
    [NSException raise:XT_CONSTRAINT_ERROR
                format:@"%@: %@", XT_CONSTRAINT_ERROR, constraint];
}

- (id)findViewFromKey:(NSString*)key
{
    if ([key isEqualToString:@"superview"]) {
        return self.view;
    } else {
        return self.subViews[key];
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

@end