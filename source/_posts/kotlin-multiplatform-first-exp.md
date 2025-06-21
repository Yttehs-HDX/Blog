---
title: Kotlin Multiplatform First Experience
date: 2024-12-17 19:53:52
tags: [Lang, Kotlin, Android, Guide]
category: [Guide, Lang, Kotlin]
thumbnail: /image/kotlin-multiplatform-first-exp/head.webp
excerpt: Details in Kotlin Multiplatform Project
---

## Before Reading

Head picture is from the template project created by [Kotlin Multiplatform wizard](https://kmp.jetbrains.com).

### What's Kotlin Multiplatform

[Kotlin Multiplatform (KMP)](https://kotlinlang.org/docs/multiplatform-intro.html#learn-key-concepts) is a feature introduced by JetBrains to allow developers to write shared code across multiple platforms using the Kotlin programming language. It enables developers to create applications that run on various platforms such as iOS, Android, desktop (mostly JVM), and server-side environments.

### Example Repository

My first KMP project: [Yttehs-HDX/KMP-Counter](https://github.com/Yttehs-HDX/KMP-Counter), with both Android and Desktop(JVM) supported.

### Errata

Before delving into the text, it's important to note that there may be some **grammar or syntax errors**  present. This could be due to translation errors, typing mistakes, or the author's unique writing style ( I'm a Chinese native speaker 😅 ).

## Getting Start

Entering the KMP project, in path `composeApp/src`, there are platform specific modules (such as `androidMain` and `desktopMain`) and platform shared module - `commonMain`.

```bash
$ tree -L 1 composeApp/src
androidMain
commonMain
desktopMain
```

Their access permission is that:

- modules `androidMain`, `desktopMain`, etc. have access to module `commonMain`.
- but module `commonMain` has **NO** access to other platform specific modules.

[composeApp/build.gradle.kts](https://github.com/Yttehs-HDX/KMP-Counter/blob/main/composeApp/build.gradle.kts#L31) defines dependency injection for each platform.

```kotlin
kotlin {
    ...
    sourceSets {
        val desktopMain by getting
        
        androidMain.dependencies {
            implementation(...)
            ...
        }
        commonMain.dependencies {
            implementation(...)
            ...
        }
        desktopMain.dependencies {
            implementation(...)
            ...
        }
    }
    ...
}
```

## How Shared Module Uses Platform-specific APIs?

Kotlin provides two keywords `expect` and `actual`, splitting the defination (in shared module) and implementation (in platform-specific modules).

> Like `features` in Rust, Kotlin only compile actual objects in the chosen platform.  
> So if lack of Android SDK, desktop platform can be compiled successfully.

`expect` keyword is the defination.

- commonMain

At [`commonMain/kotlin/pkg_name/cache/DatabaseDriverFactory.kt`](https://github.com/Yttehs-HDX/KMP-Counter/blob/main/composeApp/src/commonMain/kotlin/org/shettyyttehs/counter/cache/DatabaseDriverFactory.kt)

```kotlin
expect class DatabaseDriverFactory {
    fun createDriver(): SqlDriver
}

expect val databaseFactory: DatabaseDriverFactory
```

`actual` keyword is the implementation.

- androidMain

At [`androidMain/kotlin/pkg_name/cache/DatabaseDriverFactory.android.kt`](https://github.com/Yttehs-HDX/KMP-Counter/blob/main/composeApp/src/androidMain/kotlin/org/shettyyttehs/counter/cache/DatabaseDriverFactory.android.kt)

Implement database driver by AndroidSqliteDriver.

```kotlin
actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        val context = MyApplication.Context
        return AndroidSqliteDriver(AppDatabase.Schema, context, "counter.db")
    }
}

actual val databaseFactory by lazy {
    DatabaseDriverFactory()
}
```

- desktopMain

At [`desktopMain/kotlin/pkg_name/cache/DatabaseDriverFactory.jvm.kt`](https://github.com/Yttehs-HDX/KMP-Counter/blob/main/composeApp/src/desktopMain/kotlin/org/shettyyttehs/counter/cache/DatabaseDriverFactory.jvm.kt)

Impliment database driver by JdbcSqliteDriver.

```kotlin
actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        val dbPath = getDatabasePath()
        val driver = JdbcSqliteDriver(
            url = "jdbc:sqlite:$dbPath"
        )

        // Create the database if it doesn't exist
        val dbFile = File(dbPath)
        if (!dbFile.exists()) {
            AppDatabase.Schema.create(driver)
        }

        return driver
    }
}

actual val databaseFactory by lazy {
    DatabaseDriverFactory()
}
```

## Design Specifications

- Define interfaces in `commonMain` and implement in platform-specific modules.
- Do not use platform-specific code in `commonMain`.

Example:

Desktop Target does not support the default view model factory.

So you should use:

```kotlin
val someViewModel = viewModel { SomeViewModel() }
```

Instead of:

```kotlin
val someViewModel = viewModel<SomeViewModel>()
```

It's Android only!

The better implementation is to write a view model factory in `commonMain`.
