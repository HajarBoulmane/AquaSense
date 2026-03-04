// ============================================================
// AquaSense — app.js
// Firebase Realtime DB + Leaflet Map + OpenWeatherMap
// ============================================================

import { initializeApp }
  from "https://www.gstatic.com/firebasejs/10.11.0/firebase-app.js";
import { getDatabase, ref, onValue, set, push, remove }
  from "https://www.gstatic.com/firebasejs/10.11.0/firebase-database.js";

// ── FIREBASE CONFIG ───────────────────────────────────────────
// ⚠️  FOR GITHUB: move these values to a separate config.js file
//     and add config.js to your .gitignore
//     Then import: import { FB } from './config.js';
//
//     For a school/homework project it is safe to leave as-is —
//     but LOCK your Firebase Rules so only your ESP32 can WRITE.
//     (Firebase Console → Realtime Database → Rules)
const FB = {
  apiKey:            "AIzaSyAqHZa6CS_Ewevevsy3x2M8jl62PF0P2FA",
  authDomain:        "aquasense-58345.firebaseapp.com",
  databaseURL:       "https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app",
  projectId:         "aquasense-58345",
  storageBucket:     "aquasense-58345.firebasestorage.app",
  messagingSenderId: "453888586687",
  appId:             "1:453888586687:web:a161df037d9ded93f8670a",
};

// ── OPENWEATHERMAP (free key — replace with yours for production) ──
// Get a free key at: https://openweathermap.org/api
const OWM_KEY = ""; // leave empty to use simulated weather
const OWM_URL = "https://api.openweathermap.org/data/2.5/forecast";

// ── MOROCCO CITIES ─────────────────────────────────────────────
export const MOROCCO_CITIES = [
  { name:"Casablanca",  lat:33.5731, lon:-7.5898,  region:"Casablanca-Settat"   },
  { name:"Rabat",       lat:34.0132, lon:-6.8326,  region:"Rabat-Salé-Kénitra"  },
  { name:"Marrakech",   lat:31.6295, lon:-7.9811,  region:"Marrakech-Safi"      },
  { name:"Fès",         lat:34.0181, lon:-5.0078,  region:"Fès-Meknès"         },
  { name:"Tanger",      lat:35.7595, lon:-5.8340,  region:"Tanger-Tétouan-Al Hoceïma" },
  { name:"Agadir",      lat:30.4278, lon:-9.5981,  region:"Souss-Massa"        },
  { name:"Oujda",       lat:34.6851, lon:-1.9114,  region:"Oriental"           },
  { name:"Meknès",      lat:33.8935, lon:-5.5473,  region:"Fès-Meknès"         },
  { name:"Kenitra",     lat:34.2610, lon:-6.5802,  region:"Rabat-Salé-Kénitra" },
  { name:"Tétouan",     lat:35.5785, lon:-5.3684,  region:"Tanger-Tétouan-Al Hoceïma" },
  { name:"Safi",        lat:32.2994, lon:-9.2372,  region:"Marrakech-Safi"     },
  { name:"El Jadida",   lat:33.2549, lon:-8.5079,  region:"Casablanca-Settat"  },
  { name:"Béni Mellal", lat:32.3373, lon:-6.3498,  region:"Béni Mellal-Khénifra" },
  { name:"Nador",       lat:35.1740, lon:-2.9283,  region:"Oriental"           },
  { name:"Laâyoune",    lat:27.1536, lon:-13.2033, region:"Laâyoune-Sakia El Hamra" },
  { name:"Dakhla",      lat:23.6848, lon:-15.9578, region:"Dakhla-Oued Ed-Dahab" },
  { name:"Essaouira",   lat:31.5085, lon:-9.7595,  region:"Marrakech-Safi"     },
  { name:"Ouarzazate",  lat:30.9335, lon:-6.9370,  region:"Drâa-Tafilalet"     },
  { name:"Ifrane",      lat:33.5228, lon:-5.1069,  region:"Fès-Meknès"         },
  { name:"Taroudant",   lat:30.4728, lon:-8.8749,  region:"Souss-Massa"        },
  { name:"Tiznit",      lat:29.6974, lon:-9.7316,  region:"Souss-Massa"        },
  { name:"Guelmim",     lat:28.9870, lon:-10.0574, region:"Guelmim-Oued Noun"  },
  { name:"Errachidia",  lat:31.9319, lon:-4.4261,  region:"Drâa-Tafilalet"     },
  { name:"Zagora",      lat:30.3321, lon:-5.8375,  region:"Drâa-Tafilalet"     },
  { name:"Tinghir",     lat:31.5228, lon:-5.5256,  region:"Drâa-Tafilalet"     },
];

// ── DEMO SENSORS (placed across all Morocco) ──────────────────
const DEMO_SENSORS = [
  { id:"well-01", name:"Puits Casablanca",  type:"well",      location:"Grand Casablanca",    lat:33.57, lon:-7.59,  level_pct:72, capacity_m3:500, temp_c:19.2, ph:7.1, online:true  },
  { id:"well-02", name:"Puits Marrakech",   type:"well",      location:"Marrakech-Safi",      lat:31.63, lon:-7.98,  level_pct:18, capacity_m3:400, temp_c:23.5, ph:7.4, online:true  },
  { id:"res-01",  name:"Réservoir Fès",     type:"reservoir", location:"Fès-Meknès",          lat:34.02, lon:-5.01,  level_pct:55, capacity_m3:800, temp_c:17.8, ph:7.0, online:true  },
  { id:"well-03", name:"Puits Agadir",      type:"well",      location:"Souss-Massa",         lat:30.43, lon:-9.60,  level_pct:41, capacity_m3:350, temp_c:22.1, ph:7.2, online:true  },
  { id:"tank-01", name:"Réservoir Oujda",   type:"tank",      location:"Oriental",            lat:34.69, lon:-1.91,  level_pct:67, capacity_m3:300, temp_c:16.5, ph:7.3, online:true  },
  { id:"well-04", name:"Puits Ouarzazate",  type:"well",      location:"Drâa-Tafilalet",      lat:30.93, lon:-6.94,  level_pct:22, capacity_m3:300, temp_c:26.3, ph:7.5, online:true  },
  { id:"well-05", name:"Puits Taroudant",   type:"well",      location:"Souss-Massa",         lat:30.47, lon:-8.87,  level_pct:14, capacity_m3:350, temp_c:24.8, ph:7.1, online:false },
  { id:"res-02",  name:"Réservoir Rabat",   type:"reservoir", location:"Rabat-Salé-Kénitra",  lat:34.01, lon:-6.83,  level_pct:83, capacity_m3:600, temp_c:18.2, ph:7.0, online:true  },
  { id:"well-06", name:"Puits Laâyoune",    type:"well",      location:"Laâyoune-Sakia El Hamra",lat:27.15,lon:-13.20,level_pct:31, capacity_m3:200, temp_c:28.5, ph:7.6, online:true  },
  { id:"well-07", name:"Puits Dakhla",      type:"well",      location:"Dakhla-Oued Ed-Dahab",lat:23.68, lon:-15.96, level_pct:26, capacity_m3:180, temp_c:27.2, ph:7.4, online:true  },
  { id:"tank-02", name:"Réservoir Tanger",  type:"tank",      location:"Tanger-Tétouan",      lat:35.76, lon:-5.83,  level_pct:78, capacity_m3:400, temp_c:15.8, ph:6.9, online:true  },
  { id:"well-08", name:"Puits Errachidia",  type:"well",      location:"Drâa-Tafilalet",      lat:31.93, lon:-4.43,  level_pct:34, capacity_m3:250, temp_c:25.9, ph:7.3, online:true  },
];

