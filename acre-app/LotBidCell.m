//
//  LotBidCell.m
//  Acre
//
//  Created by Justin Armstrong on 12/5/10.
//  Copyright 2010 Actinic inc. All rights reserved.
//

#import "LotBidCell.h"


@implementation LotBidCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
