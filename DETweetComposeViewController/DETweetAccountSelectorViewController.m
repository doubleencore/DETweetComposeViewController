//
//  DETweetAccountSelectorViewController.m
//  DETweeter
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
//  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
//  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "DETweetAccountSelectorViewController.h"
#import "DETweetPoster.h"


#define DETweetAccountSelectorSelectorSelectedAccountTextColor [UIColor colorWithRed:0.20f green:0.31f blue:0.52f alpha:1.0f]


@interface DETweetAccountSelectorViewController ()

@property(nonatomic,retain) NSArray *accounts;

@end


@implementation DETweetAccountSelectorViewController

    // Public
@synthesize delegate = _delegate;
@synthesize selectedAccount = _selectedAccount;

    // Private
@synthesize accounts = _accounts;


#pragma mark - Setup & Teardown

- (void)dealloc
{
    _delegate = nil;
    [_selectedAccount release], _selectedAccount = nil;
    [_accounts release], _accounts = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(240.0f, 140.0f);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.accounts = [DETweetPoster accounts];
}


- (void)viewDidUnload
{
        // Keep _delegate & _selectedAccount.
    
    self.accounts = nil;
    
    [super viewDidUnload];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    ACAccount *account = [self.accounts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = account.accountDescription;

    if ([account.identifier isEqualToString:self.selectedAccount.identifier]) {
        cell.textLabel.textColor = DETweetAccountSelectorSelectorSelectedAccountTextColor;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}
 

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedAccount = [self.accounts objectAtIndex:indexPath.row];
    
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    selectedCell.textLabel.textColor = DETweetAccountSelectorSelectorSelectedAccountTextColor;
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(tweetAccountSelectorViewController:didSelectAccount:)]) {
        [self.delegate tweetAccountSelectorViewController:self didSelectAccount:self.selectedAccount];
    }
}


@end
