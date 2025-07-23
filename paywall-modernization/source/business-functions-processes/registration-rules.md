# Customer Registration Business Rules

## Email Validation Rules
1. Email must be unique across all customers
2. Email format: local@domain.tld
3. Maximum length: 50 characters
4. Case-insensitive for uniqueness check

## Password Requirements
1. Minimum 8 characters
2. Must contain at least one uppercase letter
3. Must contain at least one number
4. Must contain at least one special character
5. Cannot contain email address
6. Stored as SHA-256 hash with salt

## Subscription Plans
### Basic (BAS)
- Monthly: $9.99
- Annual: $99.99 (save $19.89)
- Features: Basic content access, email support
- Max users: 1

### Premium (PRE)
- Monthly: $19.99
- Annual: $199.99 (save $39.89)
- Features: All Basic + priority support, analytics, API
- Max users: 5

### Enterprise (ENT)
- Monthly: $49.99
- Annual: $499.99 (save $99.89)
- Features: All Premium + dedicated support, custom integration
- Max users: Unlimited

## Payment Processing
1. Credit Card: Real-time validation via CCVALID
2. PayPal: Deferred validation
3. Bank Transfer: Manual approval required
4. Failed payments: Retry 3 times over 7 days

## Activation Process
1. Generate 32-character activation key
2. Key expires after 7 days
3. Send via email immediately
4. One-time use only
