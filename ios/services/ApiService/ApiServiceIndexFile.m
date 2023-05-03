//
//  IndexFileApiService.m
//  greenTravel
//
//  Created by Alex K on 10.07.22.
//

#import "ApiServiceIndexFile.h"
#import "IndexModelData.h"
#import "LocaleConstants.h"
#import "LocaleUtils.h"
#import <Keys/GreenTravelKeys.h>
#import "CategoryUtils.h"

@interface ApiServiceIndexFile()
@property (strong, nonatomic) NSURLSession *session;
@end

@implementation ApiServiceIndexFile

static const NSString * kAPIVersion = @"v1";

- (instancetype)initWithSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (NSString *)categoriesURL {
  NSString *lang = getCurrentLocaleLanguageCode();
  GreenTravelKeys *keys = [GreenTravelKeys new];
  return [NSString stringWithFormat:@"%@/objects_%@_%@.json",
          keys.nativeClientIndexFileBaseUrl, kAPIVersion, lang];
}

- (void)loadCategories:(NSString *)currentHash
             forceLoad:(BOOL)forceLoad
        withCompletion:(CategoriesCompletion)completion {
  
  NSURL *url = [NSURL URLWithString:[self categoriesURL]];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:120];
  NSURLSessionDataTask *task =
  [self.session dataTaskWithRequest:request
                  completionHandler:^(NSData * _Nullable data,
                                      NSURLResponse * _Nullable response,
                                      NSError * _Nullable error) {
    IndexModelData *indexModelData = [[IndexModelData alloc] init];
    if (!data) {
      completion(indexModelData, @[], currentHash);
      return;
    }
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *updatedHash = headers[@"ETag"];
    // TODO: compare currentHash and updatedHash and do not parse new data
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions error:&error];
    
    NSArray<NSDictionary *> *rawItems = [parsedData[@"objects"][@"items"] copy];
    NSArray<NSDictionary *> *rawCategories = [parsedData[@"categories"] copy];
    NSMutableDictionary<NSString *, NSDictionary *> *accumulatedCategories =
    [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, NSDictionary *> *accumulatedItems =
    [[NSMutableDictionary alloc] init];
    [rawCategories enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull rawCategory,
                                                NSUInteger idx, BOOL * _Nonnull stop) {
      accumulatedCategories[rawCategory[@"id"]] = rawCategory;
    }];
    [rawItems enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull rawItem,
                                           NSUInteger idx, BOOL * _Nonnull stop) {
      accumulatedItems[rawItem[@"id"]] = rawItem;
    }];
    
    indexModelData = rawIndexToIndexModelData(accumulatedCategories, accumulatedItems);
    completion(indexModelData, @[], updatedHash);
  }];
  [task resume];
}

@end
