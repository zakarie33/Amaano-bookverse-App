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

<img width="809" height="1080" alt="image" src="https://github.com/user-attachments/assets/22489316-7e9a-405e-85a2-1af094ec86fb" />


<img width="960" height="1280" alt="image" src="https://github.com/user-attachments/assets/79cf31ce-b18f-48ab-b0f0-d5df62ce6d29" />

<img width="809" height="1080" alt="image" src="https://github.com/user-attachments/assets/6fbe4a29-2c07-45ce-92f0-24955b2880ac" />
<img width="426" height="922" alt="image" src="https://github.com/user-attachments/assets/cd22caf3-7cf2-442f-831e-758d8b21a1dd" />


<img width="420" height="935" alt="image" src="https://github.com/user-attachments/assets/8bf17a57-c989-4ebc-90b1-c8e28b8d5944" />

<img width="809" height="1080" alt="image" src="https://github.com/user-attachments/assets/dd11c9e7-e969-46df-96d3-3cc632a55f6f" />

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
