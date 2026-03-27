# Screen 04: Results Page (Diagnosis)
## i-SpEye Cataract Detection App

---

### Overview
The final screen displaying the AI analysis results. Shows diagnosis (cataract detected/normal), confidence level, medical recommendation, disclaimer, and options to download report or start a new scan.

---

### Layout Structure

```
┌─────────────────────────────────────────┐
│                                          │
│         ┌───────────────────┐            │
│         │       ✓ / ⚠️      │            │
│         │   (circular icon) │            │
│         └───────────────────┘            │
│                                          │
│      Cataract Detected /                 │
│       No Cataract Detected               │
│                                          │
│      ┌─────────────────────┐             │
│      │ 📊 94.5% Confidence  │             │
│      └─────────────────────┘             │
│                                          │
│         ────────────────────             │
│                                          │
│            🏥 Recommendation             │
│                                          │
│      Please consult an eye specialist    │
│      for a comprehensive examination    │
│                                          │
│         ────────────────────             │
│                                          │
│      ┌──────────────────────┐           │
│      │ ℹ️ This is a screening│           │
│      │ tool and should not  │           │
│      │ replace professional  │           │
│      │ medical advice.       │           │
│      └──────────────────────┘           │
│                                          │
│     ┌──────────────────────────┐         │
│     │  ⬇️   Download Report      │         │
│     └──────────────────────────┘         │
│                                          │
│     ┌──────────────────────────┐         │
│     │  🔄      New Scan          │         │
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

#### 2. Main Results Card
```
Position: Centered
Padding: 24px all sides

Container:
  Background: #ffffff
  Border Radius: 28px
  Padding: 32px all sides
  Shadow:
    - Color: rgba(0, 0, 0, 0.15)
    - Blur: 40px
    - Offset: (0, 20px)
```

#### 3. Status Icon Container
```
Position: Top of card
Margin Bottom: 24px

Container:
  Background: (conditional)
    - Cataract: #ffe0e0 (warning-bg)
    - Normal: #d4edda (success-bg)
  Shape: BoxShape.circle
  Padding: 24px all sides

Image:
  Source: AssetImage
    - Cataract: 'images/warning.png'
    - Normal: 'images/check.png'
  Width: 80px
  Height: 80px
```

#### 4. Diagnosis Text
```
Position: Below icon
Margin Bottom: 16px
Alignment: center

Text: (conditional)
  - Cataract: "Cataract Detected"
  - Normal: "No Cataract Detected"

Style:
  Font Size: 26px
  Font Weight: 700
  Font Family: InriaSans
  Color: (conditional)
    - Cataract: #ff6b6b (warning)
    - Normal: #51cf66 (success)
  TextAlign: center
```

#### 5. Confidence Badge
```
Position: Below diagnosis text
Margin Bottom: 32px
Alignment: center

Container:
  Padding: 10px horizontal, 20px vertical
  Background: (conditional)
    - Cataract: #ffe0e0 (warning-bg)
    - Normal: #d4edda (success-bg)
  Border Radius: 20px (pill shape)

Row:
  MainAxisSize: min

  Icon: Icons.analytics_rounded
    Size: 18px
    Color: (conditional)
      - Cataract: #ff6b6b
      - Normal: #51cf66

  Spacing: 8px

  Text: "{confidence}% Confidence"
    Font Size: 14px
    Font Weight: 700
    Font Family: InriaSans
    Color: (conditional)
      - Cataract: #ff6b6b
      - Normal: #51cf66

Confidence Calculation:
  - If prediction < 0.7: confidence = (1 - prediction) * 100
  - If prediction >= 0.7: confidence = prediction * 100
  - Display: toStringAsFixed(1) + "%"
```

#### 6. First Divider
```
Position: Below confidence badge
Margin Bottom: 24px

Container:
  Height: 1px
  Color: #e0e0e0
```

#### 7. Recommendation Section
```
Position: Below first divider
Margin Bottom: 24px
Alignment: center

Column:
  Icon: Icons.medical_information_rounded
    Size: 32px
    Color: #087ee1
  Margin Bottom: 12px

  Text: "Recommendation"
    Font Size: 16px
    Font Weight: 700
    Color: #1a1a2e
    Font Family: InriaSans
  Margin Bottom: 8px

  Padding: 16px horizontal

  Text: "Please consult an eye specialist for a comprehensive examination"
    Font Size: 14px
    Color: #4a4a68
    Line Height: 1.5
    Font Family: InriaSans
    TextAlign: center
```

#### 8. Second Divider
```
Position: Below recommendation
Margin Bottom: 20px

Container:
  Height: 1px
  Color: #e0e0e0
```

#### 9. Disclaimer Card
```
Position: Above action buttons
Margin Bottom: 24px (inside card)

Container:
  Padding: 16px all sides
  Background: #fff3cd (warning yellow)
  Border Radius: 12px

Row:
  Icon: Icons.info_outline_rounded
    Size: 20px
    Color: #856404

  Spacing: 12px

  Expanded Text: "This is a screening tool and should not replace professional medical advice."
    Font Size: 12px
    Color: #856404
    Font Family: InriaSans
```

---

### Action Buttons Section

#### 10. Download Report Button
```
Position: Below results card
Margin Bottom: 16px

SizedBox:
  Width: double.infinity
  Height: 56px

