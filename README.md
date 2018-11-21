#   ADStorage

(A)utomatic (D)ata (Storage) - archive objects for app sessions, or write them to the file system.

##  Import to project
```objc
//  ADStorage.h
//  ADStorage.m
```

##  Import usage in project
```objc
#import "ADStorage.h"
```

##  Usage

<hr></hr>

### Store object to disk
The "archive" will determine whether the app will archive the file, or just store it for the session (removed when app exits).
```objc
UIImage *customImage = [UIImage imageName:@"myimage.png"];
[[ADStorage sharedStorage] storeObject:customImage withKey:@"myimagekeyname" archived:YES];
```
### Store object for session (removed on app exit)
```objc
UIImage *customImage = [UIImage imageName:@"myimage.png"];
[[ADStorage sharedStorage] storeObject:customImage withKey:@"myimagekeyname" archived:NO];
```
<hr></hr>

### Retreive object from disk
The object you will get back will be an ADObject - which has "key" and "value" properties.
```objc
NSString *keyname = @"myimagekeyname";
ADStorage *obj = [[ADStorage sharedStorage] storedObjectWithKey:keyname archived:YES];

//  get image from obj.value
//  get key from obj.key
```

### Retreive object for session (removed on app exit)
```objc
NSString *keyname = @"myimagekeyname";
ADStorage *obj = [[ADStorage sharedStorage] storedObjectWithKey:keyname archived:NO];

//  get image from obj.value
//  get key from obj.key
```

<hr></hr>

### Remove object from disk
Removes an object out of storage or from disk - whether it's local or session.
```objc
NSString *keyname = @"myimagekeyname";
[[ADStorage sharedStorage] removeStoredObjectWithKey:keyname archived:YES];
```

### Remove object for session
```objc
NSString *keyname = @"myimagekeyname";
[[ADStorage sharedStorage] removeStoredObjectWithKey:keyname archived:NO];
```

<hr></hr>

### Get all keys
Change the "archived" to YES or NO depending on whether you want session or archived storage.
```objc
NSArray *keys = [[ADStorage sharedStorage] allObjectKeysFromArchived:NO];
```

<hr></hr>

### Get all objects
Change the "archived" to YES or NO depending on whether you want session or archived storage. Returns "ADObject" items.
```objc
NSArray *objects = [[ADStorage sharedStorage] allObjectsFromArchived:NO];
```

<hr></hr>

##  Credits
Declan Land

