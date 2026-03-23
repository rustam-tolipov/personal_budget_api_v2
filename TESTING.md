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
| `members_controller_spec` | GET /members (200), POST /members (201) | - |
| `categories_controller_spec` | POST /categories single member, POST /categories multiple members | - |

### Models

| File | Covered | Notes |
|---|---|---|
| `user_spec` | Presence validations, uniqueness, min lengths | Tests `first_name`, `last_name` presence and 8-char password minimum — these validations do not exist on the User model. Tests will fail. |
| `member_spec` | Nothing | File exists with `pending` only |

### Mailers

| File | Covered | Notes |
|---|---|---|
| `user_mailer_spec` | Nothing | File exists with `pending` only |

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

### Tests asserting non-existent validations (`user_spec`)

`user_spec.rb` tests the following behaviors that the `User` model does not enforce:

```ruby
it 'is not valid without a first name'   # no validates :first_name presence on User
it 'is not valid without a last name'    # no validates :last_name presence on User
it 'is not valid if password is less than 8 characters'  # Devise config sets minimum to 6
```

These tests will fail when run. Either the validations need to be added to the model,
or the tests need to be corrected to match actual behavior.

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

1. Fix the broken `user_spec` assertions (validations vs model mismatch)
2. Write `Transaction` model spec (validates presence, `after_destroy` callback)
3. Write `TransactionsController` request spec (create with rollback scenario, update, destroy)
4. Move existing specs from `spec/controllers/` to `spec/requests/`
5. Fill in missing controller actions (members destroy, categories remove_from_member)
6. Write `TotalAmount` and `Category` model specs
7. Add assertions to the logout test
