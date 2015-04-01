
// Helper to configure auto layout constraints
//
// Based on this tutorial: http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/

#import <Foundation/Foundation.h>


@interface AutolayoutHelper : NSObject

- (id)initWithView:(UIView*)view subViews:(NSDictionary*)subViews;

- (void)addConstraint:(NSString*)constraint;

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews constraints:(NSArray*)constraints;

+ (void)configureView:(UIView*)view subViews:(NSDictionary*)subViews metrics:(NSDictionary*)metrics constraints:(NSArray*)constraints;

- (void)addSubViewsToParentView;

+ (void)setDisplayBackgroundColorsForDebugging:(BOOL)displayColor;

- (void)prepareSubViews;
@end