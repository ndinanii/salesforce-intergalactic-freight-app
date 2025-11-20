# Intergalactic Freight & Trade Corp: Fullstack Logistics Solution

A comprehensive freight management application built on Salesforce with a modern fullstack architecture. This project manages cargo shipments, customs documentation, and agent communications with complete data modeling, automation, Apex, UI components, AI integration, and deployment capabilities.

## 🚀 Project Overview

This is a complete Salesforce solution with backend API and frontend application for Intergalactic Freight & Trade Corp., demonstrating mastery across the entire Salesforce platform and modern web development.

## 📁 Project Structure

```
salesforce-intergalactic-freight-app/
├── force-app/                  # Salesforce metadata
│   └── main/default/
│       ├── objects/            # Custom Objects: Agent, Cargo, Customs_Document, Shipment
│       ├── classes/            # Apex Classes (6 controllers/validators)
│       ├── triggers/           # Apex Triggers (2 automation triggers)
│       ├── lwc/                # Lightning Web Components (7 components)
│       ├── applications/       # Custom Salesforce Apps
│       └── permissionsets/     # Permission Sets & Security
├── backend/                    # Node.js API (To be created)
├── frontend/                   # React Frontend (To be created)
├── manifest/                   # Deployment manifests
│   ├── package.xml
│   ├── destructiveChanges.xml
│   └── package-empty.xml
├── clear-org.ps1              # Script to clear org metadata
└── README.md
```

## 1. Objective

To build a fully functional Salesforce org integrated with modern fullstack technologies that meets the complex operational needs of a freight and trade company.

---

## 🎯 Engineering Philosophy: The Colt Protocol

This project follows **The Colt Protocol** methodology, a systematic 6-stage approach to Salesforce development:

### The 6-Stage Pipeline

1. **Requirements Elicitation** - Define goals, personas, and Definition of Done (DoD)
2. **User-Centric Design** - Strict adherence to Lightning Design System (SLDS)
3. **Business Process Mapping** - Synchronous vs. Asynchronous processing decisions
4. **Data Modeling & ERD** - Security-first schema design with OWD and sharing rules
5. **Defining Testable Criteria** - Test-Driven Development (TDD) with 85%+ coverage
6. **Clear Documentation** - ApexDoc standards and structured project artifacts

### 📂 Project Documentation

Comprehensive documentation following The Colt Protocol is available in the `_documentation/` folder:

```
_documentation/
├── 00_Project_Brief/          # Project Charter & Stakeholder Register
├── 01_Requirements/           # User Stories & Functional Specs
├── 02_Design/                 # UX Wireframes, UI Mockups, SLDS Theme Map
├── 03_Architecture/           # Process Flows, ERD, Security Matrix
├── 04_Testing/                # Test Plan, Data Factory Spec, UAT Scripts
└── 05_Manuals/                # Admin Guide & User Guide
```

### Salesforce Best Practices Applied

- **Security First**: with sharing keywords in Apex, SOQL injection prevention
- **Governor Limits**: Bulkified code, asynchronous processing for heavy operations
- **SLDS Compliance**: All LWC components follow Lightning Design System
- **Test Coverage**: 85%+ code coverage with meaningful assertions
- **Documentation**: ApexDoc comments and structured project documentation

---

## 2. Core Features & Implementation

### Section 1: Salesforce Fundamentals & Security
- Customized Lightning Experience for **Freight Agents** and **Operations Managers**.
- Applied security controls via **Profiles, Permission Sets, and Identity Basics**.
- Created 3 key reports (Shipment Volume, Average Delivery Time, Customs Success Rate) and 1 dashboard.

### Section 2: Data Modeling and Management
- Created a custom data model with `Shipment`, `Cargo`, and `Customs Document` objects.
- Implemented picklists and **Duplicate Rules** for data integrity.

### Section 3: Business Logic and Process Automation
- Authored **Validation Rules** (e.g., ETA after Departure Date).
- Built an **Approval Process** for shipment discounts.
- Developed a **Record-Triggered Flow** to assign shipments and send delay notifications.

### Section 4: App Creation & Deployment
- Built a dedicated **Lightning App** for Operations.
- Utilized both **Org Development** and **Package Development** models for deployment.

### Section 5: Apex Development & Logic
- Wrote **Apex Classes** to calculate interplanetary fuel costs and validate customs requirements.
- Implemented **Apex Triggers** to prevent deletion of active shipments and auto-generate customs documents.
- Used **Asynchronous Apex** to process bulk shipment data efficiently.

### Section 6: Custom User Interface
- Created a **Visualforce page** for shipment summaries.
- Built a **Lightning Web Component (LWC)** for a mock real-time shipment tracker.
- Developed an **Aura Component** for quick cargo assignment.

### Section 7: Testing, Debugging, and Deployment
- Wrote **Apex Test Classes** with over 75% code coverage.
- Deployed changes via **Salesforce CLI (SFDX)**.
- Used **Apex Replay Debugger** to diagnose and fix bugs.

### Section 8: Agentforce AI
- Configured AI to predict delivery delays and suggest optimal shipping routes.
- Built an **AI-powered chatbot** to answer customer shipment queries.
