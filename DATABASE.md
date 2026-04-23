# YourHour Database

This app now has a Firestore-ready database starter built around a single
`users` collection.

## Collection

### `users/{uid}`

Each signed-in user stores:

- `uid`: Firebase Auth user id
- `email`: user email address
- `nickname`: anonymous display name chosen at signup
- `selectedRole`: `listener` or `speaker`
- `createdAt`: profile creation timestamp
- `updatedAt`: last profile update timestamp
- `lastActiveAt`: last time the user selected a role or updated profile state

## Security

Firestore rules allow users to read and write only their own document:

- `/users/{userId}` is accessible only when `request.auth.uid == userId`

## Dart files

- `lib/models/app_user.dart`: Firestore user document model
- `lib/services/user_repository.dart`: database access layer for creating,
  fetching, watching, and updating user profile data

## Next integration step

After running `flutter pub get`, the UI can call `UserRepository` during signup,
login, and role selection to persist user data in Firestore.
