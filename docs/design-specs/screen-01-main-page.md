# Screen 01: Main Page (Home)
## i-SpEye Cataract Detection App

---

### Overview
The entry screen of the app. Users see the app logo, photography instructions, and primary actions to capture or upload an eye image.

---

### Layout Structure

```
┌─────────────────────────────────────────┐
│  Status Bar (Safe Area)                  │
├─────────────────────────────────────────┤
│                                          │
│         ┌───────────────────┐            │
│         │                   │            │
│         │    i-SpEye Logo   │            │
│         │                   │            │
│         └───────────────────┘            │
│                                          │
│         ┌───────────────────┐            │
│         │  ℹ️  For accurate  │            │
│         │     results:      │            │
│         │                   │            │
│         │  • Take picture   │            │
│         │    indoors...     │            │
│         │  • Remove glasses │            │
│         │    or contacts    │            │
│         │  • Hold camera    │            │
│         │    at eye level   │            │
│         │  • Use flash if   │            │
│         │    poorly lit     │            │
│         │  • Keep camera    │            │
│         │    steady         │            │
│         │  • Open eyes wide │            │
│         └───────────────────┘            │
│                                          │
│     ┌──────────────────────────┐         │
│     │    📷      Take Photo     │         │
│     └──────────────────────────┘         │
│                                          │
│     ┌──────────────────────────┐         │
│     │   🖼️     Upload Photo     │         │
│     └──────────────────────────┘         │
│                                          │
│      AI-Powered Cataract Detection       │
│                                          │
└─────────────────────────────────────────┘
```

---

### Component Specifications

#### 1. Background Container
```
Type: Full-screen Container
Decoration: LinearGradient
  - Start: Alignment.topLeft
  - End: Alignment.bottomRight
  - Colors:
    * Stop 0%: #087ee1
    * Stop 100%: #05e8ba
SafeArea: true (respect system UI)
```

#### 2. Logo Card
```
Position: Top center
Margin: 0 auto

Container:
  Background: #ffffff
  Border Radius: 20px
  Padding: 20px all sides
  Shadow:
    - Color: rgba(0, 0, 0, 0.1)
    - Blur: 20px
    - Offset: (0, 10px)

Image (i-Speye.png):
  Width: 180px
  Height: 90px
  Fit: BoxFit.contain
```

#### 3. Instructions Card
```
Position: Below logo, vertically centered
Margin Top: 40px (from logo)

Container:
  Background: rgba(255, 255, 255, 0.95)
  Border Radius: 24px
  Padding: 24px all sides
  Shadow:
    - Color: rgba(0, 0, 0, 0.1)
    - Blur: 20px
    - Offset: (0, 10px)

Header Row:
  Icon Container:
    Background: #087ee1
    Border Radius: 12px
    Padding: 10px all sides
    Icon: Icons.info_outline
    Icon Size: 24px
    Icon Color: #ffffff

  Text: "For accurate results:"
    Font Size: 18px
    Font Weight: 700
    Color: #1a1a2e
    Font Family: InriaSans

  Spacing: 12px between icon and text

Bullet List:
  Type: Conventional bullets
  Bullet Color: #087ee1
  Items:
    1. "Take the picture indoors in a well-lit room (preferably by natural light)"
    2. "Remove glasses or contact lenses"
    3. "Hold the rear camera at eye level"
    4. "Use the camera's flash or a bright light if in a poorly lit room"
    5. "Keep the camera steady - the image should not be blurry"
    6. "Open your eyes wide"

  Text Style:
    Font Size: 14px
    Font Weight: 400
    Color: #4a4a68
    Line Height: 1.5
    Font Family: InriaSans

  Item Spacing: 8px vertical
```

#### 4. Action Buttons Section
```
Position: Below instructions card
Margin Top: 40px

--- Primary Button: Take Photo ---

SizedBox:
  Width: double.infinity (full width minus padding)
  Height: 56px

ElevatedButton:
  Style: ElevatedButton.styleFrom
  Background Color: #ffffff
  Foreground Color: #087ee1
  Elevation: 0
  Shadow Color: transparent
  Shape: RoundedRectangleBorder
    Border Radius: 16px

  Icon: Icons.camera_alt_rounded
    Size: 24px

  Label: "Take Photo"
    Font Size: 16px
    Font Weight: 700
    Font Family: InriaSans

--- Secondary Button: Upload Photo ---

SizedBox:
  Width: double.infinity
  Height: 56px
  Margin Top: 16px

ElevatedButton:
  Same style as Take Photo button

  Icon: Icons.photo_library_rounded
    Size: 24px

  Label: "Upload Photo"
    Font Size: 16px
    Font Weight: 700
    Font Family: InriaSans
```

#### 5. Footer Text
```
Position: Bottom of content
Margin Top: 20px

Text: "AI-Powered Cataract Detection"
  Font Size: 12px
  Color: rgba(255, 255, 255, 0.7)
  Font Family: InriaSans
  Alignment: center
```

---

### Spacing Summary

| Element | Spacing |
|---------|---------|
| Screen Padding | 24px horizontal, 20px vertical |
| Logo to Instructions | 40px |
| Instructions to Buttons | 40px |
| Button Spacing | 16px |
| Buttons to Footer | 20px |

---

### Interactions

| Element | Action | Navigation |
|---------|--------|------------|
| Take Photo Button | Opens camera | → UploadPage with camera image |
| Upload Photo Button | Opens gallery | → UploadPage with selected image |

---

### States

#### Button States
```
Default:
  - Background: #ffffff
  - Text: #087ee1
  - Shadow: none

Pressed:
  - Background: #ffffff with 0.95 opacity

Disabled:
  - Opacity: 0.5
```

---

### Accessibility Notes

- All buttons are 56px tall (exceeds 44px minimum)
- Instructions card has high contrast text (#4a4a68 on white)
- Icon + text combo in header for better comprehension
- Bullet points clearly separated for screen readers

---

### Design Tokens Used

```
Colors:
  - gradient-start: #087ee1
  - gradient-end: #05e8ba
  - bg-white: #ffffff
  - text-primary: #1a1a2e
  - text-secondary: #4a4a68
  - text-on-primary: rgba(255,255,255,0.7)

Spacing:
  - space-4: 16px
  - space-5: 20px
  - space-6: 24px
  - space-10: 40px

Border Radius:
  - radius-xl: 24px
  - radius-lg: 20px
  - radius-md: 16px
  - radius-sm: 12px

Shadows:
  - shadow-md: 0 10px 20px rgba(0,0,0,0.1)
```

---

### Responsive Behavior

```
Mobile (< 768px):
  - Full width buttons
  - 24px horizontal padding
  - Logo: 180px width

Tablet (768px+):
  - Max content width: 480px
  - Centered horizontally
  - Same spacing preserved

Desktop (1024px+):
  - Same as tablet
  - Not primary target device
```