// ── STATE ─────────────────────────────────────────────────────
let sensors     = {};
let histData    = {};
let updateCount = 0;
let dataMode    = 'firebase';
let demoTimer   = null;
let THRESH_CRITICAL = 20;
let THRESH_WARN     = 40;
let leafletMap  = null;
let mapMarkers  = {};
let charts      = {};
let currentWeatherCity = MOROCCO_CITIES[0];

// ── TRANSLATIONS ──────────────────────────────────────────────
const T = {
  en:{
    dashboard:"Dashboard",wells:"Wells & Tanks",alerts:"Alerts",map:"Map View",
    predictions:"AI Predictions",weather:"Weather",history:"History",settings:"Settings",
    monitoring:"Monitoring",intelligence:"Intelligence",dataLabel:"Data",
    totalWater:"💧 Total Water",sensorsOnline:"📡 Sensors Online",
    criticalWells:"🚨 Critical Wells",warnings:"⚠️ Warnings",
    normal:"Normal",warning:"Warning",critical:"Critical",offline:"Offline",
    connected:"Firebase Connected",demo:"Demo Mode",
    name:"Name",type:"Type",level:"Level %",volume:"Volume m³",temp:"Temp °C",
    ph:"pH",lastSeen:"Last Seen",status:"Status",
    acknowledge:"Acknowledge",notify:"Notify Authorities",
    save:"Save Settings",settingsSaved:"Settings saved to Firebase!",
    confidence:"Confidence",shortageRisk:"⚠️ Shortage Risk",
    stable:"✅ Stable",declining:"📉 Declining",
  },
  fr:{
    dashboard:"Tableau de bord",wells:"Puits & Réservoirs",alerts:"Alertes",map:"Carte",
    predictions:"Prédictions IA",weather:"Météo",history:"Historique",settings:"Paramètres",
    monitoring:"Surveillance",intelligence:"Intelligence",dataLabel:"Données",
    totalWater:"💧 Total Eau",sensorsOnline:"📡 Capteurs en ligne",
    criticalWells:"🚨 Puits critiques",warnings:"⚠️ Avertissements",
    normal:"Normal",warning:"Avertissement",critical:"Critique",offline:"Hors ligne",
    connected:"Firebase Connecté",demo:"Mode Démo",
    name:"Nom",type:"Type",level:"Niveau %",volume:"Volume m³",temp:"Temp °C",
    ph:"pH",lastSeen:"Vu il y a",status:"Statut",
    acknowledge:"Accusé de réception",notify:"Notifier les autorités",
    save:"Sauvegarder",settingsSaved:"Paramètres sauvegardés!",
    confidence:"Confiance",shortageRisk:"⚠️ Risque de pénurie",
    stable:"✅ Stable",declining:"📉 En déclin",
  },
  ar:{
    dashboard:"لوحة التحكم",wells:"الآبار والخزانات",alerts:"التنبيهات",map:"الخريطة",
    predictions:"توقعات الذكاء الاصطناعي",weather:"الطقس",history:"السجل",settings:"الإعدادات",
    monitoring:"المراقبة",intelligence:"الذكاء",dataLabel:"البيانات",
    totalWater:"💧 إجمالي المياه",sensorsOnline:"📡 أجهزة متصلة",
    criticalWells:"🚨 آبار حرجة",warnings:"⚠️ تحذيرات",
    normal:"طبيعي",warning:"تحذير",critical:"حرج",offline:"غير متصل",
    connected:"Firebase متصل",demo:"وضع تجريبي",
    name:"الاسم",type:"النوع",level:"المستوى%",volume:"الحجم م³",temp:"الحرارة",
    ph:"pH",lastSeen:"آخر ظهور",status:"الحالة",
    acknowledge:"إقرار",notify:"إخطار السلطات",
    save:"حفظ",settingsSaved:"تم حفظ الإعدادات!",
    confidence:"الثقة",shortageRisk:"⚠️ خطر الشح",
    stable:"✅ مستقر",declining:"📉 في انخفاض",
  }
};
let lang = 'en';
const t = k => T[lang]?.[k] || T.en[k] || k;

// ── INIT ──────────────────────────────────────────────────────
export function initApp() {
  initCharts();
  startClock();
  connectFirebase();
}

// ── FIREBASE ──────────────────────────────────────────────────
function connectFirebase() {
  try {
    const fbApp = initializeApp(FB);
    const db    = getDatabase(fbApp);

    onValue(ref(db,'sensors'), snap => {
      const data = snap.val();
      if (!data) { seedDemoToFirebase(db); return; }
      sensors = {};
      Object.entries(data).forEach(([id,s]) => { sensors[id] = {id,...s}; });
      updateCount++;
      refresh();
    }, err => {
      console.warn('Firebase error, falling back to demo:', err.message);
      toast('w','Firebase rules blocked — running Demo Mode');
      startDemo();
    });

    onValue(ref(db,'settings'), snap => {
      const s = snap.val();
      if (s?.thresholds?.critical) THRESH_CRITICAL = s.thresholds.critical;
      if (s?.thresholds?.warning)  THRESH_WARN     = s.thresholds.warning;
      syncThresholdInputs();
    });

    setConn('live');
    toast('s','🔥 Firebase connected!');
    window.__db = db; // store for writes

  } catch(e) {
    console.error(e);
    toast('e','Firebase init error — check config');
    startDemo();
  }
}

