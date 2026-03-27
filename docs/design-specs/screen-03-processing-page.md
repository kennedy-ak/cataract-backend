# Screen 03: Processing Page (Loading)
## i-SpEye Cataract Detection App

---

### Overview
The loading screen shown while the AI analyzes the uploaded eye image. Displays animated loader with status text. Handles timeout/connection errors gracefully.

---

### Layout Structure

```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│              ┌─────────┐                 │
│            ╱             ╲               │
│           │   ▓▓▓▓▓▓▓   │               │
│           │  ▓▓    ▓▓   │   ← Animated   │
│           │   ▓▓▓▓▓▓▓   │   Spinner     │
│            ╲             ╱               │
│              └─────────┘                 │
│                                          │
│         Analyzing Image                  │
│                                          │
│    Please wait while we examine         │
│         the image...                    │
│                                          │
│                                          │
│                                          │
└─────────────────────────────────────────┘
```

### Error State Layout

```
┌─────────────────────────────────────────┐
│                                          │
│         ┌───────────────────┐            │
│         │       ⚠️          │            │
│         │   (circle icon)   │            │
│         └───────────────────┘            │
│                                          │
│         Connection Error                 │
│                                          │
│    Something went wrong. Please check   │
│    your internet connection or try      │
│         again later.                    │
│                                          │
│     ┌──────────────────────────┐         │
│     │    🔄     Try Again       │         │
│     └──────────────────────────┘         │
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

SafeArea: true
```

#### 2. Loading Animation Container
```
Position: Centered
Alignment: center

Container (outer glow):
  Background: #ffffff
  Shape: BoxShape.circle
  Shadow:
    - Color: rgba(255, 255, 255, 0.3)
    - Blur: 40px
    - Spread Radius: 20px (creates glow effect)
  Padding: 32px all sides

Animated Widget: SpinKitFadingFour
  Color: #087ee1 (primary blue)
  Size: 60px
  Animation Type: Fading four-way spinner

Alternative loaders (if needed):
  - SpinKitDoubleBounce
  - SpinKitWave
  - SpinKitPulse
```

#### 3. Loading Text
```
Position: Below loader
Margin Top: 40px

Text: "Analyzing Image"
  Font Size: 24px
  Font Weight: 700
  Color: #ffffff
  Font Family: InriaSans
  Alignment: center
```

#### 4. Subtitle Text
```
Position: Below loading text
Margin Top: 12px

Text: "Please wait while we examine the image..."
  Font Size: 14px
  Color: rgba(255, 255, 255, 0.7)
  Font Family: InriaSans
  Alignment: center
  TextAlign: center
```

---

### Error State Specifications

#### Error Card Container
```
Position: Centered
Margin: 24px all sides

Container:
  Background: #ffffff
  Border Radius: 24px
  Padding: 24px all sides
  Shadow:
    - Color: rgba(0, 0, 0, 0.15)
    - Blur: 30px
    - Offset: (0, 15px)

MainAxisSize: min (shrinks to content)
```

#### Error Icon Container
```
Position: Top of error card
Margin Bottom: 24px

Container:
  Background: #ff6b6b (warning/coral)
  Shape: BoxShape.circle
  Padding: 16px all sides

Icon: Icons.error_outline_rounded
  Color: #ffffff
  Size: 48px
```

#### Error Title
```
Position: Below icon
Margin Bottom: 12px

Text: "Connection Error"
  Font Size: 22px
  Font Weight: 700
  Color: #1a1a2e
  Font Family: InriaSans
  Alignment: center
```

#### Error Message
```
Position: Below title
Margin Bottom: 24px

Text: "Something went wrong. Please check your internet connection or try again later."
  Font Size: 14px
  Color: #4a4a68
  Line Height: 1.5
  Font Family: InriaSans
  TextAlign: center
```

#### Try Again Button
```
Position: Bottom of error card
Width: double.infinity (within card)
Height: 52px

ElevatedButton:
  Background Color: #087ee1
  Foreground Color: #ffffff
  Shape: RoundedRectangleBorder
    Border Radius: 14px

  Icon: Icons.refresh_rounded

  Label: "Try Again"
    Font Weight: 700
    Font Family: InriaSans

  Action: Reset error state, restart processing
```

---

### State Management

#### State Variable: _hasError
```
Type: bool
Initial Value: false

When true:
  - Shows error card UI
  - Hides loading animation

When false:
  - Shows loading animation
  - Hides error card

Triggered by:
  - 30-second timeout (Future.delayed)
  - Exception catch in processing
```

#### Processing Flow
```
1. initState() calls _startProcessing()
2. _startProcessing() sets up 30-second timeout
3. If timeout expires: _hasError = true
4. If error occurs: _hasError = true
5. On "Try Again": _hasError = false, restart _startProcessing()
```

---

### Timeout Configuration

```
Current: 30 seconds (Duration(seconds: 30))

Recommendations:
  - Typical analysis: 2-5 seconds
  - Poor network: 10-15 seconds
  - 30-second timeout is generous

If timeout is too frequent, consider:
  - Increasing to 45 or 60 seconds
  - Adding network retry logic
  - Showing countdown timer
```

---

### Animation Specifications

```
Loader Animation (SpinKitFadingFour):
  - Type: Four fading squares rotating
  - Duration: ~1200ms per cycle
  - Curve: easeInOut
  - Repeats: infinite

Container Glow:
  - Pulse effect (if implemented)
  - Duration: 2000ms
  - Scale: 1.0 to 1.05
  - Opacity: 0.3 to 0.5

Page Transitions:
  - Entry: MaterialPageRoute slide-in
  - Exit: Replaced by ResultsPage
```

---

### Design Tokens Used

```
Colors:
  - gradient-start: #087ee1
  - gradient-end: #05e8ba
  - bg-white: #ffffff
  - text-primary: #1a1a2e
  - text-secondary: #4a4a68
  - text-on-primary: #ffffff
  - text-on-primary-dim: rgba(255,255,255,0.7)
  - warning: #ff6b6b

Spacing:
  - space-6: 24px
  - space-10: 40px
  - space-12: 48px

Border Radius:
  - radius-xl: 24px
  - radius-md: 14px

Shadows:
  - shadow-lg: 0 15px 30px rgba(0,0,0,0.15)
  - shadow-glow: 0 0 40px rgba(255,255,255,0.3)
```

---

### Accessibility Notes

```
Loading State:
  - Clear "Analyzing" message indicates activity
  - Subtitle explains what's happening
  - White text on gradient has good contrast

Error State:
  - High contrast error icon (red circle, white icon)
  - Clear error message
  - Actionable "Try Again" button
  - Error card provides visual focus

Consider adding:
  - Screen reader announcements for loading state
  - Progress indication if API supports it
```

---

### Enhancement Opportunities

```
1. Progress Indicator:
   - If API provides progress updates
   - Circular progress bar with percentage

2. Countdown Timer:
   - Show remaining time before timeout
   - Reduce user anxiety

3. Animated Tips:
   - Rotate helpful tips during loading
   - "Did you know..." facts about eye health

4. Skeleton Screens:
   - Preview of results layout
   - Creates anticipation

5. Cancel Button:
   - Allow users to cancel long-running requests
   - Return to previous screen
```
