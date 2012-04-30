//
//  DetailReportViewCell.m
//  TimeTracker
//
//  Created by Eben Bruyns on 20/08/08.
//  
//  Copyright (c) 2008-2013, SDK Innovation Ltd.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met: 
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. 
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution. 
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies, 
//  either expressed or implied, of the FreeBSD Project.

#import "DetailReportViewCell.h"


@implementation DetailReportViewCell

@synthesize customerLabel, projectLabel, durationLabel, taskLabel, createDateLabel, indicator, commentLabel;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize the labels, their fonts, colors, alignment, and background color.
        customerLabel = [self createLabel];
        projectLabel = [self createLabel];
        taskLabel = [self createLabel];
        createDateLabel = [self createLabel];
        commentLabel = [self createLabel];
		
        indicator = [[UILabel alloc] initWithFrame:CGRectZero];
		indicator.font = [UIFont boldSystemFontOfSize:12];
		indicator.textColor = [UIColor darkGrayColor];
		indicator.textAlignment = UITextAlignmentLeft;
		indicator.backgroundColor = [UIColor clearColor];
		
		
		durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        durationLabel.font = [UIFont boldSystemFontOfSize:24];
        durationLabel.backgroundColor = [UIColor clearColor];
		durationLabel.textAlignment = UITextAlignmentRight;
        
        // Add the labels to the content view of the cell.
        
        // Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
        // rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
        // into and out of editing mode.
        
        [self.contentView addSubview:customerLabel];
        [self.contentView addSubview:projectLabel];
        [self.contentView addSubview:taskLabel];
        [self.contentView addSubview:createDateLabel];
        [self.contentView addSubview:durationLabel];
		[self.contentView addSubview:indicator];
		[self.contentView addSubview:commentLabel];
    }
    return self;
}

- (UITextField *)createLabel {
	UITextField *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:12];
	label.textColor = [UIColor darkGrayColor];
	label.textAlignment = UITextAlignmentLeft;
	label.backgroundColor = [UIColor clearColor];
	return label;
}

- (void)dealloc {
	[indicator release];
    [customerLabel release];
    [projectLabel release];
    [taskLabel release];
    [createDateLabel release];
    [durationLabel release];
	[commentLabel release];
    [super dealloc];
}



- (void)layoutSubviews {
    [super layoutSubviews];
    // Start with a rect that is inset from the content view by 10 pixels on all sides.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 10);
    CGRect rect = baseRect;
	int width = 81;
	rect.origin.y -= 15;
    rect.size.width = width;
    customerLabel.frame = rect;
    rect.origin.x += width+10;
    projectLabel.frame = rect;
	
	
    
	rect.origin.x = 10;
	rect.origin.y += 15;
	rect.size.width = width;
	createDateLabel.frame = rect;
	
    
	rect.origin.x += width + 10;
	
	rect.size.width = width;
	taskLabel.frame = rect;
	
	rect.origin.y += 15;
	rect.origin.x = 10;
	rect.size.width = 220;
	commentLabel.frame = rect;
	
	rect.origin.x = 178;
	rect.origin.y = 2;
	rect.size.width = width+15;
    durationLabel.frame = rect;
	
	rect.origin.x = 10;
	rect.origin.y = 10;
	rect.size.width = 100;
	indicator.frame = rect;
	
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        customerLabel.textColor = [UIColor whiteColor];
        projectLabel.textColor = [UIColor whiteColor];
        taskLabel.textColor = [UIColor whiteColor];
        durationLabel.textColor = [UIColor whiteColor];
		createDateLabel.textColor = [UIColor whiteColor];
		commentLabel.textColor = [UIColor whiteColor];
		
    } else {
        customerLabel.textColor = [UIColor blackColor];
        projectLabel.textColor = [UIColor blackColor];
        taskLabel.textColor = [UIColor blackColor];
        durationLabel.textColor = [UIColor blackColor];
        createDateLabel.textColor = [UIColor blackColor];
        commentLabel.textColor = [UIColor blackColor];
    }
}


@end
