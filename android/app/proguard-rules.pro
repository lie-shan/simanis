# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# Play Core Library untuk In-app Updates
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep classes for mobile_scanner
-keep class io.github.edufolly.fluttermobilescanner.** { *; }

# Keep classes for audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Keep classes for url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep classes for file_picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Keep classes for pdfview
-keep class io.endigo.plugins.pdfviewflutter.** { *; }

# Keep classes for path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Keep classes for shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep generic signature of Call, ResponseCall, Response
-keep class retrofit2.** { *; }

# Keep generic signature of RxJava interfaces for frameworks using Retrofit
-keep class io.reactivex.** { *; }
-keep class com.jakewharton.rx.** { *; }

# Keep attributes
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
