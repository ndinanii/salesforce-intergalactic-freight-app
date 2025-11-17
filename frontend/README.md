# Frontend - React Application

Modern React frontend with Material-UI for the Intergalactic Freight & Trade Corp application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
# Create .env file
VITE_API_URL=http://localhost:3000/api
```

3. Run development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3001`

## Features

- **Dashboard**: Overview of shipments, cargo, and agents
- **Shipments**: Manage and track shipments
- **Cargo**: Cargo inventory management
- **Agents**: Freight agent management
- **Customs**: Customs document handling

## Tech Stack

- React 18
- Vite (build tool)
- Material-UI (UI components)
- React Router (navigation)
- React Query (data fetching)
- Axios (HTTP client)

## Project Structure

```
frontend/
├── public/              # Static assets
├── src/
│   ├── components/      # Reusable components
│   │   └── Layout.jsx   # Main layout with navigation
│   ├── pages/          # Page components
│   │   ├── Dashboard.jsx
│   │   ├── Shipments.jsx
│   │   ├── Cargo.jsx
│   │   ├── Agents.jsx
│   │   └── Customs.jsx
│   ├── services/       # API services
│   │   └── api.js      # API client configuration
│   ├── App.jsx         # Main app component
│   └── main.jsx        # Entry point
├── index.html          # HTML template
└── vite.config.js      # Vite configuration
```
