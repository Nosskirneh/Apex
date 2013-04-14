#ifndef STK_CONSTANTS_H
#define STK_CONSTANTS_H

#ifdef DEBUG
	#define DLog(fmt, ...) NSLog((@"STK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
	#define CLog(fmt, ...) NSLog((@"STK: " fmt), ##__VA_ARGS__)
#else
	#define DLog(...)
	#define CLog(...)
#endif

@class NSString;
extern NSString * const STKTweakName;

#define PREFS_PATH [NSString stringWithFormat:@"%@/Library/Preferences/com.a3tweaks.%@.plist"];

// Function to translate a number from one range to another
// For instance 248 in the range [0, 320] -> something 0.0 -> 0.1
extern double STKScaleNumber(double numToScale, double prevMin, double prevMax, double newMin, double newMax);

// Wrapper function
extern double STKAlphaFromDistance(double distance);

#endif
