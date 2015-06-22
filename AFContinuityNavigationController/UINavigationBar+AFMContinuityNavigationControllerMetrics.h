
#import <UIKit/UIKit.h>

@interface UINavigationBar (AFMContinuityNavigationControllerMetrics)

// Where the title should sit when the given navigationItem is at the
// top of the stack. In the navigation bar's coordinates.
- (CGRect)af_frameForNavigationItemTitle:(UINavigationItem *)navigationItem;

@end
