//
//  ADStorage.m
//  iOSDec
//
//  Created by Declan Land
//  Copyright Declan Land. All rights reserved.
//

#import "ADStorage.h"

@implementation ADObject
@end

@implementation ADStorage {
    NSMutableArray *privateObjects; //  private objects.
}

+ (id)sharedStorage {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    }); return _sharedObject;
}

#pragma mark    -   Storage:

- (BOOL)storeObject:(id)object withKey:(NSString *)key {
    
    if (!object) { return NO; }
    if (!key) { return NO; }
    if (key.length == 0) { return NO; }
    
    if (!self->privateObjects) {
        self->privateObjects = [[NSMutableArray alloc] init];
    }
    
    //  check existence:
    ADObject *adobject      =   [[ADObject alloc] init];
    
    if ([[self allObjects] count] != 0) {
        
        if ([[self allObjectKeys] containsObject:key]) {
            
            NSPredicate *pred   =   [NSPredicate predicateWithFormat:@"self.key == %@", key];
            NSArray *filter     =   [self->privateObjects filteredArrayUsingPredicate:pred];
            
            if (filter.count != 0) {
                adobject        =   [filter firstObject];
            }
            
        }
        
    }
    
    [adobject setValue:object];
    [adobject setKey:key];
    [self->privateObjects addObject:adobject];
    
    return YES;
    
}