async function seedDemoToFirebase(db) {
  loadDemoSensors();
  for (const [id,s] of Object.entries(sensors)) {
    await set(ref(db,`sensors/${id}`), {
      name:s.name, type:s.type, location:s.location,
      lat:s.lat, lon:s.lon,
      level_pct:s.level_pct, volume_m3:s.volume_m3,
      capacity_m3:s.capacity_m3, temp_c:s.temp_c, ph:s.ph,
      online:s.online, last_ts:Math.floor(Date.now()/1000)
    });
  }
  toast('i','Demo sensors seeded into Firebase. Connect your ESP32 to overwrite with real data!');
}

function loadDemoSensors() {
  sensors = {};
  DEMO_SENSORS.forEach(s => {
    sensors[s.id] = {...s, volume_m3:Math.round((s.level_pct/100)*s.capacity_m3), last_ts:Date.now()/1000};
  });
}

function startDemo() {
  dataMode = 'demo';
  loadDemoSensors();
  setConn('demo');
  refresh();
  demoTimer = setInterval(()=>{
    Object.values(sensors).forEach(s => {
      if (!s.online) return;
      s.level_pct = Math.max(4, Math.min(100, s.level_pct + (Math.random()-.53)*2));
      s.volume_m3 = Math.round((s.level_pct/100)*s.capacity_m3);
      s.last_ts   = Date.now()/1000;
    });
    updateCount++;
    refresh();
  }, 5000);
}

// ── CONNECTION STATUS ─────────────────────────────────────────
function setConn(state) {
  const dot  = $('conn-dot');
  const lbl  = $('conn-label');
  const sub  = $('conn-sub');
  const chip = $('live-chip');
  const ctxt = $('live-chip-text');
  if (!dot) return;
  if (state==='live') {
    dot.className='conn-dot live'; lbl.textContent=t('connected'); sub.textContent='Real-time RTDB';
    chip.className='live-pill live'; ctxt.textContent='🔥 Firebase Live';
    $('mode-badge').textContent='🔥 LIVE';
  } else if (state==='demo') {
    dot.className='conn-dot demo'; lbl.textContent=t('demo'); sub.textContent='Simulated — 5s updates';
    chip.className='live-pill demo'; ctxt.textContent='▶ Demo Mode';
    $('mode-badge').textContent='▶ DEMO';
  } else {
    dot.className='conn-dot error'; lbl.textContent='Error'; sub.textContent='Check Firebase rules';
    chip.className='live-pill error'; ctxt.textContent='⚠️ Error';
  }
}

// ── MAIN REFRESH ──────────────────────────────────────────────
function refresh() {
  const list = Object.values(sensors);
  if (!list.length) return;

  const tc = +($('thresh-critical')?.value||20);
  const tw = +($('thresh-warn')?.value||40);
  THRESH_CRITICAL = tc; THRESH_WARN = tw;

  const totalVol  = list.reduce((a,s)=>a+(s.volume_m3||0),0);
  const online    = list.filter(s=>s.online).length;
  const critical  = list.filter(s=>s.online&&s.level_pct<=tc).length;
  const warned    = list.filter(s=>s.online&&s.level_pct>tc&&s.level_pct<=tw).length;
  const avgLvl    = Math.round(list.reduce((a,s)=>a+s.level_pct,0)/list.length);

  setVal('stat-total',    Math.round(totalVol)+' m³');
  setVal('stat-online',   online+'/'+list.length);
  setVal('stat-critical', critical);
  setVal('stat-warned',   warned);
  setTxt('avg-level',   avgLvl+'%');
  setTxt('update-count', updateCount);

  // alert badge
  const alertN = list.filter(s=>!s.online||s.level_pct<=tw).length;
  const nb = $('nav-alert-count');
  if (nb) { nb.textContent=alertN; nb.style.display=alertN>0?'':'none'; }

  // notif pip
  const np = $('notif-pip');
  if (np) np.style.display = critical>0?'block':'none';

  // history
  const now = Date.now();
  list.forEach(s=>{
    if (!histData[s.id]) histData[s.id]=[];
    histData[s.id].push({t:now, lvl:Math.round(s.level_pct)});
    if (histData[s.id].length>100) histData[s.id].shift();
  });

  renderWellList(list);
  renderWellsTable(list);
  buildAlertFeed(list);
  buildNotifItems(list);
  updateEventLog(list);
  updateCharts(list);
  updateMap(list);
  renderPredictions(list);
  syncThresholdInputs();

  if (dataMode==='firebase' && window.__db) writeAlertsToFirebase(list);
}

// ── WELL LIST ─────────────────────────────────────────────────
function renderWellList(list) {
  const c = $('well-list-main');
  if (!c) return;
  if (!list.length) { c.innerHTML=`<div class="empty"><div class="ei">📡</div>Connecting…</div>`; return; }
  c.innerHTML = list.map(s=>{
    const pct = Math.round(s.level_pct);
    const cls = !s.online?'offline':pct<=THRESH_CRITICAL?'danger':pct<=THRESH_WARN?'warn':'ok';
    const col = cls==='danger'?'var(--danger)':cls==='warn'?'var(--warn)':cls==='offline'?'var(--muted)':'linear-gradient(90deg,var(--accent),var(--accent2))';
    return `<div class="well-item flash-row" onclick="App.sensorDetail('${s.id}')">
      <div class="w-dot ${cls}"></div>
      <div class="w-info">
        <div class="w-name">${s.name||s.id}${!s.online?' <small style="color:var(--muted)">[offline]</small>':''}</div>
        <div class="w-loc">📍 ${s.location||'—'} · ${s.type||'well'}</div>
      </div>
      <div class="w-bar-wrap"><div class="w-bar-fill" style="width:${pct}%;background:${col}"></div></div>
      <span class="w-pct" style="color:${cls==='danger'?'var(--danger)':cls==='warn'?'var(--warn)':cls==='offline'?'var(--muted)':'var(--accent2)'}">${pct}%</span>
      <span class="w-ago">${timeSince(s.last_ts||0)}</span>
    </div>`;
  }).join('');
}

