# Logo Assets

## Adding Your Custom Logo

To replace the built-in logo with a custom image:

1. Add your logo image file to this directory (`assets/images/`)
2. Recommended formats: PNG with transparent background
3. Recommended sizes:
   - `logo.png` - 512x512px (main logo)
   - `logo_small.png` - 256x256px (small version)

4. Update the `app_logo.dart` widget to use your image:
   ```dart
   Image.asset(
     'assets/images/logo.png',
     width: size,
     height: size,
   )
   ```

## Current Implementation

The app currently uses a programmatic logo with:
- Teal gradient background
- Medical services icon (representing dental care)
- Plus sign overlay
- "Dentify" text with tagline

This provides a professional appearance without requiring external image files.
