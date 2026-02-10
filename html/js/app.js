// CSRP Medical System - UI JavaScript

let currentMenu = null;
let selectedPatient = null;
let equipmentData = {};
let treatmentsData = {};
let currentTreatmentFilter = 'all';

// Listen for NUI messages
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.type) {
        case 'toggleUI':
            toggleUI(data.show, data.menu, data.data);
            break;
        case 'updateVitals':
            updateVitals(data.vitals);
            break;
    }
});

// Toggle UI visibility
function toggleUI(show, menu, data) {
    const app = document.getElementById('app');
    const patientMenu = document.getElementById('patient-menu');
    const paramedicMenu = document.getElementById('paramedic-menu');
    
    if (show) {
        app.style.display = 'flex';
        currentMenu = menu;
        
        if (menu === 'patient') {
            patientMenu.style.display = 'block';
            paramedicMenu.style.display = 'none';
            
            if (data.vitals) {
                updateVitals(data.vitals);
            }
            if (data.injuries) {
                updateInjuries(data.injuries);
            }
        } else if (menu === 'paramedic') {
            patientMenu.style.display = 'none';
            paramedicMenu.style.display = 'block';
            
            if (data.equipment) {
                equipmentData = data.equipment;
                updateEquipment(data.equipment);
            }
            if (data.treatments) {
                treatmentsData = data.treatments;
                updateTreatments(data.treatments);
            }
            if (data.nearbyPlayers) {
                updatePatientsList(data.nearbyPlayers);
            }
        }
    } else {
        app.style.display = 'none';
        patientMenu.style.display = 'none';
        paramedicMenu.style.display = 'none';
    }
}

// Update vitals display
function updateVitals(vitals) {
    if (!vitals) return;
    
    document.getElementById('hr').textContent = Math.round(vitals.heartRate || 0);
    document.getElementById('bp').textContent = 
        Math.round(vitals.bloodPressureSystolic || 0) + '/' + 
        Math.round(vitals.bloodPressureDiastolic || 0);
    document.getElementById('spo2').textContent = Math.round(vitals.oxygenSaturation || 0);
    document.getElementById('rr').textContent = Math.round(vitals.respiratoryRate || 0);
    document.getElementById('temp').textContent = (vitals.temperature || 0).toFixed(1);
    
    const consciousnessLevels = ['Unresponsive', 'Pain', 'Voice', 'Alert'];
    document.getElementById('consciousness').textContent = 
        consciousnessLevels[Math.min(3, Math.max(0, (vitals.consciousness || 4) - 1))];
    
    // Color code vitals
    colorCodeVital('hr', vitals.heartRate, 60, 100, 40, 150);
    colorCodeVital('spo2', vitals.oxygenSaturation, 95, 100, 85, 94);
    colorCodeVital('temp', vitals.temperature, 36.1, 37.2, 35, 38);
}

// Color code vital sign
function colorCodeVital(elementId, value, normalMin, normalMax, criticalMin, criticalMax) {
    const element = document.getElementById(elementId);
    element.classList.remove('normal', 'warning', 'critical');
    
    if (value >= normalMin && value <= normalMax) {
        element.classList.add('normal');
    } else if (value >= criticalMin && value <= criticalMax) {
        element.classList.add('warning');
    } else {
        element.classList.add('critical');
    }
}

// Update injuries list
function updateInjuries(injuries) {
    const injuriesList = document.getElementById('injuries-list');
    
    if (!injuries || injuries.length === 0) {
        injuriesList.innerHTML = '<p style="color: #666;">No injuries detected</p>';
        return;
    }
    
    let html = '';
    injuries.forEach(injury => {
        const severityClass = ['minor', 'moderate', 'severe', 'critical'][injury.severity - 1] || 'moderate';
        const severityText = ['Minor', 'Moderate', 'Severe', 'Critical'][injury.severity - 1] || 'Moderate';
        
        html += `
            <div class="injury-item">
                <div class="injury-name">
                    ${injury.type.replace(/_/g, ' ').toUpperCase()}
                    <span class="injury-severity severity-${severityClass}">${severityText}</span>
                </div>
                <div class="injury-details">
                    Location: ${injury.zone.replace(/_/g, ' ').toUpperCase()}
                    ${injury.bleeding > 0 ? ' - Bleeding: ' + Math.round(injury.bleeding) + '%' : ''}
                </div>
            </div>
        `;
    });
    
    injuriesList.innerHTML = html;
}

