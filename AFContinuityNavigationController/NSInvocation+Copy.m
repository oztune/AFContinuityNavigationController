
#import "NSInvocation+Copy.h"

@implementation NSInvocation(Copy)

- (id)copyWithZone:(NSZone *)zone {
    
    NSMethodSignature *signature = [self methodSignature];
    
    NSInvocation *invocationCopy = [NSInvocation invocationWithMethodSignature:signature];
    NSUInteger argCount = [signature numberOfArguments];
    
    [invocationCopy setTarget:self.target];
    [invocationCopy setSelector:self.selector];
    
    if (argCount > 2) {
        for (NSUInteger i = 2; i < (argCount - 2); ++i) {
            const char *argumentType = [signature getArgumentTypeAtIndex:i];
            
            NSUInteger argumentLength;
            NSGetSizeAndAlignment(argumentType, &argumentLength, NULL);
            
            char buffer[argumentLength];
            
            [self getArgument:buffer atIndex:i];
            [invocationCopy setArgument:buffer atIndex:i];
        }
        
    }
    
    return invocationCopy;
}

@end