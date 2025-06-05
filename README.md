<!--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━-->
<p align="center">
  <!-- If you have a logo or app icon, place it in `/docs/assets` and point to it here -->
  <img src="docs/assets/icon.png" alt="MovieMatchApp Logo" width="120"/>
  <h1 align="center">MovieMatchApp</h1>
  <p align="center">
    Swipe-style movie recommendations on iOS—powered by hybrid AI models and a clean SwiftUI interface.
  </p>
  <p align="center">
    <!-- Optional badges: replace URLs/paths as appropriate -->
    <a href="https://github.com/jaineelmodi11/MovieMatchApp/actions">
      <img src="https://img.shields.io/github/actions/workflow/status/jaineelmodi11/MovieMatchApp/ci.yml?branch=main" alt="Build Status"/>
    </a>
    <a href="https://github.com/jaineelmodi11/MovieMatchApp/releases/latest">
      <img src="https://img.shields.io/github/v/release/jaineelmodi11/MovieMatchApp" alt="Latest Release"/>
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg" alt="MIT License"/>
    </a>
  </p>
</p>
<!--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━-->

<div align="center">
  <strong>Download on the App Store:</strong>  
  <!-- If you have an App Store link, put it here -->
  <a href="https://apps.apple.com/app/idXXXXXXXXX"><img src="docs/assets/appstore-badge.svg" alt="App Store"/></a>  
  &nbsp;&nbsp;&nbsp;
  <strong>Source Code:</strong>  
  <a href="https://github.com/jaineelmodi11/MovieMatchApp"><code>github.com/jaineelmodi11/MovieMatchApp</code></a>
</div>

---

## 🚀 Table of Contents