// ── WELLS TABLE ───────────────────────────────────────────────
function renderWellsTable(list) {
  const tb = $('wells-tbody');
  if (!tb) return;
  tb.innerHTML = list.map(s=>{
    const pct=Math.round(s.level_pct);
    const cls=!s.online?'offline':pct<=THRESH_CRITICAL?'danger':pct<=THRESH_WARN?'warn':'ok';
    const lbl=!s.online?t('offline'):cls==='danger'?t('critical'):cls==='warn'?t('warning'):t('normal');
    return `<tr>
      <td><strong>${s.name||s.id}</strong></td>
      <td>${s.type||'well'}</td>
      <td style="color:${cls==='danger'?'var(--danger)':cls==='warn'?'var(--warn)':'var(--accent2)'};font-weight:700">${pct}%</td>
      <td>${Math.round(s.volume_m3||0)}</td>
      <td>${s.temp_c!=null?Number(s.temp_c).toFixed(1):'—'}</td>
      <td>${s.ph!=null?Number(s.ph).toFixed(1):'—'}</td>
      <td>${s.location||'—'}</td>
      <td>${timeSince(s.last_ts||0)}</td>
      <td><span class="badge ${cls}">● ${lbl}</span></td>
    </tr>`;
  }).join('');
}

// ── ALERT FEED ────────────────────────────────────────────────
function buildAlertFeed(list) {
  const items = [];
  list.forEach(s=>{
    if (!s.online)              items.push({type:'danger',icon:'⚡',title:`Sensor Offline: ${s.name}`,body:`Last level: ${Math.round(s.level_pct)}%. Manual check needed.`,time:timeSince(s.last_ts||0)});
    else if (s.level_pct<=THRESH_CRITICAL) items.push({type:'danger',icon:'🚨',title:`CRITICAL: ${s.name} — ${Math.round(s.level_pct)}%`,body:`Below critical threshold (${THRESH_CRITICAL}%). ~${daysLeft(s)} days to depletion.`,time:timeSince(s.last_ts||0)});
    else if (s.level_pct<=THRESH_WARN)    items.push({type:'warn', icon:'⚠️',title:`Warning: ${s.name} — ${Math.round(s.level_pct)}%`,body:`Below warning threshold (${THRESH_WARN}%). Monitor closely.`,time:timeSince(s.last_ts||0)});
  });

  const feed = $('alert-feed');
  if (!feed) return;
  feed.innerHTML = items.length
    ? items.map((a,i)=>`
        <div class="alert-item ${a.type}" style="animation-delay:${i*.06}s">
          <div class="alert-icon">${a.icon}</div>
          <div class="alert-body">
            <h4>${a.title}</h4><p>${a.body}</p>
            <div class="alert-meta">🕐 ${a.time}</div>
            <div class="alert-actions">
              <button class="btn btn-sm btn-primary" onclick="this.closest('.alert-item').remove()">${t('acknowledge')}</button>
              <button class="btn btn-sm btn-outline" onclick="App.notify('${a.title}')">${t('notify')}</button>
            </div>
          </div>
        </div>`).join('')
    : `<div class="empty"><div class="ei">✅</div>All sensors normal</div>`;

  setTxt('al-critical', items.filter(a=>a.type==='danger').length);
  setTxt('al-warn',     items.filter(a=>a.type==='warn').length);
  setTxt('al-info',     0);
  setTxt('al-ok', list.filter(s=>s.online&&s.level_pct>THRESH_WARN).length);
}

function buildNotifItems(list) {
  const c = $('notif-items');
  if (!c) return;
  const items = list
    .filter(s=>!s.online||s.level_pct<=THRESH_WARN)
    .map(s=>({
      icon: !s.online?'⚡':s.level_pct<=THRESH_CRITICAL?'🚨':'⚠️',
      text: !s.online?`Offline: ${s.name}`:`${s.name}: ${Math.round(s.level_pct)}%`,
      time: timeSince(s.last_ts||0)
    }));
  c.innerHTML = items.length
    ? items.map(n=>`<div class="notif-item"><div style="font-size:19px">${n.icon}</div><div><p>${n.text}</p><span>${n.time}</span></div></div>`).join('')
    : `<div class="empty" style="padding:18px">✅ All clear</div>`;
}

// ── EVENT LOG ─────────────────────────────────────────────────
function updateEventLog(list) {
  const log = $('event-log');
  if (!log) return;
  list.forEach(s=>{
    const pct=Math.round(s.level_pct);
    const cls=!s.online?'offline':pct<=THRESH_CRITICAL?'danger':pct<=THRESH_WARN?'warn':'ok';
    const lbl=!s.online?t('offline'):cls==='danger'?t('critical'):cls==='warn'?t('warning'):t('normal');
    const tr=document.createElement('tr');
    tr.className='row-flash';
    tr.innerHTML=`<td>${new Date().toLocaleTimeString()}</td><td>${s.name||s.id}</td><td>${pct}%</td><td>${Math.round(s.volume_m3||0)}</td><td><span class="badge ${cls}">● ${lbl}</span></td>`;
    log.insertBefore(tr, log.firstChild);
    setTimeout(()=>tr.classList.remove('row-flash'),1000);
    if (log.children.length>120) log.removeChild(log.lastChild);
  });
}

