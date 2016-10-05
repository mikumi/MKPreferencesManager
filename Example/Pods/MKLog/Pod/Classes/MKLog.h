//
//  MKLog.h
//  MKCommons
//
//  Created by Michael Kuck on 9/30/13.
//  Copyright (c) 2013 Michael Kuck. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MKLogLevel) {
    MKLogLevelNone = 0, MKLogLevelError = 1, MKLogLevelWarning = 2, MKLogLevelInfo = 3, MKLogLevelDebug = 4, MKLogLevelVerbose = 5
};

extern void MKSetLogLevel(MKLogLevel logLevel);
extern MKLogLevel MKGetCurrentLogLevel();
extern void MKSetUseTimestamps(BOOL enabled);
extern BOOL MKIsUsingTimestamps();
extern void _MK_LOG_INTERNAL(MKLogLevel logLevel, NSString *className, NSUInteger line, NSString *message);

#define MKLogError(message, ...) { \
    NSString *_mk_log_className = NSStringFromClass([self class]); \
    NSUInteger _mk_log_line = __LINE__; \
    NSString *_mk_log_message = [NSString stringWithFormat:(message),##__VA_ARGS__]; \
    _MK_LOG_INTERNAL(MKLogLevelError, _mk_log_className, _mk_log_line, _mk_log_message); \
}

#define MKLogWarning(message, ...) { \
    NSString *_mk_log_className = NSStringFromClass([self class]); \
    NSUInteger _mk_log_line = __LINE__; \
    NSString *_mk_log_message = [NSString stringWithFormat:(message),##__VA_ARGS__]; \
    _MK_LOG_INTERNAL(MKLogLevelWarning, _mk_log_className, _mk_log_line, _mk_log_message); \
}

#define MKLogInfo(message, ...) { \
    NSString *_mk_log_className = NSStringFromClass([self class]); \
    NSUInteger _mk_log_line = __LINE__; \
    NSString *_mk_log_message = [NSString stringWithFormat:(message),##__VA_ARGS__]; \
    _MK_LOG_INTERNAL(MKLogLevelInfo, _mk_log_className, _mk_log_line, _mk_log_message); \
}

#define MKLogDebug(message, ...) { \
    NSString *_mk_log_className = NSStringFromClass([self class]); \
    NSUInteger _mk_log_line = __LINE__; \
    NSString *_mk_log_message = [NSString stringWithFormat:(message),##__VA_ARGS__]; \
    _MK_LOG_INTERNAL(MKLogLevelDebug, _mk_log_className, _mk_log_line, _mk_log_message); \
}

#define MKLogVerbose(message, ...) { \
    NSString *_mk_log_className = NSStringFromClass([self class]); \
    NSUInteger _mk_log_line = __LINE__; \
    NSString *_mk_log_message = [NSString stringWithFormat:(message),##__VA_ARGS__]; \
    _MK_LOG_INTERNAL(MKLogLevelVerbose, _mk_log_className, _mk_log_line, _mk_log_message); \
}


