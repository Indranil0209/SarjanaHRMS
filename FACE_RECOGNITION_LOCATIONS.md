# 🔍 Face Recognition - Quick Location Reference

## 📁 File Structure

```
SarjanaHRMS-main/
├── src/
│   ├── components/
│   │   └── attendance/
│   │       ├── AttendanceCheckIn.jsx          ← 📷 Face Capture UI
│   │       ├── AttendanceCheckIn.css
│   │       ├── FaceEnrollment.jsx             ← 👤 Face Enrollment
│   │       ├── MobileCheckIn.jsx              ← 📱 Mobile Face Capture
│   │       └── face-verify.js                 (if exists)
│   │
│   ├── api/
│   │   ├── attendanceCheckIn.js               ← 🔐 Face Verification API
│   │   ├── locationTracking.js                ← 📍 GPS Tracking
│   │   └── officeLocations.js                 ← 🏢 Office Setup
│   │
│   ├── services/
│   │   ├── permissionService.ts               ← 🔒 Access Control
│   │   └── authService.ts
│   │
│   ├── context/
│   │   └── AttendanceContext.jsx              ← 📊 State Management
│   │
│   └── pages/
│       ├── services/
│       │   └── Attendance.tsx                 ← 📋 Attendance Service Page
│       │
│       └── dashboard/
│           ├── OfficeLocationsSettings.jsx    ← ⚙️ HR Setup
│           └── EmployeeKYC.jsx                ← 📝 Employee Setup
│
├── migrations/
│   ├── 006_multi_tenant_geofencing.sql        ← 🗄️ Database Schema
│   │   (Contains: face_enrollments, attendance_logs tables)
│   │
│   └── 003_attendance_improvements_and_faces.sql
│
├── ai_service/                                 ← 🤖 Python AI Service
│   ├── main.py
│   ├── services/
│   │   └── face_verify.py                     ← 🧠 Face Recognition
│   └── requirements.txt
│
└── Documentation/
    ├── FACE_RECOGNITION_IMPLEMENTATION.md     ← 📖 This Guide
    ├── MULTI_TENANT_GEOFENCING_IMPLEMENTATION.md
    └── GEOFENCING_QUICK_START.md
```

---

## 🎯 Key Files & Their Roles

### Frontend (React)

**1. AttendanceCheckIn.jsx** - Main Component
```
Location: src/components/attendance/AttendanceCheckIn.jsx
Size: ~400 lines
Purpose: Employee check-in interface with face + GPS
Key Features:
  ✓ Camera capture
  ✓ Location detection
  ✓ Face image encoding
  ✓ Check-in/out logic
  ✓ Results display
```

**2. FaceEnrollment.jsx** - Enrollment Component
```
Location: src/components/attendance/FaceEnrollment.jsx
Purpose: Initial face registration for employees
Key Features:
  ✓ Photo capture
  ✓ Face quality check
  ✓ Enrollment submission
```

**3. MobileCheckIn.jsx** - Mobile Version
```
Location: src/components/attendance/MobileCheckIn.jsx
Purpose: Mobile app check-in with face
Key Features:
  ✓ Native camera integration
  ✓ Face detection
  ✓ Check-in feedback
```

### Backend (APIs)

**1. attendanceCheckIn.js** - Check-In API
```
Location: src/api/attendanceCheckIn.js
Size: ~300 lines
Key Functions:
  
  verifyFaceImage(faceImageBase64, enrolledFaceData)
  └─ Verifies face against enrolled data
  └─ Returns: Promise<boolean>
  └─ TODO: Integrate AWS/Google/Azure API
  
  uploadFaceImage(faceImageBase64, userId, companyId)
  └─ Uploads image to Supabase Storage
  └─ Returns: Promise<string> (public URL)
  
  performCheckIn(checkInData)
  └─ Main workflow: GPS → Face → Verification → Log
  └─ Returns: Promise<{ success, faceVerificationPassed, ... }>
  
  performCheckOut(checkOutData)
  └─ Records employee departure
```

**2. locationTracking.js** - GPS Tracking
```
Location: src/api/locationTracking.js
Purpose: 30-second GPS logging for field employees
```

**3. officeLocations.js** - Office API
```
Location: src/api/officeLocations.js
Purpose: Office CRUD operations for geo-fence setup
```

### Database (SQL)

