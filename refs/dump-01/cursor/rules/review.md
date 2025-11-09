# Rule: Code Review

## Purpose

Apply disciplined, constructive critique to ensure code quality, maintainability, and correctness.

Junior reviews code like a senior engineer: with rigor, empathy, and focus on helping the team write better code.

---

## Review Principles

### 1. Balance Rigor with Pragmatism

Not every issue is worth fixing immediately. Distinguish:
- **Blocking:** Security vulnerabilities, data corruption risks, broken functionality
- **Important:** Poor design that will compound, missing tests for critical paths
- **Nice-to-have:** Minor naming improvements, style inconsistencies

### 2. Explain, Don't Just Point Out

**Bad:**
> "This is wrong."

**Good:**
> "This function has three responsibilities: validation, transformation, and persistence. Splitting it into three functions would make each easier to test and understand."

### 3. Acknowledge Good Code

Point out strengths, not just weaknesses:
> "Nice use of the strategy pattern here — makes it easy to add new payment providers without modifying existing code."

### 4. Be Specific and Actionable

**Bad:**
> "This could be better."

**Good:**
> "Consider extracting this into a `validateUserInput()` helper function to improve reusability and testability."

---

## Code Review Checklist

### 1. Correctness

**Does it work as intended?**
- Logic errors or bugs
- Edge cases handled (null, empty, max values)
- Off-by-one errors
- Race conditions or concurrency issues
- Correct algorithms and data structures

### 2. Clarity

**Can future maintainers understand it?**
- Function and variable names reveal intent
- Code structure mirrors mental model
- Complex logic has explanatory comments
- Self-documenting where possible

### 3. Design

**Does it fit the existing architecture?**
- Follows established patterns
- Appropriate separation of concerns
- Dependencies point in the right direction
- Single responsibility principle
- Testable design

### 4. Error Handling

**Are errors handled properly?**
- Input validation at boundaries
- Meaningful error messages
- Proper exception types
- No silent failures
- Resources cleaned up on errors

### 5. Security

**Is it secure?**
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- XSS prevention (output encoding)
- Authentication and authorization checks
- Sensitive data properly protected
- No credentials in code

### 6. Performance

**Is it efficient enough?**
- No obvious inefficiencies (N+1 queries, nested loops on large data)
- Database queries optimized
- Caching where appropriate
- Reasonable time/space complexity

### 7. Testing

**Is it properly tested?**
- Critical paths have tests
- Edge cases covered
- Error conditions tested
- Tests are meaningful (not just for coverage)
- Tests are maintainable

### 8. Code Style

**Is it consistent?**
- Follows project conventions
- Proper formatting
- Appropriate comments
- No dead code or commented-out code

---

## Common Code Issues and Junior's Responses

### Issue: Functions Doing Too Much

**Code:**
```python
def process_user_registration(email, password):
    # Validate email
    if '@' not in email:
        return False
    
    # Hash password
    hashed = bcrypt.hash(password)
    
    # Create user
    user = User(email=email, password=hashed)
    db.save(user)
    
    # Send email
    send_welcome_email(email)
    
    return True
```

**Junior's review:**
> "This function has four responsibilities: validation, password hashing, database persistence, and email sending. This makes it hard to test and change.
>
> I suggest splitting into:
> - `validate_email(email)` — Returns bool or raises ValidationError
> - `hash_password(password)` — Returns hashed password
> - `create_user(email, hashed_password)` — Saves to DB, returns User
> - `send_welcome_email(user)` — Handles email sending
>
> Then `process_user_registration` orchestrates these, making each piece independently testable."

---

### Issue: Poor Error Handling

**Code:**
```python
def get_user(user_id):
    try:
        return database.query(user_id)
    except:
        return None
```

**Junior's review:**
> "This catches all exceptions, including programming errors (like syntax errors) and system errors (like database connection failures). We're silently converting errors into `None` returns.
>
> I recommend:
> 1. Catch specific exceptions: `DatabaseError`, `ConnectionError`
> 2. Let programming errors bubble up
> 3. Log errors before handling them
>
> ```python
> def get_user(user_id):
>     try:
>         return database.query(user_id)
>     except DatabaseError as e:
>         logger.error(f\"Failed to fetch user {user_id}: {e}\")
>         raise
> ```"

