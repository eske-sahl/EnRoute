import { Router, Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

const router = Router();
const DATA_FILE_PATH = path.join(__dirname, '../../data/smartbus_state.json');

// Initial baseline seed data
const initialSeedData = {
  project: 'EnRoute',
  version: '1.0.0',
  environment: 'development',
  databaseEngine: 'JSON File Persistence & PostgreSQL Dual Layer',
  owner: {
    id: 'OWNER-1',
    fullName: 'George Varghese',
    email: 'owner@stgeorge.com',
    phoneNumber: '+91 94470 12345',
    operatorName: 'St. George Motors Ernakulam',
    isVerified: true,
  },
  passengers: [
    {
      id: 'SBK-KL-987263',
      fullName: 'Anjali Nair',
      email: 'passenger@gmail.com',
      phoneNumber: '+91 98470 00004',
      walletBalance: 250.0,
      concessionCategory: 'General / Adult Standard',
      homeStation: 'Aluva Stand, Ernakulam',
      status: 'ACTIVE',
      registeredAt: '2026-10-01T00:00:00.000Z',
    },
    {
      id: 'SBK-KL-554120',
      fullName: 'Rahul Menon',
      email: 'rahul@gmail.com',
      phoneNumber: '+91 98470 00005',
      walletBalance: 120.0,
      concessionCategory: 'Student Concession (₹5 Flat Tariff)',
      homeStation: 'Kalamassery Premier, Ernakulam',
      status: 'ACTIVE',
      registeredAt: '2026-10-05T00:00:00.000Z',
    },
    {
      id: 'SBK-KL-339811',
      fullName: 'Meera Pillai',
      email: 'meera@gmail.com',
      phoneNumber: '+91 98470 00006',
      walletBalance: 450.0,
      concessionCategory: 'General / Adult Standard',
      homeStation: 'Kakkanad InfoPark, Kochi',
      status: 'ACTIVE',
      registeredAt: '2026-10-08T00:00:00.000Z',
    },
  ],
  conductors: [
    {
      id: 'COND-1',
      fullName: 'Suresh Kumar',
      userId: 'suresh.conductor',
      phoneNumber: '+91 98470 11001',
      licenseNumber: 'KL-07-COND-2018-8891',
      assignedBusReg: 'KL 07 CD 4589',
      assignedBusName: 'SpeedWings',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
    {
      id: 'COND-2',
      fullName: 'Biju Varghese',
      userId: 'biju.conductor',
      phoneNumber: '+91 98470 11002',
      licenseNumber: 'KL-05-COND-2019-3321',
      assignedBusReg: 'KL 07 CE 1204',
      assignedBusName: 'GreenCity Express',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
    {
      id: 'COND-3',
      fullName: 'Rajesh Nair',
      userId: 'rajesh.conductor',
      phoneNumber: '+91 98470 11003',
      licenseNumber: 'KL-01-COND-2021-7740',
      assignedBusReg: 'KL 07 BQ 9981',
      assignedBusName: 'City Rider',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
  ],
  buses: [
    {
      regNumber: 'KL 07 CD 4589',
      busName: 'SpeedWings',
      category: 'Ordinary Bus (Blue-Whiteline)',
      route: 'Aluva Stand ➔ Perumbavoor Stand (via Kizhakkambalam)',
      startPoint: 'Aluva Stand',
      destPoint: 'Perumbavoor Stand',
      seatingCapacity: 48,
      isTripActive: false,
      status: 'STOPPED / DEPOT',
      todayCollection: 6420.0,
      ticketsSold: 168,
      workers: {
        driver: 'Venu Pillai (Badge #KL4201)',
        conductor: 'Suresh Kumar',
        cleaner: 'Mani K.',
      },
      timetable: [
        { stop: 'Aluva Stand', time: '10:00 AM' },
        { stop: 'Bank Junction', time: '10:08 AM' },
        { stop: 'Pump Junction', time: '10:15 AM' },
        { stop: 'Kizhakkambalam', time: '10:24 AM' },
        { stop: 'Pattimattom', time: '10:35 AM' },
        { stop: 'Perumbavoor Stand', time: '10:48 AM' },
      ],
    },
    {
      regNumber: 'KL 07 CE 1204',
      busName: 'GreenCity Express',
      category: 'Limited Stop Bus (Red-Whiteline)',
      route: 'Ernakulam Kaloor ➔ Thoppumpady (via Menaka)',
      startPoint: 'Ernakulam Kaloor',
      destPoint: 'Thoppumpady',
      seatingCapacity: 52,
      isTripActive: false,
      status: 'STOPPED / DEPOT',
      todayCollection: 7840.0,
      ticketsSold: 202,
      workers: {
        driver: 'Antony Joseph',
        conductor: 'Biju Varghese',
        cleaner: 'Saji T.',
      },
      timetable: [
        { stop: 'Kaloor Stand', time: '10:30 AM' },
        { stop: 'Menaka Junction', time: '10:42 AM' },
        { stop: 'Thevara Ferry', time: '10:55 AM' },
        { stop: 'Thoppumpady', time: '11:15 AM' },
      ],
    },
    {
      regNumber: 'KL 07 BQ 9981',
      busName: 'City Rider',
      category: 'City Bus (Green-Whiteline)',
      route: 'Vytilla Hub ➔ Kakkanad InfoPark (via Palarivattom)',
      startPoint: 'Vytilla Hub',
      destPoint: 'Kakkanad InfoPark',
      seatingCapacity: 48,
      isTripActive: false,
      status: 'STOPPED / DEPOT',
      todayCollection: 4220.0,
      ticketsSold: 116,
      workers: {
        driver: 'Pradeep Kumar',
        conductor: 'Rajesh Nair',
        cleaner: 'Babu N.',
      },
      timetable: [
        { stop: 'Vytilla Hub', time: '11:00 AM' },
        { stop: 'Palarivattom Bypass', time: '11:15 AM' },
        { stop: 'Kakkanad Stand', time: '11:30 AM' },
        { stop: 'InfoPark Express', time: '11:45 AM' },
      ],
    },
  ],
  tickets: [] as any[],
};

// State loader & persistence helper
function loadState(): typeof initialSeedData {
  try {
    if (fs.existsSync(DATA_FILE_PATH)) {
      const raw = fs.readFileSync(DATA_FILE_PATH, 'utf-8');
      return JSON.parse(raw);
    }
  } catch (err) {
    console.error('Failed to read data file, using seed:', err);
  }
  saveState(initialSeedData);
  return initialSeedData;
}

function saveState(data: typeof initialSeedData): void {
  try {
    const dir = path.dirname(DATA_FILE_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(DATA_FILE_PATH, JSON.stringify(data, null, 2), 'utf-8');
  } catch (err) {
    console.error('Failed to save data file:', err);
  }
}

// -----------------------------------------------------------------------------
// 1. JSON & SYNCHRONIZATION ENDPOINTS
// -----------------------------------------------------------------------------

router.get('/json', (req: Request, res: Response) => {
  const data = loadState();
  res.status(200).json({
    ...data,
    summary: {
      totalPassengers: data.passengers.length,
      totalBuses: data.buses.length,
      totalConductors: data.conductors.length,
      totalTickets: data.tickets.length,
      activeBuses: data.buses.filter((b) => b.isTripActive).length,
    },
  });
});

/**
 * Bidirectional Sync with Frontend Flutter State
 */
router.post('/sync', (req: Request, res: Response) => {
  const incoming = req.body;
  const current = loadState();

  // Merge passengers
  if (Array.isArray(incoming.passengers)) {
    for (const p of incoming.passengers) {
      const idx = current.passengers.findIndex((item) => item.id === p.id);
      if (idx !== -1) {
        current.passengers[idx] = { ...current.passengers[idx], ...p };
      } else {
        current.passengers.push(p);
      }
    }
  }

  // Merge buses
  if (Array.isArray(incoming.buses)) {
    for (const b of incoming.buses) {
      const idx = current.buses.findIndex(
        (item) => item.regNumber.toUpperCase() === b.regNumber.toUpperCase()
      );
      if (idx !== -1) {
        current.buses[idx] = { ...current.buses[idx], ...b };
      } else {
        current.buses.push(b);
      }
    }
  }

  // Merge conductors
  if (Array.isArray(incoming.conductors)) {
    for (const c of incoming.conductors) {
      const idx = current.conductors.findIndex((item) => item.id === c.id || item.userId === c.userId);
      if (idx !== -1) {
        current.conductors[idx] = { ...current.conductors[idx], ...c };
      } else {
        current.conductors.push(c);
      }
    }
  }

  // Merge tickets
  if (Array.isArray(incoming.tickets)) {
    for (const t of incoming.tickets) {
      if (!current.tickets.some((item) => item.id === t.id || item.ticketNumber === t.ticketNumber)) {
        current.tickets.unshift(t);
      }
    }
  }

  saveState(current);
  res.status(200).json({ status: 'success', message: 'Backend data synchronized successfully', data: current });
});

// -----------------------------------------------------------------------------
// 2. PASSENGER CRUD ENDPOINTS
// -----------------------------------------------------------------------------

router.post('/passengers', (req: Request, res: Response) => {
  const data = loadState();
  const { fullName, email, phoneNumber, walletBalance, concessionCategory, homeStation } = req.body;

  if (!fullName || !email) {
    return res.status(400).json({ status: 'error', message: 'Full name and email are required' });
  }

  const newId = `SBK-KL-${Math.floor(100000 + Math.random() * 900000)}`;
  const newPassenger = {
    id: newId,
    fullName: fullName.trim(),
    email: email.trim(),
    phoneNumber: phoneNumber ? phoneNumber.trim() : `+91 98470 ${Math.floor(10000 + Math.random() * 90000)}`,
    walletBalance: Number(walletBalance) || 0.0,
    concessionCategory: concessionCategory || 'General / Adult Standard',
    homeStation: homeStation || 'Aluva Stand, Ernakulam',
    status: 'ACTIVE',
    registeredAt: new Date().toISOString(),
  };

  data.passengers.push(newPassenger);
  saveState(data);
  res.status(201).json({ status: 'success', message: 'Passenger created', data: newPassenger });
});

router.put('/passengers/:id', (req: Request, res: Response) => {
  const data = loadState();
  const id = req.params.id;
  const idx = data.passengers.findIndex((p) => p.id === id);

  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: `Passenger with ID ${id} not found` });
  }

  const p = data.passengers[idx];
  data.passengers[idx] = {
    ...p,
    fullName: req.body.fullName !== undefined ? req.body.fullName.trim() : p.fullName,
    email: req.body.email !== undefined ? req.body.email.trim() : p.email,
    phoneNumber: req.body.phoneNumber !== undefined ? req.body.phoneNumber.trim() : p.phoneNumber,
    walletBalance: req.body.walletBalance !== undefined ? Number(req.body.walletBalance) : p.walletBalance,
    concessionCategory: req.body.concessionCategory || p.concessionCategory,
    homeStation: req.body.homeStation || p.homeStation,
    status: req.body.status || p.status,
  };

  saveState(data);
  res.status(200).json({ status: 'success', message: 'Passenger updated', data: data.passengers[idx] });
});

router.delete('/passengers/:id', (req: Request, res: Response) => {
  const data = loadState();
  const id = req.params.id;
  const beforeCount = data.passengers.length;
  data.passengers = data.passengers.filter((p) => p.id !== id);

  if (data.passengers.length === beforeCount) {
    return res.status(404).json({ status: 'error', message: `Passenger ${id} not found` });
  }

  saveState(data);
  res.status(200).json({ status: 'success', message: `Passenger ${id} deleted successfully` });
});

// -----------------------------------------------------------------------------
// 3. BUS CRUD ENDPOINTS
// -----------------------------------------------------------------------------

router.post('/buses', (req: Request, res: Response) => {
  const data = loadState();
  const { regNumber, busName, category, route, startPoint, destPoint, seatingCapacity, workers, timetable } = req.body;

  if (!regNumber || !busName) {
    return res.status(400).json({ status: 'error', message: 'regNumber and busName are required' });
  }

  const cleanReg = regNumber.trim().toUpperCase();
  if (data.buses.some((b) => b.regNumber.toUpperCase() === cleanReg)) {
    return res.status(409).json({ status: 'error', message: `Bus with registration ${cleanReg} already exists` });
  }

  const newBus = {
    regNumber: cleanReg,
    busName: busName.trim(),
    category: category || 'Ordinary Bus (Blue-Whiteline)',
    route: route || `${startPoint || 'Aluva Stand'} ➔ ${destPoint || 'Perumbavoor Stand'}`,
    startPoint: startPoint || 'Aluva Stand',
    destPoint: destPoint || 'Perumbavoor Stand',
    seatingCapacity: Number(seatingCapacity) || 48,
    isTripActive: false,
    status: 'STOPPED / DEPOT',
    todayCollection: 0.0,
    ticketsSold: 0,
    workers: workers || { driver: 'Assigned Driver', conductor: 'Assigned Conductor', cleaner: 'Assigned Cleaner' },
    timetable: Array.isArray(timetable) && timetable.length > 0 ? timetable : [
      { stop: startPoint || 'Aluva Stand', time: '08:00 AM' },
      { stop: destPoint || 'Perumbavoor Stand', time: '09:00 AM' },
    ],
  };

  data.buses.push(newBus);
  saveState(data);
  res.status(201).json({ status: 'success', message: 'Bus registered', data: newBus });
});

router.put('/buses/:regNumber', (req: Request, res: Response) => {
  const data = loadState();
  const cleanReg = req.params.regNumber.trim().toUpperCase();
  const idx = data.buses.findIndex((b) => b.regNumber.toUpperCase() === cleanReg);

  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: `Bus ${cleanReg} not found` });
  }

  const b = data.buses[idx];
  data.buses[idx] = {
    ...b,
    busName: req.body.busName !== undefined ? req.body.busName.trim() : b.busName,
    category: req.body.category || b.category,
    route: req.body.route || b.route,
    startPoint: req.body.startPoint || b.startPoint,
    destPoint: req.body.destPoint || b.destPoint,
    seatingCapacity: req.body.seatingCapacity !== undefined ? Number(req.body.seatingCapacity) : b.seatingCapacity,
    isTripActive: req.body.isTripActive !== undefined ? Boolean(req.body.isTripActive) : b.isTripActive,
    status: req.body.status || (req.body.isTripActive ? 'RUNNING_NOW' : 'STOPPED / DEPOT'),
    workers: req.body.workers ? { ...b.workers, ...req.body.workers } : b.workers,
    timetable: req.body.timetable || b.timetable,
  };

  saveState(data);
  res.status(200).json({ status: 'success', message: 'Bus updated', data: data.buses[idx] });
});

