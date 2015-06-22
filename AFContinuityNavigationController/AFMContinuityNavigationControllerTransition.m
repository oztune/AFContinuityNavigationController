
#import "AFMContinuityNavigationControllerTransition.h"
#import "AFMContinuityNavigationController.h"
#import "UINavigationBar+AFMContinuityNavigationControllerMetrics.h"
#import "AFUMorphView.h"
#import "AFUTitleView.h"
#import "AFUtils.h"

@implementation AFMContinuityNavigationControllerTransition

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {

    // For debugging.
    //#if TARGET_IPHONE_SIMULATOR
    //    return 2.0;
    //#endif
    
    NSTimeInterval duration = 0.75;
    
    if (_navigationOperation == UINavigationControllerOperationNone) {
        duration = 0.3;
    }
    
    // When user releases finger we don't want the transition to crawl.
    //
    // We don't use [transitionContext isInteractive] because
    // it's always NO the first time this method is called.
    if (_isInteractive) duration *= 0.8;
    
    return duration;
}

- (void)animateTransientHeader:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Transform to a space that's consistent for
    // push and pop.
    //
    // Trailing = pre push, leading = post push
    UIViewController *trailingVC = nil;
    UIViewController *leadingVC = nil;
    
    if (_navigationOperation == UINavigationControllerOperationPush) {
        trailingVC = fromVC;
        leadingVC = toVC;
    } else {
        trailingVC = toVC;
        leadingVC = fromVC;
    }
    
    //
    // Check if all the info is there to do the transition
    //
    
    id navigationOrigin = leadingVC.navigationItem.afm_continuityNavigationOrigin;
    
    if (!navigationOrigin) {
        return;
    }
    
    if (![trailingVC conformsToProtocol:@protocol(AFMContinuityNavigationSource)]) {
        return;
    }
    
    UIViewController<AFMContinuityNavigationSource> *source = (UIViewController<AFMContinuityNavigationSource> *)trailingVC;
    
    // We want the final position, so lets force the source provider to layout its subviews
    [source.view layoutIfNeeded];
    UIView *trailingTransientView = [source viewForContinuityNavigationOrigin:navigationOrigin];
    
    if (!trailingTransientView) {
        return;
    }
    
    UINavigationItem *leadingNavigationItem = leadingVC.navigationItem;
    UINavigationBar *navigationBar = _navigationController.navigationBar;
    
    // We have the initialView, now get the finalView
    UIView *titleView = leadingNavigationItem.titleView;
    if ([titleView isKindOfClass:[AFUTitleView class]]) {
        titleView = [(AFUTitleView *)titleView contentView];
    }
    UIView *leadingTransientView = titleView;
    
    if (!leadingTransientView) {
        return;
    }
    
    //
    // Everything passed, time to animate
    //
    
    UIView *initialTransientView = nil;
    UIView *finalTransientView = nil;
    
    UIView *containerView = [transitionContext containerView];
    CGPoint initialPosition, finalPosition;
    
    if (_navigationOperation == UINavigationControllerOperationPush) {
        initialTransientView = trailingTransientView;
        finalTransientView = leadingTransientView;
        
        initialPosition = [trailingTransientView.superview convertPoint:trailingTransientView.center toView:containerView];
        
        CGRect frame = [navigationBar af_frameForNavigationItemTitle:leadingNavigationItem];
        frame = [navigationBar convertRect:frame toView:containerView];
        finalPosition = AFMathGetRectMid(frame);
    } else {
        initialTransientView = leadingTransientView;
        finalTransientView = trailingTransientView;
        
        CGRect frame = [navigationBar af_frameForNavigationItemTitle:leadingNavigationItem];
        frame = [navigationBar convertRect:frame toView:containerView];
        initialPosition = AFMathGetRectMid(frame);
        finalPosition = [trailingTransientView.superview convertPoint:trailingTransientView.center toView:containerView];
    }
    