**1. 006_multi_tenant_geofencing.sql** - Migration
```
Location: migrations/006_multi_tenant_geofencing.sql
Tables Created:
  
  ├── face_enrollments
  │   ├── id (UUID)
  │   ├── user_id (references users)
  │   ├── company_id (multi-tenant)
  │   ├── face_image_url (Supabase Storage path)
  │   ├── face_embedding (512D vector)
  │   ├── is_active (boolean)
  │   └── created_at, updated_at (timestamps)
  │
  ├── attendance_logs (extended)
  │   ├── ... (existing fields)
  │   ├── verification_method ('FACE_AND_GEO', 'GEO_ONLY')
  │   ├── face_verification_passed (boolean)
  │   ├── geo_verification_passed (boolean)
  │   ├── face_image_url (reference to captured photo)
  │   └── distance_from_office_meters (number)
  │
  ├── office_locations
  │   ├── id, company_id, office_name
  │   ├── latitude, longitude
  │   ├── allowed_radius_meters
  │   └── shift_start_time
  │
  └── location_tracking_logs
      ├── user_id, company_id
      ├── latitude, longitude, accuracy
      └── timestamp
```

### AI Service (Python)

**1. face_verify.py** - Face Recognition Engine
```
Location: ai_service/services/face_verify.py
Size: ~60 lines
Key Functions:
  
  enroll_employee_face(employee_id: str, image: UploadFile)
  └─ Extracts face embedding from image
  └─ Stores embedding for later comparison
  
  verify_employee_face(employee_id: str, image: UploadFile)
  └─ Extracts embedding from captured face
  └─ Compares with enrolled embedding
  └─ Returns: (verified: bool, similarity: float)

Current Implementation: Mock (ready for real API)
Production Ready: InsightFace (commented code available)
```

**2. main.py** - FastAPI Server
```
Location: ai_service/main.py
Purpose: Expose face verification as REST API endpoints
Routes:
  POST /api/face/enroll
  POST /api/face/verify
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ EMPLOYEE CHECK-IN FLOW WITH FACE RECOGNITION                   │
└─────────────────────────────────────────────────────────────────┘

1. FRONTEND (AttendanceCheckIn.jsx)
   ├─ requestCameraPermission()
   │  └─ navigator.mediaDevices.getUserMedia()
   │
   ├─ captureFace()
   │  ├─ canvas.drawImage(video)
   │  └─ canvasRef.toDataURL('image/jpeg') → Base64
   │
   └─ getLocation()
      └─ navigator.geolocation.getCurrentPosition() → {lat, lng}

2. API CALL (AttendanceCheckIn.jsx → attendanceCheckIn.js)
   └─ performCheckIn({
      userId, companyId, userLat, userLng, faceImageBase64
    })

3. BACKEND PROCESSING (attendanceCheckIn.js)
   ├─ Validate Coordinates ✓
   │
   ├─ Fetch Office Locations
   │  └─ supabase.from('office_locations')...
   │
   ├─ Check Geo-Fence
   │  ├─ isWithinOfficeRadius() for each office
   │  └─ If outside: Return OUTSIDE_GEOFENCE error ✗
   │
   ├─ FACE VERIFICATION (if faceImageBase64 provided)
   │  ├─ Fetch Enrolled Face
   │  │  └─ supabase.from('face_enrollments')...
   │  │
   │  ├─ verifyFaceImage(faceImageBase64, enrolledFaceData)
   │  │  └─ TODO: Call AWS/Google/Azure API
   │  │     OR Python AI service
   │  │  └─ Returns: isMatch (boolean)
   │  │
   │  └─ If !isMatch: Return FACE_VERIFICATION_FAILED ✗
   │
   ├─ Upload Face Photo (for logging)
   │  ├─ uploadFaceImage(faceImageBase64, userId, companyId)
   │  ├─ Convert base64 → Blob
   │  ├─ supabase.storage.upload('face-verification/...')
   │  └─ Get Public URL
   │
   ├─ Calculate Shift Status
   │  └─ checkShiftStatus() → PRESENT | LATE
   │
   └─ Insert Attendance Log
      └─ supabase.from('attendance_logs').insert({
         user_id, company_id, office_id,
         verification_method: 'FACE_AND_GEO',
         face_verification_passed: true,
         geo_verification_passed: true,
         face_image_url: 's3://...',
         status: 'PRESENT'
      })

4. RESPONSE (attendanceCheckIn.js → Frontend)
   ├─ success: true
   ├─ faceVerificationPassed: true
   ├─ attendanceLog: { ... }
   └─ verification_method: 'FACE_AND_GEO'

5. FRONTEND DISPLAY (AttendanceCheckIn.jsx)
   ├─ Show check-in success ✓
   ├─ Display office location
   ├─ Display face verification status: ✓ PASSED
   ├─ Display GPS accuracy
   └─ Start location tracking (30s intervals)
      └─ logLocation() every 30 seconds

6. DATABASE STATE
   ├─ attendance_logs: New entry with face verification
   ├─ location_tracking_logs: Started recording GPS
   └─ face_enrollments: Reference updated last_verified_at
```

