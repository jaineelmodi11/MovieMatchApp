<div align="center">
  <img src="docs/assets/app_icon.png" width="180" alt="MovieMatch Icon"/>
</div>

# MovieMatchApp

Swipe-style movie recommendations on iOS—powered by content-based AI and a clean SwiftUI interface.

---

## 📸 App Video Demo




https://github.com/user-attachments/assets/cd57a3d8-373b-4e89-afb9-21fd22350006


---

## 📖 About

MovieMatchApp is an **iOS application** built in **Swift** with **SwiftUI + Combine**, following an **MVVM** architecture for a clean separation of views and logic. It offers:

- **Tinder-Style Swipe Interface:** Quickly browse movie cards—swipe right to like, left to pass.
- **Rich Movie Details:** Tap a card to view synopsis, cast, ratings, and an embedded YouTube trailer.
- **Smooth UX:** Preloads poster images for seamless scrolling, adds haptic feedback and SwiftUI animations for engaging interactions.
- **Local Caching:** Caches recently viewed posters to improve load times and support offline exploration.

On the backend, an **Express** proxy routes API calls to a **Flask** ML service powered by a fine-tuned Sentence-Transformers model (`all-MiniLM-L6-v2`) to compute content-based movie embeddings. Swipes are recorded in PostgreSQL, laying the groundwork for future collaborative enhancements.

> **Why “MovieMatch”?**
> 1. **Discoverability:** Cuts through choice overload to surface movies you’ll love.  
> 2. **Interactivity:** Gamified swiping makes discovery fun and addictive.  
> 3. **Content-Driven AI:** Leverages semantic embeddings to recommend contextually relevant titles.

---

## ⭐ Key Features

- **Swipe Interface**  
  Browse movies one by one: swipe right to “Like,” left to “Pass.”

- **Content-Based Recommendation Engine**  
  Embeds movie overviews via a Sentence‑Transformers model and finds similar titles.

- **Firebase Authentication**  
  Email/password sign‑up & sign‑in via Firebase Auth.

- **Recsend CLI for Testing**  
  Developer-focused CLI for validating endpoints with YAML-defined requests.

---

## 🧰 Tech Stack

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" alt="Swift 5.5"/>
  <img src="https://img.shields.io/badge/SwiftUI-2.0-purple.svg" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Combine-1.0-lightgrey.svg" alt="Combine"/>
  <img src="https://img.shields.io/badge/Firebase-9.x-blue.svg" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Node.js-18.0-green.svg" alt="Node.js"/>
  <img src="https://img.shields.io/badge/Express-4.x-lightgrey.svg" alt="Express"/>
  <img src="https://img.shields.io/badge/Flask-2.1-grey.svg" alt="Flask"/>
  <img src="https://img.shields.io/badge/PostgreSQL-14.4-blue.svg" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Sentence--Transformers-orange.svg" alt="sentence-transformers"/>
  <img src="https://img.shields.io/badge/axios-1.x-blue.svg" alt="axios"/>
</p>

- **iOS Client**  
  - **Language:** Swift 5.5  
  - **UI:** SwiftUI 2.0 + Combine  
  - **Networking:** URLSession / Foundation  
  - **Auth:** Firebase Email/Password

- **Backend API**  
  - **Express Proxy:** Node.js + Express + Axios to ML service  
  - **ML Service:** Python Flask + Sentence-Transformers `all-MiniLM-L6-v2`  
  - **Database:** PostgreSQL

---

## 🏗 Architecture & Flow

```text
 ┌──────────────────────────────────┐
 │       iOS Client                 │
 │  (SwiftUI + Combine)             │
 │ ┌──────────┐   ┌───────────┐     │
 │ │  View   │──▶│ ViewModel  │     │
 │ └──────────┘   └───────────┘     │
 │      ▲                │          │
 │      │      URLSession │          │
 │      │   ┌─────────────▼────────┐ │
 │      │   │  NetworkManager     │  │
 │      │   └─────────────┬────────┘ │
 │      │                 │          │
 │      └─────────────────▼────────┘ │
 │       Express Proxy (3000)        │
 └──────────────────────────────────┘
               ▲       │             
               │       │             
               │  Flask ML Service (5000)
               │                       
          PostgreSQL                   
```

---

## 🧪 Testing Content-Based Recommendations

1. **Start services**  
   - **Flask ML Service:**
     ```bash
     cd movie-backend
     source venv/bin/activate
     python service.py
     ```  
   - **Express Proxy:**
     ```bash
     cd movie-backend
     node server.js
     ```

2. **Run Recsend CLI:**
   ```bash
   cd recsend_tests
   recsend send -f users.yaml
   recsend send -f swipes.yaml
   recsend send -f content_recs.yaml
   ```

3. **Or via cURL:**
   ```bash
   curl http://localhost:3000/recommendations/content/1 | jq .
   ```

*README updated to reflect content-based only.*
