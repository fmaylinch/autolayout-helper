# AutolayoutHelper

This is a Objective-C class that can help you [working with autolayout programmatically](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/AutoLayoutinCode/AutoLayoutinCode.html#//apple_ref/doc/uid/TP40010853-CH11-SW1) with the [visual format language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html).

## Installation 

Just copy the files to your project.

## Basic Usage

If you have a `view` where you want to put some subviews like `v1` and `v2`, call this method:

```objectivec
[AutolayoutHelper configureView:view
                       subViews:VarBindings(v1, v2)
                        metrics:@{@"h":@(50)}
                    constraints:@[
                            @"H:|[v1]|",
                            @"H:|[v2]|",
                            @"V:|-[v1(h)]-[v2]-|"
                    ]];
```

Note: `VarBindings(v1, v2)` has been defined like `NSDictionaryOfVariableBindings(v1, v2)`. Both are the same as `@{@"v1":v1, @"v2":v2}`.

This method prepares the `subViews` for autolayout (see [here](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/AdoptingAutoLayout/AdoptingAutoLayout.html#//apple_ref/doc/uid/TP40010853-CH15-SW1)), adds them to `view`, and also adds the constraints to `view`.

I recommend you to read the source code to understand everything. If you need some help with programatic autolayout, you can read this [tutorial](http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/).

## Advanced Usage

### Using extended constraint expressions

`AutolayoutHelper` extends the [visual format language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html) by adding support for constraints that require the [constraintWithItem](https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/#//apple_ref/occ/clm/NSLayoutConstraint/constraintWithItem:attribute:relatedBy:toItem:attribute:multiplier:constant:) method.

For example, let's say you want to add a constraint so the height of `v1` is half the height of `v2`. You would normally do that this way:

```objectivec
NSLayoutConstraint* c =
    [NSLayoutConstraint constraintWithItem:v1
                attribute:NSLayoutAttributeWidth
                relatedBy:NSLayoutRelationEqual
                   toItem:v2
                attribute:NSLayoutAttributeWidth
               multiplier:0.5
                 constant:0];
[view addConstraint:c];
```

That creates and adds a constraint that can be thought as this equation:

    v1.width == v2.width * 0.5 + 0

The equation is easier to read. And we could even simplify it as:

    v1.width == v2.width / 2

With `AutolayoutHelper` you could write that constraint like this:

```objectivec
    @"X:v1.width == v2.width / 2"
```

"X" stands for "extended". The syntax for extended constraints is:

    X:view1.attr1 relation view2.attr2 *|/ mult +|- const

* You can use any subview or refer to the superview using the `superview` key.
* You may use any attribute supported in iOS7 (see [NSLayoutAttribute](https://developer.apple.com/library/ios/documentation/AppKit/Reference/NSLayoutConstraint_Class/#//apple_ref/c/tdef/NSLayoutAttribute)).
* The `relation` can be `==`, `<=` or `>=`.
* The multiplier is optional (default: 1). Use `*` or `/` and a floating point number.
* The constant is optional (default: 0). Use `+` or `-` and a floating point number.

Examples:

```objectivec
    @"X:v1.top == v2.centerY * 0.5 - 10"
    @"X:v1.top >= v2.bottom"
    @"X:v1.centerX == superview.centerX + 5"
```


### Adding and removing views and constraints dynamically

Let's say you created the following layout. Notice is the same as the one above, but storing the result in a variable of type `AutolayoutHelper`.

```objectivec
AutolayoutHelper layout = [AutolayoutHelper
                  configureView:view
                       subViews:VarBindings(v1, v2)
                    constraints:@[
                            @"H:|[v1]|",
                            @"H:|[v2]|",
                            @"V:|-[v1]-[v2]-|"
                    ]];
```

Now let's suppose you want to replace the view `v2` by another `v3`.

First, remove `v2` with one of these methods:

```objectivec
[layout removeViews:VarBindings(v2)];
// or
[layout removeViewsWithKeys:@[@"v2"]];
 ```

Now the parts of the constraints that include the removed view `v2` will be automatically removed from the `view`, so the remaining constraints are: `"H:|[v1]|"` and `"V:|-[v1]"`. (We're left with the part of the vertical constraint that doesn't mention `v2`).

Now add `v3` and the necessary constraints:

```objectivec
[layout addViews:VarBindings(v3)
     constraints:@[
             @"H:|[v3]|",
             @"V:|-[v1]-[v3]-|"
     ]];
```

Now let's suppose you want to remove `v3` but you don't want to add any other view.

First remove `v3`:

```objectivec
[layout removeViews:VarBindings(v3)];
// or
[layout removeViewsWithKeys:@[@"v3"]];
 ```

Now, like before, we're left with these constraints: `"H:|[v1]|"` and `"V:|-[v1]"`. So you may want to complete the vertical constraint to anchor `v1` to the bottom of the `view`:

```objectivec
[layout addConstraint:@"V:[v1]-|"]
```

### Switching constraints

Let's suppose you want to switch between the constraints `"V:|-[v1]-[v2]-|"` and `"V:|-[v2]-[v1]-|"` in order to swap `v1` and `v2` vertically. First add the constraints that won't change:

```objectivec
AutolayoutHelper layout = [AutolayoutHelper
                  configureView:view
                       subViews:VarBindings(v1, v2)
                    constraints:@[
                            @"H:|[v1]|",
                            @"H:|[v2]|"
                    ]];
```

Then add the constraints you want first, and assign a key for them:

```objectivec
[layout addConstraints:@[@"V:|-[v1]-[v2]-|"] forKey:@"vertical swap"]
```

To switch to the other constraints, just add them using the same key. The constraints that we added before for that key will be replaced by the new ones:

```objectivec
[layout addConstraints:@[@"V:|-[v2]-[v1]-|"] forKey:@"vertical swap"]
```

### Using `UIScrollView`

If you need to use a `UIScrollView` with autolayout, check this [Stack Overflow answer](http://stackoverflow.com/a/16843937/1121497). 

You can use the `configureScrollView` helper method if you want the `UIScrollView` content view to fill the width of the main view. Here's an example:

```objectivec
UIScrollView* scrollView = [[UIScrollView alloc] init];

// Here the scrollView fills the main view, but you might want to add
// other views (like a fixed button at the bottom).
[AutolayoutHelper configureView:self.view
                       subViews:VarBindings(scrollView)
                    constraints:@[ @"H:|[scrollView]|", @"V:|[scrollView]|" ]];

// This view will be the content of the scrollView
UIView* scrollContent = [[UIView alloc] init];

// This method adds the scrollContent to the scrollView and makes it
// as wide as the self.view (the height will be adjusted depending on
// the views you add to the scrollContent later)
[AutolayoutHelper configureScrollView:scrollView contentView:scrollContent mainView:self.view];

// Now, for example, we configure the scrollContent by adding 3 views.
// The scrollContent height will be automatically adjusted thanks to the
// @"V:|-[v1]-[v2]-[v3]-|" constraint. The scrollView contentSize is also
// adjusted automatically to the size of the scrollContent. 
[AutolayoutHelper configureView:scrollContent
                       subViews:VarBindings(v1, v2, v3)
                    constraints:@[
                            @"H:|-[v1]-|",
                            @"H:|-[v2]-|",
                            @"H:|-[v3]-|",
                            @"V:|-[v1]-[v2]-[v3]-|"
                    ]];
```


### Debugging your layout

When programming your layout, it might be helpful to enable an option to set random background colors to the views, so you can see how the views are being positioned and sized. Call it before configuring the views:

```objectivec
[AutolayoutHelper setDisplayBackgroundColorsForDebugging:YES];
```
