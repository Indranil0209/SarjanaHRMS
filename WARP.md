# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Core Development
- `npm run dev` - Start development server on port 3000 (auto-opens browser)
- `npm run build` - Build for production (outputs to `dist/`)
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint on all JS/JSX files with strict warnings (--max-warnings 0)

### Testing
- No test framework is currently configured in this project

## Architecture Overview

### Technology Stack
- **Frontend**: React 18 + Vite (ESM modules)
- **Styling**: TailwindCSS with custom dark/light theme system
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Charts**: Recharts for analytics visualization
- **Icons**: Lucide React
- **Animations**: AOS (Animate On Scroll)

### Authentication & Authorization
This is a role-based HR management system with three distinct user roles:
- **Employee** - Basic dashboard with tasks, attendance, and payroll
- **HR** - Employee management, leave approvals, payroll management
- **Admin** - System overview, user management, analytics

### Core Architecture Patterns

#### Context-Based State Management
- `AuthContext` - Handles user authentication, profile management, and role-based permissions
- `ThemeContext` - Manages dark/light mode and currency (INR/USD) preferences
- Both contexts use localStorage for persistence

#### Database Schema (Supabase)
Key tables defined in `src/lib/supabase.js`:
- `profiles` - User roles and employee information
- `tasks` - Task assignment and tracking
- `payroll` - Salary and payment records
- `attendance` - Employee attendance tracking
- `messages` - Internal messaging system
- `announcements` - Company communications
- `leave_requests` - Leave management

#### Route Protection
- Protected routes require authentication (`ProtectedRoute` component)
- Public routes redirect authenticated users to dashboard
- Role-based dashboard rendering in `Dashboard.jsx`

#### Real-time Features
- Task updates via Supabase realtime subscriptions
- Message notifications
- Automatic UI updates for data changes

### Component Structure
```
src/components/
├── auth/           # Login/signup components
├── common/         # Reusable UI components (Header, LoadingScreen, etc.)
└── dashboard/      # Role-specific dashboard components
```

### Environment Configuration
Required environment variables in `.env`:
```
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_APP_NAME=SARJANA HR-TECH
VITE_APP_VERSION=1.0.0
```

### Custom Styling System
- Custom TailwindCSS configuration with light/dark mode colors
- Theme-aware classes: `light-bg`, `dark-bg`, `light-primary`, etc.
- Custom animations and box shadows for both themes
- Responsive design with mobile-first approach

### Database Helpers
Centralized database operations in `src/lib/supabase.js`:
- Role-based data fetching
- Real-time subscription management
- Standardized error handling

## Demo Credentials
| Role     | Email                | Password    |
|----------|----------------------|-------------|
| Employee | employee@sarjana.com | password123 |
| HR       | hef8q@dollicons.com  | password123 |
| Admin    | admin@sarjana.com    | password123 |

## Important Notes
- Project uses ESM modules (`"type": "module"` in package.json)
- AOS animations are initialized globally in `main.jsx` with specific settings
- All components use `data-aos` attributes for scroll animations
- Currency conversion uses hardcoded rate (83 INR = 1 USD) for demo purposes
- Dark mode preference is detected from system and stored in localStorage
- Role-based access control is handled both in frontend routing and backend queries