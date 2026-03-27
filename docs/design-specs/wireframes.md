# i-SpEye Visual Wireframes
## ASCII & Layout Reference

---

### Screen 1: Main Page (Home)

```
╔════════════════════════════════════════════════════════════╗
║  Status Bar (System - Transparent)                         ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║                   ┌─────────────────┐                      ║
║                   │  ┌───────────┐  │   ← White Card      ║
║                   │  │           │  │     20px radius     ║
║                   │  │  i-SpEye  │  │     180x90px        ║
║                   │  │   Logo    │  │     Shadow: md      ║
║                   │  │           │  │                      ║
║                   │  └───────────┘  │                      ║
║                   └─────────────────┘                      ║
║                                                            ║
║                     ↓ 40px spacing                         ║
║                                                            ║
║            ┌─────────────────────────────┐                ║
║            │  ┌───┐ For accurate results:│  ← White Card  ║
║            │  │ ℹ️ │                      │    24px radius │
║            │  └───┘                      │    Shadow: md  ║
║            │                             │                ║
║            │  • Take picture indoors...  │                ║
║            │  • Remove glasses or...     │                ║
║            │  • Hold camera at eye...    │                ║
║            │  • Use camera's flash...    │                ║
║            │  • Keep camera steady...    │                ║
║            │  • Open your eyes wide      │                ║
║            └─────────────────────────────┘                ║
║                                                            ║
║                     ↓ 40px spacing                         ║
║                                                            ║
║       ╔═══════════════════════════════════════╗           ║
║       ║  📷              Take Photo           ║ ← 56px tall║
║       ║           (Full Width Button)         ║    White bg║
║       ╚═══════════════════════════════════════╝    16px rad║
║                                                            ║
║                     ↓ 16px spacing                         ║
║                                                            ║
║       ╔═══════════════════════════════════════╗           ║
║       ║  🖼️           Upload Photo            ║ ← Same     ║
║       ║           (Full Width Button)         ║    style   ║
║       ╚═══════════════════════════════════════╝           ║
║                                                            ║
║                     ↓ 20px spacing                         ║
║                                                            ║
║           AI-Powered Cataract Detection                   ║
║                  (12px, white 70%)                         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

Background: Linear Gradient
  Top-Left:  #087ee1 (Blue)
  Bottom-Right: #05e8ba (Teal)

Padding: 24px horizontal
```

---

### Screen 2: Upload Page (Image Preview)

```
╔════════════════════════════════════════════════════════════╗
║  ← Review Image                            (AppBar)       ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║                     ↓ Auto spacing                         ║
║                                                            ║
║              ╔═══════════════════════╗                     ║
║              ║                       ║                     ║
║              ║                       ║                     ║
║              ║                       ║                     ║
║              ║     IMAGE PREVIEW     ║  ← 300x300px       ║
║              ║       (300x300)       ║     24px radius    ║
║              ║                       ║     Shadow: lg     ║
║              ║                       ║                     ║
║              ║                       ║                     ║
║              ║                       ║                     ║
║              ╚═══════════════════════╝                     ║
║                                                            ║
║                     ↓ 48px spacing                         ║
║                                                            ║
║    ╔═══════════════╗  ╔═══════════════╗                   ║
║    ║   📷         ║  ║   🖼️         ║  ← 56px tall      ║
║    ║   Re-take    ║  ║  Re-select    ║     Each 50%      ║
║    ╚═══════════════╝  ╚═══════════════╝     16px gap      ║
║                                                            ║
║                     ↓ 20px spacing                         ║
║                                                            ║
║       ╔═══════════════════════════════════════╗           ║
║       ║  📊          Analyze Image            ║ ← 64px tall║
║       ║         (Prominent Action)            ║    Gradient ║
║       ╚═══════════════════════════════════════╝    button  ║
║                                                            ║
║                     ↓ 0px (attached)                      ║
║                                                            ║
║        ┌─────────────────────────────────┐               ║
║        │ 💡 Ensure the eye is clearly    │  ← Tip bubble  ║
║        │    visible                       ║    20% overlay ║
║        └─────────────────────────────────┘               ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

Background: Same gradient (blue → teal)
Padding: 24px all sides
```

---

### Screen 3: Processing Page (Loading)

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║                                                            ║
║                                                            ║
║                   ┌─────────┐                              ║
║                 ╱     ●     ╲                             ║
║                │    ●   ●    │  ← Animated Spinner        ║
║                │      ●      │     SpinKitFadingFour      ║
║                 ╲           ╱      60px, blue            ║
║                  └─────────┘        White glow            ║
║                                                            ║
║                     ↓ 40px                                 ║
║                                                            ║
║                   Analyzing Image                         ║
║                      (24px bold)                          ║
║                                                            ║
║                     ↓ 12px                                 ║
║                                                            ║
║            Please wait while we examine                   ║
║                 the image...                              ║
║                   (14px regular)                          ║
║                                                            ║
║                                                            ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

ERROR STATE (if timeout or failure):

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              ┌─────────────────────┐                       ║
║              │       ┌─────┐       │                       ║
║              │       │ ⚠️  │       │  ← Red circle icon    ║
║              │       └─────┘       │     48px             ║
║              │                     │                       ║
║              │   Connection Error  │  ← 22px bold         ║
║              │                     │                       ║
║              │  Something went...  │  ← 14px regular      ║
║              │                     │                       ║
║              │  ┌───────────────┐  │                       ║
║              │  │   🔄 Try Again │  │  ← Blue button      ║
║              │  └───────────────┘  │     52px tall        ║
║              └─────────────────────┘                       ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

---

