# Backend - Node.js API

Backend API for Salesforce integration using Express.js and jsforce.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your Salesforce credentials
```

3. Run development server:
```bash
npm run dev
```

## API Endpoints

### Shipments
- `GET /api/shipments` - Get all shipments
- `GET /api/shipments/:id` - Get shipment by ID
- `GET /api/shipments/status/active` - Get active shipments
- `POST /api/shipments` - Create new shipment
- `PUT /api/shipments/:id` - Update shipment
- `DELETE /api/shipments/:id` - Delete shipment

### Cargo
- `GET /api/cargo` - Get all cargo (To be implemented)

### Agents
- `GET /api/agents` - Get all agents (To be implemented)

### Customs
- `GET /api/customs` - Get customs documents (To be implemented)

## Project Structure

```
backend/
├── src/
│   ├── routes/          # API route definitions
│   ├── services/        # Business logic & Salesforce integration
│   ├── controllers/     # Request handlers (to be added)
│   ├── middleware/      # Custom middleware (to be added)
│   └── server.js        # Express server setup
├── .env.example         # Environment variables template
└── package.json         # Dependencies
```
