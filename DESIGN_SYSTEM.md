# Design System - UI/UX Guidelines

**Framework:** Material Design 3  
**Style:** Clean, Professional, Modern  
**Inspiration:** Slack, Linear, Notion

---

## 🎨 COLOR PALETTE

### Primary Colors (Blue)
```dart
// Professional Blue - Main brand color
static const primary50 = Color(0xFFEFF6FF);   // Lightest
static const primary100 = Color(0xFFDBEAFE);
static const primary200 = Color(0xFFBFDBFE);
static const primary300 = Color(0xFF93C5FD);
static const primary400 = Color(0xFF60A5FA);
static const primary500 = Color(0xFF3B82F6);  // Base
static const primary600 = Color(0xFF2563EB);  // Primary
static const primary700 = Color(0xFF1D4ED8);  // Dark
static const primary800 = Color(0xFF1E40AF);
static const primary900 = Color(0xFF1E3A8A);  // Darkest
```

### Secondary Colors (Purple)
```dart
// Purple Accent - Secondary actions
static const secondary50 = Color(0xFFFAF5FF);
static const secondary100 = Color(0xFFF3E8FF);
static const secondary200 = Color(0xFFE9D5FF);
static const secondary300 = Color(0xFFD8B4FE);
static const secondary400 = Color(0xFFC084FC);
static const secondary500 = Color(0xFFA855F7);
static const secondary600 = Color(0xFF9333EA);  // Secondary
static const secondary700 = Color(0xFF7E22CE);
static const secondary800 = Color(0xFF6B21A8);
static const secondary900 = Color(0xFF581C87);
```

### Neutral Colors (Slate)
```dart
// Backgrounds, surfaces, borders
static const neutral50 = Color(0xFFF8FAFC);   // Background
static const neutral100 = Color(0xFFF1F5F9);  // Surface variant
static const neutral200 = Color(0xFFE2E8F0);  // Border
static const neutral300 = Color(0xFFCBD5E1);
static const neutral400 = Color(0xFF94A3B8);  // Text tertiary
static const neutral500 = Color(0xFF64748B);
static const neutral600 = Color(0xFF475569);  // Text secondary
static const neutral700 = Color(0xFF334155);
static const neutral800 = Color(0xFF1E293B);
static const neutral900 = Color(0xFF0F172A);  // Text primary
```

### Status Colors
```dart
// Success (Green)
static const success = Color(0xFF10B981);
static const successLight = Color(0xFF34D399);
static const successDark = Color(0xFF059669);

// Warning (Amber)
static const warning = Color(0xFFF59E0B);
static const warningLight = Color(0xFFFBBF24);
static const warningDark = Color(0xFFD97706);

// Error (Red)
static const error = Color(0xFFEF4444);
static const errorLight = Color(0xFFF87171);
static const errorDark = Color(0xFFDC2626);

// Info (Blue)
static const info = Color(0xFF3B82F6);
static const infoLight = Color(0xFF60A5FA);
static const infoDark = Color(0xFF2563EB);
```

---

## 📝 TYPOGRAPHY

### Font Family
```dart
// Primary: Inter (Google Fonts)
fontFamily: 'Inter'

// Fallback
fontFamilyFallback: ['SF Pro', 'Segoe UI', 'Roboto']
```

### Text Styles
```dart
// Display - Large headings
displayLarge: TextStyle(
  fontSize: 57,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.25,
),

// Headline - Section headings
headlineLarge: TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
),
headlineMedium: TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
),
headlineSmall: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
),

// Title - Card titles
titleLarge: TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
),
titleMedium: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
),
titleSmall: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
),

// Body - Main content
bodyLarge: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.5,
),
bodyMedium: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
),
bodySmall: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.4,
),

// Label - Buttons, labels
labelLarge: TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.1,
),
labelMedium: TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
),
labelSmall: TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.5,
),
```

---

