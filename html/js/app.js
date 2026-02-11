// ==========================================
// CSRP Medical System - Main App JS
// ==========================================

let darkMode = localStorage.getItem('csrp-medical-darkmode') === 'true' || false;
let currentMenu = null;
let patientData = null;
let equipmentData = null;

// ==========================================
// UTILITY FUNCTIONS
// ==========================================

// Safe fetch wrapper with error handling
async function post(url, data = {}) {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(data)
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error(`Fetch error for ${url}:`, error);
        // Return empty object instead of failing
        return {};
    }
}

// Alternative post method for when fetch fails (dev mode)
function postNUI(action, data = {}) {
    if (window.invokeNative) {
        // In-game
        return post(action, data);
    } else {
        // Browser dev mode
        console.log(`[DEV] NUI Callback: ${action}`, data);
        return Promise.resolve({});
    }
}

// ==========================================
// DARK MODE SYSTEM
// ==========================================

function initDarkMode() {
    const body = document.body;
    const toggle = document.getElementById('darkModeToggle');
    
    if (darkMode) {
        body.classList.add('dark-mode');
        if (toggle) toggle.checked = true;
    }
    
    if (toggle) {
        toggle.addEventListener('change', toggleDarkMode);
    }
}

function toggleDarkMode() {
    darkMode = !darkMode;
    document.body.classList.toggle('dark-mode');
    localStorage.setItem('csrp-medical-darkmode', darkMode);
    
    // Notify Lua side
    postNUI('darkModeChanged', { enabled: darkMode });
}

// ==========================================
// MENU SYSTEM
// ==========================================

function openMenu(menuType, data) {
    currentMenu = menuType;
    
    // Show app container
    const app = document.getElementById('app');
    if (app) {
        app.style.display = 'flex';
    }
    
    // Hide all menus first
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    // Show requested menu
    const menu = document.getElementById(`${menuType}Menu`);
    if (menu) {
        menu.style.display = 'flex';
        
        // Populate menu based on type
        switch(menuType) {
            case 'patient':
                populatePatientMenu(data);
                break;
            case 'paramedic':
                populateParamedicMenu(data);
                break;
            case 'mci':
                populateMCIMenu(data);
                break;
            case 'equipment':
                populateEquipmentMenu(data);
                break;
        }
    }
}

function closeMenu() {
    document.querySelectorAll('.menu-container').forEach(menu => {
        menu.style.display = 'none';
    });
    
    // Hide app container
    const app = document.getElementById('app');
    if (app) {
        app.style.display = 'none';
    }
    
    currentMenu = null;
    
    // Notify Lua
    postNUI('closeMenu', {});
}

// ==========================================
// PATIENT MENU
// ==========================================

function populatePatientMenu(data) {
    patientData = data;
    
    // Update vitals display
    updateVitalsDisplay('patient', data.vitals);
    
    // Update injuries list
    const injuriesList = document.getElementById('patientInjuriesList');
    if (injuriesList) {
        injuriesList.innerHTML = '';
        
        if (data.injuries && data.injuries.length > 0) {
            data.injuries.forEach(injury => {
                const injuryCard = createInjuryCard(injury);
                injuriesList.appendChild(injuryCard);
            });
        } else {
            injuriesList.innerHTML = '<div class="no-injuries">No injuries detected</div>';
        }
    }
    
    // Update pain level
    const painLevel = document.getElementById('painLevel');
    const painBar = document.getElementById('painBar');
    if (painLevel && painBar && data.pain) {
        painLevel.textContent = `${data.pain}%`;
        painBar.style.width = `${data.pain}%`;
        painBar.className = 'pain-bar ' + getPainClass(data.pain);
    }
    
    // Update condition
    const conditionText = document.getElementById('conditionText');
    if (conditionText && data.condition) {
        conditionText.textContent = data.condition;
        conditionText.className = 'condition-text ' + getConditionClass(data.condition);
    }
}

