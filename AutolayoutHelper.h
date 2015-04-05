
// Helper to configure auto layout constraints
//
// Based on this tutorial: http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/

#import <Foundation/Foundation.h>


@interface AutolayoutHelper : NSObject

- (id)initWithView:(UIView*)view subViews:(NSDictionary*)subViews;

- (void)addSubViewsToParentView;

- (void)disableAutoresizingMask;

- (void)setRandomBackgroundColors;

+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColor;

- (void)addConstraint:(NSString*)constraint;

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

/**
 * Helper method to configure a UIScrollView that has the same width as the mainView.
 * First add the scrollView to the mainView (using AutolayoutHelper also, if you want).
 * For more info see: http://stackoverflow.com/a/16843937/1121497
 */
+ (void)configureScrollView:(UIScrollView*)scrollView contentView:(UIView*)contentView mainView:(UIView*)mainView;

@end