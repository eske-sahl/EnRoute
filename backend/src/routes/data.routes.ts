import { Router, Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

const router = Router();
const DATA_FILE_PATH = path.join(__dirname, '../../data/smartbus_state.json');
const ADMIN_HTML_PATH = path.join(__dirname, '../../data/admin.html');

interface TimetableEntry {
  stop?: string;
  stopName?: string;
  time: string;
}

interface BusWorkers {
  driver?: string;
  driverPhone?: string;
  conductor?: string;
  conductorPhone?: string;
  cleaner?: string;
  cleanerPhone?: string;
}

interface BusRecord {
  regNumber: string;
  busName: string;
  category: string;
  route: string;
  startPoint: string;
  destPoint: string;
  seatingCapacity: number;
  isTripActive: boolean;
  status: string;
  todayCollection: number;
  ticketsSold?: number;
  ticketsCount?: number;
  workers?: BusWorkers;
  driverName?: string;
  driverPhone?: string;
  conductorName?: string;
  conductorPhone?: string;
  conductorEmail?: string;
  cleanerName?: string;
  cleanerPhone?: string;
  ownerName?: string;
  ownerPhone?: string;
  ownerEmail?: string;
  companyName?: string;
  timetable?: TimetableEntry[];
  stops?: any[];
  verificationStatus?: string;
  isApprovedByAdmin?: boolean;
  chassisNumber?: string;
  permitNumber?: string;
  fitnessValidity?: string;
  insurancePolicyNumber?: string;
  currentStop?: string;
  nextStop?: string;
  eta?: string;
  isLiveGpsActive?: boolean;
  currentLatitude?: number;
  currentLongitude?: number;
  conductorLocationString?: string;
  customFareChart?: Record<string, number>;
  [key: string]: any;
}

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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      companyName: 'St. George Motors Ernakulam',
      driverName: 'Venu Pillai (Badge #KL4201)',
      driverPhone: '+91 94470 55112',
      conductorName: 'Suresh Kumar',
      conductorPhone: '+91 98470 11001',
      cleanerName: 'Mani K.',
      cleanerPhone: '+91 94470 55113',
      chassisNumber: 'MB1-420-KL-CHASSIS-8891',
      permitNumber: 'KL/2026/MVD/STAGE/0491',
      fitnessValidity: '28-Dec-2027',
      insurancePolicyNumber: 'NIC-KL-COM-778210',
      verificationStatus: 'ADMIN_APPROVED',
      isApprovedByAdmin: true,
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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      companyName: 'St. George Motors Ernakulam',
      driverName: 'Antony Joseph',
      driverPhone: '+91 94470 55114',
      conductorName: 'Biju Varghese',
      conductorPhone: '+91 98470 11002',
      cleanerName: 'Saji T.',
      cleanerPhone: '+91 94470 55115',
      chassisNumber: 'MB1-420-KL-CHASSIS-9922',
      permitNumber: 'KL/2026/MVD/STAGE/0512',
      fitnessValidity: '15-Nov-2027',
      insurancePolicyNumber: 'UI-KL-COM-883901',
      verificationStatus: 'ADMIN_APPROVED',
      isApprovedByAdmin: true,
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
      ownerName: 'George Varghese',
      ownerPhone: '+91 94470 12345',
      ownerEmail: 'owner@stgeorge.com',
      companyName: 'St. George Motors Ernakulam',
      driverName: 'Pradeep Kumar',
      driverPhone: '+91 94470 55116',
      conductorName: 'Rajesh Nair',
      conductorPhone: '+91 98470 11003',
      cleanerName: 'Babu N.',
      cleanerPhone: '+91 94470 55117',
      chassisNumber: 'MB1-420-KL-CHASSIS-1104',
      permitNumber: 'KL/2026/MVD/STAGE/0688',
      fitnessValidity: '10-Oct-2027',
      insurancePolicyNumber: 'OIC-KL-COM-991204',
      verificationStatus: 'ADMIN_APPROVED',
      isApprovedByAdmin: true,
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
  ] as BusRecord[],
  tickets: [] as any[],
};

