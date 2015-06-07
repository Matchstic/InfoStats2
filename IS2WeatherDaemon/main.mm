#import "IS2WeatherProvider.h"

int main(int argc, char **argv, char **envp) {
    
    NSLog(@"*** [InfoStats2 | Weather] :: Loading up weather provider.");
    
	//initialize our daemon
	IS2WeatherUpdater *provider = [IS2WeatherUpdater sharedInstance];
    
	//start a timer so that the process does not exit.
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                              interval:0.01
                                                target:provider
                                              selector:@selector(timerFireMethod:)
                                              userInfo:nil
                                               repeats:NO];
    
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
    
	return 0;
}