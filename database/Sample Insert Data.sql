-- Inserting Rows into Users and Accounts
CALL InsertUser('12345-1234567-2', 'Alice', 'Smith', '1990-01-01', 'alice.smith@example.com', '12345678902', 'Y');
CALL InsertUser('23456-2345678-2', 'Bob', 'Johnson', '1995-03-15', 'bob.johnson@example.com', '23456789012', 'N');
CALL InsertUser('34567-3456789-3', 'Charlie', 'Brown', '1988-07-20', 'charlie.brown@example.com', '34567819012', 'Y');
CALL InsertUser('45678-4567890-4', 'David', 'Lee', '1985-12-10', 'david.lee@example.com', '4567890123', 'N');
CALL InsertUser('56789-5678901-5', 'Emily', 'Davis', '1992-05-25', 'emily.davis@example.com', '5678901234', 'Y');
CALL InsertUser('67890-6789012-6', 'Frank', 'Martinez', '1998-09-05', 'frank.martinez@example.com', '6789012345', 'N');
CALL InsertUser('78901-7890123-7', 'Grace', 'Garcia', '1983-04-30', 'grace.garcia@example.com', '7890123456', 'Y');
CALL InsertUser('89012-8901234-8', 'Henry', 'Wilson', '1991-11-12', 'henry.wilson@example.com', '8901234567', 'N');
CALL InsertUser('90123-9012345-9', 'Isabella', 'Lopez', '1987-08-18', 'isabella.lopez@example.com', '9012345678', 'Y');
CALL InsertUser('01234-0123456-0', 'Jack', 'Thompson', '1994-02-28', 'jack.thompson@example.com', '0123456789', 'N');

-- Inserting Rows into Merchants

CALL InsertMerchant('Merchant One', 'merchant.one@example.com');
CALL InsertMerchant('Merchant Two', 'merchant.two@example.com');
CALL InsertMerchant('Merchant Three', 'merchant.three@example.com');
CALL InsertMerchant('Merchant Four', 'merchant.four@example.com');
CALL InsertMerchant('Merchant Five', 'merchant.five@example.com');
CALL InsertMerchant('Merchant Six', 'merchant.six@example.com');
CALL InsertMerchant('Merchant Seven', 'merchant.seven@example.com');
CALL InsertMerchant('Merchant Eight', 'merchant.eight@example.com');
CALL InsertMerchant('Merchant Nine', 'merchant.nine@example.com');
CALL InsertMerchant('Merchant Ten', 'merchant.ten@example.com');


-- Inserting Rows into Transactions
CALL InsertTransactionOnly(1, 2, 100.00, 1, 1);
CALL InsertTransactionOnly(2, 3, 150.50, 2, 1);
CALL InsertTransactionOnly(3, 4, 200.75, 3, 1);
CALL InsertTransactionOnly(4, 5, 250.00, 4, 1);
CALL InsertTransactionOnly(5, 6, 300.25, 1, 1);
CALL InsertTransactionOnly(6, 7, 350.50, 2, 1);
CALL InsertTransactionOnly(7, 8, 400.75, 3, 1);
CALL InsertTransactionOnly(8, 9, 450.00, 4, 1);
CALL InsertTransactionOnly(9, 10, 500.25, 1, 1);
CALL InsertTransactionOnly(10, 1, 550.50, 2, 1);


-- Getting Loans
CALL getLoan(1,2000,2,'MONTH');
CALL getLoan(2,2000,2,'MONTH');
CALL getLoan(3,2000,2,'MONTH');
CALL getLoan(4,2000,2,'MONTH');
CALL getLoan(5,2000,2,'MONTH');

-- Paying Loans
CALL payLoan(1);
CALL payLoan(2);
CALL payLoan(3);
CALL payLoan(4);
CALL payLoan(5);

