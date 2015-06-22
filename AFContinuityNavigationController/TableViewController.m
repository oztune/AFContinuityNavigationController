
#import "TableViewController.h"

@interface TableViewController ()

@property (nonatomic, strong) NSArray *data;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = nil;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.edgesForExtendedLayout = UIRectEdgeAll & ~UIRectEdgeTop;
}

+ (NSArray *)names {
    return @[@"Lilly", @"Harry", @"Ron", @"Severus", @"Minerva", @"Neville", @"Sirius", @"Frank", @"Regulus", @"Cho", @"Fleur", @"Albus", @"Seamus", @"Mundungus", @"Rubeus", @"Luna", @"Remus", @"Ginny", @"Percy"];
}

- (NSArray *)data {
    if (!_data) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[TableViewController names]];
        // Shuffle
        for (int i = 0; i < arr.count; ++i) {
            int index = arc4random() % arr.count;
            id temp = arr[index];
            [arr removeObjectAtIndex:index];
            [arr addObject:temp];
        }
        _data = [arr copy];
    }
    return _data;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *item = self.data[indexPath.row];
    
    cell.textLabel.text = item;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.data[indexPath.row];
    UITableViewController *newController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    newController.navigationItem.title = item;
    newController.navigationItem.afm_continuityNavigationOrigin = item;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:newController animated:YES];
    });
}

#pragma mark - Continuity delegate

- (UIView *)viewForContinuityNavigationOrigin:(id)origin {
    __block UIView *view = nil;
    [self.data enumerateObjectsUsingBlock:^(NSString *item, NSUInteger idx, BOOL *stop) {
        if ([item isEqual:origin]) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            view = cell.textLabel;
            
            // Small hack since the view's frame needs
            // to be tight fitting
            CGRect origFrame = view.frame;
            [view sizeToFit];
            CGRect frame = view.frame;
            frame.origin.y = origFrame.origin.y + origFrame.size.height * 0.5 - frame.size.height * 0.5;
            view.frame = frame;
            
            *stop = YES;
        }
    }];
    
    return view;
}

@end
