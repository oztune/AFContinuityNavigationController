
#import <UIKit/UIKit.h>

@interface AFUMorphView : UIView

- (id)initWithInitialView:(UIView *)initialView finalView:(UIView *)finalView;
- (id)initWithInitialView:(UIView *)initialView finalView:(UIView *)finalView maintainAspectRatio:(BOOL)maintainAspectRatio;

// TOOD: transitionProgress?
@property (nonatomic) CGFloat morphProgress;

@end