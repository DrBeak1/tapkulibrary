//
//  TKTimeGraphController.m
//  Created by Devin Ross on 7/24/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
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

#import "TKGraphController.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"
#import "UIDevice+Resolutions.h"

@implementation TKGraphController
@synthesize graph;

- (void) dealloc {
	[graph release];
	[super dealloc];
}

- (id) init{
	if(![super init]) return nil;
	return self;
}


- (void) loadView
{
    if ([[UIDevice currentDevice] resolution]==UIDeviceResolution_iPhoneRetina4) {
        graph = [[TKGraphView alloc] initWithFrame:CGRectMake(0, 0, 568, 300)];
    } else {
        graph = [[TKGraphView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
    }

	self.view = graph;
}

- (void) viewDidLoad 
{
    [super viewDidLoad];
    
	//graph = [[TKGraph alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
	//graph.dataSource = self;
	//graph.backgroundColor = [UIColor whiteColor];
	//[self.view addSubview:graph];
	
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	close = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	close.frame = CGRectMake(-10, 0, 65, 45);
	
	
	
	[close setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/graph/close"] forState:UIControlStateNormal];
	[close setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/graph/close_touch"] forState:UIControlStateHighlighted];
	[close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //IPAD
        close.hidden = YES;
    } else {
    //IPHONE
        close.hidden = NO;
    }

	[self.view addSubview:close];
    
}

- (void) viewWillAppear:(BOOL)animated 
{
	 [super viewWillAppear:animated];
	 statusColor = [UIApplication sharedApplication].statusBarStyle;
	 [UIApplication sharedApplication].statusBarStyle =  UIStatusBarStyleBlackOpaque;
 }
- (void) viewWillDisappear:(BOOL)animated 
{
	 [super viewWillDisappear:animated];
	 [UIApplication sharedApplication].statusBarStyle =  statusColor;
}


- (void) close
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void) viewDidUnload {
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
    return YES;
}


@end
