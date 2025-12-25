CREATE DATABASE IF NOT EXISTS SpeedyPay;

USE SpeedyPay;

CREATE TABLE IF NOT EXISTS Card(
	card_number VARCHAR(19) PRIMARY KEY,
    expiry_month INT,
    expiry_year INT,
    cvc INT,
    status VARCHAR(10) DEFAULT 'Active',
    created_at DATETIME DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Users(
	user_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    cnic VARCHAR(15) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    email VARCHAR(50) UNIQUE,
    phone_number VARCHAR(50) NOT NULL UNIQUE,
    debit_card_number VARCHAR(19) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (debit_card_number) references Card(card_number)
);

    
CREATE TABLE IF NOT EXISTS Accounts(
	account_number VARCHAR(16) PRIMARY KEY,
    user_id INT,
    balance DECIMAL(15,2) DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) references Users(user_id)
);

CREATE TABLE IF NOT EXISTS Transaction_Type (
    transaction_type_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_name VARCHAR(50) NOT NULL
);

INSERT INTO Transaction_Type (transaction_name) 
VALUES ('Deposit'), ('Withdrawal'), ('Transfer'), ('Payment');

CREATE TABLE IF NOT EXISTS Payment_Method (
    payment_method_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_method_name VARCHAR(50) NOT NULL
);

INSERT INTO Payment_Method (payment_method_name) 
VALUES ('In App'), ('Card'); 

CREATE TABLE IF NOT EXISTS Transactions(
	transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(16),
    transfer_to_account_number VARCHAR(16) DEFAULT NULL,
    payment_method INT DEFAULT NULL,
    transaction_amount DECIMAL(15,2),
    transaction_type INT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY (account_number) references Accounts(account_number),
    FOREIGN KEY (transaction_type) references Transaction_Type(transaction_type_id),
    FOREIGN KEY (payment_method) references Payment_Method(payment_method_id)
);

CREATE TABLE IF NOT EXISTS MerchantAccount(
	merchant_id VARCHAR(16) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.0,
    created_at DATETIME DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS Invoices(
	invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(16),
    merchant_id VARCHAR(16),
    transaction_type INT,
    payment_method INT,
    amount INT,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (account_number) references Accounts(account_number),
    FOREIGN KEY (merchant_id) references MerchantAccount(merchant_id),
    FOREIGN KEY(transaction_type) references Transaction_Type(transaction_type_id),
    FOREIGN KEY (payment_method) references Payment_Method(payment_method_id)
);


CREATE TABLE IF NOT EXISTS Support(
	ticket_number INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    comments VARCHAR(1000) NOT NULL,
    status VARCHAR(10) DEFAULT 'Open',
    FOREIGN KEY (user_id) references Users(user_id)
);

CREATE TABLE IF NOT EXISTS Loans(
	loan_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(16),
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(15,2) DEFAULT 5.00,
    term VARCHAR(20),
    loan_date DATE,
    due_date DATE,
    repayment_date DATE DEFAULT NULL,
    repayed_amount DECIMAL(15,2) DEFAULT NULL,
    status VARCHAR(10) DEFAULT 'Active',
    FOREIGN KEY (account_number) REFERENCES Accounts(account_number)
);

CREATE TABLE IF NOT EXISTS LoansApplied(
	loan_applied_id INT PRIMARY KEY AUTO_INCREMENT,
    account_number VARCHAR(16),
    loan_amount DECIMAL(15,2),
    term VARCHAR(20),
    loan_date DATE,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (account_number) REFERENCES Accounts(account_number)
);
    
