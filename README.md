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

On the backend, an **Express** proxy routes API calls to a **Flask** ML service powered by a **SNLI/MNLI fine-tuned** Sentence-Transformers model (`all-MiniLM-L6-v2` in `finetuned_embedding/fine_tuned_model`) to compute content-based movie embeddings. Swipes are recorded in PostgreSQL, laying the groundwork for future collaborative enhancements.

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
  - **ML Service: Python Flask + **SNLI/MNLI fine-tuned** Sentence-Transformers all-MiniLM-L6-v2  
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

## 🧪 Testing with Recsend CLI

We use a developer-focused **Recsend CLI** to automate end-to-end testing of our content-based recommendation endpoint. RecSend lets you:

- **Define Tests in YAML:** Specify request details, headers, body, and expected status codes or response content in version-controlled YAML files.
- **Run Single or Multiple Suites:** Execute individual test files with `recsend send -f <file>` or batch tests via shell scripts.
- **Immediate Feedback:** See request URLs, HTTP status codes, response bodies, and simple diffs against expected values.
- **CI Integration:** Invoke RecSend in GitHub Actions (or other CI) to enforce API stability on every push/PR.

### Sample Test Files

#### `users.yaml`
```yaml
url: http://localhost:3000/users/importOrGetId
method: POST
headers:
  Content-Type: application/json
body:
  firebaseUid: "test-uid-123"
  displayName: "Test User"
expected:
  status_code: 200
  body_contains:
    userId: 14
```

#### `swipes.yaml`
```yaml
url: http://localhost:3000/swipes
method: POST
headers:
  Content-Type: application/json
body:
  userId: 14
  movieId: 1376434
  direction: "like"
expected:
  status_code: 200
  body_contains:
    success: true
```

#### `content_recs.yaml`
```yaml
url: http://localhost:3000/recommendations/content/14
method: GET
expected:
  status_code: 200
  body_contains:
    - id
    - overview
    - title
```

### Running Tests

```bash
cd recsend_tests
recsend send -f users.yaml
recsend send -f swipes.yaml
recsend send -f content_recs.yaml
```

Or create a `run-tests.sh` script:
```bash
#!/usr/bin/env bash
set -e
recsend send -f users.yaml
recsend send -f swipes.yaml
recsend send -f content_recs.yaml
echo "All tests passed!"
```

### Manual cURL Check

```bash
curl http://localhost:3000/recommendations/content/1 | jq .
```
