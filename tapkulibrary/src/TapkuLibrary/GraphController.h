//
//  GraphController.h
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


#import <TapkuLibrary/TapkuLibrary.h>
#import "TKGraphController.h"
#import "TKGraphView.h"
@class GraphPoint;

typedef enum {
    GraphDataSetTypeCompletedWOD,
    GraphDataSetTypeMaxWeightRecord,
    GraphDataSetTypeMaxDistanceRecord,
    GraphDataSetTypeMaxHeightRecord,
    GraphDataSetTypeMaxRepsRecord
} GraphDataSetType;

typedef enum {
    MaxRecordSortOptionTime,
    MaxRecordSortOptionOtherVariable
} MaxRecordSortOption;

@interface GraphController : TKGraphController 

@property(nonatomic, retain)NSMutableArray *data;
@property(nonatomic, retain)UIActivityIndicatorView *indicator;
@property(assign)BOOL isForTime;
@property(nonatomic, retain)NSMutableArray *originalData;
@property(nonatomic, retain)NSString *recordTitle;
@property(assign)NSInteger recordIndex;
@property(assign)NSInteger highestNumber;
@property(assign)NSInteger lowestNumber;
@property(assign)NSTimeInterval earliestDate;
@property(assign)NSTimeInterval latestDate;

-(void)setupOriginaldataWithSetType:(GraphDataSetType)type;
-(id)initWithDataSet:(NSMutableArray *)dataSet forDataType:(GraphDataSetType)dataSetType;


@end


@interface GraphPoint : NSObject <TKGraphViewPoint>

@property(assign)NSInteger pk;
@property(nonatomic, retain)NSNumber *value;
@property(nonatomic, retain)NSDate *aDate;
@property(assign)BOOL forTime;

- (id) initWithID:(int)pk value:(NSNumber*)number andDate:(NSDate *)date forTime:(BOOL)isForTime;


@end
