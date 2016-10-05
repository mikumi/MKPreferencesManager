//
//  MKLog.m
//  MKCommons
//
//  Created by Michael Kuck on 9/30/13.
//  Copyright (c) 2013 Michael Kuck. All rights reserved.
//

#import "MKLog.h"

static MKLogLevel _logLevel = MKLogLevelWarning;
static BOOL _isUsingTimestamps = NO;

/**
 * Set the global logging level
 *
 * @param logLevel The maximum MKLogLevel for messages (lower level messages are more important). 0 is nothing.
 */
void MKSetLogLevel(MKLogLevel logLevel) {
    _logLevel = logLevel;
}

/**
 * Get the global logging level
 *
 * @return MKLogLevel. 0 is nothing.
 */
MKLogLevel MKGetCurrentLogLevel() {
    return _logLevel;
}

/**
 * Enable timestamps in log
 *
 * @param enabled Set to YES if timestamps should be used, otherwise NO.
 */
void MKSetUseTimestamps(BOOL enabled) {
    _isUsingTimestamps = enabled;
}

/**
 * Check if log is using timestamps.
 *
 * @return YES if using timestamps, otherwise NO.
 */
BOOL MKIsUsingTimestamps() {
    return _isUsingTimestamps;
}

/**
 * Method for internal use only. Use MKLog[Level](...) instead.
 */
void _MK_LOG_INTERNAL(MKLogLevel logLevel, NSString *className, NSUInteger line, NSString *message) {
    if (MKGetCurrentLogLevel() >= logLevel) {
        NSString *logLevelPrefix;
        if (logLevel == MKLogLevelError) {
            logLevelPrefix = @"[ERROR] ";
        } else if (logLevel == MKLogLevelWarning) {
            logLevelPrefix = @"[WARNING] ";
        } else {
            logLevelPrefix = @"";
        }
        NSString *timestampPrefix;
        if (MKIsUsingTimestamps()) {
            NSDate *const timestamp = [NSDate date];
            NSDateFormatter *const format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yy/MM/dd HH:mm:ss "];
            timestampPrefix = [format stringFromDate:timestamp];
        } else {
            timestampPrefix = @"";
        }
        NSString *const output = [NSString stringWithFormat:@"%@%@<%@:%lu> %@", timestampPrefix, logLevelPrefix,
                                                            className, (unsigned long)line, message];
        NSLog(@"%@", output);
    }
}

