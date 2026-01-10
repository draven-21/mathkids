# MathKids Design System Documentation

## Overview
This design system provides a comprehensive guide for building a modern, cheerful, and engaging educational app for young learners. The system emphasizes solid colors, layering, transparency, soft shapes, and subtle motion to create an approachable yet polished user experience.

---

## Design Philosophy

### Core Principles
1. **Solid Colors Over Gradients** - Use vibrant, flat colors for clarity and modern aesthetics
2. **Layering & Depth** - Create visual hierarchy through shadows, elevation, and transparency
3. **Soft, Friendly Shapes** - Round corners and circular elements for approachability
4. **Clear Visual Hierarchy** - Guide users naturally through content with size, weight, and spacing
5. **Subtle Motion** - Enhance engagement with purposeful animations
6. **Accessibility First** - Ensure readability, contrast, and touch-friendly interactions

### Target Audience
- **Primary:** Children aged 6-12
- **Secondary:** Parents and educators monitoring progress
- **Key Considerations:** 
  - Large touch targets (minimum 44pt)
  - High contrast for readability
  - Cheerful, encouraging visual language
  - No overwhelming complexity

---

## Color System

### Primary Colors

#### Light Theme
```dart
Primary (Trust Blue):    #4A90E2  // Main brand color, buttons, active states
Secondary (Energetic Orange): #F39C12  // Accents, achievements, warmth
Success (Clear Green):   #27AE60  // Correct answers, progress, growth
Warning (Attention Red): #E74C3C  // Errors, alerts, streaks
Accent (Playful Purple): #9B59B6  // Special features, variations
```

#### Surface Colors
```dart
Background:              #FAFBFC  // Main app background (soft off-white)
Surface:                 #FFFFFF  // Cards, panels, elevated surfaces
Surface Variant:         #F5F7FA  // Subtle background variations
```

#### Text Colors
```dart
Text Primary:            #2C3E50  // Main content text (dark blue-gray)
Text Secondary:          #7F8C8D  // Supporting text, labels (muted gray)
Text Disabled:           #BDC3C7  // Inactive/disabled text
```

#### Border & Divider Colors
```dart
Border:                  #E1E8ED  // Subtle borders, dividers
Outline:                 #D1D8DD  // Input fields, card outlines
```

### Color Usage Guidelines

#### Primary Blue (#4A90E2)
- **Usage:** Main action buttons, navigation, primary interactive elements
- **Variants:**
  - 12% opacity: Subtle backgrounds for icon containers
  - 15% opacity: Hover/focus states
  - 30% opacity: Shadow colors
- **Accessibility:** AAA contrast on white backgrounds

#### Secondary Orange (#F39C12)
- **Usage:** Secondary actions, achievements, badges, leaderboard accents
- **Psychology:** Energy, enthusiasm, achievement
- **Pairs with:** Primary blue, success green

#### Success Green (#27AE60)
- **Usage:** Correct answers, progress indicators, completion states
- **Psychology:** Growth, success, positive reinforcement
- **Animation:** Pair with celebration effects

#### Warning Red (#E74C3C)
- **Usage:** Incorrect answers, alerts, streak indicators (positive context)
- **Psychology:** Attention, importance, warmth (fire/streak context)
- **Careful use:** Don't overuse to avoid negative feelings

#### Accent Purple (#9B59B6)
- **Usage:** Special modes, creative features, alternative actions
- **Psychology:** Creativity, imagination, playfulness

---

## Typography

### Font Families
- **Primary:** System default (San Francisco on iOS, Roboto on Android)
- **Weight Range:** 400 (Regular), 600 (SemiBold), 700 (Bold), 800 (ExtraBold), 900 (Black)

### Type Scale

#### Headlines
```dart
Headline Large:   32sp / Weight 900 / Line Height 1.2
Headline Medium:  28sp / Weight 800 / Line Height 1.2
Headline Small:   24sp / Weight 800 / Line Height 1.3
```
**Usage:** Page titles, major section headers, celebration messages

#### Titles
```dart
Title Large:      22sp / Weight 700 / Line Height 1.3
Title Medium:     18sp / Weight 700 / Line Height 1.4
Title Small:      16sp / Weight 700 / Line Height 1.4
```
**Usage:** Card titles, dialog headers, section labels

#### Body Text
```dart
Body Large:       16sp / Weight 600 / Line Height 1.5
Body Medium:      14sp / Weight 500 / Line Height 1.5
Body Small:       12sp / Weight 500 / Line Height 1.5
```
**Usage:** Main content, descriptions, instructions

