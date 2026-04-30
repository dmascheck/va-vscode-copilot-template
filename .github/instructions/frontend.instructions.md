---
applyTo: "**/*.tsx, **/*.ts, **/*.jsx, **/web/**, **/frontend/**, **/src/components/**, **/src/pages/**"
---

# Frontend Standards

## TypeScript (Always over JavaScript)

```typescript
// Strict mode required — tsconfig.json: "strict": true
interface VeteranSummary {
  id: string;
  name: string;
  dob: string;
  activeProblems: Problem[];
}

// Always type props explicitly
interface VeteranCardProps {
  veteran: VeteranSummary;
  onSelect: (id: string) => void;
  isLoading?: boolean;
}
```

## React Patterns

- Functional components + hooks only (no class components)
- `useCallback` for stable event handlers
- Always include `aria-label` and `data-testid` on interactive elements

## Logging (MANDATORY)

```typescript
import { logger } from '@/utils/logger';

// Use logger instead of console
logger.info('Component mounted', { component: 'VeteranCard' });
logger.error('API call failed', { endpoint: '/api/veterans', error: err.message });
```

- **NEVER** use `console.log()`, `console.warn()`, `console.error()`

## Error Handling

Always handle async errors — never let promises float unhandled.

## Accessibility

- All interactive elements need `aria-label`
- Follow Section 508 compliance (VA requirement)
- Test with screen readers
- Color contrast must meet WCAG 2.1 AA
