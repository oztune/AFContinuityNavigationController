
@import UIKit;

#import "UINavigationItem+AFMContinuityNavigationController.h"

/**
 The purpose of this navigation controller subclass
 is to add the concept of a continuity context which persists as viewControllers change
 in the form of the title morphing into/out of a subview in the top view controller.
 
 While the special transition animations this class provides automatically
 are nice, it would be nice to keep it more 'pure' and have it do only a single
 task. Conceptually the animation is orthogonal to the 'context' features, but
 I tried to refactor it away to a completely separate delegate but it was too complicated.
 Maybe one day in the future it'll be worth another try.
 
 Functionality:
 - Have the title bar follow along as the current viewController
   changes, using an abstract 'navigationContext' property in the navigationItem
 - Push and pop with a z-axis animation
 - Makes the navigationBar translucent
 */
@interface AFMContinuityNavigationController : UINavigationController

@end

@protocol AFMContinuityNavigationSource

- (UIView *)viewForContinuityNavigationOrigin:(id)origin;

@end

// Optional
@protocol AFMContinuityNavigationControllerDelegate<UINavigationControllerDelegate>

@optional
- (BOOL)shouldContinuityNavigationControllerPopInteractively:(AFMContinuityNavigationController *)continuityNavigationController;

@end