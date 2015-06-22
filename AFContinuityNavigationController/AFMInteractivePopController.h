
@import UIKit;

@class AFMInteractivePopController;

@protocol AFMInteractivePopControllerDelegate

- (BOOL)shouldInteractivePopControllerPop:(AFMInteractivePopController *)interactivePopController;

@end

@interface AFMInteractivePopController : NSObject

@property (nonatomic, weak) id<AFMInteractivePopControllerDelegate> delegate;
@property (nonatomic, readonly) id<UIViewControllerInteractiveTransitioning> interactionController;

- (void)attachToNavigationController:(UINavigationController *)navigationController;

@end
