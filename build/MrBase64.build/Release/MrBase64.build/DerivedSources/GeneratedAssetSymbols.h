#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "MascotCharacter" asset catalog image resource.
static NSString * const ACImageNameMascotCharacter AC_SWIFT_PRIVATE = @"MascotCharacter";

#undef AC_SWIFT_PRIVATE