router.delete('/buses/:regNumber', (req: Request, res: Response) => {
  const data = loadState();
  const cleanReg = req.params.regNumber.trim().toUpperCase();
  const beforeCount = data.buses.length;
  data.buses = data.buses.filter((b) => b.regNumber.toUpperCase() !== cleanReg);

  if (data.buses.length === beforeCount) {
    return res.status(404).json({ status: 'error', message: `Bus ${cleanReg} not found` });
  }

  saveState(data);
  res.status(200).json({ status: 'success', message: `Bus ${cleanReg} deleted successfully` });
});

// -----------------------------------------------------------------------------
// 4. CONDUCTOR CRUD ENDPOINTS
// -----------------------------------------------------------------------------

router.post('/conductors', (req: Request, res: Response) => {
  const data = loadState();
  const { fullName, userId, phoneNumber, licenseNumber, assignedBusReg, assignedBusName } = req.body;

  if (!fullName || !userId) {
    return res.status(400).json({ status: 'error', message: 'fullName and userId are required' });
  }

  const newId = `COND-${data.conductors.length + 1}`;
  const newConductor = {
    id: newId,
    fullName: fullName.trim(),
    userId: userId.trim().toLowerCase(),
    phoneNumber: phoneNumber || `+91 98470 ${Math.floor(10000 + Math.random() * 90000)}`,
    licenseNumber: licenseNumber || `KL-COND-${Math.floor(1000 + Math.random() * 9000)}`,
    assignedBusReg: assignedBusReg || 'Unassigned',
    assignedBusName: assignedBusName || 'Unassigned',
    role: 'ROLE_CONDUCTOR',
    status: 'ACTIVE',
  };

  data.conductors.push(newConductor);
  saveState(data);
  res.status(201).json({ status: 'success', message: 'Conductor created', data: newConductor });
});

