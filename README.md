# SARJANA HR-TECH 🏢

A modern, full-stack Human Resource Management System built with React, TailwindCSS, and Supabase.

## ✨ Features

### 🔐 Authentication & Authorization
- **Role-based access control** (Employee, HR, Admin)
- **Secure authentication** with Supabase Auth
- **JWT token management** with automatic refresh
- **Protected routes** based on user roles

### 💼 Employee Dashboard
- ✅ **Task Management** - View assigned tasks with real-time updates
- 📊 **Attendance Tracking** - Monitor attendance and performance
- 💰 **Payroll Summary** - View salary breakdown and payment history
- 🎯 **Performance Metrics** - Track individual performance trends
- 💬 **Internal Messaging** - Communicate with HR team

### 🧑‍💼 HR Dashboard
- 👥 **Employee Management** - CRUD operations for employee records
- 📈 **Analytics Dashboard** - Performance and satisfaction analytics
- 💸 **Payroll Management** - Automated salary calculations
- 📋 **Leave Management** - Approve/reject leave requests
- 📢 **Announcements** - Send company-wide communications
- 📊 **Attendance Reports** - Track employee attendance patterns

### 👑 Admin Dashboard
- 🏗️ **System Overview** - Complete organizational metrics
- 🧰 **User Management** - Manage HR and Employee accounts
- 📊 **Analytics Suite** - Advanced reporting and insights
- 🎯 **Task Assignment** - Delegate tasks across teams
- 💹 **Financial Overview** - Payroll costs and budget tracking
- ⚙️ **System Health** - Monitor application performance

### 🎨 UI/UX Features
- 🌓 **Dark/Light Mode** - Toggle with system preference detection
- 💱 **Currency Toggle** - Switch between INR ₹ and USD $
- 🕐 **Live IST Clock** - Real-time Indian Standard Time display
- 🎭 **AOS Animations** - Smooth scroll animations throughout
- 📱 **Responsive Design** - Mobile-first approach with TailwindCSS
- ✨ **Professional Theme** - Modern gradient buttons and cards

## 🛠️ Tech Stack

- **Frontend**: React 18 + Vite
- **Styling**: TailwindCSS with custom theme
- **Backend**: Supabase (Database + Auth + Realtime)
- **Charts**: Recharts for analytics visualization  
- **Icons**: Lucide React
- **Animations**: AOS (Animate On Scroll)
- **Deployment**: Vercel (recommended)

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ 
- npm or yarn
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sarjana-hr-tech
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp .env.example .env
   ```
   
   Update `.env` with your Supabase credentials:
   ```env
   VITE_SUPABASE_URL=your_supabase_project_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 📊 Database Schema

### Core Tables

```sql
-- User profiles with roles
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT CHECK (role IN ('employee', 'hr', 'admin')) DEFAULT 'employee',
    department TEXT,
    position TEXT,
    salary DECIMAL,
    hire_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Task management
CREATE TABLE tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES profiles(id),
    assigned_by UUID REFERENCES profiles(id),
    status TEXT DEFAULT 'pending',
    priority TEXT DEFAULT 'medium',
    due_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Payroll records
CREATE TABLE payroll (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES profiles(id),
    base_salary DECIMAL NOT NULL,
    bonus DECIMAL DEFAULT 0,
    deductions DECIMAL DEFAULT 0,
    total_salary DECIMAL GENERATED ALWAYS AS (base_salary + bonus - deductions) STORED,
    pay_period TEXT,
    paid_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Attendance tracking
CREATE TABLE attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    employee_id UUID REFERENCES profiles(id),
    date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    status TEXT DEFAULT 'present',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Internal messaging
CREATE TABLE messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES profiles(id),
    recipient_id UUID REFERENCES profiles(id),
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 🎭 Demo Credentials

| Role     | Email                 | Password    |
|----------|-----------------------|-------------|
| Employee | employee@sarjana.com  | password123 |
| HR       | hr@sarjana.com        | password123 |
| Admin    | admin@sarjana.com     | password123 |

## 🏗️ Project Structure

```
sarjana-hr-tech/
├── src/
│   ├── components/
│   │   ├── auth/           # Authentication components
│   │   ├── common/         # Reusable UI components
│   │   └── dashboard/      # Role-specific dashboard components
│   ├── context/            # React Context providers
│   ├── hooks/              # Custom React hooks
│   ├── lib/               # Supabase configuration
│   ├── pages/             # Page components
│   ├── utils/             # Helper functions
│   └── assets/            # Static assets
├── public/                # Public assets
└── docs/                  # Documentation
```

## 🎨 Customization

### Theme Colors
Update `tailwind.config.js` to customize the color scheme:

```javascript
colors: {
  light: {
    bg: '#F9FAFB',      // Light background
    primary: '#2563EB',  // Primary blue
    accent: '#16A34A',   // Success green
    text: '#1E293B',     // Text color
    card: '#FFFFFF',     // Card background
  },
  dark: {
    bg: '#0F172A',       // Dark background
    primary: '#3B82F6',  // Lighter blue
    accent: '#10B981',   // Lighter green
    text: '#E2E8F0',     // Light text
    card: '#1E293B',     // Dark card background
  }
}
```

### AOS Animations
Customize animations in `src/main.jsx`:

```javascript
AOS.init({
  duration: 800,        // Animation duration
  easing: 'ease-in-out', // Animation easing
  once: true,           // Animate only once
  offset: 50,           // Offset from viewport
});
```

## 🚀 Deployment

### Vercel (Recommended)

1. **Connect your repository to Vercel**
2. **Add environment variables** in Vercel dashboard
3. **Deploy automatically** on git push

### Other Platforms

- **Netlify**: Drag & drop `dist` folder after `npm run build`
- **Firebase Hosting**: Use Firebase CLI
- **GitHub Pages**: Enable in repository settings

## 📋 Available Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, please open an issue in the GitHub repository or contact the development team.

## 🙏 Acknowledgments

- **Supabase** for the incredible backend-as-a-service platform
- **TailwindCSS** for the utility-first CSS framework
- **Lucide** for the beautiful icon library
- **Recharts** for the responsive chart library

---

**Built with ❤️ for modern HR management**