//
//  SpotDetailViewController.m
//  Memoris
//
//  Created by 高橋 弘 on 2014/06/28.
//  Copyright (c) 2014年 高橋 弘. All rights reserved.
//

#import "SpotDetailViewController.h"

@interface SpotDetailViewController ()

@end

@implementation SpotDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifcycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = [_venueDict objectForKey:@"name"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}



#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView viewWithTag:100].hidden = YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"スポット情報";
    } else {
        return @"スポットページ";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 320;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    return cell;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = [_venueDict objectForKey:@"name"];
        }
        else {
            NSDictionary *locDict = [_venueDict objectForKey:@"location"];
            
            NSString *state = [locDict objectForKey:@"state"];
            if (!state) state = @"";
            
            NSString *city = [locDict objectForKey:@"city"];
            if (!city) city = @"";
            
            NSString *address = [locDict objectForKey:@"address"];
            if (!address) address = @"";
            
            NSString *crossStreet = [locDict objectForKey:@"crossStreet"];
            if (!crossStreet) crossStreet = @"";
            
            NSString *joinedString = [NSString stringWithFormat:@"%@ %@ %@ %@", state, city, address, crossStreet];
            
            NSArray *formattedAddress = [locDict objectForKey:@"formattedAddress"];
            NSString *joinedString_ = [formattedAddress componentsJoinedByString:@","];
            NSLog(@"joinedString_ = %@", joinedString_);
            
            cell.textLabel.text = joinedString;
        }
        
    } else {
        NSURL *url = [NSURL URLWithString:[_venueDict objectForKey:@"url"]];
        if (url) {
            UIWebView *webView = [[UIWebView alloc] init];
            webView.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.height);
            webView.delegate = self;
            [cell.contentView addSubview:webView];
            NSURLRequest *req = [NSURLRequest requestWithURL:url];
            [webView loadRequest:req];
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            indicator.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.height);
            indicator.tag = 100;
            [indicator startAnimating];
            [webView addSubview:indicator];
        }
        else {
            cell.textLabel.text = @"ページはありません";
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
