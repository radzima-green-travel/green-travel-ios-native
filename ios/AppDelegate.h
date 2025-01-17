#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (assign, nonatomic) UIInterfaceOrientationMask orientationLock;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

