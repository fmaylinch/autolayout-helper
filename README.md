# AutolayoutHelper

This is a simple Objective-C class that can help you configuring auto-layout programmatically with the [visual format language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html).

## Instalation 

Just copy the files to your project.

## Usage

If you have a `view` where you want to put some subviews like `v1` and `v2`, call this method:

    [AutolayoutHelper configureView:view
                           subViews:NSDictionaryOfVariableBindings(v1, v2)
                        constraints:@[
                                @"H:|[v1]|",
                                @"H:|[v2]|",
                                @"V:|-[v1]-[v2]-|"
                        ]];

This method configures the `subViews`, adds them to the `view`, and adds the constraints. I recommend you to read the source code to understand everything. If you need some help with the auto-layout constraints, see this [short tutorial](http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/).

If you need some metrics for your constraints, use the method that has the metrics parameter:

    [AutolayoutHelper configureView:view
                           subViews:NSDictionaryOfVariableBindings(v1, v2)
                            metrics:@{@"h":@(50)}
                        constraints:@[
                                @"H:|[v1]|",
                                @"H:|[v2]|",
                                @"V:|-[v1(h)]-[v2(h)]-|"
                        ]];

### Using `UIScrollView`

If you need to use a `UIScrollView` with auto-layout, check this [Stack Overflow answer](http://stackoverflow.com/a/16843937/1121497). 

You can use the `configureScrollView` helper method if you want the `UIScrollView` content view to fill the width of the main view. Here's an example:

    UIScrollView* scrollView = [[UIScrollView alloc] init];
    
    // Here the scrollView fills the main view, but you might want to add other views (like a fixed button at the bottom).
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(scrollView)
                        constraints:@[ @"H:|[scrollView]|", @"V:|[scrollView]|" ]];

    // This view will be the content of the scrollView
    UIView* scrollContent = [[UIView alloc] init];

    // This method adds the scrollContent to the scrollView and makes it as wide as the self.view (the height will be adjusted depending on the views you add to the scrollContent later)
    [AutolayoutHelper configureScrollView:scrollView contentView:scrollContent mainView:self.view];

    // Now we configure the scrollContent by adding 3 views. The scrollContent height will be automatically adjusted thanks to the @"V:|-[v1]-[v2]-[v3]-|" constraint. The scrollView contentSize is also adjusted automatically to the size of the scrollContent. 
    [AutolayoutHelper configureView:scrollContent
                           subViews:NSDictionaryOfVariableBindings(v1, v2, v3)
                        constraints:@[
                                @"H:|-[v1]-|",
                                @"H:|-[v2]-|",
                                @"H:|-[v3]-|",
                                @"V:|-[v1]-[v2]-[v3]-|"
                        ]];



### Debugging your layout

When programming your layout, it might be helpful to enable an option to set random background colors to the views, so you can see how the views are being positioned and sized. Call it before configuring the views:

    [AutolayoutHelper setDisplayBackgroundColorsForDebugging:YES];