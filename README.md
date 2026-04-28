# 🏋️‍♂️ Stax - Fitness & Workout Tracker

Stax is a native iOS fitness and workout tracking application designed to help users log their exercises, track their workout sessions, and monitor their fitness progress. Built with a clean, modular architecture, Stax offers a seamless and intuitive user experience.

> ⚠️ **Note:** This is a personal portfolio project. The source code is provided for educational and demonstration purposes. You are welcome to download, review, and test the code locally, but **commercial use or redistribution is strictly prohibited**.

<div align="center">
  <img src="https://ik.imagekit.io/wgp06waey/ForGithub/baner.png?updatedAt=1777398659972" alt="Screenshot 1" width="260" style="margin: 0 10px;">
  <img src="https://ik.imagekit.io/wgp06waey/ForGithub/4.png" alt="Screenshot 2" width="260" style="margin: 0 10px;">
</div>

## ✨ Features

- **User Authentication**: Secure login and registration via Firebase.
- **Profile Management**: Update profile image, name, and bio with real-time UI updates.
- **Workout Tracking**: Log exercises with live session tracking and timers.
- **Workout History**: View past workouts with detailed summaries and statistics.
- **Muscle Analytics**: Visualize muscle group distribution with charts.
- **Progress Tracking**: Monitor volume, duration, and workout frequency over time.
- **Offline-First Architecture**: CoreData ensures full functionality without internet.
- **Data Synchronization**: Syncs local data with Firebase when online.
- **Image Handling**: Upload and cache images using ImageKit + Kingfisher.
- **HealthKit Integration**: Track calories burned and visualize activity progress.

## 🛠 Tech Stack

- **Platform**: iOS (Native)
- **Language**: Swift
- **Architecture**: MVVM-C (Model-View-ViewModel with Coordinators)
- **UI Frameworks**: 
  - **UIKit** (Programmatic UI)
  - **Charts**: Swift Charts (via SwiftUI)
