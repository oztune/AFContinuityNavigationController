
#import "AFMInteractivePopController.h"

@interface AFMInteractivePopController()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *screenGestureRecognizer;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;
@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation AFMInteractivePopController

- (id)init {
    self = [super init];
    if (self) {
        _screenGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onGesture:)];
        _screenGestureRecognizer.edges = UIRectEdgeLeft;
        _screenGestureRecognizer.delegate = self;
    }
    return self;
}

- (void)attachToNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
    [navigationController.view addGestureRecognizer:_screenGestureRecognizer];
}

- (BOOL)shouldPop {
    if (self.delegate) {
        return [self.delegate shouldInteractivePopControllerPop:self];
    }
    return YES;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionController {
    return _percentDrivenTransition;
}

#pragma mark - Gesture action

- (void)onGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if ([self shouldPop]) {
                _percentDrivenTransition = [UIPercentDrivenInteractiveTransition new];
                [_navigationController popViewControllerAnimated:YES];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            UIView *view = _navigationController.view;
            CGPoint p = [gesture translationInView:view];
            CGFloat t = p.x / view.bounds.size.width;
            [_percentDrivenTransition updateInteractiveTransition:t];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (gesture.state == UIGestureRecognizerStateCancelled) {
                [_percentDrivenTransition cancelInteractiveTransition];
            } else {
                UIView *view = _navigationController.view;
                if ([gesture velocityInView:view].x > 0) {
                    [_percentDrivenTransition finishInteractiveTransition];
                } else {
                    [_percentDrivenTransition cancelInteractiveTransition];
                }
            }
            _percentDrivenTransition = nil;
            break;
        default:
            break;
    }
}

#pragma mark - Gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Edge pan is the big cheese
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
