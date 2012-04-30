//
//  LookupEditViewController.h
//  TimeTracker
//
//  Created by Eben Bruyns on 10/08/08.
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

#import <UIKit/UIKit.h>
#import "Item.h"

@interface LookupEditViewController : UIViewController <UITextFieldDelegate> {
	NSString *textValue;
    id editedObject;
    NSString *editedFieldKey;
    IBOutlet UITextField *textField;
    BOOL dateEditing;
    NSDate *dateValue;
    IBOutlet UIDatePicker *datePicker;
    NSDateFormatter *dateFormatter;
	NSDateFormatter *timeFormatter;
	NSMutableArray *lookUpList;
	BOOL isNew;
	NSString *editTitle;
	BOOL isNumber;
	Item *item;
	NSNumberFormatter *numberFormatter;
}

@property (nonatomic, retain) id editedObject;
@property (nonatomic, retain) NSString *textValue;
@property (nonatomic, retain) NSString *editTitle;
@property (nonatomic, retain) NSDate *dateValue;
@property (nonatomic, retain) NSString *editedFieldKey;
@property (nonatomic, assign) BOOL dateEditing;
@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSMutableArray *lookUpList;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) BOOL isNumber;
@property (nonatomic, retain) Item *item;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (void)doSave;
@end