#### Labels
```dart
Label Large:      14sp / Weight 700 / Letter Spacing 0.1
Label Medium:     12sp / Weight 700 / Letter Spacing 0.5
Label Small:      10sp / Weight 700 / Letter Spacing 0.5
```
**Usage:** Button text, badges, small identifiers

### Typography Guidelines
- **Minimum Size:** 10sp for any readable text
- **Maximum Line Length:** 60-70 characters for body text
- **Paragraph Spacing:** 1.5-2x font size
- **Letter Spacing:** Use sparingly, mainly for uppercase labels

---

## Spacing System

### Base Unit: 8pt Grid
All spacing follows an 8-point grid system for consistency.

```dart
Spacing Scale:
XXS:  4pt  (0.5h / 1w)   // Tight grouping within components
XS:   8pt  (1h / 2w)     // Small gaps between related items
S:    12pt (1.5h / 3w)   // Standard component padding
M:    16pt (2h / 4w)     // Default card padding, section spacing
L:    24pt (3h / 6w)     // Major section separation
XL:   32pt (4h / 8w)     // Screen edge padding, large gaps
XXL:  48pt (6h / 12w)    // Significant visual breaks
```

### Component-Specific Spacing

#### Cards
```dart
Padding:         4w horizontal, 2-3h vertical
Margin:          1-2h between cards
Border Radius:   3-4w (16-24pt equivalent)
```

#### Buttons
```dart
Padding:         4w horizontal, 1.5-2h vertical
Min Height:      44pt (touch target)
Border Radius:   2-3w
Icon Spacing:    2-3w from text
```

#### Lists
```dart
Item Height:     Minimum 60pt (7.5h)
Item Padding:    4w horizontal, 2h vertical
Gap:             2-2.5h between items
```

---

## Components

### 1. Modern Card (ModernCard)

#### Variants
- **Standard Card:** Basic elevated surface with shadow
- **Glassmorphism Card:** Semi-transparent with backdrop blur effect
- **Neumorphism Card:** Soft shadows for depth without elevation

#### Specifications
```dart
Background:      Surface color (#FFFFFF)
Border Radius:   16-24pt
Shadow:          0 4pt 16pt rgba(0,0,0,0.08)
Padding:         4w default
Border:          Optional, 1.5-2pt for emphasis
```

#### Usage
- Content containers
- Action cards
- Information panels
- Interactive elements

#### States
- **Default:** Standard elevation (4pt offset)
- **Hover:** Slight scale (1.02) + increased shadow
- **Pressed:** Reduced scale (0.98) + decreased shadow
- **Disabled:** 50% opacity + no shadow

### 2. Floating Action Card (FloatingActionCard)

#### Structure
```
┌─────────────────────────────────────┐
│ [Icon] Title            [Arrow]     │
│        Subtitle                     │
│        [Badge] (optional)           │
└─────────────────────────────────────┘
```

#### Specifications
```dart
Icon Size:       14w x 14w
Icon Radius:     3.5w
Icon Shadow:     0 4pt 12pt rgba(color, 0.4)
Title:           TitleMedium, Weight 700
Subtitle:        BodyMedium
Badge:           LabelSmall with colored background
Elevation:       6pt
```

#### Color Mapping
- Primary actions: Primary blue
- Secondary actions: Secondary orange
- Success actions: Success green
- Creative modes: Accent purple

### 3. Stat Card (StatCard)

#### Layout
```
┌────────────┐
│   [Icon]   │
│            │
│   Value    │
│   Label    │
└────────────┘
```

#### Specifications
```dart
Icon Container:  12w x 12w circle
Icon Color:      White on accent background
Value:           HeadlineSmall, Weight 900
Label:           BodySmall, Weight 600
Min Width:       Equal thirds in row layout
Elevation:       3pt
```

---

## Animated Math Background

### Purpose
Provides subtle, engaging background pattern without distracting from content.

### Specifications
```dart
Symbol Set:      +, −, ×, ÷, =, √, π, ∞, %, ∑, ∫, ≈, ≠, ≤, ≥, ², ³, ½, ¼, ¾
Symbol Count:    20-25 per screen
Opacity:         0.04-0.08 (very subtle)
Size Range:      20-60pt
Speed:           0.6-1.0 (slow drift)
Angle:           -30° to -15° (slanted upward)
Animation:       30s full cycle, continuous loop
```

### Usage Guidelines
- Use on main backgrounds (not over complex content)
- Match symbol color to page theme (usually primary color)
- Keep opacity low (4-8%) for subtlety
- Slower speed for reading-heavy screens

### Implementation
```dart
AnimatedMathBackground(
  symbolColor: theme.colorScheme.primary,
  opacity: 0.05,
  symbolCount: 22,
  animationSpeed: 0.7,
)
```

