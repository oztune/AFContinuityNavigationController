
#import "UINavigationItem+AFMContinuityNavigationController.h"
#import <objc/runtime.h>

@implementation UINavigationItem(AFMContinuityNavigationController)

- (id)afm_continuityNavigationOrigin {
    return objc_getAssociatedObject(self, @selector(afm_continuityNavigationOrigin));
}

- (void)setAfm_continuityNavigationOrigin:(id)value {
    objc_setAssociatedObject(self, @selector(afm_continuityNavigationOrigin), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end