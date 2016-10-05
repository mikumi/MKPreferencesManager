# MKLog

[![CI Status](http://img.shields.io/travis/Michael Kuck/MKLog.svg?style=flat)](https://travis-ci.org/Michael Kuck/MKLog)
[![Version](https://img.shields.io/cocoapods/v/MKLog.svg?style=flat)](http://cocoapods.org/pods/MKLog)
[![License](https://img.shields.io/cocoapods/l/MKLog.svg?style=flat)](http://cocoapods.org/pods/MKLog)
[![Platform](https://img.shields.io/cocoapods/p/MKLog.svg?style=flat)](http://cocoapods.org/pods/MKLog)

A basic logger implementation for Objective-C

## Features

- 6 log levels (None, Error, Warning, Info, Debug, Verbose)
- Log level prefix for warnings and erros
- Class name and line number of caller
- Optional timestamps

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

**Configuration**
````Objective-C
void MKSetLogLevel(MKLogLevelNone|MKLogLevelError|MKLogLevelWarning|
              MKLogLevelInfo|MKLogLevelDebug|MKLogLevelVerbose);
MKLogLevel MKGetCurrentLogLevel();

void MKSetUseTimestamps(true|false);
BOOL MKIsUsingTimestamps();
````
**Logging**
````Objective-C
void MKLogError(@"Error message %@", param1, ...);
void MKLogWarning(@"Warning message %@", param1, ...);
void MKLogInfo(@"Info message %@", param1, ...);
void MKLogDebug(@"Debug message %@", param1, ...);
void MKLogVerbose(@"Verbose message %@", param1, ...);
````

## Installation

MKLog is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MKLog"
```

## Author

Michael Kuck, me@michael-kuck.com

## License

MKLog is available under the MIT license. See the LICENSE file for more info.