ElevatedButton:
  Style: ElevatedButton.styleFrom
  Background Color: #ffffff
  Foreground Color: #087ee1
  Elevation: 0
  Shadow Color: transparent
  Shape: RoundedRectangleBorder
    Border Radius: 16px

  Icon: Icons.download_rounded
    Size: 24px

  Label: "Download Report"
    Font Size: 16px
    Font Weight: 700
    Font Family: InriaSans

  Action: _createAndDownloadReport(context)
    - Generates PDF report
    - Saves to device
    - Opens PDF viewer
```

#### 11. New Scan Button (Outlined)
```
Position: Below download button
Margin Bottom: 20px

SizedBox:
  Width: double.infinity
  Height: 56px

OutlinedButton:
  Style: OutlinedButton.styleFrom
  Foreground Color: #ffffff
  Side: BorderSide
    Color: #ffffff
    Width: 2px
  Shape: RoundedRectangleBorder
    Border Radius: 16px

  Icon: Icons.refresh_rounded
    Size: 24px

  Label: "New Scan"
    Font Size: 16px
    Font Weight: 700
    Font Family: InriaSans

  Action: Navigator.popUntil(context, (route) => route.isFirst)
    - Returns to Main Page
    - Clears navigation stack
```

---

### Conditional Logic

#### Diagnosis Determination
```
Input: prediction (double from API, 0.0 to 1.0)

Threshold: 0.7

If prediction < 0.7:
  - className: "Cataract"
  - isCataractDetected: true
  - resultColor: #ff6b6b
  - resultBgColor: #ffe0e0
  - Icon: warning.png

If prediction >= 0.7:
  - className: "Normal"
  - isCataractDetected: false
  - resultColor: #51cf66
  - resultBgColor: #d4edda
  - Icon: check.png
```

#### Confidence Display
```
Raw: prediction value (0.0 - 1.0)

Display Calculation:
  If cataract detected:
    confidence = (1 - prediction) * 100
  Else:
    confidence = prediction * 100

Format: confidence.toStringAsFixed(1) + "%"
Example: "94.5%", "87.3%"
```

---

### PDF Report Specifications

#### Report Content
```
Document: pw.Document

Page Layout:
  Title: "i-SpEye Diagnosis Report"
    Style: 28px, bold

  Divider

  Date: Current date (YYYY-MM-DD format)
  Time: Current time (HH:MM:SS format)

  Diagnosis: (conditional)
    - "Cataract Detected"
    - "No Cataract Detected"
    Style: 22px, bold

  Analysis Time: "{analysisTime} seconds"
    Style: 16px

  Recommendation (bold):
    - Bullet: "This app is a screening tool and has limitations in detecting cataracts. A comprehensive eye exam by a qualified ophthalmologist is necessary for a more accurate diagnosis."

  Technical Details (bold):
    - "Certainty of diagnosis: {confidence}%"
    - "Model accuracy: 96%"
```

#### File Naming
```
Pattern: diagnosis_report_{date}_{time}.pdf

Example: diagnosis_report_2026-02-17_14_32_08.pdf

Format:
  - date: DateTime.now().toLocal().toString().split(' ')[0]
  - time: HH_MM_SS (zero-padded)
```

#### Download Behavior by Platform

**Android:**
```
Path: /storage/emulated/0/Download/
Permission: manageExternalStorage
Post-download: OpenFilex.open()
Feedback: SnackBar with path
```

**iOS:**
```
Path: getApplicationDocumentsDirectory()
Post-download: OpenFilex.open()
Feedback: SnackBar
```

**Web:**
```
Method: HTML blob download
Browser default download location
Filename: timestamped
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
  - success: #51cf66
  - success-bg: #d4edda
  - warning: #ff6b6b
  - warning-bg: #ffe0e0
  - disclaimer-bg: #fff3cd
  - disclaimer-text: #856404
  - divider: #e0e0e0

Spacing:
  - space-4: 16px
  - space-5: 20px
  - space-6: 24px
  - space-8: 32px

Border Radius:
  - radius-2xl: 28px
  - radius-xl: 24px
  - radius-md: 16px
  - radius-sm: 12px

Shadows:
  - shadow-xl: 0 20px 40px rgba(0,0,0,0.15)
```

---

### Spacing Summary

| Element | Spacing |
|---------|---------|
| Screen Padding | 24px all sides |
| Card Padding | 32px all sides |
| Icon to Diagnosis | 24px |
| Diagnosis to Badge | 16px |
| Badge to Divider | 32px |
| Divider to Section | 24px |
| Card to Download Button | 24px |
| Download to New Scan | 16px |
| New Scan to Bottom | 20px |

---

### Accessibility Notes

```
Visual Hierarchy:
  - Large, clear status icon (80px)
  - Bold, colored diagnosis text (26px)
  - Pill-shaped confidence badge
  - Clear section separators

Color Coding:
  - Green = Normal (positive association)
  - Red = Cataract (alert, needs attention)
  - Yellow disclaimer = caution

Touch Targets:
  - All buttons 56px tall
  - Clear labels with icons

Screen Reader:
  - Diagnosis clearly announced
  - Confidence percentage read aloud
  - Button purposes are clear
```

---

### Error Handling

#### Download Success SnackBar
```
Content: "Report downloaded successfully!" (or with path on Android)
Behavior: SnackBarBehavior.floating
Margin: 16px all sides
Duration: 4 seconds (or until dismissed)
```

#### Download Error SnackBar
```
Content: "Failed to download report: {error details}"
Behavior: SnackBarBehavior.floating
Margin: 16px all sides
Duration: 5 seconds
```

#### Permission Error (Android)
```
If permanently denied:
  - Opens app settings via openAppSettings()
  - Message: "Storage permission permanently denied. Please enable it in settings."
```