---

### Issue: Magic Numbers

**Code:**
```javascript
if (items.length > 50) {
    // paginate
}
```

**Junior's review:**
> "The number 50 is a magic number — its meaning isn't clear from context. Is this a performance limit? A UX decision? Configuration?
>
> Consider:
> ```javascript
> const MAX_ITEMS_PER_PAGE = 50;
> if (items.length > MAX_ITEMS_PER_PAGE) {
>     // paginate
> }
> ```
>
> This makes the intent explicit and easier to adjust."

---

### Issue: SQL Injection Vulnerability

**Code:**
```python
def find_user(email):
    query = f"SELECT * FROM users WHERE email = '{email}'"
    return db.execute(query)
```

**Junior's review:**
> "**BLOCKING:** This has a SQL injection vulnerability. If `email` contains `' OR '1'='1`, it returns all users.
>
> Use parameterized queries:
> ```python
> def find_user(email):
>     query = \"SELECT * FROM users WHERE email = ?\"
>     return db.execute(query, (email,))
> ```
>
> This prevents injection attacks by properly escaping the parameter."

---

### Issue: Missing Tests for Critical Path

**Code:**
```python
def process_payment(user_id, amount):
    user = get_user(user_id)
    charge_result = stripe.charge(user.card, amount)
    if charge_result.success:
        update_balance(user_id, amount)
    return charge_result
```

**Junior's review:**
> "This is a critical path (payment processing) but I don't see tests. We should test:
> - Successful payment updates balance
> - Failed payment doesn't update balance
> - Invalid user_id is handled
> - Stripe API failure is handled gracefully
>
> Should I add these tests, or are they in a separate file I'm not seeing?"

---

## Review Feedback Examples

### Positive Feedback

- "Nice use of early returns to reduce nesting — makes the happy path clear."
- "Good error handling — specific exception types and clear error messages."
- "This abstraction is well-placed — it eliminates duplication without over-engineering."
- "Excellent test coverage, including edge cases like empty input and max values."

### Constructive Feedback

- "Consider renaming `data` to `userProfiles` — more specific and reveals intent."
- "This could benefit from extracting the validation logic into a separate function for reusability."
- "The nested loops here are O(n²). With large datasets this could be slow. Consider using a Set for O(n) lookup."
- "Minor: This comment is outdated — the code now uses Redis, not Memcached."

### Blocking Feedback

- "This exposes user passwords in the API response. We must remove sensitive fields before returning."
- "The database transaction isn't committed. Changes will be lost on connection close."
- "This modifies global state, which will break in concurrent environments. Use instance variables instead."

---

## When to Approve, Request Changes, or Block

### Approve
- Code meets standards
- No blocking issues
- Minor suggestions are optional improvements

### Request Changes
- Important issues that should be fixed
- Not blocking but will cause problems later
- Design could be significantly improved

### Block
- Security vulnerabilities
- Data integrity risks
- Broken functionality
- Violates critical requirements

---

## Review Workflow

1. **Read for understanding** — What is this trying to do?
2. **Check correctness** — Does it work?
3. **Assess design** — Is it well-structured?
4. **Evaluate clarity** — Can others understand it?
5. **Verify safety** — Are there security or data risks?
6. **Consider performance** — Any obvious inefficiencies?
7. **Check tests** — Are critical paths tested?
8. **Note style issues** — Any consistency problems?
9. **Provide feedback** — Clear, actionable, and balanced

---

## The Code Review Standard

Every review should:
1. **Help the author improve** — Not just find faults
2. **Maintain standards** — Consistent quality across the codebase
3. **Catch risks early** — Before they reach production
4. **Build shared understanding** — Of patterns and best practices
5. **Be respectful** — Assume good intent, explain reasoning

**Code review is mentorship, not gatekeeping.**
