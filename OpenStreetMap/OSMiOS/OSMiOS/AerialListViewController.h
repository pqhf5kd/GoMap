//
//  CustomBackgroundViewController.h
//  Go Map!!
//
//  Created by Bryce on 8/20/14.
//  Copyright (c) 2014 Bryce. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AerialList;

@interface AerialListViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>
{
	AerialList * _aerials;
}

@end