// ── AI PREDICTIONS ────────────────────────────────────────────
function renderPredictions(list) {
  const ic = $('insights-container');
  if (!ic) return;
  ic.innerHTML = [...list].sort((a,b)=>a.level_pct-b.level_pct).map(s=>{
    const pct  = Math.round(s.level_pct);
    const bad  = pct<=THRESH_CRITICAL;
    const med  = pct<=THRESH_WARN;
    const conf = Math.min(96, 60+Math.round(Math.random()*30));
    const days = daysLeft(s);
    return `<div class="insight ${bad?'bad':''}">
      <h4>${bad?t('shortageRisk'):med?t('declining'):t('stable')} — ${s.name}</h4>
      <p>${s.location||'—'} · Current: <strong style="color:${bad?'var(--danger)':med?'var(--warn)':'var(--accent2)'}">${pct}%</strong> (${Math.round(s.volume_m3||0)} m³).
      ${bad?`Estimated <strong>${days} days</strong> until depletion. Immediate action required.`
           :med?`Declining. Will reach critical in ~<strong>${days*2} days</strong>.`
           :`Sufficient for ~<strong>${days} days</strong> at current usage.`}</p>
      <div class="conf-row"><span>${t('confidence')}</span><div class="conf-track"><div class="conf-fill" style="width:${conf}%"></div></div><strong>${conf}%</strong></div>
    </div>`;
  }).join('');

  const pb = $('prob-bars');
  if (!pb) return;
  pb.innerHTML = [...list].sort((a,b)=>a.level_pct-b.level_pct).map(s=>{
    const p = Math.max(0,Math.min(100,100-s.level_pct));
    const c = p>70?'var(--danger)':p>40?'var(--warn)':'var(--accent2)';
    return `<div style="margin-bottom:12px">
      <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px"><span>${s.name}</span><span style="color:${c};font-weight:700">${p}%</span></div>
      <div class="conf-track"><div class="conf-fill" style="width:${p}%;background:${c}"></div></div>
    </div>`;
  }).join('');
}

// ── WRITE ALERTS TO FIREBASE ──────────────────────────────────
async function writeAlertsToFirebase(list) {
  if (!window.__db) return;
  for (const s of list) {
    if (!s.online||s.level_pct<=THRESH_CRITICAL) {
      await set(ref(window.__db,`alerts/${s.id}`),{
        sensor_id:s.id, sensor_name:s.name||s.id,
        level_pct:Math.round(s.level_pct),
        type:!s.online?'offline':'critical',
        timestamp:Math.floor(Date.now()/1000),
        acknowledged:false
      });
    } else {
      remove(ref(window.__db,`alerts/${s.id}`)).catch(()=>{});
    }
  }
}

// ══════════════════════════════════════════════
// LEAFLET MAP (real OpenStreetMap tiles)
// ══════════════════════════════════════════════
function initMap() {
  if (leafletMap) return;
  // Morocco bounds: roughly lat 27–36, lon -14 to -1
  leafletMap = L.map('leaflet-map', {
    center:[31.5, -6.0], zoom:5,
    minZoom:5, maxZoom:14,
    maxBounds:[[20,-18],[37,0]]
  });

  // OpenStreetMap tiles (free, no key needed)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{
    attribution:'© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom:18
  }).addTo(leafletMap);

  // Draw Morocco outline hint
  updateMap(Object.values(sensors));
}

function updateMap(list) {
  if (!leafletMap) return;

  // Remove old markers
  Object.values(mapMarkers).forEach(m=>m.remove());
  mapMarkers = {};

  if (!list.length) return;

  list.forEach(s=>{
    if (!s.lat||!s.lon) return;
    const pct=Math.round(s.level_pct);
    const cls=!s.online?'offline':pct<=THRESH_CRITICAL?'danger':pct<=THRESH_WARN?'warn':'ok';

    // Popsicle/pin markers — styles fully inlined (Leaflet strips external CSS classes)
    const pinColors = {
      ok:      { bg:'rgba(0,255,200,.18)', border:'#00ffc8', glow:'rgba(0,255,200,.5)' },
      warn:    { bg:'rgba(255,184,48,.18)', border:'#ffb830', glow:'rgba(255,184,48,.5)' },
      danger:  { bg:'rgba(255,59,92,.18)',  border:'#ff3b5c', glow:'rgba(255,59,92,.5)'  },
      offline: { bg:'rgba(90,122,154,.18)', border:'#5a7a9a', glow:'rgba(90,122,154,.3)' },
    };
    const pc = pinColors[cls] || pinColors.ok;
    const pinHtml = `<div style="display:flex;flex-direction:column;align-items:center;filter:drop-shadow(0 4px 10px ${pc.glow})">
      <div style="width:40px;height:40px;border-radius:50% 50% 50% 0;transform:rotate(-45deg);background:${pc.bg};border:2.5px solid ${pc.border};display:flex;align-items:center;justify-content:center;">
        <span style="transform:rotate(45deg);font-size:17px">💧</span>
      </div>
      <div style="width:2px;height:10px;background:${pc.border};opacity:.8;margin-top:-1px"></div>
      <div style="width:8px;height:4px;border-radius:50%;background:${pc.border};opacity:.4"></div>
    </div>`;
    const icon = L.divIcon({
      className:'',
      html: pinHtml,
      iconSize:[40,60], iconAnchor:[20,60], popupAnchor:[0,-62]
    });

    const marker = L.marker([s.lat,s.lon],{icon}).addTo(leafletMap);
    marker.bindPopup(`
      <div>
        <strong style="font-size:14px">${s.name||s.id}</strong><br/>
        <span style="color:#5a7a9a;font-size:11px">📍 ${s.location||'—'} · ${s.type||'well'}</span>
        <div style="margin:10px 0;display:grid;grid-template-columns:1fr 1fr;gap:8px">
          <div style="background:#0f1f38;border-radius:8px;padding:8px;text-align:center">
            <div style="font-size:10px;color:#5a7a9a">Level</div>
            <div style="font-size:20px;font-weight:800;color:${cls==='danger'?'#ff3b5c':cls==='warn'?'#ffb830':'#00ffc8'}">${pct}%</div>
          </div>
          <div style="background:#0f1f38;border-radius:8px;padding:8px;text-align:center">
            <div style="font-size:10px;color:#5a7a9a">Volume</div>
            <div style="font-size:16px;font-weight:700;color:#00b4ff">${Math.round(s.volume_m3||0)} m³</div>
          </div>
        </div>
        <div style="font-size:11px;color:#5a7a9a">🕐 ${timeSince(s.last_ts||0)} · Temp: ${s.temp_c!=null?Number(s.temp_c).toFixed(1)+'°C':'—'} · pH: ${s.ph||'—'}</div>
        <button onclick="App.nav('wells')" style="margin-top:10px;background:#00b4ff;color:#000;border:none;border-radius:7px;padding:5px 12px;font-size:11px;font-weight:700;cursor:pointer;width:100%">
          View Details →
        </button>
      </div>
    `, {maxWidth:240});

    mapMarkers[s.id] = marker;
  });

  // Update map stats
  setTxt('map-online',  list.filter(s=>s.online).length);
  setTxt('map-offline', list.filter(s=>!s.online).length);
  setTxt('map-critical',list.filter(s=>s.online&&s.level_pct<=THRESH_CRITICAL).length);
  setTxt('map-total',   list.length);
}

