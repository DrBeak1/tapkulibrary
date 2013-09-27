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

/* ################################ */
/* ########## GraphPoint ########## */
/* ################################ */

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
    
    NSString *date = [formatter stringFromDate:self.aDate];
    
    
//	return [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.aDate]];
    return date;
}

- (NSString*)yLabel
{
    if (!self.forTime) {
        return [NSString stringWithFormat:@"%d",[self.value intValue]];
    } else {
        
        NSInteger rawSeconds = [self.value integerValue];
        
        NSInteger minutes = 0;
        NSInteger seconds = 0;
        NSInteger milliseconds = 0;

        NSString *timeAsString = [NSString stringWithFormat:@"%@", self.value];
        NSRange range = [timeAsString rangeOfString : @"." options:(NSCaseInsensitiveSearch)];
        if (range.location != NSNotFound) {
            NSArray *time = [timeAsString componentsSeparatedByString:@"."];
            NSInteger rawSecondsMinusFloatingValue = [[time objectAtIndex:0] integerValue];
            minutes = rawSecondsMinusFloatingValue / 60;
            seconds = fmod(rawSecondsMinusFloatingValue, 60);
            milliseconds = [[time objectAtIndex:1] integerValue];
        } else {
            minutes = rawSeconds / 60;
            seconds = fmod(rawSeconds, 60);
        }

        NSString *displayString = @"";
        if (milliseconds>0) {
            displayString = [NSString stringWithFormat:@"%i:%02d.%i", minutes, seconds, milliseconds];
        } else {
            displayString = [NSString stringWithFormat:@"%i:%02d", minutes, seconds];
        }

        return displayString;
    }
}



@end

/* ##################################### */
/* ########## GraphController ########## */
/* ##################################### */
@interface GraphController ()
<UIActionSheetDelegate>
{
    GraphDataSetType dataSetType;
    MaxRecordSortOption *sortOption;
}

@property(nonatomic, strong)UIButton *sortOptionsButton;

@end

@implementation GraphController
@synthesize originalData = _originalData,
highestNumber = _highestNumber,
lowestNumber = _lowestNumber,
earliestDate = _earliestDate,
latestDate = _latestDate,
recordTitle = _recordTitle,
isForTime = _isForTime,
recordIndex = _recordIndex,
data = _data,
indicator = _indicator;
@synthesize sortOptionsButton = _sortOptionsButton;

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

-(id)initWithDataSet:(NSMutableArray *)dataSet forDataType:(GraphDataSetType)dst
{
    self = [super init];
    if (self) {
        if (self.originalData) {
            self.originalData = nil;
        }
        self.originalData = dataSet;
        dataSetType = dst;
    }
    
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 &&
        [self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	self.lowestNumber = 1000000000;
	self.graph.title.text = self.recordTitle;
	[self.graph setPointDistance:50];
    sortOption = MaxRecordSortOptionTime;
    
    self.sortOptionsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.sortOptionsButton.frame = CGRectMake(self.view.frame.size.width - 30, 15, 18, 19);
    [self.sortOptionsButton addTarget:self action:@selector(showSortOptions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sortOptionsButton];
		
    [self setupOriginaldataWithSetType:dataSetType];
		
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationSlide];
    }


}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];
    }

}

#warning GraphController.m : setupOriginalDataWithSetType - requires rewrite to support new NSDecimalNumber of measurementAValue

