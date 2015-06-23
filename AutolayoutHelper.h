
// Helper to configure auto layout constraints
// Supports VFL constraints and more extended constraints (see README.md)
//
// Based on this tutorial: http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/
// Also inspired by this: http://stackoverflow.com/a/18066138/1121497

#import <UIKit/UIKit.h>

#define VarBindings NSDictionaryOfVariableBindings

#define PRIORITY_DEFAULT -1
#define XT_CONSTRAINT_SYMBOL @"X"


@interface AutolayoutHelper : NSObject


@property(nonatomic, weak) UIView* view;                    // The view where the subviews and constraints will be added
@property(nonatomic, strong) NSMutableDictionary* subViews; // Dictionary of key:subview (subviews to be added to the view)
@property(nonatomic, strong) NSDictionary* metrics;         // Metrics to be used for the constraints


// When set to true, subviews will be painted with random semi-transparent backgrounds
// just to better visualize the position and sizes of the subviews.
+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColor;


// Convenience class methods
// Arguments:
//   subViews:      NSDictionary* of (NSString*)key:(UIView*)view with subviews to add and their keys to be referred in constraints
//   subViewLayers: NSArray* of NSDictionary* subViews, useful when some views should be added before others
//   metrics:       NSDictionary* of (NSString*)key:(NSNumber*)value with metrics to be referred in constraints
//   constraints:   NSArray* of NSString* with VFL constraints (and also other extended constraints; see README.md)

// Adds subViews and VFL constraints to view
+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

// Adds subViews and VFL constraints (with given metrics) to view
+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

// Adds subViewLayers and VFL constraints (with given metrics) to view
+ (AutolayoutHelper*)configureView:(UIView*)view subViewLayers:(NSArray*)subViewLayers metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

// Adds the subview to the view so it fills it (aligns to edges)
+ (AutolayoutHelper*)configureView:(UIView*)view fillWithSubView:(UIView*)subview;

// Adds the subview to the controller.view so it fills it (aligns to edges)
+ (AutolayoutHelper*)configureViewController:(UIViewController*)controller fillWithSubView:(UIView*)subview;

// Adds the subViews and VFL constraints to a new UIView
+ (AutolayoutHelper*)subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

// Adds the subViews and VFL constraints (with given metrics) to a new UIView
+ (AutolayoutHelper*)subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

// Configures a "vertical" scroll view (see README.md)
+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView;


// Initializes this helper to configure subviews of the given view
- (id)initWithView:(UIView*)view;


// Adds subViews to self.view
- (void)addViews:(NSDictionary*)subViews;

// Adds subView to self.view, and uses subViewKey for constraints
- (void)addView:(UIView*)subView withKey:(NSString*)subViewKey;

// Adds subViews and constraints to self.view
- (void)addViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

// Removes subViews from self.view (actually, it uses only the dictionary keys)
- (void)removeViews:(NSDictionary*)subViews;

// Removes subViews with given viewKeys from self.view
- (void)removeViewsWithKeys:(NSArray*)viewKeys;

// Adds one constraint and returns an array of the generated NSLayoutConstraint
- (NSArray*)addConstraint:(NSString*)constraint;

// Adds one constraint with given priority and returns an array of the generated NSLayoutConstraint
- (NSArray*)addConstraint:(NSString*)constraint priority:(UILayoutPriority)priority;

// Adds constraints
- (void)addConstraints:(NSArray*)constraints;

// Adds constraints with given priority
- (void)addConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority;

// Adds constraints, replacing constraints that were added before with the same key
- (void)setConstraints:(NSArray*)constraints forKey:(NSString*)key;

// Adds constraints with given priority, replacing constraints that were added before with the same key
- (void)setConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority forKey:(NSString*)key;

@end