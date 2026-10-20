import { Router, Request, Response } from 'express';

const router = Router();

// Master Data Definitions matching Prisma Schema & FleetState
const backendData = {
  project: 'SmartBus Kerala',
  version: '1.0.0',
  environment: 'development',
  databaseEngine: 'PostgreSQL (Prisma ORM) / In-Memory Reactive State',
  summary: {
    totalPassengers: 3,
    totalBuses: 3,
    totalConductors: 3,
    totalOwners: 1,
    activeRoutes: 3,
  },
  owner: {
    id: 'OWNER-1',
    fullName: 'George Varghese',
    email: 'owner@stgeorge.com',
    phoneNumber: '+91 94470 12345',
    operatorName: 'St. George Motors Ernakulam',
    isVerified: true,
    fleetCount: 3,
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
      assignedBusReg: 'KL-07-CD-4501',
      assignedBusName: 'St. George Motors',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
    {
      id: 'COND-2',
      fullName: 'Biju Mathew',
      userId: 'biju.conductor',
      phoneNumber: '+91 98470 11002',
      licenseNumber: 'KL-05-COND-2019-3321',
      assignedBusReg: 'KL-05-AW-9902',
      assignedBusName: 'Kondody Motors',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
    {
      id: 'COND-3',
      fullName: 'Rajesh Nair',
      userId: 'rajesh.conductor',
      phoneNumber: '+91 98470 11003',
      licenseNumber: 'KL-01-COND-2021-7740',
      assignedBusReg: 'KL-01-BK-3304',
      assignedBusName: 'City Rider',
      role: 'ROLE_CONDUCTOR',
      status: 'ACTIVE',
    },
  ],
  buses: [
    {
      regNumber: 'KL-07-CD-4501',
      busName: 'St. George Motors',
      category: 'Limited Stop Bus (Red-Whiteline)',
      route: 'Aluva Stand ➔ Angamaly Stand via Kalamassery, Edappally, MG Road',
      startPoint: 'Aluva Stand',
      destPoint: 'Angamaly Stand',
      seatingCapacity: 49,
      isTripActive: true,
      todayCollection: 4850.0,
      ticketsSold: 142,
      workers: {
        driver: 'Biju Narayanan',
        conductor: 'Suresh Kumar',
        cleaner: 'Manoj P',
      },
      timetable: [
        { stop: 'Aluva Stand', time: '06:00 AM' },
        { stop: 'Kalamassery Premier', time: '06:20 AM' },
        { stop: 'Edappally Toll', time: '06:35 AM' },
        { stop: 'Palarivattom Bypass', time: '06:50 AM' },
        { stop: 'Vyttila Mobility Hub', time: '07:10 AM' },
        { stop: 'Kaloor Stand', time: '07:30 AM' },
        { stop: 'MG Road Maharajas', time: '07:45 AM' },
        { stop: 'Menaka High Court', time: '08:00 AM' },
        { stop: 'Seaport-Airport Junction', time: '08:25 AM' },
        { stop: 'Kakkanad Collectorate', time: '08:45 AM' },
        { stop: 'Angamaly Stand', time: '09:15 AM' },
      ],
    },
    {
      regNumber: 'KL-05-AW-9902',
      busName: 'Kondody Motors',
      category: 'Ordinary Bus (Blue-Whiteline)',
      route: 'Kaloor Stand ➔ Perumbavoor Stand via Kizhakkambalam',
      startPoint: 'Kaloor Stand',
      destPoint: 'Perumbavoor Stand',
      seatingCapacity: 45,
      isTripActive: true,
      todayCollection: 3420.0,
      ticketsSold: 98,
      workers: {
        driver: 'Sunil Varghese',
        conductor: 'Biju Mathew',
        cleaner: 'Dileep K',
      },
      timetable: [
        { stop: 'Kaloor Stand', time: '06:30 AM' },
        { stop: 'Palarivattom', time: '06:45 AM' },
        { stop: 'Kakkanad InfoPark', time: '07:10 AM' },
        { stop: 'Kizhakkambalam', time: '07:35 AM' },
        { stop: 'Pattimattom', time: '07:55 AM' },
        { stop: 'Perumbavoor Stand', time: '08:20 AM' },
      ],
    },
    {
      regNumber: 'KL-01-BK-3304',
      busName: 'City Rider',
      category: 'City Bus (Green-Whiteline)',
      route: 'Fort Kochi ➔ Kakkanad InfoPark via Thoppumpady & Vyttila',
      startPoint: 'Fort Kochi',
      destPoint: 'Kakkanad InfoPark',
      seatingCapacity: 40,
      isTripActive: false,
      todayCollection: 2150.0,
      ticketsSold: 76,
      workers: {
        driver: 'Prasad M',
        conductor: 'Rajesh Nair',
        cleaner: 'Santhosh',
      },
      timetable: [
        { stop: 'Fort Kochi Bus Terminus', time: '07:00 AM' },
        { stop: 'Thoppumpady Junction', time: '07:20 AM' },
        { stop: 'Kundannoor Bypass', time: '07:45 AM' },
        { stop: 'Vyttila Hub', time: '08:05 AM' },
        { stop: 'Chakkaraparambu', time: '08:20 AM' },
        { stop: 'Kakkanad InfoPark', time: '08:50 AM' },
      ],
    },
  ],
  sampleTickets: [
    {
      ticketNumber: 'KL-SBK-1910-1001',
      busName: 'St. George Motors',
      busRegNumber: 'KL-07-CD-4501',
      passengerName: 'Anjali Nair',
      passengerId: 'SBK-KL-987263',
      route: 'Aluva Stand ➔ MG Road Maharajas',
      fare: 35.0,
      category: 'General',
      paymentMode: 'SMART_WALLET',
      conductor: 'Suresh Kumar',
      timestamp: '2026-10-19T08:15:00.000Z',
    },
    {
      ticketNumber: 'KL-SBK-1910-1002',
      busName: 'St. George Motors',
      busRegNumber: 'KL-07-CD-4501',
      passengerName: 'Rahul Menon',
      passengerId: 'SBK-KL-554120',
      route: 'Kalamassery Premier ➔ Edappally Toll',
      fare: 5.0,
      category: 'Student Concession',
      paymentMode: 'SMART_WALLET',
      conductor: 'Suresh Kumar',
      timestamp: '2026-10-19T08:32:00.000Z',
    },
    {
      ticketNumber: 'KL-SBK-1910-1003',
      busName: 'St. George Motors',
      busRegNumber: 'KL-07-CD-4501',
      passengerName: 'Unknown',
      passengerId: 'Unknown',
      route: 'Edappally Toll ➔ Kaloor Stand',
      fare: 15.0,
      category: 'General',
      paymentMode: 'CASH',
      conductor: 'Suresh Kumar',
      timestamp: '2026-10-19T08:45:00.000Z',
      note: 'Walk-in cash ticket (Saved in conductor shift log only)',
    },
  ],
  prismaSchemaModels: [
    { name: 'User', table: 'users', fields: ['id', 'email', 'passwordHash', 'fullName', 'phoneNumber', 'role', 'status', 'createdAt', 'updatedAt'] },
    { name: 'OwnerProfile', table: 'owner_profiles', fields: ['id', 'userId', 'operatorName', 'idProofUrl', 'permitDocUrl', 'isVerified'] },
    { name: 'Bus', table: 'buses', fields: ['id', 'regNumber', 'busName', 'busType', 'seatingCapacity', 'ownerId', 'createdAt'] },
    { name: 'Route', table: 'routes', fields: ['id', 'routeNumber', 'sourceName', 'destName', 'baseFare', 'farePerStage', 'isActive'] },
    { name: 'RouteStop', table: 'route_stops', fields: ['id', 'routeId', 'stopName', 'stageIndex', 'latitude', 'longitude'] },
    { name: 'Trip', table: 'trips', fields: ['id', 'busId', 'conductorId', 'routeId', 'startTime', 'endTime', 'status', 'totalCollection'] },
    { name: 'Ticket', table: 'tickets', fields: ['id', 'ticketNumber', 'tripId', 'passengerId', 'boardingStop', 'destinationStop', 'fareAmount', 'paymentMethod', 'status'] },
    { name: 'Wallet', table: 'wallets', fields: ['id', 'userId', 'balance', 'currency', 'updatedAt'] },
    { name: 'WalletTransaction', table: 'wallet_transactions', fields: ['id', 'walletId', 'amount', 'transactionType', 'referenceId', 'createdAt'] },
    { name: 'LiveLocation', table: 'live_locations', fields: ['id', 'tripId', 'latitude', 'longitude', 'speedKmph', 'heading', 'recordedAt'] },
  ],
};

/**
 * @route   GET /api/data
 * @desc    Get all backend data as JSON
 * @access  Public
 */
router.get('/json', (req: Request, res: Response) => {
  res.status(200).json(backendData);
});

/**
 * @route   GET /data
 * @desc    Interactive HTML Web Dashboard to visually browse all backend data
 * @access  Public
 */
router.get('/', (req: Request, res: Response) => {
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SmartBus Kerala - Backend Data Explorer</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: #F4F6F8;
      color: #1A202C;
      padding: 24px;
      line-height: 1.5;
    }
    .header {
      background: linear-gradient(135deg, #003824, #005A3A);
      color: white;
      padding: 24px 32px;
      border-radius: 18px;
      box-shadow: 0 10px 25px rgba(0, 56, 36, 0.2);
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
      margin-bottom: 24px;
    }
    .brand { display: flex; align-items: center; gap: 14px; }
    .brand-icon {
      background: #F59E0B;
      color: #131A22;
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      font-weight: bold;
    }
    .brand-title { font-size: 24px; font-weight: 800; }
    .brand-subtitle { font-size: 13px; opacity: 0.85; }
    .header-links a {
      background: rgba(255,255,255,0.15);
      color: white;
      text-decoration: none;
      padding: 10px 16px;
      border-radius: 10px;
      font-size: 13px;
      font-weight: 600;
      transition: all 0.2s;
    }
    .header-links a:hover { background: rgba(255,255,255,0.3); }

    /* Stats Grid */
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 14px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
      border-left: 5px solid #005A3A;
    }
    .stat-val { font-size: 26px; font-weight: 800; color: #005A3A; }
    .stat-lbl { font-size: 12px; font-weight: 600; color: #718096; text-transform: uppercase; letter-spacing: 0.5px; }

    /* Tabs */
    .tabs-bar {
      display: flex;
      gap: 8px;
      overflow-x: auto;
      margin-bottom: 20px;
      border-bottom: 2px solid #E2E8F0;
      padding-bottom: 8px;
    }
    .tab-btn {
      background: none;
      border: none;
      padding: 10px 18px;
      font-size: 14px;
      font-weight: 700;
      color: #718096;
      cursor: pointer;
      border-radius: 8px;
      transition: all 0.2s;
    }
    .tab-btn.active {
      background: #005A3A;
      color: white;
    }
    .tab-btn:hover:not(.active) {
      background: #EDF2F7;
      color: #2D3748;
    }

    /* Content Cards */
    .section-card {
      background: white;
      padding: 24px;
      border-radius: 16px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
      margin-bottom: 24px;
    }
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 12px;
    }
    .section-title { font-size: 18px; font-weight: 700; color: #2D3748; }

    /* Table styling */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13px; }
    th {
      background: #F7FAFC;
      color: #4A5568;
      font-weight: 700;
      text-align: left;
      padding: 12px 14px;
      border-bottom: 2px solid #E2E8F0;
    }
    td {
      padding: 12px 14px;
      border-bottom: 1px solid #EDF2F7;
      vertical-align: middle;
    }
    tr:hover td { background: #F8FAFC; }
    .badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 700;
    }
    .badge-green { background: #DEF7EC; color: #03543F; }
    .badge-orange { background: #FEF3C7; color: #92400E; }
    .badge-blue { background: #E1EFFE; color: #1E429F; }
    .badge-gray { background: #EDF2F7; color: #4A5568; }
    .wallet-val { font-weight: 800; color: #005A3A; font-size: 14px; }

    /* Timetable list */
    .stop-chip {
      display: inline-block;
      background: #F1F5F9;
      border: 1px solid #CBD5E1;
      border-radius: 6px;
      padding: 3px 8px;
      margin: 2px 4px 2px 0;
      font-size: 11px;
    }
    .stop-chip b { color: #005A3A; }

    /* Code View */
    pre {
      background: #1E293B;
      color: #38BDF8;
      padding: 16px;
      border-radius: 12px;
      font-family: 'Courier New', monospace;
      font-size: 12px;
      overflow-x: auto;
      max-height: 400px;
    }
  </style>
</head>
<body>

  <div class="header">
    <div class="brand">
      <div class="brand-icon">🚍</div>
      <div>
        <div class="brand-title">SmartBus Kerala • Backend Data Explorer</div>
        <div class="brand-subtitle">Public Transit Management Engine • Real-time State & Database Schema</div>
      </div>
    </div>
    <div class="header-links">
      <a href="/api/data/json" target="_blank">📥 View Raw JSON API</a>
      <a href="http://localhost:56474" target="_blank">📱 Open Mobile Web App</a>
    </div>
  </div>

  <!-- Key Metrics -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-val">${backendData.summary.totalPassengers}</div>
      <div class="stat-lbl">Registered Passengers</div>
    </div>
    <div class="stat-card">
      <div class="stat-val">${backendData.summary.totalBuses}</div>
      <div class="stat-lbl">Fleet Active Buses</div>
    </div>
    <div class="stat-card">
      <div class="stat-val">${backendData.summary.totalConductors}</div>
      <div class="stat-lbl">Conductors Enrolled</div>
    </div>
    <div class="stat-card">
      <div class="stat-val">₹${backendData.buses.reduce((acc, b) => acc + b.todayCollection, 0).toFixed(2)}</div>
      <div class="stat-lbl">Today's Fleet Collection</div>
    </div>
  </div>

  <!-- Tab Buttons -->
  <div class="tabs-bar">
    <button class="tab-btn active" onclick="showTab('passengers')">👥 Passengers & Wallets</button>
    <button class="tab-btn" onclick="showTab('buses')">🚌 Buses & Timetable</button>
    <button class="tab-btn" onclick="showTab('conductors')">🧑‍✈️ Conductors</button>
    <button class="tab-btn" onclick="showTab('tickets')">🎫 Issued Tickets</button>
    <button class="tab-btn" onclick="showTab('schema')">🗄️ Prisma Database Schema</button>
  </div>

  <!-- Tab 1: Passengers -->
  <div id="tab-passengers" class="section-card">
    <div class="section-header">
      <div class="section-title">Registered Passenger Accounts (Independent Wallets & Ledgers)</div>
      <span class="badge badge-green">3 Active Seed Accounts</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>Passenger ID</th>
          <th>Name</th>
          <th>Mobile Number</th>
          <th>Login Email</th>
          <th>Concession Category</th>
          <th>Home Station</th>
          <th>Smart Wallet Balance</th>
        </tr>
      </thead>
      <tbody>
        ${backendData.passengers.map(p => `
          <tr>
            <td><code>${p.id}</code></td>
            <td><b>${p.fullName}</b></td>
            <td>${p.phoneNumber}</td>
            <td>${p.email}</td>
            <td><span class="badge ${p.concessionCategory.includes('Student') ? 'badge-orange' : 'badge-green'}">${p.concessionCategory}</span></td>
            <td>${p.homeStation}</td>
            <td><span class="wallet-val">₹${p.walletBalance.toFixed(2)}</span></td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>

  <!-- Tab 2: Buses -->
  <div id="tab-buses" class="section-card" style="display:none;">
    <div class="section-header">
      <div class="section-title">Active Bus Fleet, Routes & Worker Assignment</div>
      <span class="badge badge-blue">Operator: St. George Motors & Partners</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>Reg Number</th>
          <th>Bus Name</th>
          <th>Category</th>
          <th>Route (Start ➔ Dest)</th>
          <th>Workers (Driver, Conductor, Cleaner)</th>
          <th>Live Status</th>
          <th>Today's Collection</th>
        </tr>
      </thead>
      <tbody>
        ${backendData.buses.map(b => `
          <tr>
            <td><code>${b.regNumber}</code></td>
            <td><b>${b.busName}</b></td>
            <td><span class="badge badge-gray">${b.category}</span></td>
            <td>${b.route}</td>
            <td>Driver: <b>${b.workers.driver}</b><br>Conductor: <b>${b.workers.conductor}</b><br>Cleaner: <b>${b.workers.cleaner}</b></td>
            <td><span class="badge ${b.isTripActive ? 'badge-green' : 'badge-gray'}">${b.isTripActive ? 'LIVE RUNNING' : 'DEPOT'}</span></td>
            <td><b>₹${b.todayCollection.toFixed(2)}</b> (${b.ticketsSold} tix)</td>
          </tr>
        `).join('')}
      </tbody>
    </table>

    <div style="margin-top: 24px;">
      <h4 style="margin-bottom: 10px; color: #2D3748;">Route Ordered Stops & Timetable (Ascending Order):</h4>
      ${backendData.buses.map(b => `
        <div style="background: #F8FAFC; border: 1px solid #E2E8F0; padding: 12px 16px; border-radius: 12px; margin-bottom: 12px;">
          <div style="font-weight: 700; margin-bottom: 6px; color: #005A3A;">${b.busName} (${b.regNumber})</div>
          <div>
            ${b.timetable.map(s => `<span class="stop-chip">${s.stop} • <b>${s.time}</b></span>`).join('')}
          </div>
        </div>
      `).join('')}
    </div>
  </div>

  <!-- Tab 3: Conductors -->
  <div id="tab-conductors" class="section-card" style="display:none;">
    <div class="section-header">
      <div class="section-title">Owner-Provisioned Conductor Accounts</div>
      <span class="badge badge-green">3 Verified Conductors</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>Conductor ID</th>
          <th>Name</th>
          <th>Login User ID</th>
          <th>Mobile</th>
          <th>License Number</th>
          <th>Assigned Bus</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        ${backendData.conductors.map(c => `
          <tr>
            <td><code>${c.id}</code></td>
            <td><b>${c.fullName}</b></td>
            <td><code>${c.userId}</code></td>
            <td>${c.phoneNumber}</td>
            <td>${c.licenseNumber}</td>
            <td><b>${c.assignedBusName}</b> (${c.assignedBusReg})</td>
            <td><span class="badge badge-green">${c.status}</span></td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>

  <!-- Tab 4: Tickets -->
  <div id="tab-tickets" class="section-card" style="display:none;">
    <div class="section-header">
      <div class="section-title">Issued Tickets & Fare Audit Trail</div>
      <span class="badge badge-blue">Real-time Spot Receipts</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>Ticket No</th>
          <th>Bus</th>
          <th>Route Stoppage</th>
          <th>Passenger</th>
          <th>Fare</th>
          <th>Category</th>
          <th>Payment Mode</th>
          <th>Issued Conductor</th>
        </tr>
      </thead>
      <tbody>
        ${backendData.sampleTickets.map(t => `
          <tr>
            <td><code>${t.ticketNumber}</code></td>
            <td><b>${t.busName}</b></td>
            <td>${t.route}</td>
            <td><b>${t.passengerName}</b> (${t.passengerId})</td>
            <td><span class="wallet-val">₹${t.fare.toFixed(2)}</span></td>
            <td><span class="badge ${t.category.includes('Student') ? 'badge-orange' : 'badge-green'}">${t.category}</span></td>
            <td><span class="badge badge-gray">${t.paymentMode}</span></td>
            <td>${t.conductor}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>

  <!-- Tab 5: Prisma Schema -->
  <div id="tab-schema" class="section-card" style="display:none;">
    <div class="section-header">
      <div class="section-title">Prisma Relational Database Architecture (PostgreSQL)</div>
      <span class="badge badge-gray">schema.prisma</span>
    </div>
    <p style="font-size: 13px; color: #4A5568; margin-bottom: 14px;">
      The backend is structured using <b>Prisma ORM</b> with PostgreSQL. Below are the 10 core relational tables and their model attributes:
    </p>
    <table>
      <thead>
        <tr>
          <th>Prisma Model</th>
          <th>Database Table</th>
          <th>Mapped Attributes & Foreign Keys</th>
        </tr>
      </thead>
      <tbody>
        ${backendData.prismaSchemaModels.map(m => `
          <tr>
            <td><b>${m.name}</b></td>
            <td><code>${m.table}</code></td>
            <td>${m.fields.map(f => `<span class="badge badge-gray" style="margin:2px;">${f}</span>`).join('')}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>

  <script>
    function showTab(tabName) {
      document.querySelectorAll('.section-card').forEach(c => c.style.display = 'none');
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.getElementById('tab-' + tabName).style.display = 'block';
      event.target.classList.add('active');
    }
  </script>
</body>
</html>`;

  res.setHeader('Content-Type', 'text/html');
  res.send(html);
});

export default router;
