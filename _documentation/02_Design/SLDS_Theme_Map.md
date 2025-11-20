````markdown
# SLDS Theme Map

## Purpose
This document tracks all custom styling hooks and Lightning Design System (SLDS) components used in the project to ensure consistency and maintainability.

## Design Principles
- **SLDS First:** Always use Lightning Base Components and SLDS Blueprints
- **No Hard-Coded Styles:** Use styling hooks (CSS custom properties) for theming
- **Accessibility:** Ensure WCAG 2.1 AA compliance
- **Future-Proof:** Avoid overriding SLDS classes directly

---

## Color Palette
<!-- Document any custom CSS properties/tokens used -->

| CSS Variable | Value | Usage |
|--------------|-------|-------|
| `--lwc-brandPrimary` | #0176d3 | Primary brand color |
| `--lwc-brandSecondary` | #032d60 | Secondary brand color |
| `--lwc-colorTextDefault` | #181818 | Default text color |

## Typography
<!-- Document font families and text styles -->

| Element | SLDS Class | Custom Override |
|---------|------------|-----------------|
| Heading 1 | `slds-text-heading_large` | None |
| Heading 2 | `slds-text-heading_medium` | None |
| Body Text | `slds-text-body_regular` | None |

## Lightning Components Used

### Base Components
<!-- List all lightning-base-* components used -->

| Component | Purpose | Pages/LWC Using It |
|-----------|---------|-------------------|
| `lightning-card` | Container for content sections | Dashboard, Record Pages |
| `lightning-datatable` | Display tabular data | List Views |
| `lightning-button` | Actions and navigation | All pages |
| `lightning-input` | Form fields | Edit Forms |
| `lightning-combobox` | Dropdown selections | Filters |

### Custom LWC Components
<!-- List all custom Lightning Web Components -->

| Component Name | Description | SLDS Patterns Used |
|----------------|-------------|-------------------|
| `customComponentName` | Brief description | Builder, Cards, Modals |

## SLDS Blueprints Reference
<!-- Link to specific SLDS patterns used -->

- [Data Entry Patterns](https://www.lightningdesignsystem.com/guidelines/forms/)
- [Navigation Patterns](https://www.lightningdesignsystem.com/components/navigation/)
- [Data Display Patterns](https://www.lightningdesignsystem.com/components/data-tables/)

## Custom Styling Hooks
<!-- Document any CSS custom properties created for LWC components -->

```css
/* Example custom properties in LWC component CSS */
:host {
  --custom-spacing: 1rem;
  --custom-border-radius: 0.25rem;
}
```

## Responsive Design Breakpoints
<!-- Document responsive behavior using SLDS utilities -->

| Breakpoint | SLDS Class | Usage |
|------------|------------|-------|
| Small | `slds-small-size_*` | Mobile devices |
| Medium | `slds-medium-size_*` | Tablets |
| Large | `slds-large-size_*` | Desktop |

## Icons
<!-- Track SLDS icons used -->

| Icon Name | Category | Usage Context |
|-----------|----------|---------------|
| `utility:add` | Utility | Add record actions |
| `standard:account` | Standard | Account object |

---

## Design System Updates
Track when SLDS version updates are applied and any migration notes.

| Date | SLDS Version | Changes | Migration Notes |
|------|--------------|---------|-----------------|
| | | | |

---
*This document follows The Colt Protocol - Stage 2: User-Centric Design*

````