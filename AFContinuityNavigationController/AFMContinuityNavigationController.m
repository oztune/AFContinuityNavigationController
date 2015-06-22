
#import "AFMContinuityNavigationController.h"
#import "AFMContinuityNavigationControllerTransition.h"
#import "AFMInteractivePopController.h"
#import "AFMDelegateWrapper.h"
#import "AFUTitleView.h"

@interface AFMContinuityNavigationController ()<UINavigationControllerDelegate, AFMInteractivePopControllerDelegate>

@property (nonatomic, strong) AFMInteractivePopController *interactivePop;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic, strong) AFMDelegateWrapper *delegateWrapper;

@end

@implementation AFMContinuityNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _delegateWrapper = [[AFMDelegateWrapper alloc] initWithMainDelegate:self];
    self.delegate = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // This needs to be done here because the interactivePop
    // needs the view
    _interactivePop = [AFMInteractivePopController new];
    _interactivePop.delegate = self;
    [_interactivePop attachToNavigationController:self];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    super.delegate = nil;
    _delegateWrapper.userDelegate = delegate;
    super.delegate = (id<UINavigationControllerDelegate>)_delegateWrapper;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && ![navigationController.viewControllers containsObject:fromVC]) {
        operation = UINavigationControllerOperationNone;
    }
    AFMContinuityNavigationControllerTransition *controller = [[AFMContinuityNavigationControllerTransition alloc] init];
    controller.navigationOperation = operation;
    controller.navigationController = self;
    controller.isInteractive = (_interactivePop.interactionController != nil);
    
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return _interactivePop.interactionController;
}

- (BOOL)shouldInteractivePopControllerPop:(AFMInteractivePopController *)interactivePopController {
    if (_isAnimating) {
        return NO;
    }
    
    id<AFMContinuityNavigationControllerDelegate> delegate = (id<AFMContinuityNavigationControllerDelegate>)self.delegate;
    
    if ([delegate respondsToSelector:@selector(shouldContinuityNavigationControllerPopInteractively:)]) {
        return [delegate shouldContinuityNavigationControllerPopInteractively:self];
    }
    return YES;
}

#pragma mark - Other

- (UIView *)constructTitleViewForString:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = [[NSAttributedString alloc] initWithString:title attributes:self.navigationBar.titleTextAttributes];
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [label sizeToFit];
    
    CGRect bounds = label.bounds;
    bounds.size.width = MIN(bounds.size.width, self.maxWidthForTitle);
    label.bounds = bounds;
    
    AFUTitleView *titleView = [AFUTitleView new];
    titleView.contentView = label;
    
    return titleView;
}

- (CGFloat)maxWidthForTitle {
    CGFloat navBarWidth = self.navigationBar.bounds.size.width;
    
    static CGFloat estimatedNavItemWidth = 60.0;
    static CGFloat minWidth = 50.0;
    
    navBarWidth -= (estimatedNavItemWidth * 2.0);
    navBarWidth = MAX(navBarWidth, minWidth);
    
    return navBarWidth;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
    if (animated) {
        self.isAnimating = YES;
        __weak typeof(self) weakSelf = self;
        [viewController.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            weakSelf.isAnimating = NO;
        }];
    }
    
    UINavigationItem *navigationItem = viewController.navigationItem;
    
    if (!navigationItem.titleView) {
        NSString *title = navigationItem.title;
        if (!title) {
            title = viewController.title;
        }
        if (title) {
            navigationItem.titleView = [self constructTitleViewForString:title];
        }
        
        // This is a HACK to hide the back text
        navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

@end
