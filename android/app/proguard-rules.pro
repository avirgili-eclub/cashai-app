# Reglas básicas para Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Riverpod y generadores
-keep class ** extends androidx.lifecycle.ViewModel { *; }
-keep class ** implements com.example.State { *; }

# Modelo de datos y serialización
-keep class com.cashai.app.model.** { *; }
-keepclassmembers class com.cashai.app.model.** { *; }

# Para JSON serialización/deserialización
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Específico para seguridad
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }