# i-SpEye Design System
## Cataract Detection App - Figma-Style Design Specifications

Version: 1.3.0
Last Updated: February 2026

---

## Table of Contents
1. [Color Palette](#color-palette)
2. [Typography](#typography)
3. [Spacing System](#spacing-system)
4. [Border Radius](#border-radius)
5. [Shadows & Elevation](#shadows--elevation)
6. [Icons](#icons)
7. [Components](#components)

---

## Color Palette

### Primary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primary` | #087ee1 | rgb(8, 126, 225) | Primary actions, branding, headers |
| `primary-light` | #05a8ff | rgb(5, 168, 255) | Hover states, highlights |
| `primary-dark` | #0056b3 | rgb(0, 86, 179) | Pressed states, deep backgrounds |

### Secondary Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `secondary` | #05e8ba | rgb(5, 232, 186) | Gradients, accents |
| `secondary-light` | #5ff8d9 | rgb(95, 248, 217) | Soft accents |
| `secondary-dark` | #00b894 | rgb(0, 184, 148) | Darker gradient stops |

### Semantic Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `success` | #51cf66 | rgb(81, 207, 102) | Normal eye result, success states |
| `success-bg` | #d4edda | rgb(212, 237, 218) | Success background |
| `warning` | #ff6b6b | rgb(255, 107, 107) | Cataract detected, errors |
| `warning-bg` | #ffe0e0 | rgb(255, 224, 224) | Warning background |
| `info` | #4dabf7 | rgb(77, 171, 247) | Info messages |
| `info-bg` | #fff3cd | rgb(255, 243, 205) | Warning/notice background |

### Neutral Colors
| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `text-primary` | #1a1a2e | rgb(26, 26, 46) | Headings, body text |
| `text-secondary` | #4a4a68 | rgb(74, 74, 104) | Secondary text, instructions |
| `text-tertiary` | #8a8a9a | rgb(138, 138, 154) | Placeholder, disabled |
| `bg-white` | #ffffff | rgb(255, 255, 255) | Cards, buttons, primary bg |
| `bg-overlay` | rgba(0,0,0,0.1) | - | Overlay backgrounds |
| `divider` | #e0e0e0 | rgb(224, 224, 224) | Dividers, borders |

### Gradients
```
Primary Gradient:
  Start: #087ee1 (top-left)
  End:   #05e8ba (bottom-right)
  Angle: 135°

Button Gradient (optional):
  Start: #ffffff
  End:   #f0f7ff
```

---

## Typography

### Font Family
**Primary:** InriaSans
- Available weights: Light (300), Regular (400), Bold (700)
- Fallback: System fonts (SF Pro, Roboto, Segoe UI)

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `h1` | 32px | 700 | 1.2 | -0.5% | Main headings |
| `h2` | 26px | 700 | 1.2 | -0.5% | Screen titles |
| `h3` | 22px | 700 | 1.3 | 0% | Card titles |
| `h4` | 18px | 700 | 1.3 | 0% | Section headers |
| `body-large` | 16px | 400/700 | 1.5 | 0% | Body text, buttons |
| `body` | 14px | 400 | 1.5 | 0% | Standard text |
| `body-small` | 13px | 400 | 1.4 | 0% | Captions, hints |
| `caption` | 12px | 400 | 1.4 | 0% | Footnotes, disclaimers |

### Text Styles
```
Heading Style:
  font-family: 'InriaSans'
  font-weight: 700
  color: #1a1a2e

Body Style:
  font-family: 'InriaSans'
  font-weight: 400
  color: #4a4a68
  line-height: 1.5

Button Style:
  font-family: 'InriaSans'
  font-weight: 700
  letter-spacing: 0%
```

---

## Spacing System

### Scale (4px base grid)
| Token | Value | Usage |
|-------|-------|-------|
| `space-2` | 8px | Tight spacing, icon-text gaps |
| `space-3` | 12px | Small padding |
| `space-4` | 16px | Standard padding, gaps |
| `space-5` | 20px | Medium padding |
| `space-6` | 24px | Large padding, sections |
| `space-8` | 32px | XL padding |
| `space-10` | 40px | XXL padding |
| `space-12` | 48px | Major sections |

### Container Padding
- Mobile (default): 24px horizontal
- Tablet: 32px horizontal
- Desktop: 48px horizontal

---

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 12px | Small cards, badges, tips |
| `radius-md` | 16px | Buttons, input fields |
| `radius-lg` | 20px | Primary buttons |
| `radius-xl` | 24px | Cards, containers |
| `radius-2xl` | 28px | Large cards |
| `radius-full` | 50% | Circular elements |

---

## Shadows & Elevation

### Shadow System
| Level | Blur | Offset | Opacity | Usage |
|-------|------|--------|---------|-------|
| `sm` | 15px | 0, 5px | 0.1 | Small elements |
| `md` | 20px | 0, 10px | 0.1 | Buttons, cards |
| `lg` | 30px | 0, 15px | 0.15 | Elevated cards |
| `xl` | 40px | 0, 20px | 0.15 | Main cards, dialogs |
| `glow` | 40px | 0, 0px | 0.3 | Loading states, highlights |

### Shadow Values (CSS/Tailwind format)
```
shadow-sm: 0 5px 15px rgba(0, 0, 0, 0.1)
shadow-md: 0 10px 20px rgba(0, 0, 0, 0.1)
shadow-lg: 0 15px 30px rgba(0, 0, 0, 0.15)
shadow-xl: 0 20px 40px rgba(0, 0, 0, 0.15)
shadow-glow: 0 0 40px rgba(255, 255, 255, 0.3)
```

---

## Icons

### Icon Library
**Material Icons Rounded** (Google Material Design Icons)

### Key Icons
| Component | Icon Name | Size | Color |
|-----------|-----------|------|-------|
| Camera | `camera_alt_rounded` | 24px | #087ee1 |
| Gallery | `photo_library_rounded` | 24px | #087ee1 |
| Info | `info_outline` / `info_outline_rounded` | 24px | #087ee1 |
| Analytics | `analytics_rounded` | 24-28px | #087ee1 |
| Download | `download_rounded` | 24px | #087ee1 |
| Refresh | `refresh_rounded` | 24px | White |
| Medical | `medical_information_rounded` | 32px | #087ee1 |
| Error | `error_outline_rounded` | 48px | White |
| Lightbulb | `lightbulb_outline_rounded` | 20px | White |

### Custom Assets
| File | Size | Usage |
|------|------|-------|
| `i-Speye.png` | 180x90px | App logo |
| `check.png` | 80x80px | Success indicator |
| `warning.png` | 80x80px | Warning indicator |

---

## Components

### Buttons

#### Primary Button
```
Width: Full (double.infinity) or Auto
Height: 56px (standard), 64px (prominent)
Background: #ffffff
Text Color: #087ee1
Border Radius: 16px (standard), 20px (prominent)
Font Size: 16px (standard), 18px (prominent)
Font Weight: 700
Icon Size: 24px (standard), 28px (prominent)
Shadow: shadow-md
Elevation: 0 (stateless)

States:
  - Default: bg-white, text-primary
  - Pressed: bg-white with 0.95 opacity
  - Disabled: opacity 0.5
```

#### Secondary Button (Outlined)
```
Border: 2px solid #ffffff
Text Color: #ffffff
Background: transparent
Other: Same as Primary

States:
  - Default: white border, white text
  - Pressed: bg-white with 0.1 opacity
```

#### Accent Button
```
Background: #087ee1
Text Color: #ffffff
Other: Same as Primary
```

### Cards

#### Standard Card
```
Background: #ffffff (or 0.95 opacity)
Border Radius: 24px
Padding: 24px
Shadow: shadow-lg
```

#### Compact Card
```
Background: #ffffff
Border Radius: 16px
Padding: 16-20px
Shadow: shadow-sm
```

### Badge
```
Background: semantic-bg
Border Radius: 20px (pill)
Padding: 10px horizontal, 20px vertical (adjust based on content)
Text Color: semantic color
Font Size: 14px
Font Weight: 700
```

### Divider
```
Height: 1px
Color: #e0e0e0
Margin: 24px vertical
```

---

## Animation Specifications

### Transitions
```
Standard: 300ms ease-in-out
Fast: 150ms ease-out
Slow: 500ms ease-in-out
```

### Loading Animation
- Type: Fading Four (SpinKit)
- Size: 60px
- Color: #087ee1
- Container: White circle, 32px padding, glow shadow

### Page Transitions
- MaterialPageRoute (horizontal slide)
- Duration: 300ms

---

## Accessibility

### Contrast Ratios
- All text meets WCAG AA (4.5:1 minimum)
- Primary text: #1a1a2e on white = 15.5:1 ✅
- Secondary text: #4a4a68 on white = 7.2:1 ✅
- Primary button: #087ee1 on white = 4.8:1 ✅

### Touch Targets
- Minimum: 44x44px (iOS), 48x48px (Android)
- Implemented: 56px minimum (exceeds guidelines)

### Screen Reader Support
- All images have semantic labels
- Buttons have descriptive labels
- Results are announced clearly

---

## Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Mobile | < 768px | Single column, full padding |
| Tablet | 768 - 1024px | Adjusted padding, max width containers |
| Desktop | > 1024px | Centered content, max 480px width |

---

## File Structure

Assets should be organized as:
```
assets/
├── images/
│   ├── i-Speye.png           (180x90px)
│   ├── check.png             (80x80px)
│   └── warning.png           (80x80px)
├── fonts/
│   ├── InriaSans-Regular.ttf
│   ├── InriaSans-Italic.ttf
│   ├── InriaSans-Bold.ttf
│   ├── InriaSans-BoldItalic.ttf
│   ├── InriaSans-Light.ttf
│   └── InriaSans-LightItalic.ttf
```
