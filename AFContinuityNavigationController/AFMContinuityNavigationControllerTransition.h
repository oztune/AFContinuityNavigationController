
@import UIKit;

@interface AFMContinuityNavigationControllerTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) UINavigationControllerOperation navigationOperation;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic) BOOL isInteractive;

@end
