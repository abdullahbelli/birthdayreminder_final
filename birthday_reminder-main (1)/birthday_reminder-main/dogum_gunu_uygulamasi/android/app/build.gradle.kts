plugins {
    id("com.android.application")
    
    id("dev.flutter.flutter-gradle-plugin")
    
    id("com.google.gms.google-services")

    id ("org.jetbrains.kotlin.android") 
}

android {
    namespace = "com.example.dogum_gunu_uygulamasi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.dogum_gunu_uygulamasi"
        
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))

    
    implementation("com.google.firebase:firebase-auth-ktx:22.3.1")
    implementation("com.google.firebase:firebase-firestore-ktx:24.10.3")
    

    implementation("com.google.android.gms:play-services-auth:21.3.0") 

    
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}