# Robot Images

This directory contains robot-related images for the R&D Planner application.

## Files Status

⏳ **robot_icon.png** - PNG icon for the robot menu item in the drawer
   - **PLEASE ADD THIS FILE MANUALLY**
   - Should be a square image (recommended: 24x24 or 32x32 pixels)
   - Should be monochrome/black image (color will be adapted to theme)
   - Will be displayed in the drawer menu for the "Robots" section

⏳ **robot_avatar.png** - PNG image for robot avatars in the robots list
   - **PLEASE ADD THIS FILE MANUALLY**
   - Should be a square image (recommended: 64x64 or 128x128 pixels)
   - Can be colorful image (will be displayed in original colors)
   - Should have a transparent background
   - Will be displayed without background circle (transparent overlay)

## Usage

- The PNG icon is used in the drawer menu for the "Robots" section (theme-adaptive colors)
- The PNG image will be used as the avatar for robots in the robots list page (original colors)
- Drawer icon automatically adapts its color to the current theme
- Robot avatar is displayed in original colors without background circles

## Next Steps

1. Add your robot_icon.png file to this directory (for drawer menu)
2. Add your robot_avatar.png file to this directory (for robot avatars)
3. The application will automatically use them (drawer icon with theme-adaptive colors, avatar in original colors)
4. If the PNG files are not found, the app will fall back to default icons/text

## Current Implementation

The code has been updated to:
- Use PNG images for both drawer icons and robot avatars
- Display PNG icons in the drawer menu with theme-adaptive colors
- Use PNG images as robot avatars in original colors without background circles
- Apply ColorFilter only to drawer icon to adapt colors to current theme
- Handle missing images gracefully with fallback options
