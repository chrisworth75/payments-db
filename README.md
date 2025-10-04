# Payments Database

PostgreSQL database for the ccpay-bubble payment system, containing schemas for payments, fees, remissions, and apportionments.

## Database Schema

The database includes the following tables:

- **payment_fee_link** - Links payments to fees and case references
- **fee** - Fee details including codes, amounts, and case numbers
- **payment** - Payment transactions with provider details and status
- **fee_pay_apportion** - Apportionment of payments to fees
- **remission** - Help with Fees (HWF) remission data
- **status_history** - Payment status change history
- **payment_audit_history** - Audit trail for payment operations

## Local Development

### Using Docker Compose

```bash
docker-compose up -d
```

### Manual Docker Setup

```bash
docker run -d \
  --name payments-db \
  --network payments-network \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=payments \
  -v $(pwd)/db-init:/docker-entrypoint-initdb.d:ro \
  -p 5446:5432 \
  postgres:15-alpine
```

### Connection Details

- **Host**: localhost
- **Port**: 5446
- **Database**: payments
- **Username**: postgres
- **Password**: postgres

## Jenkins CI/CD

The Jenkinsfile automates:

1. **Test Environment** - Creates test database on port 5445
2. **Schema Validation** - Validates SQL files
3. **Schema Testing** - Tests schema and sample data creation
4. **Deployment** - Deploys production database on port 5446

### Pipeline Stages

- Checkout code
- Setup test PostgreSQL container
- Validate SQL files exist
- Test schema creation
- Load sample data
- Deploy production database (main branch only)

## Integration with ccpay-bubble

The payments database is used by ccpay-bubble for:

- Payment processing and tracking
- Fee calculation and apportionment
- Remission (Help with Fees) management
- Payment status history
- Audit trail

Configure in ccpay-bubble:

```yaml
database:
  host: localhost
  port: 5446
  name: payments
  user: postgres
  password: postgres
```

## Sample Data

The database includes sample data for:
- 2 payment fee links (Divorce and Probate)
- 2 fees (£550 and £273)
- 2 successful payments
- Fee-payment apportionments
- Payment status history
- Audit records

## Database Ports

- **Test**: 5445 (used during Jenkins testing)
- **Production**: 5446 (deployed container)

## Network

- **Network Name**: payments-network
- **Purpose**: Allows ccpay-bubble and related services to communicate with the database
