# NameCard Widget Setup Guide

## Overview
This project now includes two iOS widgets:
1. **Random Contact Widget** - Shows a random contact with deep link to detail view
2. **Category Distribution Widget** - Displays pie chart of contacts by category

## Files Created

### Main App Updates
- [NameCardApp.swift](NameCard/NameCardApp.swift) - Updated with App Group support and deep linking
- [Shared/WidgetDataManager.swift](NameCard/Shared/WidgetDataManager.swift) - Data provider for widgets

### Widget Extension Files
- [NameCardWidget/NameCardWidget.swift](NameCardWidget/NameCardWidget.swift) - Widget bundle
- [NameCardWidget/RandomContactWidget.swift](NameCardWidget/RandomContactWidget.swift) - Random contact widget implementation
- [NameCardWidget/CategoryChartWidget.swift](NameCardWidget/CategoryChartWidget.swift) - Category chart widget implementation

## Setup Steps in Xcode

### 1. Create Widget Extension Target

1. Open `NameCard.xcodeproj` in Xcode
2. **File → New → Target**
3. Select **Widget Extension**
4. Configure:
   - **Product Name:** `NameCardWidget`
   - **Include Configuration Intent:** ✓ (checked)
   - **Language:** Swift
   - **Embed in Application:** NameCard
5. Click **Finish**
6. **Activate the scheme** when prompted

### 2. Add Widget Files to Target

1. In Project Navigator, select the `NameCardWidget` folder
2. Delete the default boilerplate files (keep `Assets.xcassets` and `Info.plist`)
3. Drag these files into the `NameCardWidget` folder:
   - `NameCardWidget.swift`
   - `RandomContactWidget.swift`
   - `CategoryChartWidget.swift`
4. **Also add to Widget target:**
   - `NameCard/Shared/WidgetDataManager.swift`
   - `NameCard/Models/StoredContact.swift`
   - `NameCard/Models/ContactCategory.swift`

   → Right-click each file → Show File Inspector → Check **NameCardWidget** under Target Membership

### 3. Configure App Groups

#### Main App Target (`NameCard`)
1. Select project → `NameCard` target → **Signing & Capabilities**
2. Click **+ Capability** → Add **App Groups**
3. Click **+** under App Groups
4. Enter: `group.com.yourteam.namecard` (replace with your team/bundle ID)
5. Click **OK**

#### Widget Extension Target (`NameCardWidget`)
1. Select project → `NameCardWidget` target → **Signing & Capabilities**
2. Click **+ Capability** → Add **App Groups**
3. **Select the same group**: `group.com.yourteam.namecard`

### 4. Update App Group Identifier in Code

Find and replace `group.com.yourteam.namecard` with your actual App Group identifier in:
- [NameCardApp.swift](NameCard/NameCardApp.swift#L15)
- [Shared/WidgetDataManager.swift](NameCard/Shared/WidgetDataManager.swift#L9)

### 5. Configure URL Scheme (Deep Linking)

1. Select project → `NameCard` target → **Info** tab
2. Expand **URL Types**
3. Click **+** to add URL Type:
   - **Identifier:** `com.yourteam.namecard`
   - **URL Schemes:** `namecard`
   - **Role:** Editor

### 6. Build and Run

1. Select **NameCard** scheme
2. Build and run on device/simulator (⌘R)
3. Long-press home screen → **+** → Search "NameCard"
4. Add both widgets to test

## Widget Features

### Random Contact Widget

**Sizes:** Small, Medium, Large

**Features:**
- Displays random contact from database
- Shows name, organization, category
- Category color coding
- Tap to open contact detail in app
- Updates every hour

**Deep Link:** `namecard://contact/{uuid}`

### Category Distribution Widget

**Sizes:** Small, Medium, Large

**Features:**
- Pie chart showing category distribution
- Total contact count
- Category breakdown with percentages (Large widget)
- Color-coded categories
- Updates every 30 minutes

## Testing

### 1. Add Sample Data
- App automatically seeds data on first launch
- Or add contacts manually in the app

### 2. Test Widgets
- Add widgets to home screen
- Verify data displays correctly
- Test deep linking by tapping Random Contact widget

### 3. Test Deep Linking

**Method 1: From Widget (Recommended)**
1. Add Random Contact Widget to home screen
2. Tap on the widget
3. App should open and navigate to the contact detail view

**Method 2: Using Safari (Testing)**
1. Open Safari on simulator/device
2. In address bar, type: `namecard://contact/{contact-uuid}`
3. App should open and navigate to contact detail

**Method 3: Using Terminal (Testing)**
```bash
# Get a contact UUID first from the app or logs
xcrun simctl openurl booted "namecard://contact/REPLACE-WITH-REAL-UUID"
```

**Debug Deep Links:**
- Open Console in Xcode (⇧⌘C)
- Filter by "Deep link" or "namecard://"
- Look for these log messages:
  - ✅ Deep link received: {uuid}
  - ✅ Found contact: {name}
  - ❌ Invalid deep link URL: {url}
  - ❌ Contact not found for ID: {uuid}

### 4. Test App Groups
- Add contact in app
- Widget should update on next timeline refresh
- Force refresh: Remove and re-add widget

## Troubleshooting

### Widget Shows "No Contacts"
- Verify App Groups are configured identically in both targets
- Check App Group identifier matches in code
- Ensure SwiftData models are added to Widget target membership

### Deep Link Not Working
- Verify URL scheme is configured in main app target (Info → URL Types)
- Check URL format: `namecard://contact/{valid-uuid}`
- Ensure `.onOpenURL` handler is in [ContentView.swift](NameCard/ContentView.swift#L21-23)
- Check console for debug logs (✅ or ❌ messages)
- Verify contact UUID exists in database

### Build Errors
- Ensure all model files have Widget target membership
- Check that WidgetKit and Charts frameworks are available
- Clean build folder (⇧⌘K) and rebuild

### Widget Not Updating
- Timelines: Random Contact (1 hour), Category Chart (30 min)
- Force update: Remove and re-add widget
- Check console logs for errors in Widget scheme

## Customization

### Update Refresh Intervals

**Random Contact:** [RandomContactWidget.swift](NameCardWidget/RandomContactWidget.swift#L29)
```swift
let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
```

**Category Chart:** [CategoryChartWidget.swift](NameCardWidget/CategoryChartWidget.swift#L47)
```swift
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
```

### Modify Widget Appearance
- Edit view files for each widget size
- Customize colors, fonts, layouts in widget view structs
- Update empty state views

## Next Steps

After completing Xcode setup:
- [ ] Test both widgets on device
- [ ] Verify deep linking works
- [ ] Test with different data scenarios (0 contacts, many categories, etc.)
- [ ] Consider adding widget configuration intents for customization
- [ ] Add widget screenshots for App Store

---

**Note:** Replace `group.com.yourteam.namecard` throughout the code with your actual App Group identifier based on your team ID and bundle identifier.