1. [About](#about)  
2. [Key Features](#key-features)  
3. [Tech Stack](#tech-stack)  
4. [Architecture & Flow](#architecture--flow)  
5. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Installation & Setup](#installation--setup)  
   - [Building & Running](#building--running)  
6. [Usage](#usage)  
   - [Navigating the App](#navigating-the-app)  
   - [Movie Swipe Flow](#movie-swipe-flow)  
7. [Configuration & Environment Variables](#configuration--environment-variables)  
8. [Testing with Recsend CLI](#testing-with-recsend-cli)  
9. [Screenshots](#screenshots)  
10. [Continuous Integration (CI)](#continuous-integration-ci)  
11. [Contributing](#contributing)  
12. [License](#license)  
13. [Acknowledgments & Credits](#acknowledgments--credits)  
14. [Contact](#contact)

---

## 📖 About

MovieMatchApp is an **iOS application** built in **Swift** (SwiftUI/UIKit) that allows users to swipe left/right on movie cards—much like a dating app—and receive **personalized, hybrid‐model** recommendations. Behind the scenes, we combine:

- **Content-based filtering** (sentence embeddings of movie overviews via a Sentence-Transformers model)  
- **Collaborative filtering** (implicit feedback matrix factorization)

All of this runs on a backend (Flask/Node/Django—or whatever your stack is). The iOS client calls RESTful endpoints to fetch “next swipe card,” record “liked/disliked” swipes, and retrieve top recommendations.

> **Why “MovieMatch”?**  
> 1. **Discoverability:** Streaming platforms overload you with choices. MovieMatchApp narrows it down to what you’ll actually enjoy.  
> 2. **Interactivity:** A familiar swipe UI makes exploring movies fun (and addictive!).  
> 3. **Hybrid AI Engine:** By combining sentence embeddings and collaborative signals, recommendations become both novel and relevant.

<br/>

---

## ⭐ Key Features

- **Swipe Interface**  
  - Quickly browse movies one by one; swipe right to “Like,” left to “Pass.”

- **Hybrid Recommendation Engine**  
  - **Content-Based:** Uses a fine‐tuned Sentence-Transformers model to calculate similarity between movie overviews.  
  - **Collaborative Filtering:** Leverages user‐movie interaction data (implicit feedback) to refine suggestions.

- **Firebase Authentication** (or your chosen Auth)  
  - Email/password sign-up & sign-in. Optionally, include Google/Facebook OAuth.

- **Movie Details & Trailers**  
  - Tap on a card to see synopsis, cast, ratings, and embedded trailer (YouTube).

- **Daily/Weekly Email Digest**  
  - (Optional) Get top 5 new recommendations in your inbox every morning.  

- **Offline Caching**  
  - Stores recently viewed posters and details to improve load times when network is slow.

- **Dark Mode Support**  
  - Fully responsive to iOS system appearance.

- **Unit & UI Tests**  
  - Xcode Test target covering core MVVM logic and critical UI flows.

- **Recsend CLI for End-to-End Testing**  
  - Instead of hand-crafting cURL calls, we use [Recsend-Developer-Focused-CLI](https://github.com/jaineelmodi11/recsend-developer-focused-CLI) to validate all backend endpoints (swipe events, recommendation fetch, user signup) from Swift code. See [“Testing with Recsend CLI”](#testing-with-recsend-cli) below.

---

## 🧰 Tech Stack

<p align="center">
  <!-- You can swap icons/badges if you prefer -->
  <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" alt="Swift 5.5"/>
  <img src="https://img.shields.io/badge/Xcode-14.0-blue.svg" alt="Xcode 14"/>
  <img src="https://img.shields.io/badge/SwiftUI-2.0-purple.svg" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/Combine-1.0-lightgrey.svg" alt="Combine"/>
  <img src="https://img.shields.io/badge/Alamofire-5.4.4-red.svg" alt="Alamofire"/>
  <img src="https://img.shields.io/badge/Realm-10.25-lightblue.svg" alt="Realm"/>
  <img src="https://img.shields.io/badge/Firebase-9.9.1-yellow.svg" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Node.js-18.0-green.svg" alt="Node.js (backend)"/>
  <img src="https://img.shields.io/badge/Flask-2.1-grey.svg" alt="Flask (backend)"/>
  <img src="https://img.shields.io/badge/PostgreSQL-14.4-blue.svg" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Redis-6.2-red.svg" alt="Redis (Celery broker)"/>
</p>

- **iOS Client**  
  - **Language:** Swift 5.5+  
  - **UI:** SwiftUI (with Combine) or UIKit MVVM pattern.  
  - **Networking:** Alamofire for REST calls.  
  - **Local Persistence:** Realm (or Core Data) to cache posters and data.  
  - **Auth:** Firebase Authentication (email/password).  
  - **Dependency Management:** Swift Package Manager (SPM) or CocoaPods.

- **Backend API**  
  - **Language:** Python (Flask) *or* Node.js (Express) *or* Django REST (choose whichever applies).  
  - **Database:** PostgreSQL for structured data (users, movies, swipes, recommendations).  
  - **Caching / Message Broker:** Redis + Celery for nightly retraining & email digests.  
  - **ML Libraries:**  
    - `sentence-transformers` (e.g., `all-MiniLM-L6-v2`) for content embeddings.  
    - `implicit` library for collaborative filtering.  
  - **Hosting/Deployment:** Heroku / AWS Elastic Beanstalk / Docker (your chosen platform).

- **Testing**  
  - **iOS Unit/UI Tests:** Xcode XCTest Framework (MovieMatchTests, MovieMatchUITests).  
  - **API Tests:** Recsend CLI (see below).  
  - **Continuous Integration:** GitHub Actions to run Xcode builds & tests upon each push.

---

## 🏗 Architecture & Flow

```text
 ┌──────────────────────────────────┐
 │       iOS Client                 │
 │  (SwiftUI + Combine)             │
 │                                  │
 │ ┌──────────┐   ┌───────────┐     │
 │ │  View   │──▶│ ViewModel  │     │
 │ └──────────┘   └───────────┘     │
 │      ▲                │          │
 │      │                │          │
 │      │      Alamofire │          │
 │      │   ┌────────────▼───────┐  │
 │      │   │  Networking Layer  │  │
 │      │   │(APIService + JSON) │  │
 │      │   └─────────┬──────────┘  │
 │      │             │             │
 │      │      JSON   │             │
 │      └─────────────▼───────────┘ │
 │            Flask / Express API   │
 └──────────────────────────────────┘
               ▲        ▲
               │        │
         ┌─────┘        └─────┐
         │                    │
 ┌────────────┐          ┌─────────────┐
 │ PostgreSQL │          │   Redis /   │
 │ (Persistent│          │  Celery for │
 │  Storage)  │          │  Tasks/Email│
 └────────────┘          └─────────────┘
      ▲
      │
 ┌───────────────┐
 │ ML Engine     │
 │  (sentence-   │
 │ transformers+ │
 │ implicit CF)  │
 └───────────────┘
```text


## 🔧 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Xcode 14.0+** (for building and running the iOS client)  
- **Swift 5.5+**  
- **CocoaPods** or **Swift Package Manager** (depending on how you manage dependencies)  
- **Python 3.9+** (if you’re running the backend locally with Flask)  
- **PostgreSQL 14+** (for local database)  
- **Redis 6+** (if you use Celery on the backend)  
- **Recsend CLI** (for API testing—see the “Testing with Recsend CLI” section below)

### Installation & Setup

#### Clone the MovieMatchApp Repo

```bash
git clone https://github.com/jaineelmodi11/MovieMatchApp.git
cd MovieMatchApp
```bash


