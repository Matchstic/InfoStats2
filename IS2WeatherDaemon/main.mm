#import "IS2WeatherProvider.h"
#import "IS2LocationManager.h"
#import "IS2DaemonListener.h"
#import "IS2LocationProvider.h"

int main(int argc, char **argv, char **envp) {
    
    NSLog(@"*** [InfoStats2d] :: Loading up daemon.");
    
	// initialize our daemon
    IS2DaemonListener *listener = [[IS2DaemonListener alloc] init];
    IS2LocationManager *locationManager = [[IS2LocationManager alloc] init];
	IS2WeatherUpdater *provider = [[IS2WeatherUpdater alloc] initWithLocationManager:locationManager];
    IS2LocationProvider *locationProvider = [[IS2LocationProvider alloc] initWithLocationManager:locationManager];
    
    listener.weatherProvider = provider;
    listener.locationProvider = locationProvider;
    
	// start a timer so that the process does not exit.
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                              interval:1 // Slight delay for battery life improvements
                                                target:listener
                                              selector:@selector(timerFireMethod:)
                                              userInfo:nil
                                               repeats:YES];
    
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[runLoop run];
    
	return 0;
}