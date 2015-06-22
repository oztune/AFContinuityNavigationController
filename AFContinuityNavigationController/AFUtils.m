
#import "AFUtils.h"

CGFloat AFMathLerp(CGFloat from, CGFloat to, CGFloat t) {
    return from + (to - from) * t;
}

CGPoint AFMathGetRectMid(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

@implementation AFUtils

+ (UIImageView *)captureView:(UIView *)view {
    
    CGFloat viewAlpha = view.alpha;
    view.alpha = 1.0;
    
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [view.layer renderInContext:context];
        //    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    view.alpha = viewAlpha;
    
    return [[UIImageView alloc] initWithImage:image];
}

@end
