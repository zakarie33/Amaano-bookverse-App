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
  <img src="screenshots/mobile/home.png" width="200" alt="Home">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/details.jpg" width="200" alt="Book Details">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/cart.jpg" width="200" alt="Shopping Cart">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/purchases.jpg" width="200" alt="Purchases">
</p>

<p align="center">
  <img src="screenshots/mobile/interests.jpg" width="200" alt="Interests">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/verification-method.png" width="200" alt="Verification Method">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/email-verification.png" width="200" alt="Email Verification">
  &nbsp;&nbsp;
  <img src="screenshots/mobile/onboarding.jpg" width="200" alt="Onboarding">
</p>

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
