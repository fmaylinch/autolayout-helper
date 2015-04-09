
// Helper to configure auto layout constraints
//
// Based on this tutorial: http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/
// Also inspired by this: http://stackoverflow.com/a/18066138/1121497

#import <Foundation/Foundation.h>

#define VarBindings(...) _NSDictionaryOfVariableBindings(@"" # __VA_ARGS__, __VA_ARGS__, nil)

@interface AutolayoutHelper : NSObject


@property(nonatomic, weak) UIView* view;
@property(nonatomic, strong) NSMutableDictionary* subViews;
@property(nonatomic, strong) NSDictionary* metrics;


+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColor;

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

+ (AutolayoutHelper*)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

- (id)initWithView:(UIView*)view;

- (void)addViews:(NSDictionary*)subViews;

- (void)addViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

- (void)removeViews:(NSDictionary*)subViews;

- (NSArray*)addConstraint:(NSString*)constraint;

- (void)addConstraints:(NSArray*)constraints;

// Adds the given constraints, but first removes any constraints added previously with this method using the same key
- (void)addConstraints:(NSArray*)constraints forKey:(NSString*)key;

/**
 * Helper method to configure a UIScrollView that has the same width as the mainView.
 * First add the scrollView to the mainView (using AutolayoutHelper also, if you want).
 * For more info see: http://stackoverflow.com/a/16843937/1121497
 */
+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView;

@end