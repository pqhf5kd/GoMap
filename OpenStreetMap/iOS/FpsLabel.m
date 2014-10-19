//
//  FpsLabel.m
//  Go Map!!
//
//  Created by Bryce on 6/15/14.
//  Copyright (c) 2014 Bryce. All rights reserved.
//

#import "DisplayLink.h"
#import "FpsLabel.h"

#define ENABLE_FPS	1


const int FRAME_COUNT = 60;

@implementation FpsLabel
{
	int					_historyPos;
	CFTimeInterval		_history[ FRAME_COUNT ];	// average last 60 frames
	dispatch_source_t	_timer;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

#if ENABLE_FPS
	DisplayLink * displayLink = [DisplayLink shared];
	__weak FpsLabel * weakSelf = self;
	[displayLink addName:@"FpsLabel" block:^{
		[weakSelf frameUpdated];
	}];

	// create a timer to update the text twice a second
	dispatch_queue_t queue = dispatch_get_main_queue();
	_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	if ( _timer ) {
		dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, NSEC_PER_SEC/2, NSEC_PER_SEC/5);
		dispatch_source_set_event_handler(_timer, ^{
			[self updateText];
		} );
		dispatch_resume(_timer);
	}
	self.layer.shadowColor		= UIColor.whiteColor.CGColor;
	self.layer.shadowPath		= CGPathCreateWithRect(self.bounds, NULL);
	self.layer.shadowOpacity	= 0.3;
	self.layer.shadowRadius		= 0;
	self.layer.shadowOffset		= CGSizeMake(0, 0);

#else
	self.text = nil;
	self.hidden = YES;
#endif
}

- (void)dealloc
{
	if ( _timer ) {
		DisplayLink * displayLink = [DisplayLink shared];
		[displayLink removeName:@"FpsLabel"];
		dispatch_source_cancel( _timer );
	}
}

- (void)updateText
{
	// scan backward to see how many frames were drawn in the last second
	int frameCount = 0;
	int pos = (_historyPos + FRAME_COUNT - 1) % FRAME_COUNT;
	CFTimeInterval last = _history[ pos ];
	CFTimeInterval prev = 0.0;
	do {
		if ( --pos < 0 )
			pos = FRAME_COUNT - 1;
		prev = _history[pos];
		++frameCount;
		if ( last - prev >= 1.0 )
			break;
	} while ( pos != _historyPos );

	CFTimeInterval average = frameCount / (last - prev);
	if ( average >= 10.0 )
		self.text = [NSString stringWithFormat:@"%.1f FPS", average];
	else
		self.text = [NSString stringWithFormat:@"%.2f FPS", average];
	if ( average < 4.0 ) {
		NSLog(@"frame");
	}
}

- (void)frameUpdated
{
#if ENABLE_FPS
	// add to history
	CFTimeInterval now = CACurrentMediaTime();
	_history[_historyPos++] = now;
	if ( _historyPos >= FRAME_COUNT )
		_historyPos = 0;

//	[self updateText];
#endif
}

@end
