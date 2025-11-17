# 🚀 Quick Start Guide - IFTC Fullstack Application

This guide will help you set up the complete Salesforce Intergalactic Freight & Trade Corp application with backend API and frontend.

## 📋 Prerequisites

- Node.js 18+ and npm
- Salesforce CLI (`sf` command)
- Git
- A Salesforce Developer Org

## 🎯 Quick Setup (5 Steps)

### Step 1: Salesforce Org Authorization

The org is already authorized! Verify with:
```powershell
sf org list
```

You should see `IntergalacticFreight` as your target org.

### Step 2: Review Retrieved Metadata

All custom metadata has been retrieved from your Salesforce org:

**Custom Objects (4):**
- `Agent__c` - Freight agent management
- `Cargo__c` - Cargo/shipment items  
- `Customs_Document__c` - Customs documentation
- `Shipment__c` - Shipment tracking

**Apex Classes (6):**
- CargoAssignmentController
- CustomsClearanceValidator
- InterplanetaryFuelCalculator
- OperationsManagerController
- ShipmentController
- ShipmentSummaryController

**Apex Triggers (2):**
- AutoGenerateCustomsDocument
- PreventActiveShipmentDeletion

**Lightning Web Components (7):**
- freightAgentDashboard, managerQuickActions, operationsManagerDashboard
- quickActions, realtimeTracking, recentShipments, teamShipments

### Step 3: Clear Org (Optional - For Clean Start)

⚠️ **WARNING:** This will delete ALL custom metadata from your org!

```powershell
.\clear-org.ps1
```

This script will:
1. Prompt for confirmation
2. Delete all custom objects, Apex classes, triggers, and LWC components
3. Leave your org clean for rebuilding from scratch

### Step 4: Setup Backend API

```powershell
# Navigate to backend folder
cd backend

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your Salesforce credentials
# You need: SF_USERNAME, SF_PASSWORD, SF_SECURITY_TOKEN

# Start development server
npm run dev
```

Backend will run on `http://localhost:3000`

**Available API Endpoints:**
- `GET /health` - Health check
- `GET /api/shipments` - Get all shipments
- `GET /api/shipments/:id` - Get shipment by ID
- `GET /api/shipments/status/active` - Get active shipments
- `POST /api/shipments` - Create shipment
- `PUT /api/shipments/:id` - Update shipment
- `DELETE /api/shipments/:id` - Delete shipment

### Step 5: Setup Frontend

```powershell
# Open new terminal
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend will run on `http://localhost:3001`

## 🏗️ Architecture Overview

```
┌─────────────────┐
│   React App     │  ← User Interface (Port 3001)
│  (Frontend)     │
└────────┬────────┘
         │ HTTP/REST
         ↓
┌─────────────────┐
│   Express API   │  ← Business Logic (Port 3000)
│   (Backend)     │
└────────┬────────┘
         │ jsforce/REST
         ↓
┌─────────────────┐
│   Salesforce    │  ← Data Layer
│      Org        │
└─────────────────┘
```

## 📊 What's Included

### Salesforce Layer (`force-app/`)
✅ Complete data model with custom objects  
✅ Business logic with Apex classes  
✅ Automation with triggers  
✅ UI components with LWC  
✅ Security with permission sets  

### Backend Layer (`backend/`)
✅ Express.js server  
✅ jsforce Salesforce integration  
✅ RESTful API endpoints  
✅ Authentication ready  
✅ CORS configured  

### Frontend Layer (`frontend/`)
✅ React 18 with Vite  
✅ Material-UI components  
✅ React Router navigation  
✅ React Query for data fetching  
✅ Responsive dashboard layout  

## 🔧 Development Workflow

### Deploy Salesforce Changes
```powershell
# Deploy all metadata to org
sf project deploy start --source-dir force-app

# Deploy specific component
sf project deploy start --source-dir force-app/main/default/classes
```

### Retrieve Salesforce Changes
```powershell
# Retrieve all metadata
sf project retrieve start --manifest manifest/package.xml

# Retrieve specific types
sf project retrieve start --metadata ApexClass,LightningComponentBundle
```

### Backend Development
```powershell
cd backend
npm run dev  # Auto-restart on file changes
```

### Frontend Development
```powershell
cd frontend
npm run dev  # Hot reload enabled
```

## 🔐 Salesforce Credentials Setup

### Option 1: Username-Password Flow (Development)
Edit `backend/.env`:
```env
SF_LOGIN_URL=https://login.salesforce.com
SF_USERNAME=your-email@example.com
SF_PASSWORD=your-password
SF_SECURITY_TOKEN=your-security-token
```

To get your security token:
1. Go to Salesforce Setup
2. Search "Reset My Security Token"
3. Click "Reset Security Token"
4. Check your email

### Option 2: OAuth 2.0 (Production)
1. Create Connected App in Salesforce
2. Get Consumer Key and Secret
3. Update `.env` with OAuth credentials

## 🧪 Testing

### Test Backend API
```powershell
# Test health endpoint
Invoke-WebRequest -Uri http://localhost:3000/health

# Test shipments endpoint
Invoke-WebRequest -Uri http://localhost:3000/api/shipments
```

### Test Salesforce Connection
```powershell
sf org open
```

## 📁 Project Structure

```
salesforce-intergalactic-freight-app/
├── force-app/              # Salesforce metadata
├── backend/               # Node.js API
│   ├── src/
│   │   ├── routes/       # API routes
│   │   ├── services/     # Business logic
│   │   └── server.js     # Express server
│   └── package.json
├── frontend/             # React app
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── pages/       # Page components
│   │   └── services/    # API client
│   └── package.json
├── manifest/            # Deployment manifests
├── clear-org.ps1       # Org cleanup script
└── README.md
```

## 🐛 Troubleshooting

### Backend won't start
- Check `.env` file exists and has correct credentials
- Verify Salesforce credentials are valid
- Check port 3000 is not in use

### Frontend won't start
- Check port 3001 is not in use
- Run `npm install` again
- Clear cache: `rm -rf node_modules; npm install`

### Salesforce CLI issues
- Update CLI: `sf update`
- Re-authenticate: `sf org login web`
- Check org status: `sf org list`

### API connection errors
- Verify backend is running
- Check CORS settings
- Verify API URL in frontend `.env`

## 📚 Next Steps

1. **Customize Data Model**: Add custom fields to objects
2. **Build API Endpoints**: Implement cargo, agents, customs APIs
3. **Create UI Components**: Build detailed pages for each module
4. **Add Authentication**: Implement JWT authentication
5. **Add Real-time Features**: WebSocket for live tracking
6. **Deploy to Production**: Set up CI/CD pipeline

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and test
3. Commit: `git commit -m "Add your feature"`
4. Push: `git push origin feature/your-feature`
5. Create Pull Request

## 📞 Support

- Check documentation in `/docs`
- Review Salesforce metadata in `/force-app`
- Test API endpoints at `/api/*`
- View frontend at `http://localhost:3001`

## ✅ Checklist

- [x] Salesforce org authorized
- [x] Metadata retrieved from org
- [x] Backend structure created
- [x] Frontend structure created
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] .env configured
- [ ] Backend running
- [ ] Frontend running
- [ ] Full stack tested

---

🚀 **You're all set! Happy coding!**