router.put('/conductors/:id', (req: Request, res: Response) => {
  const data = loadState();
  const id = req.params.id;
  const idx = data.conductors.findIndex((c) => c.id === id || c.userId === id);

  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: `Conductor ${id} not found` });
  }

  const c = data.conductors[idx];
  data.conductors[idx] = {
    ...c,
    fullName: req.body.fullName || c.fullName,
    phoneNumber: req.body.phoneNumber || c.phoneNumber,
    licenseNumber: req.body.licenseNumber || c.licenseNumber,
    assignedBusReg: req.body.assignedBusReg || c.assignedBusReg,
    assignedBusName: req.body.assignedBusName || c.assignedBusName,
    status: req.body.status || c.status,
  };

  saveState(data);
  res.status(200).json({ status: 'success', message: 'Conductor updated', data: data.conductors[idx] });
});

router.delete('/conductors/:id', (req: Request, res: Response) => {
  const data = loadState();
  const id = req.params.id;
  const beforeCount = data.conductors.length;
  data.conductors = data.conductors.filter((c) => c.id !== id && c.userId !== id);

  if (data.conductors.length === beforeCount) {
    return res.status(404).json({ status: 'error', message: `Conductor ${id} not found` });
  }

  saveState(data);
  res.status(200).json({ status: 'success', message: `Conductor ${id} deleted successfully` });
});

// -----------------------------------------------------------------------------
// 5. TICKETS CRUD ENDPOINTS
// -----------------------------------------------------------------------------

router.post('/tickets', (req: Request, res: Response) => {
  const data = loadState();
  const ticket = req.body;
  if (!ticket.ticketNumber && !ticket.id) {
    ticket.ticketNumber = `KL-SBK-${Date.now()}`;
  }
  ticket.id = ticket.id || ticket.ticketNumber;
  ticket.issuedAt = ticket.issuedAt || new Date().toISOString();

  data.tickets.unshift(ticket);
  saveState(data);
  res.status(201).json({ status: 'success', message: 'Ticket saved', data: ticket });
});