---

## Shadows & Elevation

### Shadow System
Shadows create depth and visual hierarchy without gradients.

#### Levels
```dart
Level 1 (Subtle):
  offset: (0, 2pt)
  blur: 8pt
  opacity: 0.04
  usage: Subtle cards, dividers

Level 2 (Default):
  offset: (0, 4pt)
  blur: 16pt
  opacity: 0.06
  usage: Standard cards, panels

Level 3 (Raised):
  offset: (0, 6pt)
  blur: 20pt
  opacity: 0.08
  usage: Action cards, highlighted items

Level 4 (Floating):
  offset: (0, 10pt)
  blur: 30pt
  opacity: 0.10
  usage: Modals, overlays, popovers
```

### Icon Container Shadows
```dart
Color-specific glow:
  blur: 8-12pt
  opacity: 0.3-0.4 of icon color
  offset: (0, 3-4pt)
```

---

## Glassmorphism Effects

### When to Use
- Modal overlays
- Header sections on colored backgrounds
- Feature highlights
- Premium/special content areas

### Specifications
```dart
Background:      Base color at 10-20% opacity
Backdrop Blur:   Light blur effect (ColorFilter)
Border:          White at 20% opacity, 1.5pt
Shadow:          Subtle glow matching background
```

### Implementation Example
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
)
```

---

## Neumorphism Effects

### When to Use
- Interactive buttons with tactile feel
- Toggle switches
- Slider controls
- Minimal, calm UI sections

### Specifications
```dart
Light Shadow:
  color: White at 70% opacity
  offset: (-6, -6)
  blur: 12pt

Dark Shadow:
  color: Black at 15% opacity
  offset: (6, 6)
  blur: 12pt

