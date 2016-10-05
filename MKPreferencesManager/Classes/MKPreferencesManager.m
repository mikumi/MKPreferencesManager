//
//  MKPreferencesManager.m
//  Ping Monitor
//
//  Created by Michael Kuck on 9/24/13.
//  Copyright (c) 2013 Michael Kuck. All rights reserved.
//

#import "MKPreferencesManager.h"

#import "MKLog.h"

NSString *const MKPreferencesManagerKeysDidChangeNotification = @"MKPreferencesManagerKeysDidChangeNotification";
NSString *const MKPreferencesManagerChangedKeys               = @"MKPreferencesManagerChangedKeys";

//============================================================
//== Private Interface
//============================================================
@interface MKPreferencesManager ()

@property (strong, atomic, readonly) NSMutableArray *ignoreListForSyncing;

@property (strong, nonatomic, readonly) NSUserDefaults            *localStore;
@property (strong, nonatomic, readonly) NSUbiquitousKeyValueStore *iCloudStore;

- (void)iCloudUpdate:(NSNotification *)notification;

@end

//============================================================
//== Implementation
//============================================================
@implementation MKPreferencesManager

#pragma mark - Life Cycle

- (instancetype)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]
            ubiquitousKeyValueStore:[NSUbiquitousKeyValueStore defaultStore]];
}

/**
* One of the parameters can be nil if desired. If both are nil, nothing is stored, not even temporarily.
*/
- (instancetype)initWithUserDefaults:(NSUserDefaults *)localStore
             ubiquitousKeyValueStore:(NSUbiquitousKeyValueStore *)iCloudStore
{
    return [self initWithUserDefaults:localStore ubiquitousKeyValueStore:iCloudStore ignoredKeysForICloud:@[]];
}

/**
* One of the stores can be nil if desired. If both are nil, nothing is stored, not even temporarily. The ignored key
* list can be empty, but not nil
*/
- (instancetype)initWithUserDefaults:(NSUserDefaults *)localStore
             ubiquitousKeyValueStore:(NSUbiquitousKeyValueStore *)iCloudStore
                ignoredKeysForICloud:(NSArray *)iCloudIgnoreList
{
    NSAssert(localStore || iCloudStore, @"You must provide at least one store to save data in");
    NSAssert(iCloudIgnoreList, @"Ignore list cannot be nil");
    self = [super init];
    if (self) {
        _localStore           = localStore;
        _iCloudStore          = iCloudStore;
        _ignoreListForSyncing = [[NSMutableArray alloc] initWithArray:iCloudIgnoreList];

        [self synchronize];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudUpdate:)
                name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                object:self.iCloudStore];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
* Manager with default standardUserDefaults and iCloud's NSUbiquitousKeyValueStore defaultStore. All keys will be
* synced by default.
*/
+ (MKPreferencesManager *)defaultManager
{
    static dispatch_once_t      onceToken;
    static MKPreferencesManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MKPreferencesManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public methods

/**
* Synchronizes iCloud and local storage
*/
- (void)synchronize
{
    [self.localStore synchronize];
    [self.iCloudStore synchronize];
    MKLogVerbose(@"PreferencesManager keys synchronized.")
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    [self.localStore setBool:value forKey:key];
    if (![self.ignoreListForSyncing containsObject:key]) {
        [self.iCloudStore setBool:value forKey:key];
    }
}

- (void)setDouble:(double)value forKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    [self.localStore setDouble:value forKey:key];
    if (![self.ignoreListForSyncing containsObject:key]) {
        [self.iCloudStore setDouble:value forKey:key];
    }
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    [self.localStore setInteger:value forKey:key];
    if (![self.ignoreListForSyncing containsObject:key]) {
        [self.iCloudStore setLongLong:value forKey:key];
    }
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    [self.localStore setObject:object forKey:key];
    if (![self.ignoreListForSyncing containsObject:key]) {
        [self.iCloudStore setObject:object forKey:key];
    }
}

