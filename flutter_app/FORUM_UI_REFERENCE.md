# Community Forum - UI Reference Guide

## Screen Layouts

### 1. Community Forum Screen (`community_forum_screen.dart`)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ≡  Community Forum          🔄      ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃  All | Shillong | Khanapara | Juwai  ┃  ← Tabs
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                       ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ 👤 Username    [VIP]     2h ago │ ┃
┃  │                    [Shillong FR] │ ┃
┃  │                                  │ ┃
┃  │  [03] [17] [42] [68] [91]       │ ┃  ← Number Chips
┃  │                                  │ ┃
┃  │  📈 Confidence: [85%]            │ ┃  ← Confidence Badge
┃  │                                  │ ┃
┃  │  This is my prediction based on │ ┃  ← Description
┃  │  yesterday's pattern analysis... │ ┃
┃  │                                  │ ┃
┃  │  ♥ 24                            │ ┃  ← Likes
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ ... more posts ...               │ ┃
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                  [+ New Post]  ← FAB
```

### 2. Create Post Screen (`create_forum_post_screen.dart`)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  ←  Create Post                      ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                       ┃
┃  Select Game                          ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ Shillong Teer            ▼      │ ┃  ← Dropdown
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┃  Prediction Type                      ┃
┃  ┌────────────┐   ┌────────────────┐ ┃
┃  │     FR     │   │      SR        │ ┃  ← Toggle Buttons
┃  │ First Round│   │ Second Round   │ ┃
┃  └────────────┘   └────────────────┘ ┃
┃                                       ┃
┃  Select Numbers (up to 10)   3/10     ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ [00][01][02][03][04][05][06]... │ ┃  ← Number Grid
┃  │ [10][11][12][13][14][15][16]... │ ┃  ← 10x10 Grid
┃  │ [20][21][22][23][24][25][26]... │ ┃
┃  │ ... (continues to 99)           │ ┃
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┃  Confidence Level           85%       ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ Low  ●━━━━━━━○━━━━━━━  High     │ ┃  ← Slider
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┃  Description (Optional)               ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │ Share your insights...          │ ┃  ← Text Area
┃  │                                 │ ┃
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┃  ┌─────────────────────────────────┐ ┃
┃  │    📤 Post to Community         │ ┃  ← Submit Button
┃  └─────────────────────────────────┘ ┃
┃                                       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## Component Details

### Post Card Components

#### 1. User Header
```
┌────────────────────────────────────┐
│ 👤  Username         [VIP]   2h ago│
│                       [Game FR/SR] │
└────────────────────────────────────┘
├─ Avatar: Circular, gradient bg
├─ Username: Bold, 16px
├─ VIP Badge: Purple gradient (if premium)
├─ Time: "2 hours ago" format
└─ Game Badge: Color coded (FR=Blue, SR=Green)
```

#### 2. Number Chips
```
[03] [17] [42] [68] [91]

Style:
- Gradient background (Indigo)
- White text, bold
- Rounded corners (8px)
- Shadow effect
- Padding: 8px horizontal
```

#### 3. Confidence Badge
```
📈 Confidence: [85%]

