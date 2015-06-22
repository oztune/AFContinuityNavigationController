
#import "ViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make the top bar transparent
    UINavigationBar *navigationBar = self.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                        forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [UIImage new];
    navigationBar.translucent = YES;
    
    UITableViewController *tableViewController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.navigationItem.title = @"Good guys";
    
    [self pushViewController:tableViewController animated:NO];
}

@end
