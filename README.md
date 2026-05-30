# Infinite Logic Prison

Ultra-hard mobile puzzle game prototype focused on logic, memory, and deduction.

## Included foundations

- Deterministic endless room generator (no luck mechanics)
- Multi-category puzzle engine with dynamic difficulty scaling
- Persistent action history model for dynamic world memory
- Notebook timeline with clue search
- IQ-style score + rarity estimate + endgame unlock condition
- Flutter + Firebase-ready structure (local persistence + cloud sync repository)
- GitHub Actions workflow to run tests, build Android APK, and upload the APK artifact on every push

## Local setup

1. Install Flutter (stable channel)
2. From project root, generate platforms if needed:
   ```bash
   flutter create --platforms=android,ios .
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run tests:
   ```bash
   flutter test
   ```
5. Run app:
   ```bash
   flutter run
   ```