//    AFUMorphView *test = [[AFUMorphView alloc] initWithInitialView:initialTransientView finalView:finalTransientView];
//    [containerView addSubview:test];
//    test.backgroundColor = [UIColor greenColor];
//    test.center = CGPointMake(150.0, 300.0);
    
    AFUMorphView *morph = [[AFUMorphView alloc] initWithInitialView:initialTransientView finalView:finalTransientView];
    
    morph.center = initialPosition;
    
    initialTransientView.hidden = YES;
    finalTransientView.hidden = YES;
    
    [containerView addSubview:morph];
    
	void (^animations)() = ^{
        morph.morphProgress = 1.0;
		morph.center = finalPosition;
	};
	void (^completion)(BOOL) = ^(BOOL finished) {
        [morph removeFromSuperview];
        initialTransientView.hidden = NO;
        finalTransientView.hidden = NO;
    };
	
	if ([transitionContext isInteractive]) {
		[UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
			[UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.6 animations:animations];
		} completion:completion];
	} else {
//		[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
//        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0.0 options:kNilOptions animations:animations completion:completion];
        
        NSTimeInterval durationMult = 0.8;
        NSTimeInterval delayMult = _navigationOperation == UINavigationControllerOperationPop ? (1.0 - durationMult) : 0.0;
        
        [UIView animateWithDuration:duration * durationMult delay:duration * delayMult usingSpringWithDamping:0.9 initialSpringVelocity:0.0 options:kNilOptions animations:animations completion:completion];
	}
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    static CGFloat springDamping = 0.87;//85;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    UIView *containerView = [transitionContext containerView];
    
    [containerView addSubview:toView];
    
    CGRect fromInitialFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFinalFrame = [transitionContext finalFrameForViewController:toVC];
    
    //
    
    BOOL fromViewEnabled = fromView.userInteractionEnabled;
    BOOL toViewEnabled = toView.userInteractionEnabled;
    
    fromView.userInteractionEnabled = NO;
    toView.userInteractionEnabled = NO;
    
    dispatch_block_t afterAnim = [^{
        fromView.userInteractionEnabled = fromViewEnabled;
        toView.userInteractionEnabled = toViewEnabled;
    } copy];
    
    ///
    
    // Reset everything
    // This keeps things sane with interactive transitiona
    // which can cancel at odd spots.
    toView.transform = CGAffineTransformIdentity;
    fromView.transform = CGAffineTransformIdentity;
    
    toView.alpha = 1.0;
    fromView.alpha = 1.0;
    
    toView.frame = toFinalFrame;
    fromView.frame = fromInitialFrame;
    
    ////
    
    [self animateTransientHeader:transitionContext];
    
//    CGFloat scale = 0.9;
    
    // NOTE: Keep this if we want the anchor to be dynamic
    CATransform3D beforeEnterTransform = CATransform3DIdentity;
    beforeEnterTransform.m34 = 1.0 / -500;
    
//    CALayer *layer = fromView.layer;
//    CGPoint layerAnchor = layer.anchorPoint;
//    CGSize layerSize = layer.bounds.size;
    
//    CGPoint anchor = CGPointMake(0.5 * layerSize.width, 0.5 * layerSize.height);
//    CGPoint center = CGPointMake(layerAnchor.x * layerSize.width, layerAnchor.y * layerSize.height);
//    CGPoint offset = CGPointMake(anchor.x - center.x, anchor.y - center.y);
    
//    beforeEnterTransform = CATransform3DTranslate(beforeEnterTransform, offset.x, offset.y, -100.0);
    beforeEnterTransform = CATransform3DRotate(beforeEnterTransform, 20 * (M_PI / 180.0), 0.0, 1.0, 0.0);
    beforeEnterTransform = CATransform3DTranslate(beforeEnterTransform, -toFinalFrame.size.width * 0.8, 0.0, -50.0);
