# Close Menu Fix Summary

## Problem Statement
The CSRP Medical System was experiencing two critical issues:
1. **Stack Overflow Error**: "Maximum call stack size exceeded" error when closing the menu
2. **Forcefocus Issue**: Menu stayed in forcefocus (SetNuiFocus) when closing

## Error Analysis

### Stack Overflow Cause
The error was caused by potential recursive calls to `closeMenu()` when:
- Multiple event handlers (inline onclick + addEventListener) could trigger simultaneously
- Rapid repeated calls without protection
- Error handling edge cases during fetch operations

### Forcefocus Issue
The Lua backend was correctly calling `SetNuiFocus(false, false)`, but the issue occurred when:
- The JavaScript closeMenu wasn't properly triggering the Lua callback
- State desync between JavaScript and Lua
- Event handler conflicts preventing proper callback execution

## Changes Made

### 1. HTML Changes (`html/index.html`)
**Lines Changed**: 15, 68

**Before**:
```html
<button class="close-btn" onclick="closeMenu()">×</button>
```

**After**:
```html
<button class="close-menu-btn">×</button>
```

**Rationale**:
- Removed inline `onclick` handlers to prevent duplicate event handling
- Changed class from `close-btn` to `close-menu-btn` to match JavaScript event listener selector
- Ensures single, controlled event handler attachment

### 2. JavaScript Changes (`html/js/app.js`)

#### Added Global Flag (Line 10)
```javascript
let isClosing = false; // Prevent multiple simultaneous close calls
```

**Rationale**: Guards against recursive or simultaneous close operations

#### Updated `closeMenu()` Function (Lines 138-168)
**Before**:
```javascript
function closeMenu(notifyBackend = true) {
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    if (appElement) {
        appElement.style.display = 'none';
    }
    
    currentMenu = null;
    
    if (notifyBackend) {
        postNUI('closeMenu', {});
    }
}
```

**After**:
```javascript
function closeMenu(notifyBackend = true) {
    // Prevent multiple simultaneous close calls
    if (isClosing) {
        return;
    }
    
    // Don't try to close if no menu is open
    if (!currentMenu) {
        return;
    }
    
    isClosing = true;
    
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    if (appElement) {
        appElement.style.display = 'none';
    }
    
    currentMenu = null;
    
    if (notifyBackend) {
        postNUI('closeMenu', {});
    }
    
    // Reset the flag immediately after synchronous operations complete
    isClosing = false;
}
```

**Key Improvements**:
1. **Guard clause**: Returns early if already closing (prevents recursion)
2. **State check**: Returns early if no menu is open (prevents unnecessary operations)
3. **Flag management**: Sets flag during operation, resets immediately after
4. **Simplified logic**: Uses only `currentMenu` for state tracking (removed redundant display style check)

#### Updated `openMenu()` Function (Line 99)
```javascript
function openMenu(menuType, data) {
    currentMenu = menuType;
    isClosing = false; // Reset closing flag when opening a menu
    // ... rest of function
}
```

**Rationale**: Ensures `isClosing` flag is reset when opening a new menu, preventing stuck states

#### Improved Error Handling in `post()` (Lines 40-47)
**Before**:
```javascript
catch (error) {
    const errorMsg = error && error.message ? error.message : String(error);
    console.error(`Fetch error for ${url}: ${errorMsg}`);
    return {};
}
```

**After**:
```javascript
catch (error) {
    let errorMsg = 'Unknown error';
    try {
        errorMsg = error && error.message ? error.message : String(error);
    } catch (stringifyError) {
        errorMsg = 'Error converting error message';
    }
    console.error(`Fetch error for ${url}: ${errorMsg}`);
    return {};
}
```

**Rationale**: 
- Additional try-catch prevents stack overflow if error object has circular references
- Graceful fallback to generic message if error conversion fails
- Prevents the error handler itself from causing errors

### 3. Configuration Changes (`.gitignore`)
Added `test_close_menu.html` to gitignore to exclude test files from version control.

## How The Fix Works