### Screen 4: Results Page (Diagnosis)

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║              ┌─────────────────────────┐                   ║
║              │                         │                   ║
║              │      ┌─────────┐        │                   ║
║              │      │   ✓     │        │  ← Green check    ║
║              │      │  or ⚠️  │        │    or red warn    ║
║              │      └─────────┘        │    80px icon      ║
║              │                         │                   ║
║              │   Cataract Detected     │  ← 26px bold      ║
║              │    or No Cataract       │    colored        ║
║              │                         │                   ║
║              │  ┌─────────────────┐    │                   ║
║              │  │ 📊 94.5% Conf.  │    │  ← Pill badge     ║
║              │  └─────────────────┘    │                   ║
║              │         ────────        │                   ║
║              │                         │                   ║
║              │       🏥 Recom.         │                   ║
║              │   Please consult...     │                   ║
║              │                         │                   ║
║              │         ────────        │                   ║
║              │  ┌─────────────────┐    │                   ║
║              │  │ℹ️ Screening tool│    │  ← Yellow warning ║
║              │  └─────────────────┘    │                   ║
║              └─────────────────────────┘                   ║
║                                                            ║
║                     ↓ 24px                                 ║
║                                                            ║
║       ╔═══════════════════════════════════════╗           ║
║       ║  ⬇️            Download Report        ║ ← 56px tall║
║       ╚═══════════════════════════════════════╝    White   ║
║                                                            ║
║                     ↓ 16px                                 ║
║                                                            ║
║       ╔═══════════════════════════════════════╗           ║
║       ║  🔄               New Scan            ║ ← Outlined ║
║       ╚═══════════════════════════════════════╝    White  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

BACKGROUND: Same blue→teal gradient
MAIN CARD: White, 28px radius, 32px padding

COLOR VARIATIONS:

CATARACT DETECTED:
  Icon: warning.png
  Color: #ff6b6b (coral/red)
  Background: #ffe0e0 (light red)
  Badge: Same colors

NORMAL (No Cataract):
  Icon: check.png
  Color: #51cf66 (green)
  Background: #d4edda (light green)
  Badge: Same colors
```

---

### Component Library Reference

#### Buttons
```
┌────────────────────────────────────┐
│  📷  Take Photo                    │  Primary: White bg
└────────────────────────────────────┘  Blue text
                                        56px tall
┌────────────────────────────────────┐  16px radius
│  📷  Take Photo                    │  Shadow: md
└────────────────────────────────────┘

╔══════════════════════════════════════╗
║  📊  Analyze Image                  ║  Prominent: Gradient
╚══════════════════════════════════════╝  64px tall
                                          20px radius

┌────────────────────────────────────┐
│  🔄  New Scan                       │  Outlined: White border
└────────────────────────────────────┘  White text
                                          56px tall
```

#### Cards
```
┌──────────────────────────────┐
│  ℹ️  For accurate results:    │  Instructions
│                               │  24px radius
│  • Bullet point one           │  White bg
│  • Bullet point two           │  Shadow: md
│  • Bullet point three         │
└──────────────────────────────┘

┌──────────────────────────────┐
│                               │  Results Card
│  [Large Icon]                 │  28px radius
│                               │  32px padding
│  Diagnosis Text               │  Shadow: xl
│                               │
│  [Confidence Badge]           │
│                               │
│  ─────────                    │
│                               │
│  Recommendation               │
│                               │
│  ─────────                    │
│                               │
│  [Disclaimer]                 │
└──────────────────────────────┘
```

#### Badges
```
┌──────────────────┐
│ 📊 94.5% Conf.   │  Pill: 20px radius
└──────────────────┘  Semantic bg color

┌────────────────────────┐
│ 💡 Ensure eye visible  │  Tip: 12px radius
└────────────────────────┘  20% white overlay

┌────────────────────────────┐
│ ℹ️ This is a screening tool│  Warning: 12px radius
└────────────────────────────┘  Yellow (#fff3cd) bg
```

---

### Color Palette Reference

```
GRADIENT (Background):
  #087ee1 ──────────────► #05e8ba
   (Blue)                (Teal)

PRIMARY (Actions):
  Button BG:    #ffffff
  Button Text:  #087ee1
  Icon:         #087ee1

SUCCESS (Normal Result):
  Text/Badge:   #51cf66
  Background:   #d4edda
  Icon:         check.png

WARNING (Cataract Result):
  Text/Badge:   #ff6b6b
  Background:   #ffe0e0
  Icon:         warning.png

TEXT:
  Headings:     #1a1a2e
  Body:         #4a4a68
  On Gradient:  #ffffff
  Subtle:       rgba(255,255,255,0.7)

DIVIDER: #e0e0e0
```

---

### Spacing Reference

```
┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
│8 │12│16│20│24│32│40│48│  │  │  │  │
└──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
2  3  4  5  6  8  10 12

COMMON PATTERNS:
  Screen padding:     24px (6)
  Button spacing:     16px (4)
  Section spacing:    40px (10)
  Card padding:       24-32px (6-8)
  Icon-text gap:      8-12px (2-3)
```

---

### Border Radius Reference

```
12px ┌────┐  Small cards, badges
16px ┌──────┐ Buttons, inputs
20px ┌────────┐ Primary buttons
24px ┌──────────┐ Standard cards
28px ┌────────────┐ Large cards
     ╱═══════════╲ 50%  Circular elements
```

---

### Shadow Reference

```
Level SM: 0 5px 15px rgba(0,0,0,0.1)
           Small elements

Level MD: 0 10px 20px rgba(0,0,0,0.1)
           Buttons, standard cards

Level LG: 0 15px 30px rgba(0,0,0,0.15)
           Elevated cards, image preview

Level XL: 0 20px 40px rgba(0,0,0,0.15)
           Main cards, results

Glow:    0 0 40px rgba(255,255,255,0.3)
         Loading animation
```
