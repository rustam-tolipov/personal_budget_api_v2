abort('Refusing to seed production — seeds are destructive') if Rails.env.production?

puts '🌱 Seeding...'

ActiveRecord::Base.transaction do
  Transaction.delete_all
  Budget.delete_all
  Invitation.delete_all
  FamilyGroupMembership.delete_all
  Account.update_all(active_family_group_id: nil)
  FamilyGroup.delete_all
  Account.delete_all
end

PASSWORD = 'password123'.freeze

bob = Account.create!(
  username: 'bob',
  email: 'bob@example.com',
  first_name: 'Bob',
  last_name: 'Tolipov',
  password: PASSWORD,
  password_confirmation: PASSWORD
)

alice = Account.create!(
  username: 'alice',
  email: 'alice@example.com',
  first_name: 'Alice',
  last_name: 'Tolipova',
  password: PASSWORD,
  password_confirmation: PASSWORD
)

# Carol has an account but no membership yet — she is the target of the
# pending invitation used to exercise the Layer 3 invitation flow.
carol = Account.create!(
  username: 'carol',
  email: 'carol@example.com',
  first_name: 'Carol',
  last_name: 'Smith',
  password: PASSWORD,
  password_confirmation: PASSWORD
)

family = FamilyGroup.create!(name: 'Tolipov Family', owner: bob)
FamilyGroupMembership.create!(family_group: family, account: bob, role: :admin)
FamilyGroupMembership.create!(family_group: family, account: alice, role: :member)
bob.update!(active_family_group: family)
alice.update!(active_family_group: family)

Invitation.create!(
  family_group: family,
  inviter: bob,
  invitation_email: carol.email
)

today = Date.current

family_budgets = [
  Budget.create!(name: 'Groceries', budget_type: :expense, limit: 800,
                 start_date: today.beginning_of_month, end_date: today.end_of_month,
                 family_group: family),
  Budget.create!(name: 'Household', budget_type: :family, limit: 1200,
                 start_date: today.beginning_of_month, end_date: today.end_of_month,
                 family_group: family),
  Budget.create!(name: 'Vacation Fund', budget_type: :savings, limit: 5000,
                 family_group: family)
]

personal_budgets = [
  Budget.create!(name: 'Bob Pocket Money', budget_type: :personal, limit: 300,
                 start_date: today.beginning_of_month, end_date: today.end_of_month,
                 account: bob),
  Budget.create!(name: 'Alice Hobbies', budget_type: :personal, limit: 250,
                 start_date: today.beginning_of_month, end_date: today.end_of_month,
                 account: alice)
]

members = [bob, alice]

ActiveRecord::Base.transaction do
  500.times do
    account = members.sample

    # ~1 in 10 transactions is uncategorized (budget is optional);
    # otherwise pick a family budget or the member's own personal budget,
    # respecting the account_matches_budget_owner validation.
    budget =
      if rand(10).zero?
        nil
      else
        (family_budgets + personal_budgets.select { |b| b.account_id == account.id }).sample
      end

    created_at = Faker::Time.between(from: 90.days.ago, to: Time.current)

    Transaction.create!(
      name: Faker::Commerce.product_name,
      amount: Faker::Commerce.price(range: 1.0..500.0),
      transaction_type: rand(4).zero? ? :credit : :debit,
      account: account,
      budget: budget,
      created_at: created_at,
      updated_at: created_at
    )
  end
end

puts "🌱 Done: #{Account.count} accounts, #{FamilyGroup.count} family group, " \
     "#{FamilyGroupMembership.count} memberships, #{Invitation.count} pending invitation, " \
     "#{Budget.count} budgets, #{Transaction.count} transactions"
