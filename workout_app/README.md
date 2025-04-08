# Smart Workout Trainer

A modern Flutter application for tracking workouts, steps, and fitness progress.

## Features

### Step Tracking

- Real-time step counting with pedometer integration
- Daily step goals and progress tracking
- Calorie burn estimation based on steps and user weight
- Weekly step statistics with visual graphs
- Fallback to mock step counting when pedometer is unavailable

### Workout Management

- Create and manage custom workout templates
- Add exercises with detailed information:
  - Sets and reps tracking
  - Weight tracking
  - Exercise notes
- Weekly workout schedule planning
- Quick access to today's workout

### Progress Tracking

- Progress photo gallery
- Built-in BMI calculator
- Weight tracking
- Workout history

### User Experience

- Dark/Light theme support
- Intuitive navigation
- Responsive design
- Offline capability

## Project Structure

```
lib/
├── config/         # App configuration and constants
├── helpers/        # Helper classes for various functionalities
├── models/         # Data models
├── pages/         # Main screen implementations
├── providers/     # State management providers
├── services/      # Backend services
└── widgets/       # Reusable UI components
```

## Technical Details

### Dependencies

- Flutter SDK
- Provider for state management
- Pedometer for step tracking
- SharedPreferences for local storage
- ImagePicker for photo capture
- FL Chart for data visualization

### Key Components

#### PedometerHelper

- Manages step counting functionality
- Handles permission requests
- Provides mock mode for testing

#### WorkoutTemplateHelper

- Manages workout templates
- Handles CRUD operations for workouts
- Maintains workout history

#### StepsCalorieHelper

- Calculates calories burned
- Manages step goals
- Tracks daily progress

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Requirements

- Flutter 3.0 or higher
- iOS 11+ / Android 6.0+
- Physical device for step counting (emulator supports mock mode)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Contributors and testers
- UEK 335 course team