function createInjuryCard(injury) {
    const card = document.createElement('div');
    card.className = 'injury-card severity-' + injury.severity;
    
    card.innerHTML = `
        <div class="injury-header">
            <div class="injury-icon">
                <i class="${getInjuryIcon(injury.type)}"></i>
            </div>
            <div class="injury-info">
                <h3>${injury.name}</h3>
                <span class="injury-location">${injury.bodyZone}</span>
            </div>
            <div class="injury-severity">
                <span class="severity-badge ${injury.severity}">${injury.severity}</span>
            </div>
        </div>
        <div class="injury-body">
            <div class="injury-symptoms">
                ${injury.symptoms ? injury.symptoms.map(s => `<span class="symptom-tag">${s}</span>`).join('') : ''}
            </div>
            ${injury.treatments && injury.treatments.length > 0 ? `
                <div class="injury-treatments">
                    <strong>Applied Treatments:</strong>
                    <ul>
                        ${injury.treatments.map(t => `<li>${t}</li>`).join('')}
                    </ul>
                </div>
            ` : ''}
        </div>
    `;
    
    return card;
}

// ==========================================
// PARAMEDIC MENU
// ==========================================

function populateParamedicMenu(data) {
    patientData = data.patient;
    equipmentData = data.equipment;
    
    // Update patient info header
    updatePatientHeader(data.patient);
    
    // Update vitals
    updateVitalsDisplay('paramedic', data.patient.vitals);
    
    // Update body map
    updateBodyMap(data.patient.injuries);
    
    // Update injury list
    updateParamedicInjuryList(data.patient.injuries);
    
    // Update equipment inventory
    updateEquipmentInventory(data.equipment);
    
    // Update assessment checklist
    updateAssessmentChecklist(data.patient.assessments);
}

function updatePatientHeader(patient) {
    const header = document.getElementById('patientHeader');
    if (!header) return;
    
    header.innerHTML = `
        <div class="patient-basic-info">
            <h2>${patient.name || 'Unknown Patient'}</h2>
            <span class="patient-id">ID: ${patient.id || 'N/A'}</span>
        </div>
        <div class="patient-status">
            <div class="consciousness-badge ${getConsciousnessClass(patient.consciousness)}">
                ${patient.consciousness || 'Unknown'}
            </div>
            <div class="priority-badge ${patient.priority ? 'priority-' + patient.priority : ''}">
                ${patient.priority ? 'P' + patient.priority : 'Not Triaged'}
            </div>
        </div>
    `;
}

function updateVitalsDisplay(context, vitals) {
    if (!vitals) return;
    
    const prefix = context === 'paramedic' ? 'para' : 'patient';
    
    // Heart Rate
    updateVitalElement(`${prefix}HeartRate`, vitals.heartRate, 'bpm', getHRClass(vitals.heartRate));
    
    // Blood Pressure
    const bpElement = document.getElementById(`${prefix}BloodPressure`);
    if (bpElement) {
        bpElement.textContent = `${vitals.bpSystolic}/${vitals.bpDiastolic}`;
        bpElement.className = 'vital-value ' + getBPClass(vitals.bpSystolic);
    }
    
    // Respiratory Rate
    updateVitalElement(`${prefix}RespiratoryRate`, vitals.respiratoryRate, '/min', getRRClass(vitals.respiratoryRate));
    
    // SpO2
    updateVitalElement(`${prefix}SpO2`, vitals.spo2, '%', getSpO2Class(vitals.spo2));
    
    // Temperature
    updateVitalElement(`${prefix}Temperature`, vitals.temperature, '°C', getTempClass(vitals.temperature));
    
    // Update vital trend arrows if available
    if (vitals.trends) {
        updateVitalTrends(prefix, vitals.trends);
    }
}

function updateVitalElement(elementId, value, unit, className) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = value ? `${value} ${unit}` : 'N/A';
        element.className = 'vital-value ' + className;
    }
}

function updateBodyMap(injuries) {
    // Clear previous highlights
    document.querySelectorAll('.body-part').forEach(part => {
        part.className = 'body-part';
    });
    
    // Highlight injured body parts
    if (injuries && injuries.length > 0) {
        injuries.forEach(injury => {
            const bodyPart = document.getElementById(`bodyPart-${injury.bodyZone}`);
            if (bodyPart) {
                bodyPart.classList.add('injured');
                bodyPart.classList.add('severity-' + injury.severity);
                
                // Add click handler
                bodyPart.onclick = () => showInjuryDetails(injury);
            }
        });
    }
}

function updateParamedicInjuryList(injuries) {
    const list = document.getElementById('paramedicInjuryList');
    if (!list) return;
    
    list.innerHTML = '';
    
    if (!injuries || injuries.length === 0) {
        list.innerHTML = '<div class="no-injuries">No injuries detected - Complete assessment</div>';
        return;
    }
    
    injuries.forEach((injury, index) => {
        const injuryRow = document.createElement('div');
        injuryRow.className = 'injury-row severity-' + injury.severity;
        injuryRow.innerHTML = `
            <div class="injury-number">${index + 1}</div>
            <div class="injury-details">
                <strong>${injury.name}</strong>
                <span class="injury-zone">${injury.bodyZone}</span>
            </div>
            <div class="injury-severity-badge ${injury.severity}">${injury.severity}</div>
            <button class="btn-treat" onclick="openTreatmentMenu(${index})">Treat</button>
        `;
        list.appendChild(injuryRow);
    });
}

