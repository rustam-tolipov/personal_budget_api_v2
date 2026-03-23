<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<br />
<div align="center">
  <a href="https://github.com/Rustamxon7/personal_budget_api_v2">
    <img src="images/beedget.svg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Personal Budget Planner API</h3>

  <p align="center">
    A Rails 7 JSON API for collaborative family budget tracking.
    <br />
    <a href="https://github.com/Rustamxon7/personal_budget_api_v2/issues">Report Bug</a>
    ·
    <a href="https://github.com/Rustamxon7/personal_budget_api_v2/issues">Request Feature</a>
  </p>
</div>

---

## About

A Rails 7 API-only backend for tracking personal and family finances. Users can create budget members (family participants), assign income/expense categories to them, and log transactions. Each write updates a cached `total_amounts` table to avoid recomputing balances on every read.

**Frontend repo:** [personal_budget_ui_v2](https://github.com/Rustamxon7/personal_budget_ui_v2)

---

## Tech Stack

- **Ruby** 3.3.6 / **Rails** 7.0
- **PostgreSQL**
- **Devise** + **devise-jwt** - JWT authentication (token in `Authorization: Bearer` header, 48h expiry)
- **CarrierWave** + **Cloudinary** - avatar uploads
- **Active Model Serializers** - JSON response shaping
- **RSpec** - request and model specs
- **Rswag** - Swagger API docs at `/`
- **Fly.io** - deployment

---

## Getting Started

### Prerequisites

- Ruby 3.3.6
- PostgreSQL running locally

### Installation

1. Clone the repo

   ```sh
   git clone https://github.com/Rustamxon7/personal_budget_api_v2.git
   cd personal_budget_api_v2
   ```

2. Install dependencies

   ```sh
   bundle install
   ```

3. Set up environment variables

   ```sh
   cp .env.example .env
   ```

   Fill in your PostgreSQL credentials, Cloudinary keys, and a `SECRET_KEY_BASE` (generate one with `rails secret`).

4. Set up the database

   ```sh
   rails db:reset
   ```

5. Start the server

   ```sh
   rails s
   ```

---

## Authentication

Authentication uses Devise with JWT tokens.

- **Sign up:** `POST /api/v1/auth/signup`
- **Log in:** `POST /api/v1/auth/login` - returns a JWT token in the response
- **Log out:** `DELETE /api/v1/auth/logout`

Pass the token on all subsequent requests:

```
Authorization: Bearer <token>
```

Tokens expire after 48 hours. There is currently no token denylist - logging out does not invalidate the token server-side. See [Known Limitations](#known-limitations).

---

## Data Model

```
User
 └── Members (budget participants)
      └── Categories (income or expense)
           └── Transactions
                └── TotalAmounts (cached balance per category + member)
```

- A `User` auto-creates a default `Member` on registration
- `Categories` are shared across members via a join table
- Each `Transaction` write updates the corresponding `TotalAmount` record inside a database transaction block

---

## Running Tests

```sh
bundle exec rspec
```

---

## Known Limitations

These are documented gaps - not bugs to work around, but areas planned for future improvement:

- **No authorization layer** - any authenticated user can read or modify any other user's data. Ownership checks are not enforced beyond `authenticate_user!`.
- **No JWT token denylist** - logging out does not revoke the token server-side. A stolen token remains valid until expiry.
- **CarrierWave** - planned replacement with ActiveStorage.
- **Active Model Serializers** - planned replacement with jsonapi-serializer.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Contact

Rustam Tolipov - rustamtolipov.dev@gmail.com

Project Link: [https://github.com/Rustamxon7/personal_budget_api_v2](https://github.com/Rustamxon7/personal_budget_api_v2)

---

<!-- MARKDOWN LINKS -->
[contributors-shield]: https://img.shields.io/github/contributors/Rustamxon7/personal_budget_api_v2.svg?style=for-the-badge
[contributors-url]: https://github.com/Rustamxon7/personal_budget_api_v2/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Rustamxon7/personal_budget_api_v2.svg?style=for-the-badge
[forks-url]: https://github.com/Rustamxon7/personal_budget_api_v2/network/members
[stars-shield]: https://img.shields.io/github/stars/Rustamxon7/personal_budget_api_v2.svg?style=for-the-badge
[stars-url]: https://github.com/Rustamxon7/personal_budget_api_v2/stargazers
[issues-shield]: https://img.shields.io/github/issues/Rustamxon7/personal_budget_api_v2.svg?style=for-the-badge
[issues-url]: https://github.com/Rustamxon7/personal_budget_api_v2/issues
[license-shield]: https://img.shields.io/github/license/Rustamxon7/personal_budget_api_v2.svg?style=for-the-badge
[license-url]: https://github.com/Rustamxon7/personal_budget_api_v2/blob/master/LICENSE
