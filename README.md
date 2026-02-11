
## 📁 Project Structure
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

---