//    beforeEnterTransform = CGAffineTransformTranslate(beforeEnterTransform, offset.x, offset.y);
//    beforeEnterTransform = CATransform3DScale(beforeEnterTransform, scale, scale, scale);
//    beforeEnterTransform = CGAffineTransformScale(beforeEnterTransform, scale, scale);
//    beforeEnterTransform = CATransform3DTranslate(beforeEnterTransform, -offset.x, --offset.y, 0.0);
//    beforeEnterTransform = CGAffineTransformTranslate(beforeEnterTransform, -offset.x, -offset.y);
    
    CATransform3D toBeforeEnterTransform = CATransform3DIdentity;
    toBeforeEnterTransform.m34 = 1.0 / -500;
    toBeforeEnterTransform = CATransform3DRotate(toBeforeEnterTransform, 20 * (M_PI / 180.0), 0.0, 1.0, 0.0);
    toBeforeEnterTransform = CATransform3DTranslate(toBeforeEnterTransform, toFinalFrame.size.width * 1.15, 0.0, 0.0);
    
    ///
    
    if (_navigationOperation == UINavigationControllerOperationNone) {
        toView.layer.transform = CATransform3DIdentity;
        fromView.layer.transform = CATransform3DIdentity;
        
        toView.alpha = 0.0;
        fromView.alpha = 1.0;
        
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1.0;
            fromView.alpha = 0.0;
            
            CGFloat scale = 0.8;
            CATransform3D transform = CATransform3DMakeScale(scale, scale, scale);
            fromView.layer.transform = transform;
        } completion:^(BOOL finished) {
            afterAnim();
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else if (_navigationOperation == UINavigationControllerOperationPush) {
        
        NSTimeInterval aDuration = duration * 0.5;
        NSTimeInterval bDelay = aDuration * 0.3;
        NSTimeInterval bDuration = duration - bDelay;
        
        toView.frame = toFinalFrame;// CGRectOffset(toFinalFrame, toFinalFrame.size.width, 0.0);
        toView.layer.transform = toBeforeEnterTransform;
        
        [UIView animateWithDuration:aDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromView.alpha = 0.0;
            fromView.layer.transform = beforeEnterTransform;
        } completion:nil];
        
        [UIView animateWithDuration:bDuration delay:bDelay usingSpringWithDamping:springDamping initialSpringVelocity:0.0 options:0 animations:^{
            toView.alpha = 1.0;
            toView.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            fromView.alpha = 1.0;
            fromView.transform = CGAffineTransformIdentity;
            
            afterAnim();
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
        
        //        [UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
        //            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
        //                fromView.alpha = 0.0;
        //                fromView.transform = beforeEnterTransform;
        //            }];
        //            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
        //                toView.alpha = 1.0;
        //                toView.frame = toFinalFrame;
        //            }];
        //        } completion:^(BOOL finished) {
        //            fromView.alpha = 1.0;
        //            fromView.transform = CGAffineTransformIdentity;
        //            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        //        }];
    } else {
        toView.alpha = 0.0;
        toView.layer.transform = beforeEnterTransform;
        
        //        [UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
        //            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
        //                fromView.alpha = 0.0;
        //                fromView.frame = CGRectOffset(fromInitialFrame, 0, 100.0);
        //            }];
        //            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
        //                toView.alpha = 1.0;
        //                toView.transform = CGAffineTransformIdentity;
        //            }];
        //        } completion:^(BOOL finished) {
        //            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        //        }];
		
//		CGRect fromFinalFrame = CGRectOffset(fromInitialFrame, fromInitialFrame.size.width * 0.5, 0.0);
        
//        fromView.frame = fromFinalFrame;
//        fromView.layer.transform = toBeforeEnterTransform;
        fromView.layer.transform = CATransform3DIdentity;
        
        dispatch_block_t a = ^{
//            fromView.alpha = 0.0;
//            fromView.frame = fromFinalFrame;
            fromView.layer.transform = toBeforeEnterTransform;
        };
        dispatch_block_t b = ^{
            toView.alpha = 1.0;
            toView.layer.transform = CATransform3DIdentity;
        };
        void(^completion)(BOOL) = ^(BOOL finished){
            afterAnim();
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        };
        
        if ([transitionContext isInteractive]) {
			
			[UIView animateKeyframesWithDuration:duration delay:0.0 options:0 animations:^{
				[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:a];
				[UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:b];
			} completion:completion];
			
            //            [UIView animateWithDuration:duration delay:0.0 options:0 animations:^{
            //                toView.alpha = 1.0;
            //                toView.transform = CGAffineTransformIdentity;
            //
            //                fromView.alpha = 0.0;
            //                fromView.frame = fromFinalFrame;
            //            } completion:^(BOOL finished) {
            //                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            //            }];
        } else {
            
            CGFloat totalDuration = 0.55;
            
            [UIView animateWithDuration:duration * (0.2 / totalDuration) delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:a completion:nil];
            [UIView animateWithDuration:duration * (0.4 / totalDuration) delay:duration * (0.15 / totalDuration) usingSpringWithDamping:springDamping initialSpringVelocity:0.0 options:0 animations:b completion:completion];
        }
    }
}

@end