Colors:
- 90%+   → Green   (#10B981)
- 80-89% → Blue    (#3B82F6)
- 70-79% → Orange  (#F59E0B)
- <70%   → Grey    (#9CA3AF)
```

#### 4. Like Button
```
♥ 24

States:
- Unliked: Outlined heart, grey
- Liked: Filled heart, red (#EF4444)
- Animated transition
```

### Number Picker Grid

```
00  01  02  03  04  05  06  07  08  09
10  11  12  13  14  15  16  17  18  19
20  21  22  23  24  25  26  27  28  29
30  31  32  33  34  35  36  37  38  39
40  41  42  43  44  45  46  47  48  49
50  51  52  53  54  55  56  57  58  59
60  61  62  63  64  65  66  67  68  69
70  71  72  73  74  75  76  77  78  79
80  81  82  83  84  85  86  87  88  89
90  91  92  93  94  95  96  97  98  99

- Unselected: Light grey background
- Selected: Gradient background with shadow
- Max 10 selections
```

## Color Reference

### Primary Colors
```dart
Primary:        #6366F1  ████  (Indigo-500)
Primary Dark:   #4F46E5  ████  (Indigo-600)
Primary Light:  #818CF8  ████  (Indigo-400)
Secondary:      #10B981  ████  (Emerald-500)
Accent:         #F59E0B  ████  (Amber-500)
```

### Game Type Colors
```dart
FR Color:       #3B82F6  ████  (Blue-500)
SR Color:       #10B981  ████  (Emerald-500)
```

### Status Colors
```dart
Success:        #10B981  ████  (Green)
Error:          #EF4444  ████  (Red)
Warning:        #F59E0B  ████  (Orange)
Info:           #3B82F6  ████  (Blue)
```

### Background Colors
```dart
Background:     #F9FAFB  ████  (Grey-50)
Surface:        #FFFFFF  ████  (White)
Surface Variant:#F3F4F6  ████  (Grey-100)
```

### Text Colors
```dart
Text Primary:   #111827  ████  (Grey-900)
Text Secondary: #6B7280  ████  (Grey-500)
Text Tertiary:  #9CA3AF  ████  (Grey-400)
```

## Gradients

### Primary Gradient
```dart
colors: [#6366F1, #8B5CF6]
Top-left to Bottom-right
Used for: Buttons, Number chips
```

### Premium Gradient
```dart
colors: [#9333EA, #C026D3]
Top-left to Bottom-right
Used for: VIP badges, Premium features
```

### Success Gradient
```dart
colors: [#10B981, #059669]
Top-left to Bottom-right
Used for: Success buttons
```

## Icon Reference

### Screen Icons
- **Forum**: `Icons.forum` (menu item)
- **Add Post**: `Icons.add` (FAB)
- **Refresh**: `Icons.refresh` (app bar)
- **Back**: `Icons.arrow_back` (navigation)

### Feature Icons
- **Premium**: `Icons.workspace_premium`
- **Like**: `Icons.favorite` / `Icons.favorite_border`
- **Confidence**: `Icons.trending_up`
- **Dropdown**: `Icons.arrow_drop_down`
- **Error**: `Icons.error_outline`
- **Empty**: `Icons.forum_outlined`

## Typography Scale

### Headings
```dart
H1: 28px, Bold, -0.5 letter-spacing
H2: 22px, Semi-bold
H3: 18px, Semi-bold
```

### Body Text
```dart
Body Large:  16px, Regular
Body Medium: 14px, Regular
Body Small:  12px, Regular
Caption:     11px, Regular
```

### Button Text
```dart
15px, Semi-bold, 0.3 letter-spacing
```

## Spacing System

```dart
space4:  4px   ■
space8:  8px   ■■
space12: 12px  ■■■
space16: 16px  ■■■■
space20: 20px  ■■■■■
space24: 24px  ■■■■■■
space32: 32px  ■■■■■■■■
space48: 48px  ■■■■■■■■■■■■
```

## Border Radius

```dart
radiusSmall:  8px   ╭─╮
radiusMedium: 12px  ╭──╮
radiusLarge:  16px  ╭───╮
radiusXLarge: 24px  ╭────╮
```

## Shadows

### Card Shadow
```dart
Shadow 1: rgba(0,0,0,0.04) blur:8 offset:(0,2)
Shadow 2: rgba(0,0,0,0.02) blur:4 offset:(0,1)
```

### Elevated Shadow
```dart
rgba(0,0,0,0.1) blur:24 offset:(0,8)
```

### Button Shadow (Color-based)
```dart
color.withOpacity(0.25) blur:12 offset:(0,4)
```

## Responsive Breakpoints

```dart
size.width * 0.04   → Padding/Margins
size.width * 0.035  → Body text
size.width * 0.04   → Subtitle text
size.width * 0.045  → Heading text
size.width * 0.05   → Icon sizes
size.width * 0.1    → Large icons/avatars
```

### Grid Columns
```dart
width > 600  → 3 columns
width ≤ 600  → 2 columns
```

## Loading States

### Shimmer Placeholder
```
┌─────────────────────────────────┐
│ ◯ ▬▬▬▬▬▬▬                      │
│   ▬▬▬▬▬                         │
│                                 │
│ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬         │
└─────────────────────────────────┘
```

### Button Loading
```
┌─────────────────────┐
│         ○○○         │  ← Circular indicator
└─────────────────────┘
```

## Empty State

```
        📋

    No Posts Yet

Be the first to share
your predictions with
    the community!

  [Create Post]
```

## Error State

```
        ⚠️

 Failed to load posts

 Network error occurred

     [Retry]
```

---

## Quick Reference Table

| Component | Size | Color | Border Radius |
|-----------|------|-------|---------------|
| Post Card | Full width | White | 12px |
| Number Chip | 40px min | Gradient | 8px |
| Avatar | 10% width | Gradient | Circle |
| FAB | Standard | Primary | 16px |
| Button | 13% height | Gradient | 12px |
| Tab Bar | Full width | Primary | 0px |
| Dropdown | Full width | White | 12px |
| Text Area | Full width, 4 lines | White | 12px |
| Number Grid | 10x10 | Varies | 8px |

---

**Font Family**: Poppins (Google Fonts)
**Design System**: Material Design 3
**Theme**: Light Mode
**Minimum Flutter**: 3.0.0