// ══════════════════════════════════════════════
// WEATHER (OpenWeatherMap + simulated fallback)
// ══════════════════════════════════════════════
export async function loadWeather(city) {
  currentWeatherCity = city;

  // Update active chip
  document.querySelectorAll('.city-chip').forEach(c=>{
    c.classList.toggle('active', c.dataset.city===city.name);
  });

  const container = $('weather-forecast');
  if (!container) return;
  container.innerHTML = `<div class="weather-loading">⏳ Loading weather for <strong>${city.name}</strong>…</div>`;

  setTxt('weather-city-name', `🌦️ ${city.name}, Morocco`);
  setTxt('weather-city-region', city.region);

  if (OWM_KEY) {
    try {
      const url = `${OWM_URL}?lat=${city.lat}&lon=${city.lon}&units=metric&cnt=40&appid=${OWM_KEY}`;
      const res  = await fetch(url);
      const data = await res.json();
      if (data.cod !== '200') throw new Error(data.message);
      renderRealWeather(data, city);
      return;
    } catch(e) {
      console.warn('OWM failed:', e.message);
    }
  }

  // Simulated fallback (realistic for Morocco)
  renderSimulatedWeather(city);
}

function renderRealWeather(data, city) {
  // Group by day
  const days = {};
  data.list.forEach(item=>{
    const d = item.dt_txt.split(' ')[0];
    if (!days[d]) days[d] = [];
    days[d].push(item);
  });

  const container = $('weather-forecast');
  const dayNames  = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const entries   = Object.entries(days).slice(0,7);

  container.innerHTML = entries.map(([date,items],i)=>{
    const maxTemp = Math.round(Math.max(...items.map(x=>x.main.temp_max)));
    const minTemp = Math.round(Math.min(...items.map(x=>x.main.temp_min)));
    const rain    = items.reduce((a,x)=>a+(x.rain?.['3h']||0),0).toFixed(1);
    const desc    = items[Math.floor(items.length/2)].weather[0].description;
    const icon    = owmIcon(items[Math.floor(items.length/2)].weather[0].id);
    const d       = new Date(date);
    return `<div class="weather-day ${i===0?'today':''}">
      <div class="wd-name">${i===0?'TODAY':dayNames[d.getDay()]}</div>
      <div class="wd-icon">${icon}</div>
      <div class="wd-temp">${maxTemp}°C</div>
      <div style="font-size:10px;color:var(--muted)">${minTemp}°C</div>
      <div class="wd-rain">💧 ${rain}mm</div>
      <div class="wd-desc">${desc}</div>
    </div>`;
  }).join('');

  updateWeatherInsight(entries, city);
}

function renderSimulatedWeather(city) {
  // Simulate realistic Morocco weather based on latitude
  const isDesert  = city.lat < 30;
  const isCoastal = city.lon < -8;
  const isMountain= city.name==='Ifrane';
  const baseTemp  = isDesert?32:isCoastal?22:isMountain?14:26;
  const days      = ['TODAY','TUE','WED','THU','FRI','SAT','SUN'];
  const icons     = isDesert?['☀️','☀️','☀️','🌤️','☀️','☀️','🌤️']
                   :isCoastal?['🌤️','⛅','🌦️','☀️','⛅','🌧️','⛅']
                   :['⛅','🌦️','🌧️','⛅','☀️','🌤️','⛅'];
  const rains     = isDesert?[0,0,0,0.5,0,0,0]
                   :isCoastal?[0,2,8,0,3,20,4]
                   :[2,10,25,5,0,3,8];

  const container = $('weather-forecast');
  container.innerHTML = days.map((d,i)=>{
    const temp = baseTemp + Math.round((Math.random()-.5)*6 - i*.3);
    return `<div class="weather-day ${i===0?'today':''}">
      <div class="wd-name">${d}</div>
      <div class="wd-icon">${icons[i]}</div>
      <div class="wd-temp">${temp}°C</div>
      <div class="wd-rain">💧 ${rains[i]}mm</div>
    </div>`;
  }).join('');

  // Insight
  const totalRain = rains.reduce((a,b)=>a+b,0);
  const ic = $('weather-insight-text');
  if (ic) ic.innerHTML = `
    <strong>${city.name}</strong> (${city.region}) — 7-day total forecast: <strong style="color:var(--accent)">${totalRain}mm</strong>.
    ${isDesert?'High-aridity desert zone: very low rainfall expected. Water scarcity risk is elevated.'
    :isCoastal?'Coastal zone with moderate rainfall. Water levels expected to partially recharge.'
    :isMountain?'Mountain zone: snowmelt can significantly recharge wells in spring.'
    :'Semi-arid zone: limited rainfall. Monitor well levels closely.'}
    <br/><br/>Estimated groundwater recharge from this forecast: <strong style="color:var(--accent2)">~${Math.round(totalRain*1.8)} m³</strong> across monitored wells.
  `;
}

function owmIcon(id) {
  if (id>=200&&id<300) return '⛈️';
  if (id>=300&&id<400) return '🌧️';
  if (id>=500&&id<600) return id===500?'🌦️':'🌧️';
  if (id>=600&&id<700) return '❄️';
  if (id>=700&&id<800) return '🌫️';
  if (id===800)        return '☀️';
  if (id===801)        return '🌤️';
  if (id<=804)         return '⛅';
  return '🌡️';
}

function updateWeatherInsight(entries, city) {
  const totalRain = entries.reduce((a,[,items])=>a+items.reduce((b,x)=>b+(x.rain?.['3h']||0),0),0);
  const ic = $('weather-insight-text');
  if (ic) ic.innerHTML = `Real-time data for <strong>${city.name}</strong> (${city.region}). 7-day total rain: <strong style="color:var(--accent)">${totalRain.toFixed(1)}mm</strong>. Est. groundwater recharge: <strong style="color:var(--accent2)">~${Math.round(totalRain*1.8)} m³</strong>.`;
}

