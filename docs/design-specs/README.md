# i-SpEye Design Specifications
## Complete Figma-Style Design Documentation

---

### Quick Navigation

| Document | Description |
|----------|-------------|
| **[Design System](./design-system.md)** | Colors, typography, spacing, shadows, icons, components |
| **[Screen 01: Main Page](./screen-01-main-page.md)** | Home screen with logo, instructions, capture/upload actions |
| **[Screen 02: Upload Page](./screen-02-upload-page.md)** | Image preview with re-take/re-select/analyze options |
| **[Screen 03: Processing Page](./screen-03-processing-page.md)** | Loading animation and error handling |
| **[Screen 04: Results Page](./screen-04-results-page.md)** | Diagnosis display, confidence, report download |

---

### App Overview

**App Name:** i-SpEye
**Version:** 1.3.0
**Purpose:** AI-powered cataract detection from eye images
**Platform:** Flutter (iOS, Android, Web, Desktop)
**Backend:** FastAPI with TensorFlow Lite model

**Key Features:**
- Camera and gallery image capture
- Real-time AI analysis
- PDF report generation
- Cross-platform support

---

### Design Philosophy

The i-SpEye app follows a **medical trust** design philosophy:

1. **Clarity First** - Large, readable text with high contrast
2. **Calm Colors** - Blue-to-teal gradient evokes trust and healthcare
3. **Visual Hierarchy** - Important elements are larger and more prominent
4. **Accessible** - WCAG AA compliant with 56px minimum touch targets
5. **Reassuring** - Clear feedback at every step

---

### Color Palette Summary

```
Primary Gradient: #087ee1 → #05e8ba

Semantic:
  Success (Normal):     #51cf66 on #d4edda
  Warning (Cataract):  #ff6b6b on #ffe0e0
  Info/Notice:         #4dabf7 on #fff3cd

Text:
  Primary:   #1a1a2e
  Secondary: #4a4a68
  On Gradient: #ffffff
```

---

### Typography Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| H1 | 32px | Bold | Main headings |
| H2 | 26px | Bold | Screen titles, diagnosis |
| H3 | 22px | Bold | Card titles |
| H4 | 18px | Bold | Section headers |
| Body Large | 16px | Regular/Bold | Body, buttons |
| Body | 14px | Regular | Instructions |
| Body Small | 13px | Regular | Hints |
| Caption | 12px | Regular | Disclaimers |

**Font Family:** InriaSans

---

### Spacing System (4px grid)

```
2  = 8px   - Tight gaps
3  = 12px  - Small padding
4  = 16px  - Standard padding
5  = 20px  - Medium padding
6  = 24px  - Large padding
8  = 32px  - XL padding
10 = 40px  - XXL padding
12 = 48px  - Major sections
```

---

### Component Summary

#### Buttons
- **Primary:** White bg, blue text, 56px tall, 16-20px radius
- **Secondary:** Outlined, white border, same dimensions
- **Accent:** Blue bg, white text

#### Cards
- **Standard:** White bg, 24px radius, shadow-lg
- **Large:** 28px radius, shadow-xl
- **Small:** 16-20px radius, shadow-sm

#### Icons
- **Library:** Material Icons (Rounded variants)
- **Sizes:** 18-32px depending on context
- **Colors:** Primary blue, semantic colors

---

### Screen Flow

```
┌──────────────┐
│  Main Page   │
│              │  ┌─→ Camera ─────┐
│  [Take Photo]│──┤                ├─→ Upload Page ──→
│  [Upload]    │  └─→ Gallery ────┘                   │
└──────────────┘                                      │
                                                     [Analyze]
                                                          │
                                                          ▼
┌──────────────┐                                   ┌───────────┐
│ Results Page │◄──────────────────────────────────│Processing │
│              │                                   │   Page    │
│[Download][New│                                   └───────────┘
│    Scan]     │
└──────────────┘
     │
     └──► Back to Main
```

---

### Platform Considerations

| Feature | Mobile | Web | Desktop |
|---------|--------|-----|---------|
| Image Source | Camera + Gallery | Upload only | File picker |
| Storage | Downloads folder | Browser download | Documents folder |
| PDF Viewer | System default | Browser tab | System default |
| Permissions | Camera/Storage | None | None |

---

### AI Prompts for UI Generation

Copy these prompts into AI design tools (v0.dev, Framer AI, etc.):

```
PROMPT 1 - Full App:
Create a mobile medical app UI for cataract detection with:
- Blue-to-teal gradient background (#087ee1 to #05e8ba)
- Home screen with logo "i-SpEye", 6 bullet instructions, white card
- Image preview screen (300x300) with re-take/re-select buttons
- Loading screen with spinning animation
- Results screen with circular status icon, diagnosis text, confidence badge, recommendation section
- Style: Material Design 3, rounded cards (24px), InriaSans font
- Success: green (#51cf66), Warning: coral (#ff6b6b)
- All buttons 56px tall for accessibility

PROMPT 2 - iOS Style:
Design an iOS-style medical screening app with:
- Clean, minimal interface with lots of white space
- Large centered logo and clear typography
- Bottom sheet action buttons for camera/gallery
- Circular progress indicator during analysis
- Simple results card with large checkmark or warning icon
- Color: calming blue-teal gradient, medical/trust aesthetic
```

---

### Asset Checklist

```
Required Images:
  ✅ images/i-Speye.png      (180x90px)
  ✅ images/check.png        (80x80px)
  ✅ images/warning.png      (80x80px)

Required Fonts:
  ✅ fonts/InriaSans-Regular.ttf
  ✅ fonts/InriaSans-Italic.ttf
  ✅ fonts/InriaSans-Bold.ttf
  ✅ fonts/InriaSans-BoldItalic.ttf
  ✅ fonts/InriaSans-Light.ttf
  ✅ fonts/InriaSans-LightItalic.ttf
```

---

### Development Handoff

#### Flutter Implementation
All designs are implemented in the following files:
- `lib/main.dart` - Main page
- `lib/upload.dart` - Upload/preview page
- `lib/processing.dart` - Loading screen
- `lib/result.dart` - Results page

#### API Integration
```
Endpoint: POST /predict
Input: MultipartFormData with 'file' field
Output: JSON with 'prediction', 'className', 'confidence', 'inferenceTime'
```

---

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.3.0 | Feb 2026 | Initial design documentation |
| 1.2.x | Earlier | Original app development |

---

### Notes for Designers

1. **Gradient is key** - The blue-to-teal gradient is the brand signature. Use it consistently across all screens.

2. **White cards on gradient** - This creates depth and focus. Always use shadow-lg or greater for separation.

3. **Semantic colors** - Green for "normal" results, coral/red for "cataract detected". This is intuitive for users.

4. **Rounded corners** - 16-24px radius creates a friendly, modern medical app feel.

5. **Typography matters** - InriaSans was chosen for readability. Always use appropriate weights (700 for headings, 400 for body).

---

### Contact & Support

For questions about these design specifications, refer to:
- Project repository: `C:\Users\User2\Desktop\Cataract_Detection_App`
- Design files: `docs/design-specs/`
