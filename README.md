
Mobile Application

The BookVerse mobile application provides the complete user experience for discovering, purchasing, reading, and listening to digital content.

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

Mobile App Screenshots

Home & Discovery

<h3 align="center">Mobile App Screenshots</h3>

<p align="center">
  <img width="200" alt="WhatsApp_Image_2026-08-24_at_7 52 38_AM__3_-removebg-preview" src="https://github.com/user-attachments/assets/c5b0e9c1-33c2-47e9-abe0-a77c826f4fa4" />

  &nbsp;&nbsp;
  <img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 39_AM__2_-removebg-preview" src="https://github.com/user-attachments/assets/ca06c3ef-7663-4437-b14c-3a46f89829eb" />

  <img width="200" alt="WhatsApp_Image_2026-08-24_at_7 52 39_AM__1_-removebg-preview" src="https://github.com/user-attachments/assets/7494938e-bfee-4987-9165-7108e39dcd96" />

  <img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 38_AM__3_-removebg-preview" src="https://github.com/user-attachments/assets/59273251-f7c6-441e-a935-7e61501f43a0" />
  &nbsp;&nbsp;
<img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 38_AM__2_-removebg-preview" src="https://github.com/user-attachments/assets/d061ee18-6655-4e9e-b88c-f1286be1fa07" />

  &nbsp;&nbsp;


<p align="center">
  <img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 41_AM-removebg-preview" src="https://github.com/user-attachments/assets/9f04c6bc-82ba-4e39-b067-285b29011e78" />
  &nbsp;&nbsp;
 <img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 40_AM-removebg-preview" src="https://github.com/user-attachments/assets/7b5b56bd-5f9a-4b0d-a3d6-744b87458ed8" />

  &nbsp;&nbsp;
  <img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 40_AM-removebg-preview" src="https://github.com/user-attachments/assets/0e4bd4dd-eaf4-4f33-9f04-4e59d396a3a7" />

  &nbsp;&nbsp;
<img width="200"  alt="WhatsApp_Image_2026-08-24_at_7 52 39_AM__1_-removebg-preview" src="https://github.com/user-attachments/assets/d5eea274-1f8c-4251-9301-229a6a61bd34" />
  &nbsp;&nbsp;
<img width="447" height="559" alt="WhatsApp_Image_2026-08-24_at_7 52 38_AM-removebg-preview" src="https://github.com/user-attachments/assets/dc69d7cc-8c1d-409e-bb68-3589e949e9d2" />

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

Admin Panel Screenshots

Dashboard

<img width="1280" height="960" alt="image" src="https://github.com/user-attachments/assets/ff7ad390-b63a-4a6e-838a-794f1989901e" />

<img width="1280" height="960" alt="image" src="https://github.com/user-attachments/assets/222828d3-c41e-45f8-9702-7191c795a29a" />


<img width="1346" height="591" alt="image" src="https://github.com/user-attachments/assets/0a18e07d-6512-481c-87b8-c6244a531763" />


<img width="1344" height="617" alt="image" src="https://github.com/user-attachments/assets/07371d77-a577-4ea9-ac76-28493b6dc759" />

Screenshot Structure


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
│  BookVerse Admin    │
│  React / Next.js    │
└─────────────────────┘

Mobile App → Customer Experience

Admin Panel → Platform Management

Supabase → Shared Backend Infrastructure

This keeps the mobile application showcase separate from the web admin dashboard showcase, while still presenting both as parts of the same BookVerse system.