function updateEquipmentInventory(equipment) {
    const inventory = document.getElementById('equipmentInventory');
    if (!inventory || !equipment) return;
    
    inventory.innerHTML = '';
    
    Object.keys(equipment).forEach(itemKey => {
        const item = equipment[itemKey];
        const itemDiv = document.createElement('div');
        itemDiv.className = 'equipment-item';
        
        const percentage = (item.current / item.max) * 100;
        let statusClass = 'good';
        if (percentage < 25) statusClass = 'critical';
        else if (percentage < 50) statusClass = 'low';
        
        itemDiv.innerHTML = `
            <div class="equipment-icon">
                <i class="${getEquipmentIcon(itemKey)}"></i>
            </div>
            <div class="equipment-info">
                <span class="equipment-name">${item.name}</span>
                <div class="equipment-bar">
                    <div class="equipment-bar-fill ${statusClass}" style="width: ${percentage}%"></div>
                </div>
                <span class="equipment-count">${item.current} / ${item.max}</span>
            </div>
        `;
        
        inventory.appendChild(itemDiv);
    });
}

function updateAssessmentChecklist(assessments) {
    const checklist = document.getElementById('assessmentChecklist');
    if (!checklist || !assessments) return;
    
    const checks = [
        {key: 'airway', label: 'Airway Clear'},
        {key: 'breathing', label: 'Breathing Assessed'},
        {key: 'circulation', label: 'Circulation Checked'},
        {key: 'disability', label: 'Disability/Neuro'},
        {key: 'exposure', label: 'Exposure/Environment'}
    ];
    
    checklist.innerHTML = checks.map(check => `
        <div class="assessment-check ${assessments[check.key] ? 'completed' : ''}">
            <i class="fas fa-${assessments[check.key] ? 'check-circle' : 'circle'}"></i>
            <span>${check.label}</span>
        </div>
    `).join('');
}

// ==========================================
// MCI (MULTI-CASUALTY INCIDENT) MENU
// ==========================================

function populateMCIMenu(data) {
    const patientGrid = document.getElementById('mciPatientGrid');
    if (!patientGrid || !data.patients) return;
    
    patientGrid.innerHTML = '';
    
    data.patients.forEach(patient => {
        const card = document.createElement('div');
        card.className = `mci-patient-card priority-${patient.priority || 'none'}`;
        card.innerHTML = `
            <div class="mci-card-header">
                <span class="mci-patient-name">${patient.name || 'Unknown'}</span>
                <span class="mci-priority-badge ${patient.priority ? 'P' + patient.priority : ''}">${patient.priority ? 'P' + patient.priority : 'Not Triaged'}</span>
            </div>
            <div class="mci-card-body">
                <div class="mci-vitals-mini">
                    <span>HR: ${patient.vitals.heartRate || '?'}</span>
                    <span>BP: ${patient.vitals.bpSystolic || '?'}/${patient.vitals.bpDiastolic || '?'}</span>
                    <span>SpO2: ${patient.vitals.spo2 || '?'}%</span>
                </div>
                <div class="mci-injury-count">${patient.injuryCount || 0} injuries</div>
            </div>
            <div class="mci-card-footer">
                <button class="btn-mci-assess" onclick="assessMCIPatient(${patient.id})">Assess</button>
                <button class="btn-mci-triage" onclick="triageMCIPatient(${patient.id})">Triage</button>
            </div>
        `;
        patientGrid.appendChild(card);
    });
}

// ==========================================
// TREATMENT ACTIONS
// ==========================================

function openTreatmentMenu(injuryIndex) {
    postNUI('openTreatmentMenu', { injuryIndex: injuryIndex });
}

function performTreatment(treatmentType, injuryIndex) {
    postNUI('performTreatment', { 
        treatment: treatmentType, 
        injuryIndex: injuryIndex 
    });
}

function administerMedication(medicationType) {
    postNUI('administerMedication', { medication: medicationType });
}

function performAssessment(assessmentType) {
    postNUI('performAssessment', { assessment: assessmentType });
}

