# CSRP Medical System - Menu System Guide

## 📋 Table of Contents
1. [Quick Start](#quick-start)
2. [Menu System Architecture](#menu-system-architecture)
3. [Step-by-Step Workflow](#step-by-step-workflow)
4. [How Each Component Works](#how-each-component-works)
5. [Common Issues & Solutions](#common-issues--solutions)
6. [Technical Deep Dive](#technical-deep-dive)

---

## 🚀 Quick Start

### For Players
**Opening the Patient Menu:**
1. Press **F6** while in-game
2. View your current vital signs (heart rate, blood pressure, etc.)
3. See all active injuries and their severity
4. Request help from nearby paramedics
5. Press **Escape** or click **×** to close

### For Paramedics
**Opening the Paramedic Tablet:**
1. Press **F7** while in-game (requires paramedic role)
2. **Patients Tab**: See nearby players within 10 meters
   - Click on a patient to select them
   - Perform ABCDE assessment or secondary survey
   - Check their vital signs
3. **Treatments Tab**: Browse available medical treatments
   - Filter by category (Airway, Breathing, Circulation, Medications)
   - Apply treatments to selected patient
4. **Equipment Tab**: View your medical supply inventory
   - Monitor equipment charge levels
   - Visit hospitals to resupply (press E near hospital)
5. Press **Escape** or click **×** to close

---

## 🏗️ Menu System Architecture

The menu system uses a **two-layer architecture**:

```
┌─────────────────────────────────────────────────────────────┐
│                    GAME CLIENT (Lua)                         │
│  • Detects key presses (F6, F7)                             │
│  • Manages game state (player vitals, injuries, equipment)  │
│  • Controls NUI focus (mouse/keyboard input)                │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ SendNUIMessage()
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    NUI INTERFACE (HTML/JS)                   │
│  • Renders menu visuals                                     │
│  • Handles user interactions (clicks, tabs, buttons)        │
│  • Sends actions back to Lua via callbacks                  │
└─────────────────────────────────────────────────────────────┘
```

### Key Files
- **client/main.lua** - Detects F6/F7 key presses, initializes system
- **client/ui.lua** - Toggles menus, formats data for NUI
- **html/index.html** - Menu HTML structure
- **html/js/app.js** - Menu rendering and interaction logic

---

## 📖 Step-by-Step Workflow

### Opening Patient Menu (F6)

```
Step 1: Player Presses F6
    ↓
Step 2: Game detects key press (client/main.lua)
    ├─ IsControlJustReleased(0, 167) = true
    └─ Checks Config.Permissions.UsePatientMenu
    ↓
Step 3: Toggle menu function called (client/ui.lua)
    ├─ Sets uiOpen = true
    ├─ Sets currentMenu = 'patient'
    ├─ Calls SetNuiFocus(true, true) → Enables mouse/keyboard for UI
    └─ Gathers player data:
        ├─ GetPlayerVitals() → {heartRate, bloodPressure, etc.}
        └─ GetInjuriesForNUI() → [{injury1}, {injury2}, ...]
    ↓
Step 4: Send data to NUI interface
    └─ SendNUIMessage({
         action: 'openMenu',
         menuType: 'patient',
         data: {vitals: {...}, injuries: [...]}
       })
    ↓
Step 5: JavaScript receives message (html/js/app.js)
    └─ window.addEventListener('message') catches event
    ↓
Step 6: Open menu function executes
    ├─ Shows #app container (display: flex)
    ├─ Hides all other menus
    └─ Shows #patientMenu (display: flex)
    ↓
Step 7: Populate menu with data
    ├─ updateVitalsDisplay() → Fill in #hr, #bp, #spo2, etc.
    └─ Render injury cards in #injuries-list
    ↓
Step 8: Player sees menu on screen
```

### Closing Menu (Escape or × Button)

```
Step 1: User presses Escape OR clicks × button
    ↓
Step 2: JavaScript closeMenu() called (html/js/app.js)
    ├─ Guard: if (isClosing) return  → Prevent multiple calls
    ├─ Guard: if (!currentMenu) return  → Nothing to close
    └─ Set isClosing = true
    ↓
Step 3: Hide all UI elements
    ├─ Hide .menu-container elements
    ├─ Hide #app container
    └─ Set currentMenu = null
    ↓
Step 4: Notify Lua backend
    └─ postNUI('closeMenu', {})
    ↓
Step 5: Lua receives close callback (client/ui.lua)
    └─ RegisterNUICallback('closeMenu')
        ├─ Sets uiOpen = false
        ├─ Sets currentMenu = nil
        ├─ **CRITICAL**: SetNuiFocus(false, false)
        │   └─ Releases mouse/keyboard back to game
        └─ Responds with cb('ok')
    ↓
Step 6: JavaScript completes
    └─ Set isClosing = false
    ↓
Step 7: Menu closed, player can move again
```

### Opening Paramedic Menu (F7)

Similar to Patient Menu, but with extra steps:

```
Step 1-2: Same as patient menu (F7 = control code 168)
    ↓
Step 3: Toggle paramedic menu (client/ui.lua)
    ├─ Sets uiOpen = true
    ├─ Sets currentMenu = 'paramedic'
    ├─ Calls SetNuiFocus(true, true)
    └─ Gathers MORE data:
        ├─ GetNearbyPlayers(10.0) → [{id, name, distance}, ...]
        ├─ GetParamedicEquipment() → {bandages: 50/50, morphine: 10/10, ...}
        └─ Treatments.Definitions → All available treatments
    ↓
Step 4-8: Same rendering flow as patient menu
    └─ But renders THREE tabs instead of simple panel:
        • Patients Tab (default)
        • Treatments Tab
        • Equipment Tab
```

---

## 🔧 How Each Component Works

### 1. Key Detection System (client/main.lua)

**Location:** Lines 42-60

```lua
Citizen.CreateThread(function()
    while true do
        Wait(0)  -- Check every frame
        
        -- F6 = Control 167
        if IsControlJustReleased(0, 167) then
            if Config.Permissions.UsePatientMenu then
                TogglePatientMenu()
            end
        end
        
        -- F7 = Control 168
        if IsControlJustReleased(0, 168) then
            if Config.Permissions.UseParamedicMenu and isParamedic then
                ToggleParamedicMenu()
            end
        end
    end
end)
```

**How it works:**
- Runs in an infinite loop checking every game frame
- `IsControlJustReleased(0, code)` detects when key is pressed AND released
- Only responds if config permissions allow
- Calls appropriate toggle function

**Why this design?**
- FiveM doesn't support traditional keyboard event listeners
- Must poll control states each frame
- "JustReleased" prevents holding key from spamming

---

### 2. Menu Toggle System (client/ui.lua)

**Patient Menu Toggle (Lines 10-30):**

```lua
local uiOpen = false
local currentMenu = nil

function TogglePatientMenu()
    -- Toggle the state
    uiOpen = not uiOpen
    currentMenu = 'patient'
    
    -- CRITICAL: Enable/disable mouse/keyboard for NUI
    SetNuiFocus(uiOpen, uiOpen)
    
    if uiOpen then
        -- Opening: Send data to NUI
        SendNUIMessage({
            action = 'openMenu',
            menuType = 'patient',
            data = {
                injuries = GetInjuriesForNUI(),
                vitals = GetPlayerVitals()
            }
        })
    else
        -- Closing: Tell NUI to hide
        SendNUIMessage({
            action = 'closeMenu'
        })
    end
end
```

**State Variables:**
- `uiOpen` - Boolean, is ANY menu currently visible?
- `currentMenu` - String, which specific menu is open? ('patient' or 'paramedic')

**SetNuiFocus Explained:**
```lua
SetNuiFocus(hasFocus, hasCursor)
-- hasFocus: Can UI receive keyboard input?
-- hasCursor: Can UI receive mouse input?

SetNuiFocus(true, true)   → UI active, mouse visible
SetNuiFocus(false, false) → Game active, mouse hidden
```

**Why toggle instead of separate open/close?**
- Single key (F6/F7) can both open AND close menu
- Simpler user experience
- Less key binds to remember

---

### 3. NUI Message System (Lua → JavaScript)

**Lua Side (client/ui.lua):**
```lua
SendNUIMessage({
    action = 'openMenu',        -- What to do
    menuType = 'patient',       -- Which menu
    data = {                    -- Menu data
        vitals = {...},
        injuries = [...]
    }
})
```

**JavaScript Side (html/js/app.js, lines 939-1014):**
```javascript
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'openMenu':
            openMenu(data.menuType, data.data);
            break;
        case 'closeMenu':
            closeMenu(false);  // false = don't notify backend
            break;
        case 'updateVitals':
            updateVitalsDisplay(currentMenu, data.vitals);
            break;
        // ... other actions
    }
});
```

**Message Types:**
- `openMenu` - Show a menu with data
- `closeMenu` - Hide current menu
- `updateVitals` - Update vital signs display
- `updateInjuries` - Update injuries list
- `updateEquipment` - Update equipment inventory
- `updatePatientData` - Update selected patient in paramedic menu
- `showNotification` - Display popup message

---

### 4. Menu Rendering (html/js/app.js)

**Opening Menu (Lines 97-136):**
```javascript
function openMenu(menuType, data) {
    currentMenu = menuType;
    isClosing = false;  // Reset guard flag
    
    // 1. Show app container
    if (appElement) {
        appElement.style.display = 'flex';
    }
    
    // 2. Hide ALL menus first
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    // 3. Show the requested menu
    const menu = document.getElementById(`${menuType}Menu`);
    if (menu) {
        menu.style.display = 'flex';
        
        // 4. Populate with data
        switch(menuType) {
            case 'patient':
                populatePatientMenu(data);
                break;
            case 'paramedic':
                populateParamedicMenu(data);
                break;
        }
    }
}
```

**Closing Menu (Lines 138-174):**
```javascript
function closeMenu(notifyBackend = true) {
    // Guards to prevent issues
    if (isClosing) return;      // Already closing
    if (!currentMenu) return;   // Nothing open
    
    isClosing = true;  // Set flag
    
    // Hide all menus
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    // Hide app container
    if (appElement) {
        appElement.style.display = 'none';
    }
    
    currentMenu = null;
    
    // Tell Lua backend (unless backend initiated close)
    if (notifyBackend) {
        postNUI('closeMenu', {});
    }
    
    isClosing = false;  // Reset flag
}
```

**Why the isClosing flag?**
- Prevents "Maximum call stack size exceeded" error
- User might press Escape rapidly or click button multiple times
- Guard prevents function from calling itself recursively

**Why notifyBackend parameter?**
- When **user** closes menu → Tell Lua to release input focus
- When **Lua** closes menu → Don't callback to Lua (infinite loop)

---

### 5. NUI Callbacks (JavaScript → Lua)

**JavaScript Side (html/js/app.js):**
```javascript
// Send action to Lua
async function post(url, data = {}) {
    const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    });
    return await response.json();
}

// Example: Applying treatment
function applyTreatmentById(treatmentId) {
    postNUI('applyTreatment', { 
        targetId: selectedPatientId, 
        treatmentId: treatmentId 
    });
}
```

**Lua Side (client/ui.lua, lines 116-195):**
```lua
RegisterNUICallback('applyTreatment', function(data, cb)
    if data.targetId and data.treatmentId then
        ApplyTreatment(data.targetId, data.treatmentId, data.injuryId)
        cb('ok')  -- Must respond to JavaScript
    else
        cb('error')
    end
end)
```

**How it works:**
1. JavaScript makes HTTP request to `https://csrp-medical-system/applyTreatment`
2. FiveM intercepts this special URL format
3. Calls registered Lua callback with data
4. Lua performs action (apply treatment to player)
5. Lua calls `cb('ok')` or `cb('error')` to respond
6. JavaScript receives response

**Why HTTP fetch for local communication?**
- NUI (Chromium-based UI) can only communicate via HTTP requests
- FiveM provides special protocol handler
- Standard web technology (fetch API)

---

### 6. Tab System (Paramedic Menu)

**HTML Structure (html/index.html, lines 72-114):**
```html
<div class="tab-container">
    <button class="tab-btn active" onclick="showTab('patients', this)">Patients</button>
    <button class="tab-btn" onclick="showTab('treatments', this)">Treatments</button>
    <button class="tab-btn" onclick="showTab('equipment', this)">Equipment</button>
</div>

<div id="patients-tab" class="tab-content active">...</div>
<div id="treatments-tab" class="tab-content">...</div>
<div id="equipment-tab" class="tab-content">...</div>
```

**JavaScript Logic (html/js/app.js, lines 1059-1080):**
```javascript
function showTab(tabName, buttonElement) {
    // 1. Hide all tab contents
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 2. Deactivate all tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // 3. Show selected tab
    const selectedTab = document.getElementById(`${tabName}-tab`);
    if (selectedTab) {
        selectedTab.classList.add('active');
    }
    
    // 4. Activate clicked button
    if (buttonElement) {
        buttonElement.classList.add('active');
    }
}
```

**How it works:**
- CSS `.active` class controls visibility (display: block vs none)
- Clicking tab button calls `showTab()`
- Function removes ALL active classes, then adds to selected
- Visual result: Only one tab visible at a time

---

### 7. Patient Data Flow (Paramedic Selecting Patient)

**Complete Request → Response Cycle:**

```
Step 1: Paramedic clicks patient in list
    ↓
Step 2: JavaScript calls selectPatient(patientId)
    └─ postNUI('selectPatient', {patientId: 123})
    ↓
Step 3: Lua receives callback
    └─ RegisterNUICallback('selectPatient')
        └─ TriggerServerEvent('csrp_medical:requestPatientData', patientId)
    ↓
Step 4: Server forwards request to patient's client
    └─ TriggerClientEvent('csrp_medical:sendPatientData', patientId, paramedicId)
    ↓
Step 5: Patient's client gathers their data
    └─ RegisterNetEvent('csrp_medical:sendPatientData')
        ├─ GetInjuriesForNUI()
        ├─ GetPlayerVitals()
        └─ TriggerServerEvent('csrp_medical:sendPatientDataToParamedic', paramedicId, data)
    ↓
Step 6: Server forwards patient data back to paramedic
    └─ TriggerClientEvent('csrp_medical:receivePatientData', paramedicId, patientData)
    ↓
Step 7: Paramedic's client receives data
    └─ RegisterNetEvent('csrp_medical:receivePatientData')
        └─ SendNUIMessage({action: 'updatePatientData', patient: data})
    ↓
Step 8: Paramedic's UI updates
    └─ JavaScript receives 'updatePatientData' message
        ├─ Updates #patient-vitals div
        ├─ Updates #patient-injuries list
        └─ Shows assessment buttons
```

**Why so many steps?**
- Patient data lives on patient's client (not paramedic's)
- Must use network events to request across clients
- Server acts as intermediary (prevents direct client-to-client)
- Security: Server can validate requests

---

## 🐛 Common Issues & Solutions

### Issue 1: Menu Won't Open

**Symptoms:**
- Press F6/F7, nothing happens
- No errors in console

**Possible Causes:**

**A. Permission Check Failed**
```lua
-- Check config.lua
Config.Permissions.UsePatientMenu = true  -- Must be true
Config.Permissions.UseParamedicMenu = true  -- Must be true for F7

-- For paramedics, also check:
Config.Permissions.ParamedicJobs = {'ambulance', 'doctor', 'ems'}
```

**Solution:** 
- Verify `Config.Permissions.UsePatientMenu = true` in config.lua
- For paramedics, ensure your job is in `ParamedicJobs` table
- Restart resource after config changes: `/restart csrp_medical`

**B. Key Bind Conflict**
Another resource might be using F6/F7.

**Solution:**
- Press F8 console while holding F6
- Look for messages from other resources
- Disable conflicting resource or change keybind

**C. Resource Not Started**
```bash
# In server console
resources    # Check if csrp_medical is in list
ensure csrp_medical    # Start it manually
```

---

### Issue 2: Menu Opens But Shows No Data

**Symptoms:**
- Menu opens but vitals show "--"
- Injuries list is empty
- Equipment shows 0/0

**Possible Causes:**

**A. Data Functions Not Initialized**
```lua
-- client/main.lua should have run:
playerVitals = InitializeVitals()
playerInjuries = {}
paramedicEquipment = Equipment.Initialize()
```

**Solution:**
- Check F8 console for errors mentioning "Equipment module not loaded"
- Verify `modules/equipment.lua` exists and is loaded in `fxmanifest.lua`
- Resource might have started before player loaded, restart: `/restart csrp_medical`

**B. JavaScript Field Name Mismatch**
If you see `undefined` or `null` in vital fields:

```javascript
// app.js should handle both formats:
const hr = (vitals.heartRate !== undefined) ? vitals.heartRate : '--';
const bp = `${vitals.bloodPressureSystolic || vitals.bpSystolic || '--'}/${vitals.bloodPressureDiastolic || vitals.bpDiastolic || '--'}`;
```

**Solution:**
- Check browser console (F12) for JavaScript errors
- Verify `html/js/app.js` has recent bug fixes
- Update to latest version

---

### Issue 3: Can't Close Menu / Stuck in UI

**Symptoms:**
- Press Escape, menu stays visible
- Can't move character
- Mouse cursor stuck on screen

**Cause:**
`SetNuiFocus(false, false)` not being called.

**Solution:**

**A. Check Lua callback is registered:**
```lua
-- client/ui.lua should have:
RegisterNUICallback('closeMenu', function(data, cb)
    uiOpen = false
    currentMenu = nil
    SetNuiFocus(false, false)  -- THIS IS CRITICAL
    cb('ok')
end)
```

**B. Force close manually:**
```lua
-- In F8 console, type:
SetNuiFocus(false, false)
```

**C. Check for JavaScript errors:**
- Press F12 to open browser devtools
- Look in Console tab for errors
- JavaScript error might prevent close callback from firing

---

### Issue 4: "Maximum Call Stack Size Exceeded" Error

**Symptoms:**
- Browser console shows stack overflow error
- Menu closes but with error
- Multiple close events firing

**Cause:**
Multiple event handlers calling `closeMenu()` recursively.

**Solution:**
Ensure `html/index.html` does NOT have inline onclick:

```html
<!-- WRONG: -->
<button class="close-btn" onclick="closeMenu()">×</button>

<!-- CORRECT: -->
<button class="close-menu-btn">×</button>
```

And `html/js/app.js` should have guard clause:

```javascript
function closeMenu(notifyBackend = true) {
    if (isClosing) return;      // Guard 1
    if (!currentMenu) return;   // Guard 2
    
    isClosing = true;
    // ... rest of function
    isClosing = false;
}
```

---

### Issue 5: Vital Signs Show "--" Instead of "0"

**Symptoms:**
- Patient in cardiac arrest (heart rate = 0)
- Menu shows "--" instead of "0"

**Cause:**
JavaScript using `||` operator which treats 0 as falsy.

**Wrong Code:**
```javascript
heartRate: vitals.heartRate || '--'  // 0 becomes '--'
```

**Correct Code:**
```javascript
heartRate: (vitals.heartRate !== undefined && vitals.heartRate !== null) 
           ? vitals.heartRate 
           : '--'
```

**Solution:**
- Update `html/js/app.js` to latest version
- Bug was fixed in commit addressing null/zero handling

---

### Issue 6: Paramedic Menu Shows "No Patients Nearby" But Players Are Close

**Symptoms:**
- Other players within 10 meters
- Paramedic menu Patients tab shows empty
- "No nearby patients" message

**Cause:**
`GetNearbyPlayers()` calculation issue or players not loaded.

**Debug Steps:**

1. **Check F8 console for errors**
2. **Verify player loading:**
   ```lua
   -- In F8 console:
   /medebug    -- Enable debug mode
   ```
3. **Check distance calculation:**
   ```lua
   -- client/ui.lua, lines 91-113
   function GetNearbyPlayers(radius)
       local players = {}
       local playerPed = PlayerPedId()
       local playerCoords = GetEntityCoords(playerPed)
       
       for _, player in ipairs(GetActivePlayers()) do
           local targetPed = GetPlayerPed(player)
           local distance = #(playerCoords - GetEntityCoords(targetPed))
           
           if distance <= radius then  -- 10.0 meters
               table.insert(players, {...})
           end
       end
       return players
   end
   ```

4. **Verify players are "active":**
   - `GetActivePlayers()` only returns loaded players
   - If player just joined, might not be in list yet
   - Wait a few seconds and reopen menu

---

## 🔬 Technical Deep Dive

### Memory Management

**JavaScript State:**
```javascript
let currentMenu = null;           // Current menu type
let patientData = null;           // Last received patient data
let equipmentData = null;         // Equipment inventory
let selectedPatientId = null;     // Selected patient in paramedic menu
let isClosing = false;            // Close operation guard
let appElement = null;            // Cached #app reference
```

**Lua State:**
```lua
local uiOpen = false              -- Is ANY menu open?
local currentMenu = nil           -- Which menu? ('patient'/'paramedic')
local playerInjuries = {}         -- Current player's injuries
local playerVitals = {}           -- Current player's vitals
local paramedicEquipment = {}     -- Paramedic's equipment inventory
local isParamedic = false         -- Does player have paramedic role?
```

**Why separate JavaScript and Lua state?**
- JavaScript can't access Lua variables directly
- Lua can't access JavaScript variables directly
- Each maintains own copy
- Synchronized via messages

---

### Performance Considerations

**Key Press Polling:**
```lua
while true do
    Wait(0)  -- Every frame (~60 FPS = ~16ms per check)
    if IsControlJustReleased(0, 167) then
        TogglePatientMenu()
    end
end
```

**Impact:** 
- Minimal CPU usage (native function call)
- `Wait(0)` yields to other threads
- Only triggers on state change (key release), not every frame

**Optimization:**
Could use `Wait(50)` (check every 50ms) with minimal user impact.

---

**Hospital Resupply Polling:**
```lua
while true do
    Wait(500)  -- Every 500ms = twice per second
    if isParamedic then
        -- Check distance to hospitals
    end
end
```

**Impact:**
- More expensive (distance calculations)
- Only runs for paramedics
- 500ms delay acceptable (not time-critical)

---

**Vitals Update Thread:**
```lua
function VitalsThread()
    Citizen.CreateThread(function()
        while true do
            Wait(Config.VitalSigns.UpdateInterval)  -- Default: 10000ms = 10 seconds
            
            if #playerInjuries > 0 then
                CalculateVitals()
                -- Update NUI if menu open
                if uiOpen and currentMenu == 'patient' then
                    SendNUIMessage({
                        action = 'updateVitals',
                        vitals = GetPlayerVitals()
                    })
                end
            end
        end
    end)
end
```

**Performance:**
- Updates every 10 seconds (configurable)
- Only sends NUI message if menu is actually open
- Skips calculations if no injuries

---

### Security Model

**Input Validation:**

**Current Implementation:**
```lua
RegisterNUICallback('applyTreatment', function(data, cb)
    if data.targetId and data.treatmentId then
        ApplyTreatment(data.targetId, data.treatmentId, data.injuryId)
        cb('ok')
    else
        cb('error')
    end
end)
```

**What's validated:**
- ✅ Fields exist (not nil)

**What's NOT validated:**
- ❌ Data types (is targetId a number?)
- ❌ Range checks (is targetId a valid player?)
- ❌ Permission checks (can this paramedic treat this player?)

**Potential Exploit:**
Malicious client could send:
```javascript
postNUI('applyTreatment', {
    targetId: 999999,           // Invalid player
    treatmentId: 'nuclear_bomb',  // Non-existent treatment
    injuryId: 'inject SQL here'   // Malicious input
})
```

**Mitigation:**
- FiveM sandboxes NUI (can't affect other players directly)
- Treatment application goes through server validation
- Invalid IDs cause Lua errors but don't crash server

**Recommended Improvements:**
```lua
RegisterNUICallback('applyTreatment', function(data, cb)
    -- Type validation
    if type(data.targetId) ~= 'number' or type(data.treatmentId) ~= 'string' then
        cb('error')
        return
    end
    
    -- Range validation
    if data.targetId < 1 or data.targetId > 1024 then
        cb('error')
        return
    end
    
    -- Existence validation
    if not Treatments.Definitions[data.treatmentId] then
        cb('error')
        return
    end
    
    -- Permission validation (server-side)
    TriggerServerEvent('csrp_medical:validateTreatment', data.targetId, data.treatmentId)
    cb('ok')
end)
```

---

### Data Flow Diagrams

**Simplified Menu Lifecycle:**
```
         START
           │
           ↓
    ┌──────────────┐
    │  Menu Closed │
    │ uiOpen=false │
    └──────┬───────┘
           │
     Press F6/F7
           │
           ↓
    ┌──────────────┐
    │ Gather Data  │
    │ Vitals, Inj. │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │  SetNuiFocus │
    │  (true,true) │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │SendNUIMessage│
    │ openMenu     │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │ Render HTML  │
    │  Menu Open   │
    │ uiOpen=true  │
    └──────┬───────┘
           │
    User Interacts
    (Select patient,
     apply treatment,
     check vitals)
           │
           ↓
    ┌──────────────┐
    │ NUI Callback │
    │ to Lua       │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │ Process      │
    │ Action       │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │ Update NUI   │
    │ (if needed)  │
    └──────┬───────┘
           │
    Press Escape
     or Click ×
           │
           ↓
    ┌──────────────┐
    │  closeMenu() │
    │  JS → Lua    │
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │  SetNuiFocus │
    │ (false,false)│
    └──────┬───────┘
           │
           ↓
    ┌──────────────┐
    │  Menu Closed │
    │ uiOpen=false │
    └──────────────┘
           │
           ↓
          END
```

---

## 📚 Additional Resources

**Related Files:**
- `config.lua` - Menu permissions, keybinds, update intervals
- `modules/injuries.lua` - Injury type definitions
- `modules/treatments.lua` - Treatment definitions
- `modules/equipment.lua` - Equipment quantities and management

**Debugging Commands:**
- `/medebug` - Toggle debug mode (detailed logging)
- `/checkvitals` - Display your current vitals in chat
- `/addinjury [type] [zone] [severity]` - Test injury system
- `/healplayer [id]` - Remove all injuries (admin)

**Configuration Options:**
```lua
-- config.lua
Config.UI = {
    OpenPatientMenu = 'F6',      -- Can change to different key
    OpenParamedicMenu = 'F7',    -- Can change to different key
    Theme = 'nhs-blue',          -- Color scheme
}

Config.VitalSigns.UpdateInterval = 10000  -- How often vitals update (ms)
Config.Progression.ProgressionInterval = 10000  -- How often injuries progress (ms)
```

---

## 🎓 Conclusion

The CSRP Medical System menu is a **well-architected, two-layer system** that:

✅ **Separates concerns**: Game logic (Lua) vs UI (JavaScript/HTML)  
✅ **Handles permissions**: Configurable access control  
✅ **Prevents common bugs**: Guard clauses, null checks, error handling  
✅ **Supports roleplay**: Patient menu (everyone) vs Paramedic tablet (medics only)  
✅ **Scales well**: Can open/close rapidly without issues  

Recent bug fixes addressed:
- ✅ Stack overflow errors on close
- ✅ Data structure mismatches (Lua ↔ JavaScript)
- ✅ Zero vs null handling in vital signs
- ✅ Forcefocus not releasing properly

The system is now **stable and production-ready** for UK RP medical roleplay scenarios.

---

**For questions or issues, refer to:**
- Main README.md
- BUG_FIX_SUMMARY.md
- CLOSE_MENU_FIX_SUMMARY.md
- Create a GitHub issue

**Happy Roleplaying! 🚑**