- (BOOL)storeObject:(id)object withKey:(NSString *)key archived:(BOOL)archived {
    
    if (!archived) {
        return [self storeObject:object withKey:key];
    }
    
    //  here.. we want to store the object in the documents directory:
    NSString *documents     =   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *adstorage     =   [documents stringByAppendingPathComponent:@"ADStorage"];
    NSFileManager *man      =   [NSFileManager defaultManager];
    if (![man fileExistsAtPath:adstorage]) {
        [man createDirectoryAtPath:adstorage withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filepath      =   [adstorage stringByAppendingPathComponent:key];
    
    //  image:
    if ([object isKindOfClass:[UIImage class]]) {
        NSData *data = UIImagePNGRepresentation(object);
        return [data writeToFile:filepath atomically:YES];
    }
    
    //  nsobject:
    if ([object isKindOfClass:[NSObject class]]) {
        NSObject *_object = (NSObject *)object;
        return [NSKeyedArchiver archiveRootObject:_object toFile:filepath];
    }
    
    //  other:
    return [object writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

- (BOOL)removeStoredObjectWithKey:(NSString *)key {
    
    if (!self->privateObjects) {
        self->privateObjects = [[NSMutableArray alloc] init];
    }
    
    //  check existence:
    if ([[self allObjects] count] == 0) {
        return NO;
    }
    
    if (![[self allObjectKeys] containsObject:key]) {
        return NO;
    }
    
    NSPredicate *predicate  =   [NSPredicate predicateWithFormat:@"self.key == %@", key];
    NSArray *filter         =   [self->privateObjects filteredArrayUsingPredicate:predicate];
    
    if (filter.count == 0) {
        return NO;
    }
    
    ADObject *adobject      =   [filter firstObject];
    [self->privateObjects removeObject:adobject];
    
    return YES;
    
}

- (BOOL)removeStoredObjectWithKey:(NSString *)key archived:(BOOL)archived {
    
    if (!archived) {
        return [self removeStoredObjectWithKey:key];
    }
    
    //  now we need to remove the file from the local storage:
    NSString *documents         =   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *adstorage         =   [documents stringByAppendingPathComponent:@"ADStorage"];
    NSFileManager *man          =   [NSFileManager defaultManager];
    NSString *filepath          =   [adstorage stringByAppendingPathComponent:key];
    
    //  return true if the folder doesn't exist
    //  because there are no items.
    if (![man fileExistsAtPath:adstorage]) {
        return YES;
    }
    
    //  return the result of removing the file:
    return [man removeItemAtPath:filepath error:nil];
    
}

- (id)storedObjectWithKey:(NSString *)key {
    
    if (!self->privateObjects) {
        return nil;
    }
    
    if (self->privateObjects.count == 0) {
        return nil;
    }
    
    if ([[self allObjectKeys] count] == 0) {
        return nil;
    }
    
    if (![[self allObjectKeys] containsObject:key]) {
        return nil;
    }
    
    NSPredicate *predicate      =   [NSPredicate predicateWithFormat:@"self.key == %@", key];
    NSArray *filter             =   [self->privateObjects filteredArrayUsingPredicate:predicate];
    
    if (filter.count == 0) {
        return nil;
    }
    
    ADObject *object            =   [filter firstObject];
    
    if (!object.value) { return nil; }
    
    return object.value;
    
}

- (id)storedObjectWithKey:(NSString *)key archived:(BOOL)archived {
    
    if (!archived) {
        return [self storedObjectWithKey:key];
    }
    
    if (!key) { return nil; }
    if (key.length == 0) { return nil; }
    
    NSArray *keys               =   [self allObjectKeysFromArchived:YES];
    if (![keys containsObject:key]) {
        return nil;
    }
    
    NSString *documents         =   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *adstorage         =   [documents stringByAppendingPathComponent:@"ADStorage"];
    NSFileManager *man          =   [NSFileManager defaultManager];
    
    if (![man fileExistsAtPath:adstorage]) {
        return nil;
    }
    
    NSArray *filenames          =   [man contentsOfDirectoryAtPath:adstorage error:nil];
    if (![filenames containsObject:key]) {
        return nil;
    }
    
    NSString *filepath          =   [adstorage stringByAppendingPathComponent:key];
    
    //  now create an adobject:
    ADObject *object            =   [[ADObject alloc] init];
    [object setKey:key];
    
    //  now get the object:
    //  image:
    if ([key hasSuffix:@"png"] || [key hasSuffix:@"PNG"] || [key hasSuffix:@"jpg"] || [key hasSuffix:@"JPG"] || [key hasSuffix:@"jpeg"] || [key hasSuffix:@"JPEG"] || [key hasSuffix:@"svg"] || [key hasSuffix:@"SVG"] || [key hasSuffix:@"gif"] || [key hasSuffix:@"GIF"]) {
        NSData *data        =   [NSData dataWithContentsOfFile:filepath options:0 error:nil];
        UIImage *image      =   [UIImage imageWithData:data];
        if (image) {
            [object setValue:image];
        }
    }
    
    //  object:
    else {
        NSData *data        =   [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        if (data) {
            [object setValue:data];
        }
    }
    
    //  check key/value:
    if (object.key && object.value) {
        return object;
    } else {
        return nil;
    }
    
}

#pragma mark    -   Keys / Values:

- (NSArray *)allObjects {
    
    NSMutableArray *objects     =   [[NSMutableArray alloc] init];
    
    if (!self->privateObjects) {
        return objects;
    }
    
    if (self->privateObjects.count == 0) {
        return objects;
    }
    
    for (id obj in self->privateObjects) {
        if ([obj isKindOfClass:[ADObject class]]) {
            ADObject *object = (ADObject *)obj;
            if (object.value) {
                [objects addObject:object.value];
            }
        }
    }
    
    return objects;
    
}

- (NSArray *)allObjectsFromArchived:(BOOL)archived {
    
    if (!archived) {
        return [self allObjects];
    }
    
    //  get file names:
    NSArray *filenames          =   [self allObjectKeysFromArchived:YES];
    if (filenames.count == 0) {
        return [NSArray array];
    }
    
    //  setup stuff:
    NSString *documents         =   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *adstorage         =   [documents stringByAppendingPathComponent:@"ADStorage"];
    NSMutableArray *objects     =   [[NSMutableArray alloc] init];
    
    //  cycle through:
    for (NSString *filename in filenames) {
        
        NSString *filepath      =   [adstorage stringByAppendingPathComponent:filename];
        ADObject *object        =   [[ADObject alloc] init];
        [object setKey:filename];
        
        //  image:
        if ([filepath hasSuffix:@"png"] || [filepath hasSuffix:@"PNG"] || [filepath hasSuffix:@"jpg"] || [filepath hasSuffix:@"JPG"] || [filepath hasSuffix:@"jpeg"] || [filepath hasSuffix:@"JPEG"] || [filepath hasSuffix:@"svg"] || [filepath hasSuffix:@"SVG"] || [filepath hasSuffix:@"gif"] || [filepath hasSuffix:@"GIF"]) {
            NSData *data        =   [NSData dataWithContentsOfFile:filepath options:0 error:nil];
            UIImage *image      =   [UIImage imageWithData:data];
            if (image) {
                [object setValue:image];
            }
        }
        
        //  object:
        else {
            NSData *data        =   [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
            if (data) {
                [object setValue:data];
            }
        }
        
        //  check key/value:
        if (object.key && object.value) {
            [objects addObject:object];
        }
        
    }
    
    return objects;
    
}

- (NSArray <NSString *>*)allObjectKeys {
    
    NSMutableArray *objects     =   [[NSMutableArray alloc] init];
    
    if (!self->privateObjects) {
        return objects;
    }
    
    if (self->privateObjects.count == 0) {
        return objects;
    }
    
    for (id obj in self->privateObjects) {
        if ([obj isKindOfClass:[ADObject class]]) {
            ADObject *object = (ADObject *)obj;
            if (object.key) {
                [objects addObject:object.key];
            }
        }
    }
    
    return objects;
    
}

- (NSArray <NSString *>*)allObjectKeysFromArchived:(BOOL)archived {
    
    if (!archived) {
        return [self allObjectKeys];
    }
    
    //  now.. we need to get all "keys" / file names
    //  from the adstorage folder:
    NSString *documents             =   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *adstorage             =   [documents stringByAppendingPathComponent:@"ADStorage"];
    NSFileManager *man              =   [NSFileManager defaultManager];
    
    //  return none if the folder doesn't exist.
    if (![man fileExistsAtPath:adstorage]) {
        return [NSArray array];
    }
    
    //  now get the file names:
    NSArray *filenames              =   [man contentsOfDirectoryAtPath:adstorage error:nil];
    if (filenames.count == 0) {
        return [NSArray array];
    }
    
    //  return filenames:
    return filenames;
    
}

@end
