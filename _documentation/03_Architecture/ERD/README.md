# Entity Relationship Diagrams (ERD)

## Purpose
This directory contains data models and schema documentation for all custom and standard objects used in the project.

## ERD Guidelines
1. **Show Relationships:** Master-Detail, Lookup, External Lookup
2. **Indicate Cardinality:** One-to-One, One-to-Many, Many-to-Many
3. **Key Fields:** Highlight required fields, unique fields, and external IDs
4. **Roll-Up Summary Fields:** Show on Master-Detail relationships

## Tools
- Schema Builder (Salesforce native)
- Lucidchart
- dbdiagram.io
- Draw.io

## File Naming Convention
- `ObjectName_Schema.png`
- `FeatureName_ERD.png`
- `Full_Data_Model.png`

---

## Schema Documentation Template

### Object: [Object API Name]

**Label:** [Object Label]  
**Type:** Custom / Standard / External  
**Sharing Model (OWD):** Private / Public Read Only / Public Read/Write

#### Key Fields

| Field API Name | Label | Type | Required | Unique | Description |
|----------------|-------|------|----------|--------|-------------|
| Name | Name | Text(80) | Yes | No | Default name field |
| CustomField__c | Custom Field | Picklist | No | No | Description of field |

#### Relationships

| Relationship Name | Type | Related Object | Cascade Delete | Roll-Up Available |
|-------------------|------|----------------|----------------|-------------------|
| Account__c | Master-Detail | Account | Yes | Yes |
| Contact__c | Lookup | Contact | No | No |

#### Validation Rules
- **Rule Name:** Description of validation logic

#### Triggers
- **Trigger Name:** Purpose and operations (before insert, after update, etc.)

#### Security Considerations
- **Field-Level Security:** List any restricted fields
- **Record Access:** Sharing rules, ownership-based sharing
- **Apex Sharing Reasons:** If using programmatic sharing

---

## Data Model Best Practices

### Master-Detail vs. Lookup
- **Master-Detail:** Use when child records should not exist without parent (cascade delete)
- **Lookup:** Use for loosely coupled relationships, allows orphaned records

### Relationship Limits
- Maximum 2 Master-Detail relationships per object
- Maximum 40 relationships per object
- Avoid circular dependencies

### External Objects
Document integration points with external systems via External Objects and External IDs.

---

## Schema Change Log

| Date | Object/Field | Change Type | Description | Author |
|------|--------------|-------------|-------------|--------|
| | | Create/Modify/Delete | | |

---
*This document follows The Colt Protocol - Stage 4: Data Modeling & ERD*