Background:    Match surface color exactly
Border Radius: 12-20pt for smooth effect
```

---

## Animations & Motion

### Animation Principles
1. **Purposeful:** Every animation serves a function
2. **Quick:** Keep durations under 300ms for UI feedback
3. **Smooth:** Use easing curves (easeInOut, easeOut)
4. **Subtle:** Don't distract from content

### Standard Durations
```dart
Instant:       0ms       // State changes, color swaps
Fast:          150ms     // Button presses, toggles
Default:       250ms     // Cards, panels, transitions
Slow:          400ms     // Page transitions, reveals
Very Slow:     800ms     // Scroll animations, special effects
```

### Easing Curves
```dart
Buttons:       Curves.easeOut
Cards:         Curves.easeInOut
Page Exits:    Curves.easeIn
Page Enters:   Curves.easeOut
Bounces:       Curves.elasticOut
```

### Animation Patterns

#### Button Press
```dart
onTapDown:  Scale 0.95, Duration 100ms
onTapUp:    Scale 1.0, Duration 150ms
```

#### Card Entry
```dart
Opacity:    0 → 1, Duration 300ms, Curve easeOut
Transform:  translateY(20) → 0, Duration 300ms
```

#### Celebration (Correct Answer)
```dart
Scale:      1.0 → 1.2 → 1.0, Duration 600ms
Rotation:   0 → 5° → -5° → 0, Duration 600ms
Opacity:    Confetti fade in/out
```

#### Loading Spinner
```dart
Rotation:   Continuous 360°, Duration 1000ms
Color:      Primary brand color
Size:       24-32pt standard
```

---

## Layout Patterns

### Screen Structure
```
┌─────────────────────────────┐
│         Header              │ SafeArea + Padding
├─────────────────────────────┤
│                             │
│      Scrollable Content     │ Background + Padding
│                             │
│                             │
├─────────────────────────────┤
│   Bottom Bar / Stats        │ Optional fixed bottom
└─────────────────────────────┘
```

### Header Pattern
```dart
Height:          Auto (SafeArea + 2-3h padding)
Background:      Surface color with subtle shadow
Content:         Icon (left) + Title (center) + Action (right)
Padding:         5w horizontal, 2.5h vertical
```

### Content Padding
```dart
Horizontal:      5w (screen edges)
Vertical:        2h (top/bottom)
Card Spacing:    2-3h between cards
Section Gaps:    4-6h between major sections
```

### Grid Layouts
```dart
2-Column:        Gap 3w, Padding 5w
3-Column:        Gap 2w, Padding 4w (tablets)
Full Width:      Max width 600pt on tablets
```

---

## Leaderboard Design

### Reference Layout Structure
The leaderboard follows a modern card-based layout inspired by competitive gaming interfaces.

#### Top Section (Podium)
```
Background:      Primary color (#4A90E2)
Border Radius:   0 / 0 / 8w / 8w (rounded bottom corners)
Shadow:          0 10pt 25pt rgba(primary, 0.3)
Padding:         4w horizontal, 3-4h vertical

Banner:
  Background:    White at 15% opacity
  Border:        White at 30% opacity, 2pt
  Radius:        8w
  Text:          "LEADERBOARD" uppercase, 18sp, Weight 900, White
  Spacing:       Above player circles

Layout:          Horizontal row (2nd, 1st, 3rd)
Alignment:       Bottom-aligned circles, 1st place taller

Each Player:
  Rank Badge:    Circular, 8-10w diameter
                 Background: White (2nd/3rd) or Secondary (1st)
                 Text: "#1", "#2", "#3" with primary color
  
  Avatar:        Layered circles (22-28w diameter)
                 Outer ring: Decorative border (2pt)
                 Middle ring: White with colored border (3-4pt)
                 Inner circle: Colored background + emoji
                 Shadow: Subtle drop shadow
  
  Name Badge:    White rounded rectangle (2w radius)
                 Text: Player name, Weight 700
                 Shadow: 0 2pt 8pt rgba(0,0,0,0.1)
  
  Points:        Large white text (18-22sp, Weight 900)
                 Shadow: Drop shadow for legibility
  
  Decoration:    Trophy icon for 1st place
                 Medal icons for 2nd/3rd place
```

#### Ranking List (4th+)
```
Layout:          Vertical list, full width
Padding:         4w horizontal
Spacing:         2.5h between cards

Each Card:
  Background:    Surface color (white)
                 Current user: Primary at 8% opacity
  Border:        Transparent default
                 Current user: Primary 2.5pt border
  Radius:        4w
  Shadow:        0 4-6pt 15-20pt rgba(0,0,0,0.06)
                 Current user: Enhanced shadow with primary tint
  Padding:       4w horizontal, 2h vertical

Card Layout:     Horizontal row
  
  [Rank Badge] [Avatar] [Name + "YOU"] [Points Badge]
  
  Rank Badge:    12w circle, Primary background
                 Text: "#4", Weight 900, White, 13sp
                 Shadow: 0 3pt 8pt rgba(primary, 0.3)
  
  Avatar:        Layered circles (12.5-14w)
                 Outer ring: Color at 30% opacity
                 Inner: Full color with emoji
                 Shadow: Subtle
  
  Name:          Weight 700, 14sp
                 "YOU" badge: Primary background at 15%
                              Border at 30%, 1pt
                              Uppercase, 9sp, Weight 800
  
  Points:        Vertical layout
                 Number: 16sp, Weight 900, Primary color
                 Label: "pts", 9sp, Primary at 70%
                 Container: Primary at 12% background
                           Primary at 20% border, 1.5pt
                           Radius: 3w
```

#### Bottom Stats Panel
```
Position:        Fixed bottom or after list
Background:      Surface with shadow
Margin:          4w all sides
Padding:         4w
Radius:          4w
Shadow:          0 -4pt 20pt rgba(0,0,0,0.08)

Layout:          Three equal columns

Each Stat:
  Icon:          12w circle, Accent color background
                 Shadow: 0 3pt 8pt rgba(color, 0.3)
                 White icon, 6w size
  
  Value:         20sp, Weight 900, OnSurface color
  Label:         10sp, Weight 600, OnSurfaceVariant
```

---

## Interaction States

### Button States
```dart
Default:
  Background:   Accent color
  Shadow:       Level 2
  Scale:        1.0

Hover (Desktop):
  Background:   Accent color (no change)
  Shadow:       Level 3
  Scale:        1.02

Pressed:
  Background:   Accent color at 90%
  Shadow:       Level 1
  Scale:        0.98

Disabled:
  Background:   OnSurfaceVariant at 12%
  Text:         OnSurface at 38%
  Shadow:       None
```

### Card States
```dart
Default:       Shadow Level 2, Scale 1.0
Current User:  Border + enhanced shadow
Hover:         Shadow Level 3, slight lift
Pressed:       Shadow Level 1, scale 0.99
```

---

## Accessibility Guidelines

### Contrast Ratios
- **Normal Text:** Minimum 4.5:1 (AA standard)
- **Large Text:** Minimum 3:1 (18pt+ or 14pt+ bold)
- **Interactive Elements:** Minimum 3:1 against background

### Touch Targets
- **Minimum Size:** 44pt x 44pt
- **Recommended:** 48pt x 48pt
- **Spacing:** Minimum 8pt between targets

### Text Legibility
- **Body Text:** 14-16sp minimum
- **Line Height:** 1.5x for body text
- **Line Length:** Maximum 70 characters

### Motion
- **Respect Reduce Motion:** Disable animations if system preference set
- **No Strobing:** Avoid flashing elements >3 times per second
- **Pause Controls:** Provide controls for continuous animations

---

## Responsive Breakpoints

### Mobile (Default)
- **Width:** < 600pt
- **Padding:** 5w (approx 20pt)
- **Columns:** 1 main column
- **Font Scale:** 1.0x

### Tablet
- **Width:** 600-900pt
- **Padding:** 8w (approx 64pt)
- **Columns:** 2 columns for cards
- **Font Scale:** 1.1x
- **Max Content Width:** 600pt centered

### Desktop (Future)
- **Width:** > 900pt
- **Padding:** 10w
- **Columns:** 3 columns for stats, 2 for cards
- **Font Scale:** 1.2x
- **Max Content Width:** 900pt centered

---

## Implementation Notes

### Using Sizer Package
All dimensions use the Sizer package for responsive sizing:
- **w:** Width percentage (1w = 1% of screen width)
- **h:** Height percentage (1h = 1% of screen height)
- **sp:** Scalable pixels for text

### Theme Access
```dart
final theme = Theme.of(context);

// Colors
theme.colorScheme.primary
theme.colorScheme.secondary
theme.colorScheme.surface
theme.colorScheme.onSurface

// Text Styles
theme.textTheme.headlineSmall
theme.textTheme.titleMedium
theme.textTheme.bodyLarge
```

### Common Patterns
```dart
// Modern Card
ModernCard(
  padding: EdgeInsets.all(4.w),
  elevation: 3,
  child: // content
)

// Floating Action Card
FloatingActionCard(
  title: 'Action',
  subtitle: 'Description',
  icon: Icons.icon_name,
  accentColor: color,
  badge: 'Optional badge',
  onTap: () {},
)

// Stat Card
StatCard(
  label: 'Label',
  value: '123',
  icon: Icons.icon,
  accentColor: color,
)
```

---

## Best Practices

### DO ✅
- Use consistent spacing from the 8pt grid
- Apply shadows for depth, not borders
- Keep colors vibrant and solid
- Round all corners (3-4w minimum)
- Provide visual feedback for all interactions
- Test on multiple screen sizes
- Ensure 44pt minimum touch targets
- Use animations purposefully
- Keep math symbols subtle in background
- Maintain high contrast for text

### DON'T ❌
- Use gradients for backgrounds (solid colors only)
- Over-animate or create motion sickness
- Use small text under 10sp
- Create touch targets smaller than 44pt
- Overwhelm with too many colors
- Use harsh borders (use shadows instead)
- Forget loading states
- Ignore accessibility
- Make background patterns too prominent
- Use low contrast text combinations

---

## Testing Checklist

### Visual Testing
- [ ] All cards have proper shadows
- [ ] Borders are rounded consistently
- [ ] Colors match design tokens
- [ ] Text is legible at all sizes
- [ ] Background animations don't distract
- [ ] Spacing follows 8pt grid

### Interaction Testing
- [ ] All buttons provide visual feedback
- [ ] Touch targets are 44pt minimum
- [ ] Animations are smooth (60fps)
- [ ] Loading states are clear
- [ ] Disabled states are obvious

### Responsive Testing
- [ ] Layouts work on small phones (320pt width)
- [ ] Layouts work on large phones (428pt width)
- [ ] Tablets show enhanced layouts
- [ ] No horizontal overflow
- [ ] Text scales appropriately

### Accessibility Testing
- [ ] Contrast ratios meet WCAG AA
- [ ] Screen reader compatible
- [ ] Keyboard navigation works
- [ ] Reduce motion preference respected
- [ ] Touch targets are accessible

---

## Version History

- **v1.0** (Current) - Initial design system with modern components, animated backgrounds, and leaderboard reference layout
- Future updates will include dark theme specifications, advanced animations, and desktop layouts

---

## Resources

### Design Files
- Figma: [Link to design files]
- Asset Library: `/assets` folder

### Code Components
- `ModernCard`: `/lib/widgets/modern_card.dart`
- `AnimatedMathBackground`: `/lib/widgets/animated_math_background.dart`
- `FloatingActionCard`: `/lib/widgets/modern_card.dart`
- `StatCard`: `/lib/widgets/modern_card.dart`

### References
- Material Design 3: https://m3.material.io
- iOS Human Interface Guidelines: https://developer.apple.com/design
- WCAG Accessibility: https://www.w3.org/WAI/WCAG21/quickref

---

*This design system is a living document. Please update as the app evolves and new patterns emerge.*