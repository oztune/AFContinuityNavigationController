
@import UIKit;

extern CGFloat AFMathLerp(CGFloat from, CGFloat to, CGFloat t);
extern CGPoint AFMathGetRectMid(CGRect rect);

@interface AFUtils : NSObject

+ (UIImageView *)captureView:(UIView *)view;

@end
