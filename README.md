# Intergalactic Freight & Trade Corp: End-to-End Logistics App

This project is a complete Salesforce solution for Intergalactic Freight & Trade Corp., a company managing cargo shipments, customs, and agent communications. The application covers data modeling, automation, Apex, UI, AI, and deployment.

## 1. Objective

To build a fully functional Salesforce org that meets the complex operational needs of a freight and trade company, demonstrating mastery across the entire Salesforce platform.

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
