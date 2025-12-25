# SwiftPay

A comprehensive database management system for a fintech payment application, developed as a course project for Database Management Systems (DBMS).

## Overview

SwiftPay is a relational database system designed to handle core banking and payment operations. It manages user accounts, financial transactions, loan processing, merchant interactions, and customer support tickets. The system is built using MySQL and implements various stored procedures, functions, and triggers to ensure data integrity and automate business logic.

## Features

- **User Management**: Register users with personal details, CNIC, and optional debit card assignment
- **Account Management**: Create and manage bank accounts with balance tracking
- **Transaction Processing**: Support for deposits, withdrawals, fund transfers, and merchant payments
- **Loan System**: Apply for and manage loans with interest calculations and repayment tracking
- **Merchant Integration**: Handle merchant accounts and invoice generation
- **Support System**: Customer support ticket creation and management
- **Debit Card Management**: Automated card number generation and assignment
- **Payment Methods**: Support for in-app and card-based payments

## Database Schema

The system consists of the following main entities:

- **Users**: Personal information and contact details
- **Accounts**: Bank account details with balance management
- **Cards**: Debit card information
- **Transactions**: All financial transaction records
- **Loans**: Loan applications and active loan management
- **MerchantAccount**: Merchant registration and balance tracking
- **Invoices**: Payment invoices for merchant transactions
- **Support**: Customer support tickets

## Setup Instructions

1. **Prerequisites**

   - MySQL Server installed
   - Access to MySQL command line or a GUI client like phpMyAdmin

2. **Database Creation**

   - Run the SQL scripts in the following order:
     1. `database/Database and Table Creation.sql` - Creates the database and all tables
     2. `database/Functions.sql` - Creates necessary functions
     3. `database/Procedures.sql` - Creates stored procedures
     4. `database/Triggers.sql` - Creates database triggers
     5. `database/Sample Insert Data.sql` - Inserts sample data for testing

3. **Sample Usage**

   ```sql
   -- Create a new user
   CALL InsertUser('12345-6789012-3', 'John', 'Doe', '1990-01-01', 'john@example.com', '+1234567890', 'Y');

   -- Perform a deposit
   CALL InsertTransactionOnly(1, NULL, 1000.00, 1, 1);

   -- Apply for a loan
   CALL getLoan(1, 5000.00, 12, 'MONTH');
   ```

## Project Structure

```
SwiftPay/
├── database/
│   ├── Database and Table Creation.sql
│   ├── Functions.sql
│   ├── Procedures.sql
│   ├── Sample Insert Data.sql
│   └── Triggers.sql
├── ERD.png
└── README.md
```

## Key Procedures

- `InsertUser`: Register new users with optional card generation
- `InsertTransactionOnly`: Process various types of transactions
- `getLoan`: Handle loan applications with eligibility checks
- `payLoan`: Process loan repayments with interest calculations
- `GenerateTicket`: Create customer support tickets
- `closeTicket`: Close support tickets

## Triggers

The system includes triggers for:

- Automatic account number generation
- Transaction logging
- Balance validation

## Technologies Used

- MySQL 8.0+
- Stored Procedures and Functions
- Database Triggers
- Entity-Relationship Modeling

## Contributing

This is a course project for educational purposes. Feel free to explore and modify the database structure for learning DBMS concepts.
