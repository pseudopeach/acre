//
//  UserDetail.m
//  Acre
//
//  Created by Justin Armstrong on 12/10/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "UserDetail.h"


@implementation UserDetail
@synthesize
	mapView,
	header1,
	headerView, 
	userData;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];

    header1.text = userData.screenName;
	
	// headerView
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.headerView.frame.size.height);
	self.headerView.backgroundColor = [UIColor clearColor];
	self.headerView.frame = newFrame;
	self.tableView.tableHeaderView = self.headerView;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	self.header1.text = userData.screenName;
	self.navigationItem.title = @"User Profile";
	
	
	mapView.pointArray = userData.mapPoints;
	
}

/*
CGContextRef contextRef = UIGraphicsGetCurrentContext();

CGContextSetRGBFillColor(contextRef, 0, 0, 255, 0.1);
CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 0.5);

// Draw a circle (filled)
CGContextFillEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));

// Draw a circle (border only)
CGContextStrokeEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));
*/


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
	//stats
	//score
	//titles
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		case 0:
			return @"Titles";
		case 1:
			return @"Stats";
		//case 2:
			//return @"Score";
	}
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0: return userData.nobleTitles.count; //titles
		case 1: return 2; //stats
		//case 2: return 1; //score
			
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
	
	if(indexPath.section == 0){ //titles
		cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
		if (cell == nil) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"titleCell"] autorelease];
		cell.textLabel.text = [userData.nobleTitles objectAtIndex:indexPath.row];
		if([cell.textLabel.text rangeOfString:@"Visc"].location == 0)
            cell.imageView.image = [UIImage imageNamed:@"title_viscount.png"];
        else if([cell.textLabel.text rangeOfString:@"Du"].location == 0)
             cell.imageView.image = [UIImage imageNamed:@"title_duke.png"];
        else
            cell.imageView.image = [UIImage imageNamed:@"title_earl.png"];
        
	}else{
		cell =  [[[UITableViewCell alloc] 
				  initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,10,175,25)];
		valueLabel.textAlignment = UITextAlignmentRight;
		valueLabel.font = [UIFont systemFontOfSize:20];
		[cell.contentView addSubview:valueLabel];
		
		if(indexPath.section == 1) //stats
			if(indexPath.row == 0){
				cell.detailTextLabel.text = @"Lots Owned";
				valueLabel.text = [NSString stringWithFormat:@"%d",userData.lotsOwned];
			}else{ //score
				cell.detailTextLabel.text = @"Score";
				valueLabel.text = [NSString stringWithFormat:@"%d",userData.score];
			}
		[valueLabel release];
				
	}	
    
    return cell;
}



- (void)viewDidUnload {
    self.headerView = nil;
	[super viewDidUnload];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }

    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;

    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view autorelease];
    [view addSubview:label];

    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (void)dealloc {
	[userData release];
	[headerView release];
	[header1 release];
	[mapView release];
	
    [super dealloc];
}


@end