### Scenario 1: User Closes Menu with Escape Key
1. User presses Escape
2. Keydown event listener calls `closeMenu()` (notifyBackend = true)
3. `closeMenu()` checks `isClosing` flag (false) and `currentMenu` (not null)
4. Sets `isClosing = true`
5. Hides all menu containers and app element
6. Sets `currentMenu = null`
7. Calls `postNUI('closeMenu', {})` to notify Lua backend
8. Lua `RegisterNUICallback('closeMenu', ...)` receives call
9. Lua sets `uiOpen = false`, `currentMenu = nil`
10. **Lua calls `SetNuiFocus(false, false)` - clears forcefocus**
11. Lua calls `cb('ok')` to respond
12. JavaScript sets `isClosing = false`
13. If Escape is pressed again, guard clause prevents re-execution

### Scenario 2: User Clicks Close Button
1. User clicks × button
2. Click event listener (attached via `addEventListener`) calls `closeMenu()`
3. Same flow as Scenario 1
4. No duplicate execution because inline onclick was removed

### Scenario 3: Backend Closes Menu
1. Lua toggle function sets `uiOpen = false`
2. Lua calls `SetNuiFocus(false, false)` immediately
3. Lua sends `SendNUIMessage({ action: 'closeMenu' })`
4. JavaScript message listener receives 'closeMenu' action
5. Calls `closeMenu(false)` (notifyBackend = false)
6. JavaScript updates UI without calling back to Lua (prevents infinite loop)

### Scenario 4: Rapid Multiple Close Attempts
1. First `closeMenu()` call sets `isClosing = true`
2. Subsequent calls immediately return due to guard clause
3. After first call completes, `isClosing` is set back to false
4. No stack overflow occurs

## Testing

### Manual Testing Checklist
- [x] JavaScript syntax validation passed (node --check)
- [x] Code review completed and feedback addressed
- [x] Security scan passed (CodeQL - 0 vulnerabilities)
- [ ] In-game testing: Open patient menu with F6, close with Escape
- [ ] In-game testing: Open paramedic menu with F7, close with X button
- [ ] In-game testing: Verify forcefocus is cleared (can move character after close)
- [ ] In-game testing: Rapid close attempts don't cause errors
- [ ] In-game testing: Toggle menu multiple times rapidly

### Test File Created
Created `test_close_menu.html` for browser-based testing of:
- Single closeMenu call
- Multiple rapid closeMenu calls
- Open then close sequence
- Button click simulation

## Expected Behavior After Fix

1. **No Stack Overflow**: Multiple or rapid close calls are safely handled
2. **Forcefocus Cleared**: `SetNuiFocus(false, false)` is reliably called when menu closes
3. **State Consistency**: JavaScript and Lua menu states remain synchronized
4. **Single Event Handler**: Only one close handler per button (no duplicates)
5. **Graceful Error Handling**: Fetch errors don't cause additional errors

## Security Considerations

### CodeQL Analysis Results
- **0 Alerts Found** - No security vulnerabilities detected
- All changes reviewed for:
  - XSS vulnerabilities
  - Code injection risks
  - Resource leaks
  - Unsafe API usage

### Security Best Practices Applied
1. No eval() or unsafe dynamic code execution
2. Proper error handling prevents information disclosure
3. Input validation maintained
4. No new external dependencies added

## Backward Compatibility

All changes are **fully backward compatible**:
- No breaking changes to function signatures
- No changes to data structures
- No changes to Lua API
- Existing functionality preserved
- Only bug fixes and safety improvements

## Files Modified

1. `html/index.html` - Removed inline onclick, fixed button classes
2. `html/js/app.js` - Added guards, improved error handling
3. `.gitignore` - Added test file exclusions
4. `test_close_menu.html` - Created (not committed)

## Verification Steps for Deployment

1. Deploy to test server
2. Test all menu open/close scenarios
3. Verify no console errors appear
4. Confirm forcefocus is properly cleared
5. Test rapid button clicking
6. Test keyboard shortcuts
7. Monitor for any new errors in FiveM console

## Rollback Plan

If issues occur, revert commits:
- `7320e8b` - Code review feedback
- `e5ef682` - Error handling improvements
- `e222616` - Initial fix

The Lua code was not modified, so no server-side changes needed for rollback.

## Known Limitations

- Test file only validates JavaScript logic, not FiveM-specific behavior
- In-game testing still required to confirm forcefocus fix
- Async postNUI response not awaited (acceptable for close operations)

## Future Improvements

1. Consider adding debouncing for close button
2. Add telemetry to track close events
3. Consider state machine for menu states
4. Add unit tests for menu operations
5. Consider making close operations async with proper await

## Contact

For issues or questions about this fix, refer to the PR or contact the development team.
