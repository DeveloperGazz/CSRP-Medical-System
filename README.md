# CSRP Medical System

A comprehensive, modular medical system for FiveM UK RP servers providing an immersive and realistic paramedic experience.

## 🚑 Features

### Comprehensive Injury System
- **40+ Injury Types** across 5 categories:
  - Trauma (gunshot wounds, stab wounds, fractures, etc.)
  - Burns (1st, 2nd, 3rd degree, chemical, electrical)
  - Medical Emergencies (cardiac arrest, stroke, asthma, overdose, etc.)
  - Environmental (hypothermia, heat stroke, drowning, smoke inhalation)
  - Internal Injuries (pneumothorax, internal bleeding, concussion, TBI)

- **Body Zone System**: Head, Chest, Abdomen, Left/Right Arms, Left/Right Legs
- **Severity Levels**: Minor, Moderate, Severe, Critical

### Real-Time Progression
- Dynamic injury progression and deterioration
- Bleeding progression with blood loss
- Shock development
- Airway obstruction for unconscious patients
- Oxygen desaturation
- Cardiac deterioration
- Secondary complications

### Vital Signs Monitoring
- **Heart Rate** (0-200+ BPM)
- **Blood Pressure** (Systolic/Diastolic)
- **Respiratory Rate** (Breaths per minute)
- **Oxygen Saturation** (0-100%)
- **Temperature** (°C)
- **Consciousness** (AVPU Scale)
- **Pupil Response**

Vitals dynamically change based on injuries, treatments, and time elapsed.

### UK Paramedic Treatments
**Airway Management:**
- Head tilt/chin lift, Recovery position
- OPA (Oropharyngeal Airway), NPA (Nasopharyngeal Airway)
- Suction

**Breathing Support:**
- Oxygen therapy (nasal cannula, non-rebreather mask)
- Bag-valve-mask ventilation
- Chest seals, Needle decompression

**Bleeding Control:**
- Direct pressure, Pressure dressings
- Tourniquets, Hemostatic gauze
- Pelvic binder, IV fluids

**Medications:**
- Pain relief: Paracetamol, Morphine, Fentanyl, Entonox
- Cardiac: Adrenaline, Aspirin, GTN
- Respiratory: Salbutamol
- Emergency: Glucose, Naloxone, Midazolam

**Other:**
- CPR/Defibrillation
- Splinting, Cervical collar
- Wound/burn dressings
- Warming/cooling measures

### Equipment Charge System
- No inventory system - uses charge-based equipment tracking
- Realistic UK ambulance stock quantities
- Resupply at hospital locations
- Visual indicators for equipment levels

### Modern NUI Interface
- NHS-inspired blue color scheme
- Patient menu: View condition, vitals, request help
- Paramedic tablet: Assess patients, apply treatments, track equipment
- Body map visualization
- Color-coded severity indicators
- Responsive design

## 📦 Installation

1. **Download** the resource
2. **Extract** to your FiveM server's `resources` folder
3. **Add** to your `server.cfg`:
   ```
   ensure csrp_medical
   ```
4. **Restart** your server

## ⚙️ Configuration

Edit `config.lua` to customize:
- Vital signs ranges and thresholds
- Injury progression rates
- Equipment quantities
- Treatment effectiveness
- Hospital locations
- UI colors and keybinds
- Permission settings
- Debug mode

### Key Configuration Options

```lua
-- Permissions
Config.Permissions.UseParamedicMenu = true
Config.Permissions.ParamedicJobs = {'ambulance', 'doctor', 'ems'}

-- Progression rates
Config.Progression.BleedingRate = 1.0
Config.Progression.ProgressionInterval = 10000 -- 10 seconds

-- UI Keybinds
Config.UI.OpenPatientMenu = 'F6'
Config.UI.OpenParamedicMenu = 'F7'
```

## 🎮 Usage

### For Players
- Press **F6** to open Patient Menu
- View your vitals and injuries
- Request help from nearby paramedics
- See applied treatments