---

## 📍 Quick Navigation

### I want to...

**...implement face verification API**
- File: `src/api/attendanceCheckIn.js` (line 20-42)
- Function: `verifyFaceImage()`
- Current: Placeholder
- TODO: Add AWS/Google/Azure integration

**...customize face capture UI**
- File: `src/components/attendance/AttendanceCheckIn.jsx`
- Section: "Face Capture Section" (line 266+)
- Modify: Camera container, preview, buttons

**...check face verification logs**
- Database: `attendance_logs` table
- Columns: `verification_method`, `face_verification_passed`, `face_image_url`
- Query:
  ```sql
  SELECT user_id, verification_method, face_verification_passed, created_at
  FROM attendance_logs
  WHERE face_verification_passed IS NOT NULL
  ORDER BY created_at DESC;
  ```

**...see stored face enrollments**
- Database: `face_enrollments` table
- Columns: `user_id`, `company_id`, `face_image_url`, `face_embedding`
- Query:
  ```sql
  SELECT user_id, company_id, face_image_url, is_active
  FROM face_enrollments
  WHERE company_id = 'your-company-id';
  ```

**...test face recognition**
- Run: `npm run dev` (starts dev server)
- Visit: `http://localhost:8000/dashboard`
- Click: "Attendance Check-In" or "Check-In" button
- Action: Allow camera → Capture face → Click check-in
- See: Face verification results in console

**...deploy AI service**
- Location: `ai_service/` directory
- Start: `python ai_service/main.py`
- Endpoint: `http://localhost:8000` (or deployed URL)
- Integrate: Update `verifyFaceImage()` to call this service

**...add face quality validation**
- Location: `src/components/attendance/AttendanceCheckIn.jsx`
- Add after capture: Face detection, blur check, lighting check
- Library: Use `face-api.js` or TensorFlow.js

**...enable SSL for camera (production)**
- HTTPS required for camera access
- Use: Let's Encrypt for free certificates
- Or: Configure reverse proxy with SSL

---

## 🔗 Component Connections

```
AttendanceCheckIn.jsx
├─ imports attendanceCheckIn.js (API)
├─ imports useAuth (Context)
├─ imports AttendanceContext (State)
└─ calls performCheckIn() with:
   ├─ verifyFaceImage() - Face Recognition
   ├─ uploadFaceImage() - Storage
   ├─ logLocation() - GPS Tracking
   └─ checkShiftStatus() - Util Function
   
↓

attendanceCheckIn.js
├─ calls supabase.from('face_enrollments')
├─ calls supabase.from('office_locations')
├─ calls supabase.from('attendance_logs')
├─ calls supabase.storage.upload() - Face Images
└─ calls verifyFaceImage() → TODO: AI Service

↓

Database (Supabase)
├─ face_enrollments table
├─ attendance_logs table
├─ office_locations table
├─ location_tracking_logs table
└─ users table
```

---

## ✅ Checklist for Implementation

- [ ] Database migration executed (006_multi_tenant_geofencing.sql)
- [ ] Face capture component rendering correctly
- [ ] Camera permission prompts working
- [ ] GPS location detection working
- [ ] Face images encoding to base64
- [ ] Face images uploading to Supabase Storage
- [ ] Enrollment data stored in face_enrollments table
- [ ] Attendance logs showing face verification data
- [ ] AI service running (for production)
- [ ] Choose face API provider (AWS/Google/Azure)
- [ ] Integrate real face verification API
- [ ] Test with multiple employees
- [ ] Adjust similarity threshold if needed
- [ ] Deploy to production
- [ ] Monitor false rejection rate

---

**Last Updated:** 2026-08-07 20:30 UTC
**Status:** ✅ Implementation Complete (Awaiting API Integration)
