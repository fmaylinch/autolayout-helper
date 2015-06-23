
// Similar to a really simple Android LinearLayout

#import <UIKit/UIKit.h>

@class AutolayoutHelper;

@interface LinearLayout : UIView

@property(nonatomic, readonly) UILayoutConstraintAxis orientation;

@property(nonatomic) CGFloat marginEnds;    // margin on both ends of the layout (according to orientation axis)
@property(nonatomic) CGFloat marginBetween; // margin between each appended view (according to orientation axis)
@property(nonatomic) CGFloat marginSides;   // margin on both sides of the layout (according to the other orientation axis)

- (instancetype)initWithOrientation:(UILayoutConstraintAxis)orientation;
- (instancetype)initVertical;
- (instancetype)initHorizontal;

- (void)setAllMargins:(CGFloat)margin;

/** Appends a view following the orientation */
- (void)appendSubview:(UIView*)view;

/** Appends a view following the orientation, and setting a constraint for the view size in the orientation axis */
- (void)appendSubview:(UIView*)view size:(CGFloat)size;

@end