// ══════════════════════════════════════════════
// CHARTS
// ══════════════════════════════════════════════
const COLORS = ['#00b4ff','#ff3b5c','#ffb830','#00ffc8','#ff6b35','#a78bfa','#34d399','#f472b6'];
const chartOpts = {
  responsive:true, maintainAspectRatio:false,
  plugins:{ legend:{ labels:{ color:'#5a7a9a', font:{size:11,family:"'DM Sans',sans-serif"} } } },
  scales:{ x:{ ticks:{color:'#5a7a9a',font:{size:10}}, grid:{color:'rgba(0,180,255,0.06)'} },
           y:{ ticks:{color:'#5a7a9a',font:{size:10}}, grid:{color:'rgba(0,180,255,0.06)'} } }
};

function initCharts() {
  const mk = (id, cfg) => { const el=document.getElementById(id); if(el){ charts[id]=new Chart(el,cfg); } };

  mk('lineChart', { type:'line', data:{labels:[],datasets:[]},
    options:{...chartOpts, interaction:{intersect:false,mode:'index'}} });

  mk('barChart', { type:'bar', data:{labels:[],datasets:[{label:'Volume m³',data:[],backgroundColor:[],borderRadius:7}]},
    options:{...chartOpts, plugins:{legend:{display:false}}} });

  mk('histChart', { type:'line', data:{labels:[],datasets:[]},
    options:{...chartOpts, elements:{point:{radius:0}}} });

  mk('predChart', { type:'line', data:{labels:Array.from({length:30},(_,i)=>`+${i+1}d`),datasets:[]},
    options:{...chartOpts, elements:{point:{radius:0}}} });
}

function updateCharts(list) {
  const maxPts = 30;
  const maxLen = Math.max(...Object.values(histData).map(h=>h.length),0);
  const labels = Array.from({length:Math.min(maxLen,maxPts)},(_,i)=>i===Math.min(maxLen,maxPts)-1?'now':`-${Math.min(maxLen,maxPts)-1-i}`);

  if (charts.lineChart) {
    charts.lineChart.data.labels = labels;
    charts.lineChart.data.datasets = list.map((s,i)=>({
      label:s.name, tension:.4, pointRadius:2, borderWidth:2, fill:false,
      borderColor:COLORS[i%COLORS.length],
      data:(histData[s.id]||[]).slice(-maxPts).map(h=>h.lvl)
    }));
    charts.lineChart.update('none');
  }
  if (charts.barChart) {
    charts.barChart.data.labels = list.map(s=>s.name);
    charts.barChart.data.datasets[0].data = list.map(s=>Math.round(s.volume_m3||0));
    charts.barChart.data.datasets[0].backgroundColor = list.map(s=>s.level_pct<=THRESH_CRITICAL?'#ff3b5c':s.level_pct<=THRESH_WARN?'#ffb830':'#00b4ff');
    charts.barChart.update('none');
  }
  if (charts.histChart) {
    const hLen = Math.max(...Object.values(histData).map(h=>h.length),0);
    charts.histChart.data.labels = Array.from({length:hLen},(_,i)=>String(i+1));
    charts.histChart.data.datasets = list.map((s,i)=>({
      label:s.name, tension:.4, pointRadius:0, borderWidth:2, fill:false,
      borderColor:COLORS[i%COLORS.length],
      data:(histData[s.id]||[]).map(h=>h.lvl)
    }));
    charts.histChart.update('none');
  }
  if (charts.predChart) {
    charts.predChart.data.datasets = list.map((s,i)=>({
      label:s.name, tension:.4, pointRadius:0, borderWidth:2,
      borderColor:COLORS[i%COLORS.length], borderDash:[5,3],
      data:Array.from({length:30},(_,j)=>Math.max(0, s.level_pct - j*(s.level_pct<=THRESH_CRITICAL?1.6:s.level_pct<=THRESH_WARN?0.8:0.25)))
    }));
    charts.predChart.update('none');
  }
}

