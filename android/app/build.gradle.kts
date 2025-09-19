plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.afc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.awesomefinancialcontrol.br" // Alterado para o ID base de produção
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    flavorDimensions += "app"

    buildTypes {
        getByName("debug") {}
        getByName("release") {}
        
    }
    
    productFlavors {
        create("dev") {
            dimension = "app"
            applicationIdSuffix = ".dev" // Mais simples que definir o ID completo
            resValue("string", "app_name", "AFC Dev")
            versionNameSuffix = "-dev"
        }
        create("prod") {
            dimension = "app"
            // Para o flavor de produção, não precisamos de sufixo no ID ou no nome da versão.
            resValue("string", "app_name", "Awesome Financial Control")
        }
    }
}

flutter {
    source = "../.."
}