router.delete('/tickets/:id', (req: Request, res: Response) => {
  const data = loadState();
  const id = req.params.id;
  const beforeCount = data.tickets.length;
  data.tickets = data.tickets.filter((t) => t.id !== id && t.ticketNumber !== id);

  if (data.tickets.length === beforeCount) {
    return res.status(404).json({ status: 'error', message: `Ticket ${id} not found` });
  }

  saveState(data);
  res.status(200).json({ status: 'success', message: `Ticket ${id} deleted` });
});

// -----------------------------------------------------------------------------
// 6. VISUAL INTERACTIVE DASHBOARD (HTML / CSS / JS with full AJAX CRUD)
// -----------------------------------------------------------------------------

router.get('/', (req: Request, res: Response) => {
  const data = loadState();
  const activeCount = data.buses.filter((b) => b.isTripActive).length;

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>EnRoute Kerala - Backend Data Management Portal</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0B0F15;
      --card-bg: #141A23;
      --border: #232C3A;
      --accent: #00875A;
      --accent-hover: #00A36C;
      --gold: #FFAB00;
      --danger: #E53935;
      --text: #F4F6F8;
      --text-muted: #8C9BAE;
      --modal-bg: #1A222D;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      padding: 24px;
    }
    .container { max-width: 1400px; margin: 0 auto; }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 20px;
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
      flex-wrap: wrap;
      gap: 16px;
    }
    .brand { display: flex; align-items: center; gap: 12px; }
    .brand-icon {
      font-size: 32px;
      background: rgba(0, 135, 90, 0.2);
      border: 1px solid var(--accent);
      border-radius: 12px;
      width: 48px;
      height: 48px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    h1 { font-size: 24px; font-weight: 800; }
    .subtitle { color: var(--text-muted); font-size: 13px; }
    .badge-live {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(0, 163, 108, 0.15);
      color: #00E676;
      border: 1px solid #00E676;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 11px;
      font-weight: 700;
    }
    .pulse-dot { width: 8px; height: 8px; background: #00E676; border-radius: 50%; animation: pulse 1.5s infinite; }
    @keyframes pulse { 0% { opacity: 0.3; } 50% { opacity: 1; } 100% { opacity: 0.3; } }

    /* Top Stats */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 16px;
      margin-bottom: 28px;
    }
    .stat-card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 18px;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .stat-label { font-size: 12px; color: var(--text-muted); font-weight: 600; text-transform: uppercase; }
    .stat-val { font-size: 26px; font-weight: 800; color: var(--text); }
    .stat-sub { font-size: 11px; color: var(--accent); }

    /* Tabs */
    .tabs {
      display: flex;
      gap: 10px;
      border-bottom: 1px solid var(--border);
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    .tab-btn {
      background: transparent;
      border: none;
      color: var(--text-muted);
      font-size: 14px;
      font-weight: 600;
      padding: 10px 18px;
      cursor: pointer;
      border-bottom: 3px solid transparent;
      transition: all 0.2s;
    }
    .tab-btn:hover { color: var(--text); }
    .tab-btn.active {
      color: #00E676;
      border-bottom: 3px solid #00E676;
    }

    /* Action bar */
    .action-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 12px;
    }
    .search-input {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 10px 14px;
      color: var(--text);
      font-size: 13px;
      width: 280px;
      outline: none;
    }
    .search-input:focus { border-color: var(--accent); }
    .btn {
      background: var(--accent);
      color: white;
      border: none;
      padding: 10px 16px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 13px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: background 0.2s;
    }
    .btn:hover { background: var(--accent-hover); }
    .btn-danger { background: var(--danger); }
    .btn-danger:hover { background: #C62828; }
    .btn-sm { padding: 6px 10px; font-size: 11px; border-radius: 6px; }

    /* Tables */
    .table-container {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 16px;
      overflow-x: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
      font-size: 13px;
    }
    th {
      background: #11151C;
      padding: 14px 16px;
      color: var(--text-muted);
      font-weight: 600;
      border-bottom: 1px solid var(--border);
    }
    td {
      padding: 14px 16px;
      border-bottom: 1px solid var(--border);
      vertical-align: middle;
    }
    tr:hover { background: rgba(255, 255, 255, 0.02); }
    .tag {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 6px;
      font-size: 10px;
      font-weight: 700;
      text-transform: uppercase;
    }
    .tag-active { background: rgba(0, 230, 118, 0.15); color: #00E676; border: 1px solid rgba(0, 230, 118, 0.3); }
    .tag-inactive { background: rgba(255, 171, 0, 0.15); color: var(--gold); border: 1px solid rgba(255, 171, 0, 0.3); }
    .mono { font-family: 'JetBrains Mono', monospace; font-size: 12px; }

    /* Modals */
    .modal-overlay {
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0, 0, 0, 0.7);
      backdrop-filter: blur(4px);
      display: none;
      align-items: center;
      justify-content: center;
      z-index: 1000;
      padding: 16px;
    }
    .modal-overlay.open { display: flex; }
    .modal-card {
      background: var(--modal-bg);
      border: 1px solid var(--border);
      border-radius: 20px;
      width: 100%;
      max-width: 500px;
      max-height: 90vh;
      overflow-y: auto;
      padding: 24px;
      box-shadow: 0 20px 40px rgba(0,0,0,0.6);
    }
    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding-bottom: 12px;
      border-bottom: 1px solid var(--border);
    }
    .form-group { margin-bottom: 14px; }
    .form-group label { display: block; font-size: 12px; color: var(--text-muted); font-weight: 600; margin-bottom: 6px; }
    .form-input {
      width: 100%;
      background: var(--bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 10px 12px;
      color: var(--text);
      font-size: 13px;
      outline: none;
    }
    .form-input:focus { border-color: var(--accent); }
    .modal-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-top: 20px;
    }
    .toast {
      position: fixed;
      bottom: 24px;
      right: 24px;
      background: var(--accent);
      color: white;
      padding: 12px 20px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 600;
      box-shadow: 0 6px 20px rgba(0,0,0,0.4);
      display: none;
      z-index: 2000;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div class="brand">
        <div class="brand-icon">🚍</div>
        <div>
          <h1>EnRoute • Backend Portal</h1>
          <div class="subtitle">Direct CRUD & Live JSON Data Management • Created by Sahl Saleem & Fathima Riyas</div>
        </div>
      </div>
      <div style="display: flex; gap: 12px; align-items: center;">
        <span class="badge-live"><span class="pulse-dot"></span> Backend Engine Online</span>
        <button class="btn btn-sm" onclick="syncWithFrontend()">🔄 Re-Sync JSON</button>
      </div>
    </header>

    <!-- Top Summary Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-label">Total Buses</div>
        <div class="stat-val" id="statBuses">${data.buses.length}</div>
        <div class="stat-sub">${activeCount} currently active on road</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Registered Passengers</div>
        <div class="stat-val" id="statPassengers">${data.passengers.length}</div>
        <div class="stat-sub">Smart Wallet Enabled</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Conductors</div>
        <div class="stat-val" id="statConductors">${data.conductors.length}</div>
        <div class="stat-sub">Terminal Login Configured</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">Tickets Issued</div>
        <div class="stat-val" id="statTickets">${data.tickets.length}</div>
        <div class="stat-sub">Live Digital Ledger</div>
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="tabs">
      <button class="tab-btn active" onclick="switchTab('passengers')">👥 Passengers</button>
      <button class="tab-btn" onclick="switchTab('buses')">🚌 Fleet & Buses</button>
      <button class="tab-btn" onclick="switchTab('conductors')">🎫 Conductors</button>
      <button class="tab-btn" onclick="switchTab('tickets')">🧾 Issued Tickets</button>
      <button class="tab-btn" onclick="switchTab('api')">📡 REST API Explorer</button>
    </div>

    <!-- 1. PASSENGERS TAB -->
    <div id="tab-passengers">
      <div class="action-bar">
        <input type="text" class="search-input" placeholder="Search passenger name, email, or ID..." oninput="filterTable('passengers-table', this.value)">
        <button class="btn" onclick="openAddPassengerModal()">+ Add New Passenger</button>
      </div>
      <div class="table-container">
        <table id="passengers-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Full Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Wallet Balance</th>
              <th>Category</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="passengers-tbody">
            ${data.passengers
              .map(
                (p) => `
              <tr id="row-passenger-${p.id}">
                <td class="mono"><strong>${p.id}</strong></td>
                <td>${p.fullName}</td>
                <td>${p.email}</td>
                <td>${p.phoneNumber}</td>
                <td style="color:#00E676; font-weight:700;">₹${Number(p.walletBalance).toFixed(1)}</td>
                <td><span class="tag ${p.concessionCategory.includes('Student') ? 'tag-inactive' : 'tag-active'}">${p.concessionCategory}</span></td>
                <td><span class="tag tag-active">${p.status}</span></td>
                <td>
                  <button class="btn btn-sm" onclick='openEditPassengerModal(${JSON.stringify(p)})'>✏️ Edit</button>
                  <button class="btn btn-sm btn-danger" onclick="deletePassenger('${p.id}')">🗑️ Delete</button>
                </td>
              </tr>
            `
              )
              .join('')}
          </tbody>
        </table>
      </div>
    </div>

    <!-- 2. BUSES TAB -->
    <div id="tab-buses" style="display:none;">
      <div class="action-bar">
        <input type="text" class="search-input" placeholder="Search bus name or plate number..." oninput="filterTable('buses-table', this.value)">
        <button class="btn" onclick="openAddBusModal()">+ Register New Bus</button>
      </div>
      <div class="table-container">
        <table id="buses-table">
          <thead>
            <tr>
              <th>Plate Number</th>
              <th>Bus Name</th>
              <th>Category</th>
              <th>Route (Start ➔ Dest)</th>
              <th>Seats</th>
              <th>Status</th>
              <th>Collection</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="buses-tbody">
            ${data.buses
              .map(
                (b) => `
              <tr id="row-bus-${b.regNumber.replace(/\\s+/g, '_')}">
                <td class="mono"><strong>${b.regNumber}</strong></td>
                <td><strong>${b.busName}</strong></td>
                <td>${b.category}</td>
                <td>${b.route}</td>
                <td>${b.seatingCapacity} seats</td>
                <td><span class="tag ${b.isTripActive ? 'tag-active' : 'tag-inactive'}">${b.isTripActive ? 'ACTIVE / RUNNING' : 'INACTIVE / DEPOT'}</span></td>
                <td style="color:#00E676; font-weight:700;">₹${Number(b.todayCollection || 0).toFixed(1)}</td>
                <td>
                  <button class="btn btn-sm" onclick='openEditBusModal(${JSON.stringify(b)})'>✏️ Edit</button>
                  <button class="btn btn-sm btn-danger" onclick="deleteBus('${b.regNumber}')">🗑️ Delete</button>
                </td>
              </tr>
            `
              )
              .join('')}
          </tbody>
        </table>
      </div>
    </div>

    <!-- 3. CONDUCTORS TAB -->
    <div id="tab-conductors" style="display:none;">
      <div class="action-bar">
        <input type="text" class="search-input" placeholder="Search conductor name or ID..." oninput="filterTable('conductors-table', this.value)">
        <button class="btn" onclick="openAddConductorModal()">+ Add New Conductor</button>
      </div>
      <div class="table-container">
        <table id="conductors-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>User ID (Login)</th>
              <th>Phone</th>
              <th>Badge / License</th>
              <th>Assigned Bus</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="conductors-tbody">
            ${data.conductors
              .map(
                (c) => `
              <tr id="row-cond-${c.id}">
                <td class="mono"><strong>${c.id}</strong></td>
                <td>${c.fullName}</td>
                <td class="mono" style="color:var(--gold);">${c.userId}</td>
                <td>${c.phoneNumber}</td>
                <td class="mono">${c.licenseNumber}</td>
                <td><strong>${c.assignedBusName || c.assignedBusReg}</strong> (${c.assignedBusReg})</td>
                <td>
                  <button class="btn btn-sm" onclick='openEditConductorModal(${JSON.stringify(c)})'>✏️ Edit</button>
                  <button class="btn btn-sm btn-danger" onclick="deleteConductor('${c.id}')">🗑️ Delete</button>
                </td>
              </tr>
            `
              )
              .join('')}
          </tbody>
        </table>
      </div>
    </div>

    <!-- 4. TICKETS TAB -->
    <div id="tab-tickets" style="display:none;">
      <div class="action-bar">
        <input type="text" class="search-input" placeholder="Search ticket number, bus or passenger..." oninput="filterTable('tickets-table', this.value)">
        <button class="btn btn-sm btn-danger" onclick="clearAllTickets()">🗑️ Clear All Tickets</button>
      </div>
      <div class="table-container">
        <table id="tickets-table">
          <thead>
            <tr>
              <th>Ticket #</th>
              <th>Bus Plate</th>
              <th>Passenger</th>
              <th>Route Stage</th>
              <th>Fare</th>
              <th>Payment Mode</th>
              <th>Issued At</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="tickets-tbody">
            ${
              data.tickets.length === 0
                ? `<tr><td colspan="8" style="text-align:center; padding:30px; color:var(--text-muted);">No tickets issued yet. Conductors can issue live tickets from their dashboard.</td></tr>`
                : data.tickets
                    .map(
                      (t) => `
              <tr id="row-ticket-${t.id || t.ticketNumber}">
                <td class="mono"><strong>${t.ticketNumber || t.id}</strong></td>
                <td>${t.busName || t.busRegNumber}</td>
                <td>${t.passengerName || 'Unknown'} (${t.passengerId || 'Walk-in'})</td>
                <td>${t.boardingStop} ➔ ${t.destStop}</td>
                <td style="color:#00E676; font-weight:700;">₹${Number(t.fare || 0).toFixed(1)}</td>
                <td><span class="tag tag-active">${t.paymentMode}</span></td>
                <td style="font-size:11px;">${new Date(t.issuedAt || Date.now()).toLocaleTimeString()}</td>
                <td>
                  <button class="btn btn-sm btn-danger" onclick="deleteTicket('${t.id || t.ticketNumber}')">🗑️ Delete</button>
                </td>
              </tr>
            `
                    )
                    .join('')
            }
          </tbody>
        </table>
      </div>
    </div>

    <!-- 5. REST API EXPLORER TAB -->
    <div id="tab-api" style="display:none;">
      <div style="background:var(--card-bg); border:1px solid var(--border); border-radius:16px; padding:24px;">
        <h2 style="font-size:18px; margin-bottom:12px;">Interactive REST API Documentation</h2>
        <p style="color:var(--text-muted); font-size:13px; margin-bottom:20px;">Use these standard endpoints to automate data creation, editing, and deletion from cURL, Postman, or mobile apps.</p>

        <div style="display:flex; flex-direction:column; gap:12px;">
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:#00E676; font-weight:bold;">GET</span> <a href="/api/data/json" target="_blank" style="color:white; text-decoration:underline;">/api/data/json</a> - Get complete unified JSON dataset
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:#29B6F6; font-weight:bold;">POST</span> /api/data/passengers - Create new passenger { fullName, email, phoneNumber, walletBalance, concessionCategory }
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:var(--gold); font-weight:bold;">PUT</span> /api/data/passengers/:id - Edit/update passenger details or wallet balance
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:var(--danger); font-weight:bold;">DELETE</span> /api/data/passengers/:id - Delete passenger record
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:#29B6F6; font-weight:bold;">POST</span> /api/data/buses - Register new bus { regNumber, busName, category, route, startPoint, destPoint, seatingCapacity }
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:var(--gold); font-weight:bold;">PUT</span> /api/data/buses/:regNumber - Update bus name, route, status, or workers
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:var(--danger); font-weight:bold;">DELETE</span> /api/data/buses/:regNumber - Delete bus record
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:#29B6F6; font-weight:bold;">POST</span> /api/data/conductors - Create conductor { fullName, userId, phoneNumber, licenseNumber, assignedBusReg }
          </div>
          <div style="background:#0D1117; padding:12px 16px; border-radius:10px; font-family:'JetBrains Mono'; font-size:12px;">
            <span style="color:var(--danger); font-weight:bold;">DELETE</span> /api/data/conductors/:id - Delete conductor record
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- MODALS -->

  <!-- Add Passenger Modal -->
  <div class="modal-overlay" id="modal-add-passenger">
    <div class="modal-card">
      <div class="modal-header">
        <h3>+ Add New Passenger</h3>
        <button class="btn btn-sm" style="background:transparent;" onclick="closeModal('modal-add-passenger')">✕</button>
      </div>
      <form onsubmit="submitAddPassenger(event)">
        <div class="form-group">
          <label>Full Name *</label>
          <input type="text" id="add-p-name" class="form-input" required placeholder="e.g. Arun Kumar">
        </div>
        <div class="form-group">
          <label>Email Address *</label>
          <input type="email" id="add-p-email" class="form-input" required placeholder="e.g. arun@gmail.com">
        </div>
        <div class="form-group">
          <label>Phone Number</label>
          <input type="text" id="add-p-phone" class="form-input" placeholder="+91 98470 XXXXX">
        </div>
        <div class="form-group">
          <label>Initial Wallet Balance (₹)</label>
          <input type="number" step="0.5" id="add-p-balance" class="form-input" value="0.0">
        </div>
        <div class="form-group">
          <label>Concession Category</label>
          <select id="add-p-cat" class="form-input">
            <option value="General / Adult Standard">General / Adult Standard</option>
            <option value="Student Concession (₹5 Flat Tariff)">Student Concession (₹5 Flat Tariff)</option>
            <option value="Senior Citizen (50% Tariff)">Senior Citizen (50% Tariff)</option>
          </select>
        </div>
        <div class="form-group">
          <label>Home Station</label>
          <input type="text" id="add-p-station" class="form-input" placeholder="e.g. Aluva Stand, Ernakulam">
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-sm" style="background:#374151;" onclick="closeModal('modal-add-passenger')">Cancel</button>
          <button type="submit" class="btn">Create Passenger</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Edit Passenger Modal -->
  <div class="modal-overlay" id="modal-edit-passenger">
    <div class="modal-card">
      <div class="modal-header">
        <h3>✏️ Edit Passenger</h3>
        <button class="btn btn-sm" style="background:transparent;" onclick="closeModal('modal-edit-passenger')">✕</button>
      </div>
      <form onsubmit="submitEditPassenger(event)">
        <input type="hidden" id="edit-p-id">
        <div class="form-group">
          <label>Full Name</label>
          <input type="text" id="edit-p-name" class="form-input" required>
        </div>
        <div class="form-group">
          <label>Email Address</label>
          <input type="email" id="edit-p-email" class="form-input" required>
        </div>
        <div class="form-group">
          <label>Phone Number</label>
          <input type="text" id="edit-p-phone" class="form-input">
        </div>
        <div class="form-group">
          <label>Wallet Balance (₹)</label>
          <input type="number" step="0.5" id="edit-p-balance" class="form-input" required>
        </div>
        <div class="form-group">
          <label>Concession Category</label>
          <select id="edit-p-cat" class="form-input">
            <option value="General / Adult Standard">General / Adult Standard</option>
            <option value="Student Concession (₹5 Flat Tariff)">Student Concession (₹5 Flat Tariff)</option>
            <option value="Senior Citizen (50% Tariff)">Senior Citizen (50% Tariff)</option>
          </select>
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-sm" style="background:#374151;" onclick="closeModal('modal-edit-passenger')">Cancel</button>
          <button type="submit" class="btn">Save Changes</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Add Bus Modal -->
  <div class="modal-overlay" id="modal-add-bus">
    <div class="modal-card">
      <div class="modal-header">
        <h3>+ Register New Bus</h3>
        <button class="btn btn-sm" style="background:transparent;" onclick="closeModal('modal-add-bus')">✕</button>
      </div>
      <form onsubmit="submitAddBus(event)">
        <div class="form-group">
          <label>Kerala Registration Plate *</label>
          <input type="text" id="add-b-reg" class="form-input" required placeholder="e.g. KL 07 DF 8899" style="text-transform:uppercase;">
        </div>
        <div class="form-group">
          <label>Bus Display Name *</label>
          <input type="text" id="add-b-name" class="form-input" required placeholder="e.g. St. Mary Super Express">
        </div>
        <div class="form-group">
          <label>Category & Livery</label>
          <select id="add-b-cat" class="form-input">
            <option value="Limited Stop Bus (Red-Whiteline)">Limited Stop Bus (Red-Whiteline)</option>
            <option value="Ordinary Bus (Blue-Whiteline)">Ordinary Bus (Blue-Whiteline)</option>
            <option value="City Bus (Green-Whiteline)">City Bus (Green-Whiteline)</option>
          </select>
        </div>
        <div class="form-group">
          <label>Start Point</label>
          <input type="text" id="add-b-start" class="form-input" placeholder="e.g. Aluva Stand">
        </div>
        <div class="form-group">
          <label>Destination Point</label>
          <input type="text" id="add-b-dest" class="form-input" placeholder="e.g. Angamaly Stand">
        </div>
        <div class="form-group">
          <label>Seating Capacity</label>
          <input type="number" id="add-b-seats" class="form-input" value="48">
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-sm" style="background:#374151;" onclick="closeModal('modal-add-bus')">Cancel</button>
          <button type="submit" class="btn">Register Bus</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Edit Bus Modal -->
  <div class="modal-overlay" id="modal-edit-bus">
    <div class="modal-card">
      <div class="modal-header">
        <h3>✏️ Edit Bus Details</h3>
        <button class="btn btn-sm" style="background:transparent;" onclick="closeModal('modal-edit-bus')">✕</button>
      </div>
      <form onsubmit="submitEditBus(event)">
        <input type="hidden" id="edit-b-reg">
        <div class="form-group">
          <label>Bus Display Name</label>
          <input type="text" id="edit-b-name" class="form-input" required>
        </div>
        <div class="form-group">
          <label>Category</label>
          <select id="edit-b-cat" class="form-input">
            <option value="Limited Stop Bus (Red-Whiteline)">Limited Stop Bus (Red-Whiteline)</option>
            <option value="Ordinary Bus (Blue-Whiteline)">Ordinary Bus (Blue-Whiteline)</option>
            <option value="City Bus (Green-Whiteline)">City Bus (Green-Whiteline)</option>
          </select>
        </div>
        <div class="form-group">
          <label>Start Point</label>
          <input type="text" id="edit-b-start" class="form-input">
        </div>
        <div class="form-group">
          <label>Destination Point</label>
          <input type="text" id="edit-b-dest" class="form-input">
        </div>
        <div class="form-group">
          <label>Trip Status</label>
          <select id="edit-b-active" class="form-input">
            <option value="false">INACTIVE / DEPOT</option>
            <option value="true">ACTIVE / RUNNING NOW</option>
          </select>
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-sm" style="background:#374151;" onclick="closeModal('modal-edit-bus')">Cancel</button>
          <button type="submit" class="btn">Save Changes</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Add Conductor Modal -->
  <div class="modal-overlay" id="modal-add-cond">
    <div class="modal-card">
      <div class="modal-header">
        <h3>+ Add New Conductor</h3>
        <button class="btn btn-sm" style="background:transparent;" onclick="closeModal('modal-add-cond')">✕</button>
      </div>
      <form onsubmit="submitAddConductor(event)">
        <div class="form-group">
          <label>Full Name *</label>
          <input type="text" id="add-c-name" class="form-input" required placeholder="e.g. Anil Varghese">
        </div>
        <div class="form-group">
          <label>User ID (Conductor Login) *</label>
          <input type="text" id="add-c-user" class="form-input" required placeholder="e.g. anil.conductor" style="text-transform:lowercase;">
        </div>
        <div class="form-group">
          <label>Phone Number</label>
          <input type="text" id="add-c-phone" class="form-input" placeholder="+91 98470 XXXXX">
        </div>
        <div class="form-group">
          <label>Conductor License Number</label>
          <input type="text" id="add-c-lic" class="form-input" placeholder="KL-MVD-COND-XXXX">
        </div>
        <div class="form-group">
          <label>Assigned Bus Registration</label>
          <input type="text" id="add-c-bus" class="form-input" placeholder="e.g. KL 07 CD 4589">
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-sm" style="background:#374151;" onclick="closeModal('modal-add-cond')">Cancel</button>
          <button type="submit" class="btn">Add Conductor</button>
        </div>
      </form>
    </div>
  </div>

  <div id="toast" class="toast">Action completed successfully</div>

  <script>
    function showToast(msg) {
      const t = document.getElementById('toast');
      t.innerText = msg;
      t.style.display = 'block';
      setTimeout(() => { t.style.display = 'none'; }, 2500);
    }

    function switchTab(tabId) {
      document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
      event.target.classList.add('active');
      ['passengers', 'buses', 'conductors', 'tickets', 'api'].forEach(t => {
        const el = document.getElementById('tab-' + t);
        if (el) el.style.display = (t === tabId) ? 'block' : 'none';
      });
    }

    function filterTable(tableId, query) {
      const q = query.toLowerCase();
      const rows = document.querySelectorAll('#' + tableId + ' tbody tr');
      rows.forEach(r => {
        const text = r.innerText.toLowerCase();
        r.style.display = text.includes(q) ? '' : 'none';
      });
    }

    function openModal(id) { document.getElementById(id).classList.add('open'); }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }

    // PASSENGERS CRUD
    function openAddPassengerModal() { openModal('modal-add-passenger'); }
    async function submitAddPassenger(e) {
      e.preventDefault();
      const payload = {
        fullName: document.getElementById('add-p-name').value,
        email: document.getElementById('add-p-email').value,
        phoneNumber: document.getElementById('add-p-phone').value,
        walletBalance: document.getElementById('add-p-balance').value,
        concessionCategory: document.getElementById('add-p-cat').value,
        homeStation: document.getElementById('add-p-station').value
      };
      const res = await fetch('/api/data/passengers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        closeModal('modal-add-passenger');
        showToast('Passenger created successfully!');
        setTimeout(() => location.reload(), 500);
      }
    }

    function openEditPassengerModal(p) {
      document.getElementById('edit-p-id').value = p.id;
      document.getElementById('edit-p-name').value = p.fullName;
      document.getElementById('edit-p-email').value = p.email;
      document.getElementById('edit-p-phone').value = p.phoneNumber;
      document.getElementById('edit-p-balance').value = p.walletBalance;
      document.getElementById('edit-p-cat').value = p.concessionCategory;
      openModal('modal-edit-passenger');
    }

    async function submitEditPassenger(e) {
      e.preventDefault();
      const id = document.getElementById('edit-p-id').value;
      const payload = {
        fullName: document.getElementById('edit-p-name').value,
        email: document.getElementById('edit-p-email').value,
        phoneNumber: document.getElementById('edit-p-phone').value,
        walletBalance: document.getElementById('edit-p-balance').value,
        concessionCategory: document.getElementById('edit-p-cat').value
      };
      const res = await fetch('/api/data/passengers/' + id, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        closeModal('modal-edit-passenger');
        showToast('Passenger updated!');
        setTimeout(() => location.reload(), 500);
      }
    }

    async function deletePassenger(id) {
      if (!confirm('Are you sure you want to delete passenger ' + id + '?')) return;
      const res = await fetch('/api/data/passengers/' + id, { method: 'DELETE' });
      if (res.ok) {
        showToast('Passenger deleted');
        const row = document.getElementById('row-passenger-' + id);
        if (row) row.remove();
      }
    }

    // BUSES CRUD
    function openAddBusModal() { openModal('modal-add-bus'); }
    async function submitAddBus(e) {
      e.preventDefault();
      const payload = {
        regNumber: document.getElementById('add-b-reg').value,
        busName: document.getElementById('add-b-name').value,
        category: document.getElementById('add-b-cat').value,
        startPoint: document.getElementById('add-b-start').value,
        destPoint: document.getElementById('add-b-dest').value,
        seatingCapacity: document.getElementById('add-b-seats').value
      };
      const res = await fetch('/api/data/buses', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        closeModal('modal-add-bus');
        showToast('Bus registered successfully!');
        setTimeout(() => location.reload(), 500);
      }
    }

    function openEditBusModal(b) {
      document.getElementById('edit-b-reg').value = b.regNumber;
      document.getElementById('edit-b-name').value = b.busName;
      document.getElementById('edit-b-cat').value = b.category;
      document.getElementById('edit-b-start').value = b.startPoint;
      document.getElementById('edit-b-dest').value = b.destPoint;
      document.getElementById('edit-b-active').value = b.isTripActive ? 'true' : 'false';
      openModal('modal-edit-bus');
    }

    async function submitEditBus(e) {
      e.preventDefault();
      const reg = document.getElementById('edit-b-reg').value;
      const payload = {
        busName: document.getElementById('edit-b-name').value,
        category: document.getElementById('edit-b-cat').value,
        startPoint: document.getElementById('edit-b-start').value,
        destPoint: document.getElementById('edit-b-dest').value,
        isTripActive: document.getElementById('edit-b-active').value === 'true'
      };
      const res = await fetch('/api/data/buses/' + encodeURIComponent(reg), {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        closeModal('modal-edit-bus');
        showToast('Bus updated successfully!');
        setTimeout(() => location.reload(), 500);
      }
    }

    async function deleteBus(reg) {
      if (!confirm('Are you sure you want to delete bus ' + reg + '?')) return;
      const res = await fetch('/api/data/buses/' + encodeURIComponent(reg), { method: 'DELETE' });
      if (res.ok) {
        showToast('Bus deleted');
        const row = document.getElementById('row-bus-' + reg.replace(/\\s+/g, '_'));
        if (row) row.remove();
      }
    }

    // CONDUCTORS CRUD
    function openAddConductorModal() { openModal('modal-add-cond'); }
    async function submitAddConductor(e) {
      e.preventDefault();
      const payload = {
        fullName: document.getElementById('add-c-name').value,
        userId: document.getElementById('add-c-user').value,
        phoneNumber: document.getElementById('add-c-phone').value,
        licenseNumber: document.getElementById('add-c-lic').value,
        assignedBusReg: document.getElementById('add-c-bus').value
      };
      const res = await fetch('/api/data/conductors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (res.ok) {
        closeModal('modal-add-cond');
        showToast('Conductor created successfully!');
        setTimeout(() => location.reload(), 500);
      }
    }

    async function deleteConductor(id) {
      if (!confirm('Are you sure you want to delete conductor ' + id + '?')) return;
      const res = await fetch('/api/data/conductors/' + id, { method: 'DELETE' });
      if (res.ok) {
        showToast('Conductor deleted');
        const row = document.getElementById('row-cond-' + id);
        if (row) row.remove();
      }
    }

    async function deleteTicket(id) {
      if (!confirm('Are you sure you want to delete ticket ' + id + '?')) return;
      const res = await fetch('/api/data/tickets/' + id, { method: 'DELETE' });
      if (res.ok) {
        showToast('Ticket deleted');
        const row = document.getElementById('row-ticket-' + id);
        if (row) row.remove();
      }
    }

    function syncWithFrontend() {
      location.reload();
    }
  </script>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html');
  res.status(200).send(html);
});

export default router;
