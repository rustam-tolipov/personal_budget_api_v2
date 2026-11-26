# Test Coverage Map

This document maps what is currently tested, what is missing, and known issues in the existing specs.
It exists so the gaps are visible and can be addressed deliberately — not discovered accidentally.

---

## Current State

Specs live in `spec/controllers/` but are written as request specs (`type: :request`).
The correct location for request specs in Rails is `spec/requests/`.
This is misleading — `spec/controllers/` conventionally holds controller unit tests, which test
the controller in isolation without routing or middleware. These are request specs and should be moved.

---

## What Is Tested

### Controllers

| File | Covered actions | Notes |
|---|---|---|
| `sessions_controller_spec` | Login (token + 200), missing password (401), logout | Logout context has no assertions — tests nothing |
| `registrations_controller_spec` | Signup success (200), duplicate email (422) | - |

### Models

| File | Covered | Notes |
|---|---|---|
| `invitation_spec` | Token on create, email presence, duplicate email in the same group, `expired?` at the exact expiration moment | - |

---

## What Is Not Tested

### Controllers with zero coverage

- `TransactionsController` - create, update, destroy, index, show, search, recent_transactions
- `UsersController` - me, show, show_by_username, search, update
- `PasswordsController` - forgot, reset

### Controller actions missing from partial coverage

**MembersController:**
- show
- update
- destroy

**CategoriesController:**
- show
- update
- destroy
- incomes
- expenses
- remove_from_member

### Models with zero coverage

- `Category` - no spec file
- `Transaction` - no spec file
- `TotalAmount` - no spec file

---

## Known Issues in Existing Specs

### Logout test has no assertions (`sessions_controller_spec`)

```ruby
context 'When logging out' do
  before do
    auth_token = login_with_api(user)
    delete logout_url, headers: { Authorization: auth_token }
  end
  # no it blocks
end
```

This context runs the request but asserts nothing. It is not a passing test — it is a silent gap.

### Specs in wrong directory

All spec files are under `spec/controllers/` but declared with `type: :request`.
They should live in `spec/requests/api/v1/` to follow Rails conventions and make
the intent clear to anyone reading the project.

---

## Priority Order for Writing New Tests

When you are ready to write tests, work in this order:

1. Write `Transaction` model spec (validates presence, `after_destroy` callback)
2. Write `TransactionsController` request spec (create with rollback scenario, update, destroy)
3. Move existing specs from `spec/controllers/` to `spec/requests/`
4. Fill in missing controller actions (members destroy, categories remove_from_member)
5. Write `TotalAmount` and `Category` model specs
6. Add assertions to the logout test
