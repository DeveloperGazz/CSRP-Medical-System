# CSRP Medical System - Installation Guide

## Quick Start (5 Minutes)

### Step 1: Download & Extract
1. Download the latest release
2. Extract to your FiveM server's `resources` folder
3. Rename folder to `csrp_medical` if needed

Your structure should look like:
```
server-data/
└── resources/
    └── csrp_medical/
        ├── fxmanifest.lua
        ├── config.lua
        ├── client/
        ├── server/
        ├── html/
        └── modules/
```

### Step 2: Server Configuration
Add to your `server.cfg`:
```cfg
ensure csrp_medical
```

### Step 3: Start Server
Restart your FiveM server:
```bash
# Linux
./run.sh +exec server.cfg

# Windows
FXServer.exe +exec server.cfg
```

### Step 4: Test In-Game
1. Join your server
2. Press **F6** to open Patient Menu
3. Press **F7** to open Paramedic Tablet (if allowed)
4. Use `/addinjury` to test (requires admin)

## Configuration (Recommended)

### Basic Setup
Edit `config.lua`:

```lua
-- Set your server's job names
Config.Permissions.ParamedicJobs = {'ambulance', 'ems', 'doctor'}

-- Enable ACE permissions for security
Config.Permissions.UseAcePermissions = true

-- Adjust progression speed
Config.Progression.BleedingRate = 1.0  -- 1.0 = normal, 0.5 = slower, 2.0 = faster

-- Configure keybinds
Config.UI.OpenPatientMenu = 'F6'
Config.UI.OpenParamedicMenu = 'F7'
```

### Hospital Locations
Add your custom hospital locations:

```lua
Config.Hospitals = {
    {
        name = "Your Hospital Name",
        coords = vector3(x, y, z),  -- Use your coordinates
        blip = true,
        resupply = true
    }
}
```

### Security Setup (Production)
For production servers, enable ACE permissions:

In `config.lua`:
```lua
Config.Permissions.UseAcePermissions = true
Config.Permissions.AdminAcePermission = 'csrp.medical.admin'
```

In `server.cfg`:
```cfg
# Grant admin group permission
add_ace group.admin csrp.medical.admin allow

# Or grant specific users
add_ace identifier.license:abc123 csrp.medical.admin allow
```

## Advanced Configuration

### Vital Signs Customization
Adjust normal ranges to match your server's medical standards:

```lua
Config.VitalSigns.HeartRate.Normal = {min = 60, max = 100}
Config.VitalSigns.BloodPressure.Normal = {
    systolic = {min = 90, max = 140},
    diastolic = {min = 60, max = 90}
}
```

### Equipment Quantities
Customize starting equipment amounts:

```lua
Config.Equipment.Bandages = 15
Config.Equipment.Tourniquets = 4
Config.Equipment.Morphine = 3
-- etc.
```

### Performance Tuning
For busy servers, adjust update intervals:

```lua
Config.VitalSigns.HeartRate.UpdateInterval = 10000  -- 10 seconds
Config.Progression.ProgressionInterval = 15000      -- 15 seconds
```

## Framework Integration

### ESX Integration (Optional)
If using ESX, you can restrict paramedic menu:

```lua
Config.Permissions.UseParamedicMenu = false  -- Disable for all
Config.Permissions.ParamedicJobs = {'ambulance'}
```

Then in `client/main.lua`, add job check:
```lua
-- Example ESX job check (you'll need to implement)
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Check job before opening paramedic menu
if ESX.GetPlayerData().job.name == 'ambulance' then
    isParamedic = true
end
```

### QBCore Integration (Optional)
Similar to ESX, add job checking as needed.

## Troubleshooting

### UI Won't Open
**Problem**: Pressing F6/F7 doesn't open menus

**Solutions**:
- Check for keybind conflicts with other resources
- Verify NUI is enabled (not in server console)
- Check F8 console for JavaScript errors
- Ensure resource is started (`ensure csrp_medical` in server.cfg)

### No Injuries Showing
**Problem**: Added injuries but nothing appears

**Solutions**:
- Check if resource is started
- Look for errors in server console
- Verify client is connected to server
- Try `/healplayer` then `/addinjury` again

### Equipment Not Working
**Problem**: Can't use treatments, says no equipment

**Solutions**:
- Check you're near a hospital to resupply
- Verify equipment quantities in config
- Try `/resupply` command (admin only)
- Restart resource

### Performance Issues
**Problem**: Server lag or FPS drops

**Solutions**:
- Increase update intervals in config
- Disable debug mode (`Config.Debug = false`)
- Reduce number of nearby player checks
- Check for other conflicting resources

### Admin Commands Not Working
**Problem**: Admin commands are blocked

**Solutions**:
- Enable admin commands: `Config.Permissions.AdminCommands = true`
- If using ACE: verify your ACE permissions are set
- Check you have correct identifier in server.cfg
- Try from server console (always works)

## Testing Checklist

Before going live:
- [ ] Resource starts without errors
- [ ] Patient menu opens (F6)
- [ ] Paramedic menu opens (F7)
- [ ] Can add test injuries
- [ ] Vitals update correctly
- [ ] Treatments work
- [ ] Equipment depletes
- [ ] Hospital resupply works
- [ ] Admin commands work
- [ ] Multi-player sync works
- [ ] No console errors
- [ ] ACE permissions work (if enabled)

## Getting Help

If you encounter issues:
1. Check this installation guide
2. Read the main README.md
3. Look for errors in F8 console
4. Check server console for errors
5. Create an issue on GitHub with:
   - Error messages
   - Steps to reproduce
   - Server configuration
   - FiveM version

## Next Steps

After installation:
1. Test all features thoroughly
2. Customize config to your liking
3. Train your paramedic team
4. Set up ACE permissions for security
5. Add custom hospital locations
6. Adjust vital signs ranges if needed

---

**Congratulations! Your CSRP Medical System is ready! 🚑**
