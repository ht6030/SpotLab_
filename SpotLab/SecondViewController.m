//
//  SecViewController.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/05/06.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SecondViewController.h"
#import "SpotsMapViewController.h"
#import "HTNotification.h"

@interface SecondViewController ()
//@property (strong, nonatomic) NSDictionary *savedDictionary;
@property (strong, nonatomic) NSMutableArray *storedArray;
@end

@implementation SecondViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"sample.binary"];
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    _storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:myData];
    NSLog(@"_storedArray:%@", _storedArray);
    
    SEL reloadTableView = @selector(reloadTableView);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:reloadTableView name:HTReloadMyPageNotification object:nil];
    
    //_savedVenueArray = [NSKeyedUnarchiver unarchiveObjectWithData:myData];
    //NSLog(@"array.count = %lu", (unsigned long)_savedVenueArray.count);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    #pragma mark TODO 編集モードにタッチ→解除可能に
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)reloadTableView
{
    NSLog(@"%s",__func__);
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"sample.binary"];
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    _storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:myData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _storedArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *listDict = [_storedArray objectAtIndex:indexPath.row];
    NSString *title = [listDict objectForKey:@"title"];
    cell.textLabel.text = title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *listDict = [_storedArray objectAtIndex:indexPath.row];
    NSMutableArray *venueArray = [listDict objectForKey:@"venues"];
    NSLog(@"venue name = %@",[[venueArray objectAtIndex:0] objectForKey:@"name"]);
    
    //[self performSegueWithIdentifier:@"showSpotsDetail" sender:self];

    SpotsMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SpotsMapScene"];
    vc.venueArray = venueArray;
    vc.title = [listDict objectForKey:@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete the row from the data source");
        
        // 配列から要素を削除してストレージにも反映
        [_storedArray removeObjectAtIndex:indexPath.row];
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"sample.binary"];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_storedArray];
        [data writeToFile:filePath atomically:YES];
        
        // テーブルビューの該当行を消す
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s",__func__);
    
    // 2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showSpotsDetail"]) {
        SpotsMapViewController *vc = segue.destinationViewController;
        
        NSDictionary *listDict = [_storedArray objectAtIndex:0];
        NSMutableArray *venueArray = [listDict objectForKey:@"venues"];
        vc.venueArray = venueArray;
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HTReloadMyPageNotification object:nil];
}

@end
