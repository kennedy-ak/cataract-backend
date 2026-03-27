# Screen 02: Upload Page (Image Review)
## i-SpEye Cataract Detection App

---

### Overview
The image preview screen where users review their captured/selected eye image before analysis. Users can re-take, re-select, or proceed to analyze the image.

---

### Layout Structure

```
┌─────────────────────────────────────────┐
│  ← Review Image         (AppBar)        │
├─────────────────────────────────────────┤
│                                          │
│         ┌───────────────────┐            │
│         │                   │            │
│         │                   │            │
│         │   Image Preview   │            │
│         │    (300x300)      │            │
│         │                   │            │
│         │                   │            │
│         └───────────────────┘            │
│                                          │
│    ┌──────────┐  ┌──────────┐           │
│    │  📷      │  │  🖼️      │           │
│    │ Re-take  │  │ Re-select│           │
│    └──────────┘  └──────────┘           │
│                                          │
│     ┌──────────────────────────┐         │
│     │  📊    Analyze Image      │         │
│     └──────────────────────────┘         │
│                                          │
│     💡 Ensure the eye is clearly visible │
│                                          │
└─────────────────────────────────────────┘
```

---

### Component Specifications

#### 1. AppBar
```
Title: "Review Image"
  Font Size: Platform default (varies)
  Font Weight: 700
  Font Family: InriaSans
  Alignment: center

Background: transparent
Elevation: 0
Leading: Back button (system default)
```

#### 2. Background Container
```
Type: Full-screen Container
Decoration: LinearGradient
  - Start: Alignment.topLeft
  - End: Alignment.bottomRight
  - Colors:
    * Stop 0%: #087ee1
    * Stop 100%: #05e8ba

SafeArea: true
```

#### 3. Image Preview Card
```
Position: Centered horizontally
Margin Top: Auto (centered vertically with spacing)

Container:
  Background: #ffffff
  Border Radius: 24px
  Shadow:
    - Color: rgba(0, 0, 0, 0.15)
    - Blur: 30px
    - Offset: (0, 15px)

ClipRRect:
  Border Radius: 24px (matches container)

Image Display:
  Dimensions: 300 x 300px
  Fit: BoxFit.cover

  Platform Detection:
    - Web (kIsWeb): Image.network(_imagePath)
    - Mobile/Desktop: Image.file(File(_imagePath))

  Border: None (uses ClipRRect for rounded corners)
```

#### 4. Action Buttons Row
```
Position: Below image preview
Margin Top: 48px

Layout: Row
  MainAxisAlignment: center
  Children spacing: 16px

--- Left Button: Re-take ---

Expanded (flex: 1)
Container:
  Height: 56px
  Background: #ffffff
  Border Radius: 16px
  Shadow:
    - Color: rgba(0, 0, 0, 0.1)
    - Blur: 15px
    - Offset: (0, 5px)

ElevatedButton:
  Style: ElevatedButton.styleFrom
  Background Color: transparent
  Foreground Color: #087ee1
  Elevation: 0
  Shadow Color: transparent
  Shape: RoundedRectangleBorder
    Border Radius: 16px

  Icon: Icons.camera_alt_rounded
    Size: 22px

  Label: "Re-take"
    Font Weight: 700
    Font Family: InriaSans

  Action: Opens camera (ImageSource.camera)
  Updates _imagePath with new selection

--- Right Button: Re-select ---

Expanded (flex: 1)
Container: Same as Re-take button

ElevatedButton:
  Same style as Re-take

  Icon: Icons.photo_library_rounded
    Size: 22px

  Label: "Re-select"
    Font Weight: 700
    Font Family: InriaSans

  Action: Opens gallery (ImageSource.gallery)
  Updates _imagePath with new selection
```