// ══════════════════════════════════════════════
// PUBLIC API (called from HTML)
// ══════════════════════════════════════════════
export const App = {
  nav(pageId, el) {
    document.querySelectorAll('.page').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(n=>n.classList.remove('active'));
    const page = document.getElementById('page-'+pageId);
    if (page) page.classList.add('active');
    if (el) el.classList.add('active');
    else document.getElementById('nav-'+pageId)?.classList.add('active');

    const titles = {
      dashboard:t('dashboard'), map:t('map'), wells:t('wells'),
      alerts:t('alerts'), predictions:t('predictions'), weather:t('weather'),
      history:t('history'), firebase:'Firebase Setup', settings:t('settings')
    };
    setTxt('page-title', titles[pageId]||pageId);
    $('notif-panel')?.classList.remove('show');
    closeSidebar();

    // Init map lazily
    if (pageId==='map') setTimeout(()=>{
      initMap();
      updateMap(Object.values(sensors));
    },100);
    // Init weather lazily
    if (pageId==='weather') setTimeout(()=>{
      if (!$('weather-forecast').children.length || $('weather-forecast').querySelector('.weather-loading')) {
        loadWeather(currentWeatherCity);
      }
    },100);
  },

  changeLang(l) {
    lang = l;
    document.body.setAttribute('dir', l==='ar'?'rtl':'ltr');
    document.querySelectorAll('[data-i18n]').forEach(el=>{
      const k=el.getAttribute('data-i18n');
      if (T[lang]?.[k]) el.textContent=T[lang][k];
    });
    // sync both lang selects
    document.querySelectorAll('.lang-select').forEach(s=>s.value=l);
    if (window.__db) {
      set(ref(window.__db,'settings/language'), l).catch(()=>{});
    }
    refresh();
  },

  sensorDetail(id) {
    const s = sensors[id];
    if (!s) return;
    const pct=Math.round(s.level_pct);
    const cls=!s.online?'offline':pct<=THRESH_CRITICAL?'danger':pct<=THRESH_WARN?'warn':'ok';
    $('modal-body').innerHTML = `
      <div style="display:flex;gap:12px;align-items:center;margin-bottom:18px">
        <div class="w-dot ${cls}" style="width:14px;height:14px;flex-shrink:0"></div>
        <div><h2 style="font-family:var(--fh);font-size:19px">${s.name||id}</h2>
        <p style="font-size:12px;color:var(--muted)">📍 ${s.location||'—'} · ${s.type||'well'}</p></div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:11px;margin-bottom:16px">
        ${iBox('Level',pct+'%',cls==='danger'?'var(--danger)':cls==='warn'?'var(--warn)':'var(--accent2)')}
        ${iBox('Volume',Math.round(s.volume_m3||0)+' m³','var(--accent)')}
        ${iBox('Capacity',(s.capacity_m3||'—')+' m³','var(--muted)')}
        ${iBox('Temp',s.temp_c!=null?Number(s.temp_c).toFixed(1)+'°C':'—','var(--warn)')}
        ${iBox('pH',s.ph!=null?Number(s.ph).toFixed(1):'—','var(--accent2)')}
        ${iBox('Status',!s.online?'Offline':cls==='danger'?'Critical':cls==='warn'?'Warning':'Normal',cls==='danger'?'var(--danger)':cls==='warn'?'var(--warn)':'var(--accent2)')}
      </div>
      <div style="height:110px;position:relative;margin-bottom:12px"><canvas id="modal-chart"></canvas></div>
      <p style="font-size:11px;color:var(--muted)">Last update: ${s.last_ts?new Date(s.last_ts*1000).toLocaleString():'—'}</p>`;
    $('sensor-modal').classList.add('show');
    setTimeout(()=>{
      const mc=$('modal-chart');
      const hist=(histData[id]||[]);
      if (mc&&hist.length) {
        new Chart(mc,{type:'line',data:{labels:hist.map((_,i)=>i+1),datasets:[{data:hist.map(h=>h.lvl),borderColor:COLORS[0],backgroundColor:'rgba(0,180,255,0.06)',fill:true,tension:.4,pointRadius:0,borderWidth:2}]},
          options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{display:false},y:{ticks:{color:'#5a7a9a',font:{size:9}},grid:{color:'rgba(0,180,255,0.06)'}}}}});
      }
    },50);
  },

  closeModal() { $('sensor-modal').classList.remove('show'); },

  notify(title) {
    if (window.__db) push(ref(window.__db,'notifications'),{message:title,sentAt:Math.floor(Date.now()/1000),type:'authority',acknowledged:false}).catch(()=>{});
    toast('s','📤 Authorities notified!');
  },

  toggleNotif() { $('notif-panel').classList.toggle('show'); },
  clearNotifs()  { $('notif-items').innerHTML=`<div class="empty" style="padding:16px">✅ All clear</div>`; $('notif-panel').classList.remove('show'); $('notif-pip').style.display='none'; },

  async saveSettings() {
    THRESH_CRITICAL = +($('thresh-critical')?.value||20);
    THRESH_WARN     = +($('thresh-warn')?.value||40);
    lang = $('lang-select')?.value||'en';
    if (window.__db) {
      await set(ref(window.__db,'settings'),{
        thresholds:{critical:THRESH_CRITICAL,warning:THRESH_WARN},
        language:lang, updatedAt:Math.floor(Date.now()/1000)
      }).catch(()=>{});
    }
    App.changeLang(lang);
    toast('s', t('settingsSaved'));
    refresh();
  },

  copyCode(btn, elId) {
    navigator.clipboard.writeText(document.getElementById(elId).innerText)
      .then(()=>{ btn.textContent='✓ Copied!'; setTimeout(()=>btn.textContent='Copy',2000); })
      .catch(()=>toast('e','Copy failed'));
  }
};

// expose for HTML onclick
window.App = App;
window.loadWeather = loadWeather;

// ── SIDEBAR ───────────────────────────────────────────────────
function closeSidebar() { $('sidebar')?.classList.remove('open'); $('overlay')?.classList.remove('show'); }
window.toggleSidebar = ()=>{ $('sidebar')?.classList.toggle('open'); $('overlay')?.classList.toggle('show'); };
window.closeSidebar  = closeSidebar;

// ── CLOCK ─────────────────────────────────────────────────────
function startClock() {
  const tick=()=>{
    setTxt('clock-time', new Date().toLocaleTimeString('en-GB'));
    setTxt('clock-date', new Date().toLocaleDateString('en-GB',{weekday:'long',day:'numeric',month:'long',year:'numeric'}));
    setTxt('last-ts',    new Date().toLocaleTimeString());
  };
  tick(); setInterval(tick,1000);
}

// ── TOAST ─────────────────────────────────────────────────────
function toast(type, msg) {
  const c=$('toasts'); if (!c) return;
  const d=document.createElement('div');
  d.className=`toast ${type}`;
  const ic={s:'✅',e:'❌',w:'⚠️',i:'ℹ️'};
  d.innerHTML=`<span>${ic[type]||'•'}</span><span>${msg}</span>`;
  c.appendChild(d);
  setTimeout(()=>{ d.style.opacity='0'; d.style.transform='translateY(5px)'; setTimeout(()=>d.remove(),300); },4200);
}
window.toast = toast;

// ── HELPERS ───────────────────────────────────────────────────
const $ = id => document.getElementById(id);
function setVal(id,v) { const el=$(id); if(!el) return; if(el.textContent!==String(v)){el.textContent=v; el.classList.add('flash'); setTimeout(()=>el.classList.remove('flash'),500);} }
function setTxt(id,v) { const el=$(id); if(el) el.textContent=v; }
function timeSince(ts) { const s=Math.floor(Date.now()/1000-ts); if(s<5) return 'just now'; if(s<60) return s+'s ago'; if(s<3600) return Math.floor(s/60)+'m ago'; return Math.floor(s/3600)+'h ago'; }
function daysLeft(s) { const vol=s.volume_m3||(s.level_pct/100)*(s.capacity_m3||400); return Math.max(1,Math.round(vol/34)); }
function syncThresholdInputs() { const c=$('thresh-critical'),w=$('thresh-warn'); if(c) c.value=THRESH_CRITICAL; if(w) w.value=THRESH_WARN; }
function iBox(label,val,color) { return `<div style="background:var(--surface2);border-radius:9px;padding:13px;border:1px solid var(--border)"><div style="font-size:10px;color:var(--muted);margin-bottom:4px;text-transform:uppercase;letter-spacing:.7px">${label}</div><div style="font-family:var(--fh);font-size:19px;font-weight:700;color:${color}">${val}</div></div>`; }