### For Paramedics
- Press **F7** to open Paramedic Tablet
- Select nearby patients to assess
- Perform ABCDE or secondary surveys
- Check vitals
- Apply appropriate treatments
- Monitor equipment levels
- Resupply at hospitals (approach hospital and press E)

## 📋 Commands

### Admin Commands
- `/addinjury [playerId] [injuryType] [bodyZone] [severity]` - Add injury to player
- `/healplayer [playerId]` - Fully heal a player
- `/resupply` - Resupply equipment (also available at hospitals)
- `/spawndummy` - Spawn training dummy patient
- `/medebug` - Toggle debug mode
- `/checkvitals` - Check your own vitals

### Examples
```
/addinjury 1 gunshot_wound chest 3
/addinjury 2 cardiac_arrest chest 4
/healplayer 1
```

## 🏥 Hospital Locations

Default hospital resupply points:
- **Pillbox Hill Medical Center**
- **Sandy Shores Medical Center**
- **Paleto Bay Medical Center**

Add more in `config.lua` under `Config.Hospitals`.

## 🔧 Technical Details

### File Structure
```
CSRP-Medical-System/
├── fxmanifest.lua
├── config.lua
├── client/
│   ├── main.lua          # Core client initialization
│   ├── injury.lua        # Injury management
│   ├── vitals.lua        # Vital signs system
│   ├── progression.lua   # Injury progression
│   ├── treatments.lua    # Treatment application
│   └── ui.lua            # NUI interface
├── server/
│   ├── main.lua          # Server initialization
│   ├── sync.lua          # Player synchronization
│   └── admin.lua         # Admin commands
├── html/
│   ├── index.html
│   ├── css/style.css
│   └── js/app.js
└── modules/
    ├── injuries.lua      # Injury definitions
    ├── treatments.lua    # Treatment definitions
    └── equipment.lua     # Equipment management
```

### Framework
- **Standalone** - No ESX/QBCore dependencies
- **Modular** - Easy to extend with new injuries/treatments
- **Optimized** - Minimal resource usage
- **Networked** - Full multiplayer support

## 🎯 Gameplay Balance

The system is designed to:
- Keep paramedics engaged with dynamic progression
- Be realistic without being overwhelming
- Provide clear visual feedback
- Support both casual and serious medical RP
- Encourage proper medical procedures

## 🔒 Security

- Input validation on all network events
- Sanitized NUI callbacks
- Server-side verification for critical operations
- Exploit prevention measures

## 🐛 Troubleshooting

**UI won't open:**
- Check that F6/F7 keybinds aren't conflicting
- Verify NUI focus is working (try F8 console)
- Check for JavaScript errors in F8

**Treatments not working:**
- Ensure player has required equipment
- Check that target player is in range
- Verify animations are loading correctly

**Performance issues:**
- Reduce `ProgressionInterval` in config
- Disable debug mode
- Check for conflicting resources

## 📝 Changelog

### Version 1.0.0 (Initial Release)
- Complete injury system with 40+ injury types
- Full vital signs monitoring
- Real-time progression system
- UK paramedic treatment options
- Equipment charge system
- NHS-inspired NUI interface
- Admin commands
- Hospital resupply system

## 🤝 Support

For issues, suggestions, or contributions:
- Create an issue on GitHub
- Join our Discord server
- Submit a pull request

## 📄 License

This resource is released under the MIT License.

## 🙏 Credits

Developed by **CSRP Development Team**

Special thanks to the FiveM community for inspiration and support.

---

**Note:** This is a roleplay enhancement resource. Always prioritize player experience and server performance.

## 🚀 Future Features

Planned additions:
- Triage system (UK METHANE)
- Medical report generation
- Training mode with dummy patients
- Multi-casualty incident support
- Voice lines and sound effects
- Additional injury types
- Advanced diagnostic tools
- Patient history tracking
- Ambulance transport effects
- More UK-specific medications
