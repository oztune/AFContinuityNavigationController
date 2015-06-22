
#import "AFMProxy.h"
#import "NSInvocation+Copy.h"

@interface AFMProxy()
{
	NSPointerArray *_receivers;
}

@end

@implementation AFMProxy

- (id)init {
	_receivers = [NSPointerArray weakObjectsPointerArray];
	return self;
}

- (void)dealloc {
	_receivers = nil;
}

- (void)addReceiver:(id)aReceiver {
	NSParameterAssert(aReceiver != nil);
	
	// Make sure there are no other references to delegate
	for (id receiver in _receivers) {
		if (receiver == aReceiver) {
			// TODO NSERROR: Exception
			return;
		}
	}

	[_receivers addPointer:(__bridge void *)aReceiver];
}

- (void)removeReceiver:(id)aReceiver {
	NSParameterAssert(aReceiver != nil);

	NSUInteger index = NSNotFound;
	NSUInteger i = 0;

	for (id receiver in _receivers) {
		if (receiver == aReceiver) {
			index = i;
			break;
		}
		++i;
	}
	if (index != NSNotFound) {
		[_receivers removePointerAtIndex:index];
	}
}

+ (AFMProxy *)proxyWithReceivers:(NSArray *)receivers {
    AFMProxy *proxy = [[AFMProxy alloc] init];
    for (id receiver in receivers) {
        [proxy addReceiver:receiver];
    }
    return proxy;
}

#pragma mark - Proxying

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
		
    for (id receiver in _receivers) {
		NSMethodSignature *sig = nil;
		
		// TODO: Is there a nicer way to do this?
		// Think about the fact that this if isn't needed
		// when the receiver is AFDelegate
		if ([receiver respondsToSelector:@selector(methodSignatureForSelector:)]) {
			sig = [(AFMProxy *)receiver methodSignatureForSelector:sel];
		} else {
			sig = [[receiver class] instanceMethodSignatureForSelector:sel];
		}
        
        if (sig) {
            return sig;
        }
    }
    
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
    BOOL isVoidReturnType = [returnType isEqualToString:@"v"];
    BOOL shouldCopyInvocationAfterFirstInvoke = !isVoidReturnType;
	
//    id<AFProxyDelegate> delegate = self.proxyDelegate;
//	
//    if (delegate) {
//        if ([delegate respondsToSelector:@selector(proxy:willForwardInvocation:)]) {
//            [delegate proxy:self willForwardInvocation:invocation];
//        }
//    }
	
	// TODO: Only copy when there's a mutation
	NSPointerArray *receivers = [_receivers copy];
	
    for (id receiver in receivers) {
        if ([receiver respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:receiver];
            
            if (shouldCopyInvocationAfterFirstInvoke) {
                invocation = [invocation copy];
                shouldCopyInvocationAfterFirstInvoke = NO;
            }
        }
    }
    
//    if (delegate) {
//		if ([delegate respondsToSelector:@selector(proxy:didForwardInvocation:)]) {
//			[delegate proxy:self didForwardInvocation:invocation];
//		}
//    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	
	BOOL responds = NO;
	
    for (id receiver in _receivers) {
		if ([receiver respondsToSelector:aSelector]) {
			responds = YES;
			break;
		}
    }
	
    return responds;
}

@end