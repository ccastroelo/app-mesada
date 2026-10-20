//
//  MSCMoreOptionTableViewCellDelegate.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

@protocol MSCMoreOptionTableViewCellDelegate<NSObject>

@required
- (void)tableView:(UITableView *)tableView deleteOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView configOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView editOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView mailOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;

@optional


@end