- **AutoLayout**: [SnapKit](https://github.com/SnapKit/SnapKit) (Programmatic constraints)
- **State Management**: Combine (Reactive bindings)
- **Local Storage**: CoreData
- **Dependency Injection**: Protocol-based DI
- **Backend / Authentication**: Firebase
- **Image Handling**: [Kingfisher](https://github.com/onevcat/Kingfisher) (Image downloading and caching)
- **Image Storage**: [ImageKit](https://imagekit.io/) (Image storage and delivery)
- **Health Data**: HealthKit

## 🏗 Architecture (MVVM-C)

Stax utilizes the **MVVM-C** architecture to ensure clean separation of concerns, testability, and modularity:
- **Model**: CoreData entities and DTOs representing the data layer.
- **View**: Programmatic UI components separated into dedicated View files (e.g., `WorkoutSessionView`, `SetRowView`).
- **ViewModel**: Handles business logic, data formatting, and state management.
- **Coordinator**: Manages navigation flow between screens, decoupling views from routing logic.

## 🧠 Key Engineering Decisions

- **Offline-First Design**: All data is stored locally via CoreData and synced with Firebase to ensure reliability.
- **Single Source of Truth**: Workout and user data are managed centrally to prevent inconsistencies.
- **Coordinator Pattern**: Navigation is fully decoupled from ViewControllers.
- **Protocol-Oriented DI**: Services are injected via protocols for testability and flexibility.

## 📁 Project Structure

<details>
<summary>Click to expand full structure</summary>

```
Stax/

├── Application/
│   ├── AppDelegate.swift
│   ├── MainCoordinator.swift
│   └── SceneDelegate.swift
├── Base.lproj/
├── Common/
│   ├── Data/
│   │   ├── CoreData/
│   │   │   ├── ExerciseDTO.swift
│   │   │   └── Stax.xcdatamodeld/
│   │   │       └── Stax.xcdatamodel/
│   │   │           └── contents
│   │   └── Repository/
│   │       ├── Core/
│   │       │   └── GenericRepository.swift
│   │       └── DataRepository.swift
│   ├── Errors/
│   │   ├── DatabaseError.swift
│   │   └── WorkoutSessionError.swift
│   ├── Helpers/
│   │   ├── AlertManager.swift
│   │   └── DataSeeder.swift
│   ├── Resources/
│   │   └── exercises_seed.json
│   ├── UIHelpers/
│   │   └── TextView.swift
│   └── Utilities/
│       └── Base/
│           └── Coordinator.swift
├── Features/
│   ├── ExerciseList/
│   │   ├── ExerciseListCoordinator.swift
│   │   ├── ExerciseListVC.swift
│   │   ├── ExerciseListVM.swift
│   │   └── ExerciseListViews/
│   │       ├── ExerciseListCell.swift
│   │       └── ExerciseListView.swift
│   ├── Home/
│   │   ├── HomeCoordinator.swift
│   │   ├── HomeVC.swift
│   │   ├── HomeVM.swift
│   │   └── HomeViews/
│   │       └── HomeView.swift
│   ├── Profile/
│   │   ├── ProfileCoordinator.swift
│   │   ├── ProfileVC.swift
│   │   ├── ProfileVM.swift
│   │   └── ProfileViews/
│   │       └── ProfileView.swift
│   ├── Workout/
│   │   ├── WorkoutCoordinator.swift
│   │   ├── WorkoutVC.swift
│   │   ├── WorkoutVM.swift
│   │   └── WorkoutViews/
│   │       ├── TableViewHeader.swift
│   │       ├── WorkoutTableViewCell.swift
│   │       └── WorkoutView.swift
│   ├── WorkoutSession/
│   │   ├── WorkoutSessionCoordinator.swift
│   │   ├── WorkoutSessionVC.swift
│   │   ├── WorkoutSessionVM.swift
│   │   ├── Services/
│   │   │   └── WorkoutTimerService.swift
│   │   ├── Sheets/
│   │   │   ├── ExerciseMenuSheet.swift
│   │   │   └── SheetView.swift
│   │   └── WorkoutSessionView/
│   │       ├── WorkoutSessionView.swift
│   │       ├── Cells/
│   │       │   ├── EmptyWorkoutTableViewCell.swift
│   │       │   ├── WorkoutSessionFooterView.swift
│   │       │   └── WorkoutSessionTableViewCell.swift
│   │       └── WorkoutSets/
│   │           ├── SetRowView.swift
│   │           ├── SetsFooterView.swift
│   │           ├── SetsHeaderView.swift
│   │           ├── WorkoutSessionExerciseListCell.swift
│   │           └── WorkoutSetsView.swift
│   └── WorkoutSummary/
│       ├── WorkoutSummaryCoordinator.swift
│       ├── WorkoutSummaryVC.swift
│       ├── WorkoutSummaryViewModel.swift
│       └── WorkoutSummaryView/
│           ├── WorkoutSummaryView.swift
│           └── UIVIews/
│               ├── DescriptionView.swift
│               ├── InformationView.swift
│               └── WorkoutSummaryHeaderView.swift
├── Info.plist
├── MainTabCoordinator/
│   ├── TabBarPage.swift
│   └── TabCoordinator.swift
```
</details>

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0+ Simulator or Device

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/rovshanr1/Stax.git
   ```
2. Open `Stax.xcodeproj` in Xcode.
3. Make sure to add your own `GoogleService-Info.plist` file from Firebase to the `Stax` directory so that Authentication works properly.
4. **ImageKit Configuration:** Create or update your `.xcconfig` file (e.g. `Support/Key.xcconfig`) and add your ImageKit public key and URL endpoint:
   ```xcconfig
   IMAGEKIT_PUBLIC_KEY = your_public_key_here
   IMAGEKIT_URL_ENDPOINT = https://ik.imagekit.io/your_endpoint/
   ```
5. Select a simulator or your connected iOS device.
6. Press `Cmd + R` to Build and Run the application.

## 📄 License

**Personal / Educational Use Only**

This project is a personal portfolio application. You are welcome to clone, explore, and run the code locally for educational or evaluation purposes. However, you may **not** use, distribute, or modify this code for commercial purposes. All rights reserved.
