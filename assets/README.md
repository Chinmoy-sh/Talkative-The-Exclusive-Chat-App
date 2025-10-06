# App Assets Placeholder

This directory contains all the assets for the Talkative app.

## Directory Structure

- **fonts/** - Custom fonts (Poppins family)
- **images/** - App images and illustrations  
- **icons/** - App icons and UI icons
- **animations/** - Lottie animation files
- **sounds/** - Notification and UI sounds

## Required Assets

### Fonts

- Poppins-Regular.ttf
- Poppins-Medium.ttf (weight: 500)
- Poppins-SemiBold.ttf (weight: 600)  
- Poppins-Bold.ttf (weight: 700)

### Images

- app_logo.png (512x512)
- splash_background.png
- onboarding_1.png
- onboarding_2.png
- onboarding_3.png
- default_avatar.png (200x200)
- empty_chat.png
- empty_status.png

### Icons  

- Various UI icons in SVG format
- Custom app icons for different platforms

### Animations

- splash_animation.json (Lottie)
- loading_animation.json (Lottie)
- success_animation.json (Lottie)
- error_animation.json (Lottie)

### Sounds

- message_sent.mp3
- message_received.mp3
- notification.mp3
- call_ringtone.mp3

## Adding Assets

1. Place your asset files in the appropriate directories
2. Update pubspec.yaml if needed
3. Use AssetImage or similar widgets to load assets

```dart
// Example usage
AssetImage('assets/images/app_logo.png')
```