## 📏 SPACING & SIZING

### Spacing Scale (8px base)
```dart
static const space4 = 4.0;    // xs
static const space8 = 8.0;    // sm
static const space12 = 12.0;  // md
static const space16 = 16.0;  // lg
static const space20 = 20.0;  // xl
static const space24 = 24.0;  // 2xl
static const space32 = 32.0;  // 3xl
static const space40 = 40.0;  // 4xl
static const space48 = 48.0;  // 5xl
static const space64 = 64.0;  // 6xl
```

### Border Radius
```dart
static const radiusXs = 4.0;
static const radiusSm = 6.0;
static const radiusMd = 8.0;
static const radiusLg = 12.0;
static const radiusXl = 16.0;
static const radius2xl = 24.0;
static const radiusFull = 9999.0;
```

### Elevation (Shadows)
```dart
// Light shadow
elevation1: BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 2,
  offset: Offset(0, 1),
),

// Medium shadow
elevation2: BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
),

// Heavy shadow
elevation3: BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 4),
),
```

---

## 🧩 COMPONENTS

### Buttons
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary600,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {},
  child: Text('Primary Button'),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary600,
    side: BorderSide(color: AppColors.neutral200),
    padding: EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
  ),
  onPressed: () {},
  child: Text('Secondary Button'),
)

// Text Button
TextButton(
  onPressed: () {},
  child: Text('Text Button'),
)
```

### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: AppColors.neutral50,
  ),
)
```

### Cards
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: AppColors.neutral200,
      width: 1,
    ),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Card content
      ],
    ),
  ),
)
```

---

## 📱 LAYOUT PATTERNS

### Slack-like 3-Column Layout
```
┌─────────────────────────────────────────────────┐
│  Header (64px)                                   │
├──────────┬──────────────┬──────────────────────┤
│          │              │                       │
│ Sidebar  │   Channels   │    Main Content      │
│ (240px)  │   (280px)    │    (Flexible)        │
│          │              │                       │
│          │              │                       │
│          │              │                       │
└──────────┴──────────────┴──────────────────────┘
```

### Responsive Breakpoints
```dart
static const mobileBreakpoint = 640;
static const tabletBreakpoint = 1024;
static const desktopBreakpoint = 1280;
```

---

## 🎭 ANIMATIONS

### Duration
```dart
static const durationFast = Duration(milliseconds: 150);
static const durationNormal = Duration(milliseconds: 300);
static const durationSlow = Duration(milliseconds: 500);
```

### Curves
```dart
static const curveDefault = Curves.easeInOut;
static const curveEmphasized = Curves.easeOutCubic;
static const curveDecelerate = Curves.decelerate;
```

---

## ♿ ACCESSIBILITY

### Minimum Touch Targets
```dart
static const minTouchTarget = 48.0;
```

### Contrast Ratios
- Normal text: 4.5:1 minimum
- Large text: 3:1 minimum
- UI components: 3:1 minimum

### Focus Indicators
```dart
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: AppColors.primary600,
    width: 2,
  ),
)
```

---

## 🌓 DARK MODE

### Dark Color Palette
```dart
// Dark backgrounds
static const darkBg = Color(0xFF0F172A);
static const darkSurface = Color(0xFF1E293B);
static const darkSurfaceVariant = Color(0xFF334155);

// Dark text
static const darkTextPrimary = Color(0xFFF8FAFC);
static const darkTextSecondary = Color(0xFFCBD5E1);
static const darkTextTertiary = Color(0xFF94A3B8);
```

---

## 📐 ICON SYSTEM

### Icon Sizes
```dart
static const iconXs = 16.0;
static const iconSm = 20.0;
static const iconMd = 24.0;
static const iconLg = 32.0;
static const iconXl = 48.0;
```

### Icon Style
- Use Material Icons
- Outlined style for most icons
- Filled style for active states

---

**This design system ensures consistency across the entire application!**
