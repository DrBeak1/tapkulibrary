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
forTime = _forTime,
pointTitle = _pointTitle;

-(id)initWithID:(int)pkv value:(NSNumber*)number andDate:(NSDate *)date forTime:(BOOL)isForTime 
{
    
    
    if(!(self=[super init])) return nil;
    
    self.pk = pkv;
    self.value = number;
    self.aDate = date;
    self.forTime = isForTime;
	
	return self;
	
}

-(id)initWithTitle:(NSString *)title andID:(int)pkv value:(NSNumber *)number forTime:(BOOL)isForTime
{
    if(!(self=[super init])) return nil;
    
    self.pk = pkv;
    self.value = number;
    self.forTime = isForTime;
	self.pointTitle = title;
    
	return self;
}


-(NSNumber*)yValue 
{
    return self.value;        
}

-(NSString*)xLabel
{
	return self.pointTitle;
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
indicator = _indicator,
dataSet = _dataSet,
isForDifferencesCurve = _isForDifferencesCurve;

-(NSMutableArray *)data
{
    if (!_data) { _data = [[NSMutableArray alloc] init]; }
    return _data;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.lowestNumber = 1000000000;
	self.graph.title.text = self.wodNameString;
	[self.graph setPointDistance:50];
	
	
    [self setupCurveData];
    
    if (!self.isForTime) {
        [self.graph setGraphWithDataPoints:self.data];

    } else {
        [self.graph setGraphWithDataPoints:self.data];
    }
    
    /*
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
     */
	
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	
}

-(void)setupCurveData
{

    NSMutableArray *points = [[NSMutableArray alloc] init];
    int a = 0;
    for (a = 0; a < [self.dataSet count]; a++) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithDictionary:[self.dataSet objectAtIndex:a]];
        NSString *title = [dictionary objectForKey:@"title"];
        
        NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
        [format setMinimumFractionDigits:3];
        [format setMaximumFractionDigits:3];
        
        NSNumber *seconds = [dictionary objectForKey:@"mps"];
                
        GraphPoint *gp = [[GraphPoint alloc] initWithTitle:title andID:a value:seconds forTime:self.isForTime];
        [points addObject:gp];
    }
    
    if (!self.isForDifferencesCurve) {
        NSArray *reverse = [[points reverseObjectEnumerator] allObjects];
        self.data = [NSMutableArray arrayWithArray:reverse];
    } else {
        self.data = [NSMutableArray arrayWithArray:points];
    }
}


-(void)setupOriginaldata
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingString:@"/DataFile.plist"];
	NSArray *load = [NSArray arrayWithContentsOfFile:filePath];
	self.originalData = [NSMutableArray arrayWithArray:load];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"theDate" ascending:TRUE];
    [self.originalData sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    int a;
    for (a = 0; a < [self.originalData count]; a++) {
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:a]];
        NSString *name = [dic objectForKey:@"theName"];
        if ([name isEqualToString:self.wodNameString]) {            
            
            NSDate *date = [dic objectForKey:@"theDate"];
            
            if ([[dic objectForKey:@"theScoreType"] isEqualToString:@"For Time:"]) {
                self.isForTime = YES;
                NSString *timeString = [dic objectForKey:@"theScore"];
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
                if ([[dic objectForKey:@"theScore"] isEqualToString:@""]) {
                    score = 0;
                } else {
                   score = [[dic objectForKey:@"theScore"] intValue]; 
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

#pragma mark - ROTATION METHODS

#pragma mark - <6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return ([self supportedInterfaceOrientations] & (1 << interfaceOrientation));
}

#pragma mark - 6.0 and >
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    
}

-(BOOL)shouldAutorotate
{
    return NO;
}


@end
