
// Helper to configure auto layout constraints
//
// Based on this tutorial: http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/
// Also inspired by this: http://stackoverflow.com/a/18066138/1121497

#import <UIKit/UIKit.h>

#define VarBindings NSDictionaryOfVariableBindings

#define PRIORITY_DEFAULT -1
#define XT_CONSTRAINT_SYMBOL @"X"


@interface AutolayoutHelper : NSObject


@property(nonatomic, weak) UIView* view;
@property(nonatomic, strong) NSMutableDictionary* subViews;
@property(nonatomic, strong) NSDictionary* metrics;


+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColor;

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

- (id)initWithView:(UIView*)view;

- (void)addViews:(NSDictionary*)subViews;

- (void)addView:(UIView*)subView withKey:(NSString*)subViewKey;

- (void)addViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

- (void)removeViews:(NSDictionary*)subViews;

- (void)removeViewsWithKeys:(NSArray*)array;

- (NSArray*)addConstraint:(NSString*)constraint;

- (NSArray*)addConstraint:(NSString*)constraint priority:(UILayoutPriority)priority;

- (void)addConstraints:(NSArray*)constraints;

- (void)addConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority;

// Adds the given constraints, but first removes any constraints added previously with this method using the same key
- (void)setConstraints:(NSArray*)constraints forKey:(NSString*)key;

- (void)setConstraints:(NSArray*)constraints priority:(UILayoutPriority)priority forKey:(NSString*)key;
/**
 * Helper method to configure a UIScrollView that has the same width as the mainView.
 * First add the scrollView to the mainView (using AutolayoutHelper also, if you want).
 * For more info see: http://stackoverflow.com/a/16843937/1121497
 */
+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView;

@end