#import <UIKit/UIKit.h>

@interface ULLog : NSObject {}

+(void)file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...;


#define ULLog(s,...) [ULLog file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]

//#define ULLog(s,...) do{}while(0)

@end