// Update patients list
function updatePatientsList(patients) {
    const patientsList = document.getElementById('patients-list');
    
    if (!patients || patients.length === 0) {
        patientsList.innerHTML = '<p style="color: #666; padding: 20px;">No patients nearby</p>';
        return;
    }
    
    let html = '';
    patients.forEach(patient => {
        html += `
            <div class="patient-card" onclick="selectPatient(${patient.serverId}, '${patient.name}')">
                <div class="patient-name">${patient.name}</div>
                <div class="patient-distance">Distance: ${patient.distance}m</div>
            </div>
        `;
    });
    
    patientsList.innerHTML = html;
}

// Select patient
function selectPatient(serverId, name) {
    selectedPatient = serverId;
    document.getElementById('selected-patient').style.display = 'block';
    
    // Request patient vitals
    fetch(`https://csrp_medical/checkVitals`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({targetId: serverId})
    });
}

// Update treatments list
function updateTreatments(treatments) {
    const treatmentsList = document.getElementById('treatments-list');
    
    let html = '';
    for (const [id, treatment] of Object.entries(treatments)) {
        if (currentTreatmentFilter !== 'all' && treatment.category !== currentTreatmentFilter) {
            continue;
        }
        
        const hasEquipment = !treatment.uses_equipment || 
            (equipmentData[treatment.equipment] && equipmentData[treatment.equipment] > 0);
        
        html += `
            <div class="treatment-card">
                <div class="treatment-name">${treatment.name}</div>
                <div class="treatment-description">${treatment.description}</div>
                <button class="treatment-btn" 
                    onclick="applyTreatment('${id}')" 
                    ${!hasEquipment || !selectedPatient ? 'disabled' : ''}>
                    Apply Treatment
                </button>
            </div>
        `;
    }
    
    treatmentsList.innerHTML = html || '<p style="color: #666; padding: 20px;">No treatments available</p>';
}

// Filter treatments
function filterTreatments(category) {
    currentTreatmentFilter = category;
    
    // Update active button
    document.querySelectorAll('.category-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    updateTreatments(treatmentsData);
}

// Update equipment display
function updateEquipment(equipment) {
    const equipmentList = document.getElementById('equipment-list');
    
    let html = '';
    for (const [name, quantity] of Object.entries(equipment)) {
        let quantityClass = '';
        if (quantity === 0) quantityClass = 'empty';
        else if (quantity <= 2) quantityClass = 'low';
        
        html += `
            <div class="equipment-item">
                <span class="equipment-name">${name.replace(/([A-Z])/g, ' $1').trim()}</span>
                <span class="equipment-quantity ${quantityClass}">${quantity}</span>
            </div>
        `;
    }
    
    equipmentList.innerHTML = html;
}

// Tab switching
function showTab(tabName) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    event.target.classList.add('active');
    document.getElementById(tabName + '-tab').classList.add('active');
}

// Close menu
function closeMenu() {
    fetch(`https://csrp_medical/close`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
}

// Request help
function requestHelp() {
    // This would trigger a distress call
    alert('Help request sent to nearby paramedics!');
}

// Apply treatment
function applyTreatment(treatmentId) {
    if (!selectedPatient) {
        alert('No patient selected');
        return;
    }
    
    fetch(`https://csrp_medical/applyTreatment`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            targetId: selectedPatient,
            treatmentId: treatmentId
        })
    });
}

// Perform ABCDE
function performABCDE() {
    if (!selectedPatient) return;
    
    fetch(`https://csrp_medical/performABCDE`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({targetId: selectedPatient})
    });
}

// Perform secondary survey
function performSecondarySurvey() {
    if (!selectedPatient) return;
    
    fetch(`https://csrp_medical/performSecondarySurvey`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({targetId: selectedPatient})
    });
}

// Check vitals
function checkVitals() {
    if (!selectedPatient) return;
    
    fetch(`https://csrp_medical/checkVitals`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({targetId: selectedPatient})
    });
}

// ESC key to close
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        closeMenu();
    }
});
