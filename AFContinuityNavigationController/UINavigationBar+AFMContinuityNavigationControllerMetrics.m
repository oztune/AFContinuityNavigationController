
#import "UINavigationBar+AFMContinuityNavigationControllerMetrics.h"

@implementation UINavigationBar (AFMContinuityNavigationControllerMetrics)

- (CGRect)af_frameForNavigationItemTitle:(UINavigationItem *)navigationItem {
    
    UIView *titleView = navigationItem.titleView;
    if (titleView.superview == self) {
        return titleView.frame;
    }
    
    CGRect frame = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    return CGRectMake(center.x, center.y, 0.0, 0.0);
}

@end
