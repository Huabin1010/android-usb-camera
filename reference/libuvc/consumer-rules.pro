# JNI RegisterNatives looks up these exact names/signatures when libUVCCamera.so loads.
# R8 must not strip unused native methods or callback interfaces, or UVCCamera.<clinit> crashes:
# NoSuchMethodError: nativeSetStatusCallback(JLcom/jiangdg/uvc/IStatusCallback;)I

-keep class com.jiangdg.uvc.** { *; }
-keep interface com.jiangdg.uvc.** { *; }
-keepclassmembers class com.jiangdg.uvc.UVCCamera {
    native <methods>;
    private long mNativePtr;
    *;
}
-keep class com.jiangdg.usb.** { *; }
-keep class com.jiangdg.utils.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
