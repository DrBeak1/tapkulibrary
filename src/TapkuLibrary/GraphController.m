//
//  GraphController.m
//  Created by Devin Ross on 7/17/09.
//
/*
 
 tapku.com || https://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import "GraphController.h"



@implementation GraphPoint
@synthesize pk = _pk,
value = _value,
aDate = _aDate,
forTime = _forTime;

-(id)initWithID:(int)pkv value:(NSNumber*)number andDate:(NSDate *)date forTime:(BOOL)isForTime 
{
    
    
    if(!(self=[super init])) return nil;
    
    self.pk = pkv;
    self.value = number;
    self.aDate = date;
    self.forTime = isForTime;
	
	return self;
	
}

-(NSNumber*)yValue 
{
    return self.value;        
}

-(NSString*)xLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
	return [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.aDate]];
}

- (NSString*)yLabel
{
    if (!self.forTime) {
        return [NSString stringWithFormat:@"%d",[self.value intValue]];
    } else {
        NSInteger theValue = [self.value integerValue];
        NSInteger sec = fmod(theValue, 60);
        NSInteger min = fmod(theValue / 60, 60);
        NSString *timeString = [NSString stringWithFormat:@"%i:%02d", min, sec];
        return timeString;
    }
}


@end

@implementation GraphController
@synthesize originalData = _originalData,
highestNumber = _highestNumber,
lowestNumber = _lowestNumber,
earliestDate = _earliestDate,
latestDate = _latestDate,
wodNameString = _wodNameString,
isForTime = _isForTime,
recordIndex = _recordIndex,
data = _data,
indicator = _indicator;

-(NSMutableArray *)data
{
    if (!_data) { _data = [[NSMutableArray alloc] init]; }
    return _data;
}

-(NSMutableArray *)originalData
{
    if (!_originalData) { _originalData = [[NSMutableArray alloc] init]; }
    return _originalData;
}

-(id)initWithDataSet:(NSMutableArray *)dataSet
{
    self = [super init];
    if (self) {
        
        self.originalData = dataSet;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.lowestNumber = 1000000000;
	self.graph.title.text = self.wodNameString;
	[self.graph setPointDistance:50];
		
    [self setupOriginaldata];
	
	if (!self.isForTime) {
        [self.graph setGraphWithDataPoints:self.data];
        self.graph.goalValue = [NSNumber numberWithInteger:self.highestNumber];
        self.graph.goalShown = YES;
        self.graph.goalTitle = @"Record";
        [self.graph showIndicatorForPoint:self.recordIndex];
        //  [self.graph scrollToPoint:self.recordIndex animated:YES];
    } else {
        [self.graph setGraphWithDataPoints:self.data];
        self.graph.goalValue = [NSNumber numberWithInteger:self.lowestNumber];
        self.graph.goalShown = YES;
        self.graph.goalTitle = @"Record";
        [self.graph showIndicatorForPoint:self.recordIndex];
        //  [self.graph scrollToPoint:self.recordIndex animated:YES];
    }

	
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	
}

-(void)setupOriginaldata
{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:TRUE];
    [self.originalData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    int a;
    for (a = 0; a < [self.originalData count]; a++) {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:a]];
        NSString *name = [dic objectForKey:@"title"];
        if ([name isEqualToString:self.wodNameString]) {            
            
            NSString *wodDateString = [dic objectForKey:@"date"];
            NSDateFormatter *updatedStringFormatter = [[NSDateFormatter alloc] init];
            [updatedStringFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [updatedStringFormatter dateFromString:wodDateString];
            if (!date) {
                NSDateFormatter *stringFormat = [[NSDateFormatter alloc] init];
                [stringFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                [stringFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
                date  = [stringFormat dateFromString:wodDateString];
            }
                        
            if ([[dic objectForKey:@"scoreType"] isEqualToString:@"For Time:"]) {
                self.isForTime = YES;
                NSString *timeString = [dic objectForKey:@"score"];
                if ([timeString isEqualToString:@""]) {
                    timeString = @"0:00";
                }
                NSArray *time = [timeString componentsSeparatedByString:@":"];
                int minutes = [[time objectAtIndex:0] intValue];
                int seconds = [[time objectAtIndex:1] intValue];
                
                NSInteger rawTime = (minutes * 60) + seconds; 
            
                if (rawTime < self.lowestNumber) {
                    self.lowestNumber = rawTime;
                    self.recordIndex = a;
                }
                GraphPoint *gp = [[GraphPoint alloc] initWithID:a value:[NSNumber numberWithInteger:rawTime] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
            } else {
                self.isForTime = NO;
                NSInteger score;
                if ([[dic objectForKey:@"score"] isEqualToString:@""]) {
                    score = 0;
                } else {
                   score = [[dic objectForKey:@"score"] intValue]; 
                }

                if (score > self.highestNumber) {
                    self.highestNumber = score;
                    self.recordIndex = a;
                }
                
                GraphPoint *gp = [[GraphPoint alloc] initWithID:a value:[NSNumber numberWithInteger:score] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
            }
        }
    }
    
}




- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
