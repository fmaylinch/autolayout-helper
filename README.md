# AutolayoutHelper

This is a Objective-C class that can help you configuring auto-layout programmatically with the [visual format language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html).

## Instalation 

Just copy the files to your project.

## Basic Usage

If you have a `view` where you want to put some subviews like `v1` and `v2`, call this method:

```objectivec
[AutolayoutHelper configureView:view
                       subViews:VarBindings(v1, v2)
                    constraints:@[
                            @"H:|[v1]|",
                            @"H:|[v2]|",
                            @"V:|-[v1]-[v2]-|"
                    ]];
```

Note: `VarBindings(v1, v2)` is the same as `NSDictionaryOfVariableBindings(v1, v2)` and the same as `@{@"v1":v1, @"v2":v2}`.

This method prepares the `subViews` for auto-layout, adds them to the `view`, and adds the constraints. I recommend you to read the source code to understand everything. If you need some help with auto-layout constraints, see this [tutorial](http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/).

If you need some metrics for your constraints, use the method that has the `metrics` parameter:

```objectivec
[AutolayoutHelper configureView:view
                       subViews:VarBindings(v1, v2)
                        metrics:@{@"h":@(50)}
                    constraints:@[
                            @"H:|[v1]|",
                            @"H:|[v2]|",
                            @"V:|-[v1(h)]-[v2(h)]-|"
                    ]];
```

## Advanced Usage

### Adding and removing views dynamically

If you need to add or remove views dynamically you can use other methods to configure the auto-layout. The following snippet does the same as the call to `configureView:` we just showed before:

```objectivec
AutolayoutHelper* helper = [[AutolayoutHelper alloc] initWithView:view];
helper.metrics = @{@"h":@(50)};
[helper addViews:VarBindings(v1, v2)
     constraints:@[
             @"H:|[v1]|",
             @"H:|[v2]|",
             @"V:|-[v1(h)]-[v2(h)]-|"
     ]];
```

Now let's suppose you want to replace the view `v2` by another `v3`.

First, remove `v2` with one of these methods:

```objectivec
[helper removeViews:VarBindings(v2)];
// or
[helper removeViewsWithKeys:@[@"v2"]];
 ```

Note that the constraints that include the removed `v2` will be automatically removed from the `view`, so now there's only one constraint left: `"H:|[v1]|"`.

Now add `v3` and the necessary constraints:

```objectivec
[helper addViews:VarBindings(v3)
     constraints:@[
             @"H:|[v3]|",
             @"V:|-[v1(h)]-[v3(h)]-|"
     ]];
```

Now let's suppose you want to remove `v3` but you don't want to add any other view.

First remove `v3`:

```objectivec
[helper removeViews:VarBindings(v3)];
// or
[helper removeViewsWithKeys:@[@"v3"]];
 ```

Now there's only one constraint left again, `"H:|[v1]|"`, so you may want to add the vertical constraint:

```objectivec
[helper addConstraint:@"V:|-[v1(h)]-|"]
```

### Switching constraints

Let's suppose you want to switch between the constraints `"V:|-[v1]-[v2]-|"` and `"V:|-[v2]-[v1]-|"` in order to swap `v1` and `v2` vertically. First add the constraints that won't change:

```objectivec
AutolayoutHelper* helper = [[AutolayoutHelper alloc] initWithView:view];
[helper addViews:VarBindings(v1, v2)
     constraints:@[
             @"H:|[v1]|",
             @"H:|[v2]|"
     ]];
```

Then add the constraints you want first, and assign a key for them:

```objectivec
[helper addConstraints:@[@"V:|-[v1]-[v2]-|"] forKey:@"vertical swap"]
```

To switch to the other constraints, just add them using the same key. The constraints added before for that key will be removed before adding the new ones:

```objectivec
[helper addConstraints:@[@"V:|-[v2]-[v1]-|"] forKey:@"vertical swap"]
```

### Using `UIScrollView`

If you need to use a `UIScrollView` with auto-layout, check this [Stack Overflow answer](http://stackoverflow.com/a/16843937/1121497). 

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

// Now configure the scrollContent by adding 3 views.
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
