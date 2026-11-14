# Flutter ProGuard rules
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-dontwarn io.flutter.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