#### 5. Analyze Button (Primary Action)
```
Position: Below action buttons row
Margin Top: 20px
Margin Bottom: 16px

SizedBox:
  Width: double.infinity (full width minus padding)
  Height: 64px

Container (wrapper):
  Decoration: LinearGradient
    Colors: [#ffffff, #f0f7ff]
  Border Radius: 20px
  Shadow:
    - Color: rgba(0, 0, 0, 0.15)
    - Blur: 20px
    - Offset: (0, 10px)

ElevatedButton:
  Style: ElevatedButton.styleFrom
  Background Color: transparent
  Foreground Color: #087ee1
  Elevation: 0
  Shadow Color: transparent
  Shape: RoundedRectangleBorder
    Border Radius: 20px

  Icon: Icons.analytics_rounded
    Size: 28px

  Label: "Analyze Image"
    Font Size: 18px
    Font Weight: 700
    Font Family: InriaSans

  Action: _uploadImage(context)
    - Navigates to ProcessingPage
    - Sends image to backend API
    - On success: Navigates to ResultsPage
    - On failure: Shows SnackBar with error
```

#### 6. Tip Container
```
Position: Below Analyze button
Margin Top: 0 (attached with 16px from above)

Container:
  Padding: 12px horizontal, 20px vertical
  Background: rgba(255, 255, 255, 0.2)
  Border Radius: 12px

Row:
  MainAxisSize: min

  Icon: Icons.lightbulb_outline_rounded
    Color: #ffffff
    Size: 20px

  Spacing: 8px

  Expanded Text: "Ensure the eye is clearly visible"
    Font Size: 13px
    Color: #ffffff
    Font Family: InriaSans
    Max Lines: unlimited (wrapped)
```

---

### Spacing Summary

| Element | Spacing |
|---------|---------|
| Screen Padding | 24px all sides |
| AppBar Bottom | Auto (system) |
| Preview to Action Buttons | 48px |
| Action Buttons to Analyze | 20px |
| Analyze to Tip | 0 (attached) |
| Button Row Internal Gap | 16px |

---

### Interactions

| Element | Action | Result |
|---------|--------|--------|
| Re-take | Opens camera | Replaces current image |
| Re-select | Opens gallery | Replaces current image |
| Analyze Image | API call | → ProcessingPage → ResultsPage |
| AppBar Back | Navigate back | → Main Page |

---

### State Management

#### Image State
```
State Variable: _imagePath (String)
  - Initialized from widget.imagePath
  - Updated when user re-takes or re-selects
  - Passed to ResultsPage after analysis
```

#### Loading State
```
When Analyze is pressed:
  1. Navigate to ProcessingPage immediately
  2. API call begins in background
  3. On response: Replace ProcessingPage with ResultsPage
  4. On error: Pop ProcessingPage, show error SnackBar
```

---

### Error Handling

#### Error SnackBar
```
Trigger: API call failure
Content: "Error processing image: {error details}"
Background Color: #ff6b6b (coral/red)
Duration: 5 seconds
Behavior: SnackBarBehavior.floating
Margin: 16px all sides
```

---

### Platform-Specific Behavior

```
Web (kIsWeb = true):
  - Image displayed via Image.network
  - File path treated as URL

Mobile (Android/iOS):
  - Image displayed via Image.file
  - File path from device storage

Desktop (Windows/macOS/Linux):
  - Image displayed via Image.file
  - Same as mobile behavior
```

---

### Design Tokens Used

```
Colors:
  - gradient-start: #087ee1
  - gradient-end: #05e8ba
  - bg-white: #ffffff
  - bg-subtle: #f0f7ff
  - bg-overlay-light: rgba(255,255,255,0.2)
  - text-on-primary: #ffffff

Spacing:
  - space-4: 16px
  - space-5: 20px
  - space-6: 24px
  - space-12: 48px

Border Radius:
  - radius-xl: 24px
  - radius-lg: 20px
  - radius-md: 16px
  - radius-sm: 12px

Shadows:
  - shadow-lg: 0 15px 30px rgba(0,0,0,0.15)
  - shadow-sm: 0 5px 15px rgba(0,0,0,0.1)
```

---

### Animation Specifications

```
Image Transition:
  - When new image selected: Fade in (200ms)
  - State update triggers setState()

Navigation:
  - MaterialPageRoute (horizontal slide)
  - Duration: 300ms
  - Curve: Curves.easeInOut
```

---

### Accessibility Notes

- All buttons 56px tall (meets accessibility standards)
- Tip text has good contrast (white on semi-transparent overlay)
- Image has sufficient size for review (300x300px)
- Clear action hierarchy: Re-take/Re-select secondary, Analyze primary