// State loader & persistence helper
function loadState(): typeof initialSeedData {
  try {
    if (fs.existsSync(DATA_FILE_PATH)) {
      const raw = fs.readFileSync(DATA_FILE_PATH, 'utf-8');
      const parsed = JSON.parse(raw);
      if (parsed && Array.isArray(parsed.buses)) {
        return parsed;
      }
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
  const pendingApprovals = data.buses.filter(
    (b) => b.verificationStatus === 'WAITING_FOR_VERIFICATION' || b.isApprovedByAdmin === false
  );
  res.status(200).json({
    ...data,
    summary: {
      totalPassengers: data.passengers.length,
      totalBuses: data.buses.length,
      pendingApprovals: pendingApprovals.length,
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

  // Handle explicit deletions
  if (Array.isArray(incoming.deletedBusRegs)) {
    const deletedSet = new Set(incoming.deletedBusRegs.map((r: string) => r.toUpperCase()));
    current.buses = current.buses.filter((b) => !deletedSet.has(b.regNumber.toUpperCase()));
  }
  if (Array.isArray(incoming.deletedConductorIds)) {
    const deletedCondSet = new Set(incoming.deletedConductorIds);
    current.conductors = current.conductors.filter((c) => !deletedCondSet.has(c.id));
  }

  // Merge buses
  if (Array.isArray(incoming.buses)) {
    for (const b of incoming.buses) {
      const idx = current.buses.findIndex(
        (item) => item.regNumber.toUpperCase() === b.regNumber.toUpperCase()
      );
      if (idx !== -1) {
        // Protect server-side approval: if already approved by admin, preserve it
        const currentApproved =
          (current.buses[idx] as any).verificationStatus === 'ADMIN_APPROVED' ||
          (current.buses[idx] as any).isApprovedByAdmin === true;
        current.buses[idx] = {
          ...current.buses[idx],
          ...b,
          verificationStatus: currentApproved
            ? 'ADMIN_APPROVED'
            : (b.verificationStatus || (current.buses[idx] as any).verificationStatus || 'ADMIN_APPROVED'),
          isApprovedByAdmin: currentApproved
            ? true
            : (b.isApprovedByAdmin ?? (current.buses[idx] as any).isApprovedByAdmin ?? true),
        };
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
// 3. BUS CRUD & ADMIN APPROVAL ENDPOINTS
// -----------------------------------------------------------------------------

router.post('/buses', (req: Request, res: Response) => {
  const data = loadState();
  const {
    regNumber,
    busName,
    category,
    route,
    startPoint,
    destPoint,
    seatingCapacity,
    workers,
    timetable,
    ownerName,
    ownerPhone,
    ownerEmail,
    chassisNumber,
    permitNumber,
    fitnessValidity,
    insurancePolicyNumber,
    verificationStatus,
    isApprovedByAdmin,
  } = req.body;

  if (!regNumber || !busName) {
    return res.status(400).json({ status: 'error', message: 'regNumber and busName are required' });
  }

  const cleanReg = regNumber.trim().toUpperCase();
  if (data.buses.some((b) => b.regNumber.toUpperCase() === cleanReg)) {
    return res.status(409).json({ status: 'error', message: `Bus with registration ${cleanReg} already exists` });
  }

  const newBus: BusRecord = {
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
    ownerName: ownerName || 'George Varghese',
    ownerPhone: ownerPhone || '+91 94470 12345',
    ownerEmail: ownerEmail || 'owner@stgeorge.com',
    chassisNumber: chassisNumber || `MB1-KL-CHASSIS-${Math.floor(1000 + Math.random() * 9000)}`,
    permitNumber: permitNumber || `KL/2026/MVD/STAGE/${Math.floor(1000 + Math.random() * 9000)}`,
    fitnessValidity: fitnessValidity || '31-Dec-2027',
    insurancePolicyNumber: insurancePolicyNumber || `NIC-KL-COM-${Math.floor(100000 + Math.random() * 900000)}`,
    verificationStatus: verificationStatus || 'WAITING_FOR_VERIFICATION',
    isApprovedByAdmin: isApprovedByAdmin !== undefined ? Boolean(isApprovedByAdmin) : false,
    workers: workers || { driver: 'Assigned Driver', conductor: 'Assigned Conductor', cleaner: 'Assigned Cleaner' },
    timetable:
      Array.isArray(timetable) && timetable.length > 0
        ? timetable
        : [
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
    driverName: req.body.driverName || b.driverName,
    driverPhone: req.body.driverPhone || b.driverPhone,
    cleanerName: req.body.cleanerName || b.cleanerName,
    cleanerPhone: req.body.cleanerPhone || b.cleanerPhone,
    conductorName: req.body.conductorName || b.conductorName,
    conductorPhone: req.body.conductorPhone || b.conductorPhone,
    chassisNumber: req.body.chassisNumber || b.chassisNumber,
    permitNumber: req.body.permitNumber || b.permitNumber,
    fitnessValidity: req.body.fitnessValidity || b.fitnessValidity,
    insurancePolicyNumber: req.body.insurancePolicyNumber || b.insurancePolicyNumber,
    ownerName: req.body.ownerName || b.ownerName,
    ownerPhone: req.body.ownerPhone || b.ownerPhone,
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

// Admin Approval Action
router.post('/buses/:regNumber/verify', (req: Request, res: Response) => {
  const data = loadState();
  const cleanReg = req.params.regNumber.trim().toUpperCase();
  const idx = data.buses.findIndex((b) => b.regNumber.toUpperCase() === cleanReg);

  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: `Bus ${cleanReg} not found` });
  }

  (data.buses[idx] as any).verificationStatus = 'ADMIN_APPROVED';
  (data.buses[idx] as any).isApprovedByAdmin = true;
  saveState(data);
  res.status(200).json({
    status: 'success',
    message: `Bus ${cleanReg} verified and authorized for public service by State Transport Admin`,
    data: data.buses[idx],
  });
});

// Admin Rejection Action
router.post('/buses/:regNumber/reject', (req: Request, res: Response) => {
  const data = loadState();
  const cleanReg = req.params.regNumber.trim().toUpperCase();
  const idx = data.buses.findIndex((b) => b.regNumber.toUpperCase() === cleanReg);

  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: `Bus ${cleanReg} not found` });
  }

  (data.buses[idx] as any).verificationStatus = 'REJECTED';
  (data.buses[idx] as any).isApprovedByAdmin = false;
  saveState(data);
  res.status(200).json({
    status: 'success',
    message: `Bus ${cleanReg} rejected by State Transport Admin`,
    data: data.buses[idx],
  });
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
    fullName: req.body.fullName !== undefined ? req.body.fullName : c.fullName,
    phoneNumber: req.body.phoneNumber !== undefined ? req.body.phoneNumber : c.phoneNumber,
    licenseNumber: req.body.licenseNumber !== undefined ? req.body.licenseNumber : c.licenseNumber,
    assignedBusReg: req.body.assignedBusReg !== undefined ? req.body.assignedBusReg : c.assignedBusReg,
    assignedBusName: req.body.assignedBusName !== undefined ? req.body.assignedBusName : c.assignedBusName,
    status: req.body.status !== undefined ? req.body.status : c.status,
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
// 6. VISUAL INTERACTIVE DASHBOARD SERVING
// -----------------------------------------------------------------------------

router.get('/', (req: Request, res: Response) => {
  const data = loadState();
  if (fs.existsSync(ADMIN_HTML_PATH)) {
    const raw = fs.readFileSync(ADMIN_HTML_PATH, 'utf-8');
    const injected = raw.replace('/*__STATE_DATA__*/null', JSON.stringify(data));
    res.setHeader('Content-Type', 'text/html');
    return res.status(200).send(injected);
  }
  return res.status(500).send('Admin dashboard HTML file not found at: ' + ADMIN_HTML_PATH);
});

export default router;