-(void)setupOriginaldataWithSetType:(GraphDataSetType)type
{
    // * Sort by date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:TRUE];
    NSArray *descriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [self.originalData sortUsingDescriptors:descriptors];
    
    NSDateFormatter *updatedStringFormatter = [[NSDateFormatter alloc] init];
    [updatedStringFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *stringFormat = [[NSDateFormatter alloc] init];
    [stringFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [stringFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];

    switch (type) {
        case GraphDataSetTypeCompletedWOD: {
            // * Completed WOD
            
            self.sortOptionsButton.hidden = YES;
            
            int a = 0;
            for (a = 0; a < [self.originalData count]; a++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:a]];
                NSString *name = [dic objectForKey:@"title"];
                if ([name isEqualToString:self.recordTitle]) {
                    
                    NSString *wodDateString = [dic objectForKey:@"date"];
                    
                    NSDate *date = [updatedStringFormatter dateFromString:wodDateString];
                    if (!date) {
                        date  = [stringFormat dateFromString:wodDateString];
                    }
                    
                    if ([[dic objectForKey:@"scoreType"] isEqualToString:@"For Time:"]) {
                        self.isForTime = YES;
                        NSString *timeString = [dic objectForKey:@"score"];
                        if ([timeString isEqualToString:@""]) {
                            timeString = @"0:00";
                        }
                        NSArray *time = [timeString componentsSeparatedByString:@":"];
                        
                        float minutes = 0.0;
                        float seconds = 0.0;
                        if (time.count>0) {
                            minutes = [[time objectAtIndex:0] floatValue];
                            if (time.count>=1) {
                                seconds = [[time objectAtIndex:1] floatValue];
                            }
                        }
                                                
                        float rawTime = (minutes * 60) + seconds;
                        
                        if (rawTime < self.lowestNumber) {
                            self.lowestNumber = rawTime;
                            self.recordIndex = a;
                        }
                        GraphPoint *gp = [[GraphPoint alloc] initWithID:a value:[NSNumber numberWithFloat:rawTime] andDate:date forTime:self.isForTime];
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

            break;
        }
        case GraphDataSetTypeMaxRepsRecord: {
            // max reps record
            
            self.sortOptionsButton.hidden = NO;
            
            int b = 0;
            for (b = 0; b < [self.originalData count]; b++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:b]];
                NSString *recordDateString = [dic objectForKey:@"date"];
                
                NSDate *date = [updatedStringFormatter dateFromString:recordDateString];
                if (!date) {
                    date  = [stringFormat dateFromString:recordDateString];
                }
                
                if (sortOption==MaxRecordSortOptionTime) {
                    self.isForTime = YES;
                    NSString *timeString = @"";
                    if ([dic objectForKey:@"measurementB"] &&
                        ![[dic objectForKey:@"measurementB"] isKindOfClass:[NSNull class]]) {
                        timeString = [dic objectForKey:@"measurementB"];
                    }
                    if ([timeString isEqualToString:@""]) {
                        timeString = @"0:00";
                    }
                    NSArray *time = [timeString componentsSeparatedByString:@":"];
                    int minutes = [[time objectAtIndex:0] intValue];
                    int seconds = [[time objectAtIndex:1] intValue];
                    
                    NSInteger rawTime = (minutes * 60) + seconds;
                    
                    if (rawTime < self.lowestNumber) {
                        self.lowestNumber = rawTime;
                        self.recordIndex = b;
                    }
                    
                    GraphPoint *gp = [[GraphPoint alloc] initWithID:b value:[NSNumber numberWithInteger:rawTime] andDate:date forTime:self.isForTime];
                    [self.data addObject:gp];
                } else {
                    self.isForTime = NO;
                    NSInteger score = 0;
                    if ([dic objectForKey:@"measurementAValue"] &&
                        ![[dic objectForKey:@"measurementAValue"] isKindOfClass:[NSNull class]]) {
                        score = [[dic objectForKey:@"measurementAValue"] integerValue];
                    }
                    
                    if (score > self.highestNumber) {
                        self.highestNumber = score;
                        self.recordIndex = b;
                    }
                    
                    GraphPoint *gp = [[GraphPoint alloc] initWithID:b value:[NSNumber numberWithInteger:score] andDate:date forTime:self.isForTime];
                    [self.data addObject:gp];
                }
                
            }
            
            break;
        }
        case GraphDataSetTypeMaxDistanceRecord: {
            // distance for time record
            
            self.sortOptionsButton.hidden = YES;
            
            int c = 0;
            for (c = 0; c < [self.originalData count]; c++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:c]];
                NSString *recordDateString = [dic objectForKey:@"date"];
                
                NSDate *date = [updatedStringFormatter dateFromString:recordDateString];
                if (!date) {
                    date  = [stringFormat dateFromString:recordDateString];
                }
                self.isForTime = YES;
                NSString *timeString = @"";
                if ([dic objectForKey:@"measurementB"] &&
                    ![[dic objectForKey:@"measurementB"] isKindOfClass:[NSNull class]]) {
                    timeString = [dic objectForKey:@"measurementB"];
                }
                if ([timeString isEqualToString:@""]) {
                    timeString = @"0:00";
                }
                NSArray *time = [timeString componentsSeparatedByString:@":"];
                int minutes = [[time objectAtIndex:0] intValue];
                int seconds = [[time objectAtIndex:1] intValue];
                
                NSInteger rawTime = (minutes * 60) + seconds;
                
                if (rawTime < self.lowestNumber) {
                    self.lowestNumber = rawTime;
                    self.recordIndex = c;
                }
                
                GraphPoint *gp = [[GraphPoint alloc] initWithID:c value:[NSNumber numberWithInteger:rawTime] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
                
            }
            
            break;
        }
        case GraphDataSetTypeMaxHeightRecord: {
            // highest height record
            
            self.sortOptionsButton.hidden = YES;
            
            int d = 0;
            for (d = 0; d < [self.originalData count]; d++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:d]];
                NSString *recordDateString = [dic objectForKey:@"date"];
                
                NSDate *date = [updatedStringFormatter dateFromString:recordDateString];
                if (!date) {
                    date  = [stringFormat dateFromString:recordDateString];
                }
                
                self.isForTime = NO;
                NSInteger score = 0;
                if ([dic objectForKey:@"measurementAValue"] &&
                    ![[dic objectForKey:@"measumrentAValue"] isKindOfClass:[NSNull class]]) {
                    score = [[dic objectForKey:@"measurementAValue"] integerValue];
                }
                
                
                if (score > self.highestNumber) {
                    self.highestNumber = score;
                    self.recordIndex = d;
                }
                
                GraphPoint *gp = [[GraphPoint alloc] initWithID:d value:[NSNumber numberWithInteger:score] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
                
            }
            
            break;
        }
        case GraphDataSetTypeMaxWeightRecord: {
            // * heaviest weight record
            self.sortOptionsButton.hidden = YES;
            
            int e = 0;
            for (e = 0; e < [self.originalData count]; e++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:e]];
                NSString *recordDateString = [dic objectForKey:@"date"];
                
                NSDate *date = [updatedStringFormatter dateFromString:recordDateString];
                if (!date) {
                    date  = [stringFormat dateFromString:recordDateString];
                }
                
                self.isForTime = NO;
                NSInteger score = 0;
                if ([dic objectForKey:@"measurementAValue"] &&
                    ![[dic objectForKey:@"measurementAValue"] isKindOfClass:[NSNull class]]) {
                    score = [[dic objectForKey:@"measurementAValue"] integerValue];
                }
                
                
                if (score > self.highestNumber) {
                    self.highestNumber = score;
                    self.recordIndex = e;
                }
                
                GraphPoint *gp = [[GraphPoint alloc] initWithID:e value:[NSNumber numberWithInteger:score] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
                
            }
            
            break;
        }
        default:{
            // * default (follows weight protocol)
            self.sortOptionsButton.hidden = YES;
            
            int e = 0;
            for (e = 0; e < [self.originalData count]; e++) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[self.originalData objectAtIndex:e]];
                NSString *recordDateString = [dic objectForKey:@"date"];
                
                NSDate *date = [updatedStringFormatter dateFromString:recordDateString];
                if (!date) {
                    date  = [stringFormat dateFromString:recordDateString];
                }
                
                self.isForTime = NO;
                NSInteger score = 0;
                if ([dic objectForKey:@"measurementAValue"] &&
                    ![[dic objectForKey:@"measurementAValue"] isKindOfClass:[NSNull class]]) {
                    score = [[dic objectForKey:@"measurementAValue"] integerValue];
                }
                
                
                if (score > self.highestNumber) {
                    self.highestNumber = score;
                    self.recordIndex = e;
                }
                
                GraphPoint *gp = [[GraphPoint alloc] initWithID:e value:[NSNumber numberWithInteger:score] andDate:date forTime:self.isForTime];
                [self.data addObject:gp];
                
            }
            
            break;
        }
    }
    
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
    
    
}

-(void)showSortOptions
{
    UIActionSheet *sortOptionsSheet = [[UIActionSheet alloc] initWithTitle:@"Graph Options"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil otherButtonTitles:@"Graph By Time", @"Graph By Reps", nil];
    [sortOptionsSheet showFromRect:self.sortOptionsButton.frame inView:self.view animated:YES];
    
}

/* #################################################### */
/* ########## UIActionSheet Delegate Methods ########## */
/* #################################################### */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // * Sort By Time
            [self.data removeAllObjects];
            sortOption = MaxRecordSortOptionTime;
            [self setupOriginaldataWithSetType:dataSetType];
            break;
        case 1:
            // * Sort By Reps
            [self.data removeAllObjects];
            sortOption = MaxRecordSortOptionOtherVariable;
            [self setupOriginaldataWithSetType:dataSetType];
            break;
        default:
            // * Cancel

            break;
    }
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    if ([self isViewLoaded]) {
        if ([self.view window] == nil)
        {
            
            // Add code to preserve data stored in the views that might be
            
            // needed later.
            
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            
            self.view = nil;
            
        }
    }
}


@end
