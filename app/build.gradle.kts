import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.play.publisher)
}

val keystorePropsFile = rootProject.file("keystore.properties")
val keystoreProps = Properties().also { props ->
    if (keystorePropsFile.exists()) keystorePropsFile.inputStream().use(props::load)
}

android {
    namespace = "io.github.pexmor.abe"
    compileSdk = 36

    defaultConfig {
        applicationId = "io.github.pexmor.abe"
        minSdk = 24
        targetSdk = 36
        versionCode = 2
        versionName = "1.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        create("release") {
            keyAlias     = keystoreProps.getProperty("keyAlias")     ?: System.getenv("KEY_ALIAS")
            keyPassword  = keystoreProps.getProperty("keyPassword")  ?: System.getenv("KEY_PASSWORD")
            storeFile    = (keystoreProps.getProperty("storeFile")   ?: System.getenv("STORE_FILE"))?.let(::file)
            storePassword = keystoreProps.getProperty("storePassword") ?: System.getenv("STORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures {
        viewBinding = true
    }
}

play {
    serviceAccountCredentials.set(rootProject.file("service-account.json"))
    // Publish to the internal test track by default; override with --track=production
    track.set("internal")
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.recyclerview)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.lifecycle.livedata.ktx)
    implementation(libs.androidx.lifecycle.viewmodel.ktx)
    implementation(libs.androidx.navigation.fragment.ktx)
    implementation(libs.androidx.navigation.ui.ktx)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}
