# Flutter wraps most of its own keep rules; these are conservative extras so
# release builds with R8 shrinking don't strip Firebase / Play Integrity classes.

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Play Integrity / App Check
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.**

# Keep annotated members used via reflection by the Firebase SDKs.
-keepattributes Signature
-keepattributes *Annotation*
