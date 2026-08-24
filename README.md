Mobile Application

The BookVerse Mobile Application provides a complete user experience for discovering, purchasing, reading, and listening to digital content.

Mobile Features

- User registration and login
- Email verification
- Personalized reading interests
- Book and audiobook discovery
- Search and filtering
- Book details
- Favorites
- Shopping cart
- Checkout
- Payment submission
- Purchase tracking
- Personal library
- PDF reading
- Audiobook listening
- User profile

---

Mobile App Screenshots

Home & Discovery

<p align="center">
  <img src="https://github.com/user-attachments/assets/c5b0e9c1-33c2-47e9-abe0-a77c826f4fa4" width="180" alt="BookVerse Mobile Home" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/ca06c3ef-7663-4437-b14c-3a46f89829eb" width="180" alt="BookVerse Mobile Discovery" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/7494938e-bfee-4987-9165-7108e39dcd96" width="180" alt="BookVerse Mobile Browse" />
</p><p align="center">
  <img src="https://github.com/user-attachments/assets/59273251-f7c6-441e-a935-7e61501f43a0" width="180" alt="BookVerse Mobile Screen" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/d061ee18-6655-4e9e-b88c-f1286be1fa07" width="180" alt="BookVerse Mobile Screen" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/9f04c6bc-82ba-4e39-b067-285b29011e78" width="180" alt="BookVerse Mobile Screen" />
</p><p align="center">
  <img src="https://github.com/user-attachments/assets/7b5b56bd-5f9a-4b0d-a3d6-744b87458ed8" width="180" alt="BookVerse Mobile Screen" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/0e4bd4dd-eaf4-4f33-9f04-4e59d396a3a7" width="180" alt="BookVerse Mobile Screen" />
  &nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/d5eea274-1f8c-4251-9301-229a6a61bd34" width="180" alt="BookVerse Mobile Screen" />
</p><p align="center">
  <img src="https://github.com/user-attachments/assets/dc69d7cc-8c1d-409e-bb68-3589e949e9d2" width="180" alt="BookVerse Mobile Screen" />
</p>---

Admin Panel

The BookVerse Admin Panel provides centralized control over the platform's users, digital content, orders, payments, and system configuration.

Admin Features

- Dashboard statistics
- User management
- Book management
- Audiobook management
- Article management
- Research paper management
- Category management
- Order management
- Payment verification
- Payment method management
- File and cover management
- Platform settings

---

Admin Panel Screenshots

Dashboard & Management

<table>
  <tr>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/ff7ad390-b63a-4a6e-838a-794f1989901e" width="100%" alt="BookVerse Admin Dashboard" />
    </td>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/222828d3-c41e-45f8-9702-7191c795a29a" width="100%" alt="BookVerse Admin Management" />
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/0a18e07d-6512-481c-87b8-c6244a531763" width="100%" alt="BookVerse Admin Panel" />
    </td>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/07371d77-a577-4ea9-ac76-28493b6dc759" width="100%" alt="BookVerse Admin Panel" />
    </td>
  </tr>
</table>---

Payment Workflow

Customer Checkout
       │
       ▼
Payment Submitted
       │
       ▼
Pending Admin Review
       │
       ├──────────────┐
       ▼              ▼
    Approved       Rejected
       │
       ▼
Library Access

---

System Architecture

┌─────────────────────┐
│   BookVerse Mobile  │
│       Flutter       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│      Supabase       │
│                     │
│  Authentication     │
│  PostgreSQL         │
│  Storage            │
│  Security / RLS     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   BookVerse Admin   │
│   React / Next.js   │
└─────────────────────┘

Platform Structure

- Mobile App → Customer Experience
- Admin Panel → Platform Management
- Supabase → Shared Backend Infrastructure

The mobile application and web administration dashboard are presented as separate interfaces while operating as integrated components of the same BookVerse ecosystem.
