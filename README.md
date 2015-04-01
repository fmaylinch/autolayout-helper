# AutolayoutHelper

This is a simple Objective-C class that can help you configuring auto-layout programmatically with the [visual format language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html).

## Instalation 

Just copy the files to your project.

## Usage

If you have a `view` where you want to put some subviews like `v1` and `v2`, call this method:

    [AutolayoutHelper configureView:view
                           subViews:@{@"v1":v1, @"v2":v2}
                        constraints:@[
                                @"H:|[v1]|",
                                @"H:|[v2]|",
                                @"V:|-[v1]-[v2]-|"
                        ]];

This method configures the subviews, adds them to the view, and adds the constraints. I recommend you to read the source code to understand everything. If you need some help with the auto-layout constraints, see this [short tutorial](http://www.thinkandbuild.it/learn-to-love-auto-layout-programmatically/).

If you need some metrics for your constraints, use the method that has the metrics parameter:

    [AutolayoutHelper configureView:view
                           subViews:@{@"v1":v1, @"v2":v2}
                            metrics:@{@"h":@(50)}
                        constraints:@[
                                @"H:|[v1]|",
                                @"H:|[v2]|",
                                @"V:|-[v1(h)]-[v2(h)]-|"
                        ]];

If you need to use a `UIScrollView` with auto-layout, check this [Stack Overflow answer](http://stackoverflow.com/a/16843937/1121497).
