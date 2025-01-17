//
//  SettingsUtils.m
//  greenTravel
//
//  Created by Alex K on 26.02.23.
//

#import "SettingsUtils.h"
#import "SettingsScreen.h"
#import "SettingsGroup.h"
#import "SettingsEntry.h"
#import "SettingsEntryNavigate.h"

void traverseSettingsTree(SettingsScreen *root,
                          void (^onVisit)(SettingsScreen *, SettingsGroup *,
                                          SettingsEntry *, BOOL *)) {
  BOOL stop = NO;
  onVisit(root, nil, nil, &stop);
  for (NSUInteger i = 0; i < [root.groups count]; i++) {
    SettingsGroup *group = root.groups[i];
    for (NSUInteger j = 0; j < [group.entries count]; j++) {
      SettingsEntry *entry = group.entries[j];
      onVisit(root, group, entry, &stop);
      if (stop) {
        return;
      }
      if ([entry isKindOfClass:[SettingsEntryNavigate class]]) {
        SettingsEntryNavigate *entryNavigate = (SettingsEntryNavigate *)entry;
        traverseSettingsTree(entryNavigate.screen, onVisit);
      }
    }
  }
}

BOOL treeContainsScreen(SettingsScreen *tree, SettingsScreen *screen) {
  __block BOOL found = NO;
  traverseSettingsTree(tree, ^(SettingsScreen *scr, SettingsGroup *gr,
                               SettingsEntry *entry, BOOL *stop) {
    if ([scr isEqual:screen]) {
      found = YES;
      *stop = YES;
    }
  });
  return found;
}