// ==========================================
// MCI ACTIONS
// ========================================== 

function assessMCIPatient(patientId) {
    postNUI('assessMCIPatient', { patientId: patientId });
}

function triageMCIPatient(patientId) {
    postNUI('triageMCIPatient', { patientId: patientId });
}

function setMCIPriority(patientId, priority) {
    postNUI('setMCIPriority', { patientId: patientId, priority: priority });
}

// ==========================================
// UTILITY FUNCTIONS FOR STYLING
// ==========================================

function getHRClass(hr) {
    if (hr === 0) return 'critical';
    if (hr < 40 || hr > 150) return 'critical';
    if (hr < 60 || hr > 100) return 'warning';
    return 'normal';
}

function getBPClass(systolic) {
    if (systolic < 70) return 'critical';
    if (systolic < 90) return 'warning';
    if (systolic > 140) return 'warning';
    return 'normal';
}

function getRRClass(rr) {
    if (rr === 0) return 'critical';
    if (rr < 8 || rr > 30) return 'critical';
    if (rr < 12 || rr > 20) return 'warning';
    return 'normal';
}

function getSpO2Class(spo2) {
    if (spo2 < 85) return 'critical';
    if (spo2 < 90) return 'warning';
    return 'normal';
}

function getTempClass(temp) {
    if (temp < 32 || temp > 40) return 'critical';
    if (temp < 35 || temp > 38.5) return 'warning';
    return 'normal';
}

function getPainClass(pain) {
    if (pain >= 80) return 'critical';
    if (pain >= 50) return 'warning';
    return 'normal';
}

function getConditionClass(condition) {
    const lower = condition.toLowerCase();
    if (lower.includes('critical') || lower.includes('unstable')) return 'critical';
    if (lower.includes('serious') || lower.includes('moderate')) return 'warning';
    return 'normal';
}

function getConsciousnessClass(consciousness) {
    const lower = consciousness ? consciousness.toLowerCase() : '';
    if (lower.includes('unresponsive')) return 'critical';
    if (lower.includes('pain') || lower.includes('voice')) return 'warning';
    return 'normal';
}

function getInjuryIcon(type) {
    const icons = {
        'blunt': 'fas fa-hand-rock',
        'penetrating': 'fas fa-syringe',
        'burns': 'fas fa-fire',
        'medical': 'fas fa-heartbeat',
        'environmental': 'fas fa-temperature-high',
        'internal': 'fas fa-lungs'
    };
    return icons[type] || 'fas fa-exclamation-triangle';
}

function getEquipmentIcon(key) {
    const icons = {
        'bandage': 'fas fa-band-aid',
        'tourniquet': 'fas fa-slash',
        'splint': 'fas fa-bone',
        'oxygen': 'fas fa-wind',
        'iv': 'fas fa-tint',
        'medication': 'fas fa-pills'
    };
    return icons[key] || 'fas fa-medkit';
}

// ==========================================
// NUI MESSAGE HANDLER
// ==========================================

window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'openMenu':
            openMenu(data.menuType, data.data);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateVitals':
            if (currentMenu === 'patient') {
                updateVitalsDisplay('patient', data.vitals);
            } else if (currentMenu === 'paramedic') {
                updateVitalsDisplay('paramedic', data.vitals);
            }
            break;
        case 'updateInjuries':
            if (currentMenu === 'patient') {
                populatePatientMenu(data);
            } else if (currentMenu === 'paramedic') {
                updateParamedicInjuryList(data.injuries);
            }
            break;
        case 'updateEquipment':
            updateEquipmentInventory(data.equipment);
            break;
        case 'showNotification':
            showNotification(data.message, data.type);
            break;
    }
});

// ==========================================
// KEYBOARD HANDLER
// ==========================================

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

// ==========================================
// NOTIFICATION SYSTEM
// ==========================================

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// ==========================================
// RESUPPLY SYSTEM
// ==========================================

function requestResupply() {
    postNUI('requestResupply', {});
}

// ==========================================
// INITIALIZATION
// ==========================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('CSRP Medical System UI Loaded');
    initDarkMode();
    
    // Setup close buttons
    document.querySelectorAll('.close-menu-btn').forEach(btn => {
        btn.addEventListener('click', closeMenu);
    });
    
    // Setup resupply button
    const resupplyBtn = document.getElementById('resupplyBtn');
    if (resupplyBtn) {
        resupplyBtn.addEventListener('click', requestResupply);
    }
});
