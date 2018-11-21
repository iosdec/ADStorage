//
//  ADStorage.h
//  iOSDec
//
//  Created by Declan Land
//  Copyright Declan Land. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*! @brief (A)ctive (D)atastore (O)bject. */
@interface ADObject : NSObject
@property (strong, nonatomic) NSString  *key;
@property (strong, nonatomic) id        value;
@end

/*!
 @brief (A)ctive (D)atastore (S)torage.
 @discussion Use Active Data Storage to store session objects. Let's say you need to cache a viewController or an NSObject from one class.. but can't access it through another.. This is the perfect solution. Use the sharedStorage to access globally stored objects, or store an ADStorage instance manually.
*/
@interface ADStorage : NSObject

/*! @brief Shared storage - use this for global storage. */
+ (id)sharedStorage;

/*! @brief Find a stored object with a given key. */
- (id)storedObjectWithKey:(NSString *)key;

/*! @brief Find a stored object with a given key - from optional archived storage. */
- (id)storedObjectWithKey:(NSString *)key archived:(BOOL)archived;

/*! @brief Store an object with a given key. */
- (BOOL)storeObject:(id)object withKey:(NSString *)key;

/*! @brief Store an object with a given key - from optional archived storage. */
- (BOOL)storeObject:(id)object withKey:(NSString *)key archived:(BOOL)archived;

/*! @brief Remove an object with a given key. */
- (BOOL)removeStoredObjectWithKey:(NSString *)key;

/*! @brief Remove an object with a given key - from optional archived storage. */
- (BOOL)removeStoredObjectWithKey:(NSString *)key archived:(BOOL)archived;

/*! @brief Array of all objects in storage. */
- (NSArray *)allObjects;

/*! @brief Array of all objects in storage - from optional archived. */
- (NSArray *)allObjectsFromArchived:(BOOL)archived;

/*! @brief Array of all object keys in storage. */
- (NSArray <NSString *> *)allObjectKeys;

/*! @brief Array of all object keys in storage - from optional archived. */
- (NSArray <NSString *> *)allObjectKeysFromArchived:(BOOL)archived;

@end
