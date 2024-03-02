//
//  ViewController.m
//  NameResolutionTest
//
//  Created by Jorge Antonio diaz-benito soriano on 13/1/24.
//

#import "ViewController.h"
#import <Network/Network.h>

@interface ViewController ()
@property (nonatomic, strong) nw_connection_t connection;
@end

@implementation ViewController

/* Catch Signal Handler functio */
void signal_callback_handler(int signum) {
  printf("Caught signal SIGPIPE %d\n",signum);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  NSLog(@"view did load");
  signal(SIGPIPE, signal_callback_handler);
  nw_parameters_t parameters = nw_parameters_create_secure_udp(NW_PARAMETERS_DISABLE_PROTOCOL, NW_PARAMETERS_DEFAULT_CONFIGURATION);
  nw_endpoint_t endpoint = nw_endpoint_create_host("localhost", "123");
  _connection = nw_connection_create(endpoint, parameters);
  nw_connection_set_queue(_connection, dispatch_get_main_queue());
  nw_connection_set_state_changed_handler(_connection, ^(nw_connection_state_t state, nw_error_t error) {
    if (state == nw_connection_state_waiting) {
      NSLog(@"Waiting");
    } else if (state == nw_connection_state_failed) {
      NSLog(@"Failed");
    } else if (state == nw_connection_state_ready) {
      NSLog(@"Ready");
      const char bytes[] = {1};
      NSLog(@"Size is %lu", sizeof(bytes));
      NSData* data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
      nw_connection_send(self->_connection, (dispatch_data_t) data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error) {
        NSLog(@"Attempted to send %@", data);
        if (error != NULL) {
          NSLog(@"Error when sending=%@", error);
        } else {
          NSLog(@"Send was successful!");
        }
      });
    } else if (state == nw_connection_state_cancelled) {
      NSLog(@"Cancelled, releasing");
      self->_connection = nil;
    } else if (state == nw_connection_state_preparing) {
      NSLog(@"Preparing");
    }
    NSLog(@"Error=%@", error);
  });
  NSLog(@"Starting connection");
  nw_connection_start(_connection);
  NSLog(@"Connection started");
}


@end