- (BOOL)boolForKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    BOOL value = NO;
    if ((![self.ignoreListForSyncing containsObject:key]) &&
        [self.iCloudStore.dictionaryRepresentation.allKeys containsObject:key]) {
        value = [self.iCloudStore boolForKey:key];
        [self.localStore setBool:value forKey:key];
    } else {
        value = [self.localStore boolForKey:key];
    }
    return value;
}

- (double)doubleForKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    double value = 0.0f;
    if ((![self.ignoreListForSyncing containsObject:key]) &&
        [self.iCloudStore.dictionaryRepresentation.allKeys containsObject:key]) {
        value = [self.iCloudStore doubleForKey:key];
        [self.localStore setDouble:value forKey:key];
    } else {
        value = [self.localStore doubleForKey:key];
    }
    return value;
}

- (NSInteger)integerForKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    NSInteger value = 0;
    if ((![self.ignoreListForSyncing containsObject:key]) &&
        [self.iCloudStore.dictionaryRepresentation.allKeys containsObject:key]) {
        value = (NSInteger)[self.iCloudStore longLongForKey:key];
        [self.localStore setInteger:value forKey:key];
    } else {
        value = [self.localStore integerForKey:key];
    }
    return value;
}

- (id)objectForKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    id value = nil;
    if ((![self.ignoreListForSyncing containsObject:key]) &&
        [self.iCloudStore.dictionaryRepresentation.allKeys containsObject:key]) {
        value = [self.iCloudStore objectForKey:key];
        [self.localStore setObject:value forKey:key];
    } else {
        value = [self.localStore objectForKey:key];
    }
    return value;
}

- (void)removeObjectForKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    [self.localStore removeObjectForKey:key];
    [self.iCloudStore removeObjectForKey:key];
}

/**
* This will remove all keys in the specified stores.
*/
- (void)resetPreferences
{
    [[self.iCloudStore dictionaryRepresentation]
            enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self.iCloudStore removeObjectForKey:key];
            }];
    [[self.localStore dictionaryRepresentation]
            enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self.localStore removeObjectForKey:key];
            }];

    [self synchronize];
}

- (void)addSyncIgnoreKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    @synchronized(self.ignoreListForSyncing) {
        if (![self.ignoreListForSyncing containsObject:key]) {
            [self.ignoreListForSyncing addObject:key];
        }
        assert([self.ignoreListForSyncing containsObject:key]);
    }
}

- (void)removeSyncIgnoreKey:(NSString *)key
{
    NSAssert(key, @"key cannot be nil");
    @synchronized(self.ignoreListForSyncing) {
        if ([self.ignoreListForSyncing containsObject:key]) {
            [self.ignoreListForSyncing removeObject:key];
        }
        assert(![self.ignoreListForSyncing containsObject:key]);
    }
}

- (NSArray *)syncIgnoreKeys
{
    @synchronized(self.ignoreListForSyncing) {
        return [NSArray arrayWithArray:self.ignoreListForSyncing];
    }
}

#pragma mark - Private methods

- (void)iCloudUpdate:(NSNotification *)notification
{
    if (!self.iCloudStore) {
        return;
    }
    NSNumber *const reason = notification.userInfo[NSUbiquitousKeyValueStoreChangeReasonKey];
    if (reason) {
        NSInteger reasonValue = [reason integerValue];
        if ((reasonValue == NSUbiquitousKeyValueStoreServerChange) ||
            (reasonValue == NSUbiquitousKeyValueStoreInitialSyncChange)) {
            NSArray *const keys = notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
            MKLogInfo(@"iCloud update received with %lu changed keys.", (unsigned long)[keys count]);
            MKLogDebug(@"Keys: %@", keys);

            NSMutableDictionary *const userInfo = [[NSMutableDictionary alloc] init];
            userInfo[MKPreferencesManagerChangedKeys] = keys;
            [[NSNotificationCenter defaultCenter]
                    postNotificationName:MKPreferencesManagerKeysDidChangeNotification object:self userInfo:userInfo];
        }
    }
}

@end
