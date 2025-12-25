DELIMITER //

CREATE PROCEDURE closeTicket(
    IN account INT
)
BEGIN
    DECLARE activeTicket INT;

    -- Retrieve the latest ticket number for the given account
    SELECT s.ticket_number INTO activeTicket
    FROM Support s
    JOIN Accounts a ON s.user_id = a.user_id
    WHERE a.account_id = account
    ORDER BY s.ticket_number DESC
    LIMIT 1;

    -- Check if there is a valid ticket for the user
    IF (activeTicket IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have an existing ticket';
    ELSE
        -- Update the status of the active ticket to 'Closed'
        UPDATE Support
        SET status = 'Closed'
        WHERE ticket_number = activeTicket;
    END IF;

END //

CREATE PROCEDURE GenerateAndAssignDebitCard(
    IN id INT
)
BEGIN
    DECLARE new_card_number VARCHAR(19);
    DECLARE new_cvc VARCHAR(3);
    
    
    -- Generate new card number and CVC
    SET new_card_number = generate_debit_card_number();
    SET new_cvc = generate_cvc();
    
    -- Insert into CARD table
    INSERT INTO Card (card_number, expiry_month, expiry_year, cvc) 
    VALUES (new_card_number, MONTH(CURDATE()), YEAR(CURDATE()) + 5, new_cvc);
    
    -- Update Users table with the new debit card number
    UPDATE Accounts
    SET debit_card_number = new_card_number
    WHERE account_number = CONCAT('ACC-',LPAD(id,12,'0'));
    
END //

CREATE PROCEDURE GenerateTicket(
	IN userID INT,
	IN commentsofIssue VARCHAR(1000)
    )
BEGIN
	IF NOT EXISTS(SELECT user_id FROM Users u WHERE u.user_id = userID) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User Does Not Exist';
	END IF;
	INSERT INTO Support(user_id,comments)
    VALUES(userID,commentsofIssue);
END //


CREATE PROCEDURE getLoan(
	IN account INT,
	IN amount DECIMAL(15,2),
    IN period INT,
    IN period_type VARCHAR(10) -- 'DAY', 'MONTH', 'YEAR'
)
BEGIN	
	DECLARE criteria INT;
    DECLARE num_of_transactions INT;
    DECLARE end_date DATE;
    DECLARE ID INT;
    DECLARE loanAppliedID VARCHAR(16);
    SET criteria = 5;
    
	IF NOT EXISTS(SELECT account_number FROM Accounts a WHERE a.account_number = CONCAT('ACC-',LPAD(account,12,'0'))) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account Does Not Exist';
	END IF;
    
    
    SELECT account_number INTO loanAppliedID FROM Loans l WHERE l.account_number =  CONCAT('ACC-',LPAD(account,12,'0'));
    
	IF loanAppliedID IS NOT NULL THEN
		IF(SELECT status FROM Loans l WHERE l.account_number =  loanAppliedID) = 'Active' THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account has an active loan';
		END IF;
    END IF;
    
    
    SELECT COUNT(*) 
    FROM Transactions t 
    WHERE t.account_number = CONCAT('ACC-',LPAD(account,12,'0'))
    INTO num_of_transactions;
    
    
    -- Calculate end_date based on period_type
    IF period_type = 'DAY' THEN
        SET end_date = DATE_ADD(CURRENT_DATE(), INTERVAL period DAY);
    ELSEIF period_type = 'MONTH' THEN
        SET end_date = DATE_ADD(CURRENT_DATE(), INTERVAL period MONTH);
    ELSEIF period_type = 'YEAR' THEN
        SET end_date = DATE_ADD(CURRENT_DATE(), INTERVAL period YEAR);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid period_type. Use DAY, MONTH, or YEAR.';
    END IF;
    
    
    INSERT INTO LoansApplied(account_number,loan_amount,term,loan_date) VALUES(CONCAT('ACC-',LPAD(account,12,'0')),amount,CONCAT(period,' ',period_type),CURRENT_DATE());
    
    SELECT loan_applied_id INTO ID
    FROM LoansApplied 
    WHERE account_number = CONCAT('ACC-',LPAD(account,12,'0')) 
    ORDER BY loan_applied_id DESC
    LIMIT 1;
    
    IF(num_of_transactions < criteria) THEN
		UPDATE LoansApplied
        SET status = 'Rejected'
        WHERE loan_applied_id = ID;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan Rejected. Criteria Not Met';
	ELSE 
		UPDATE LoansApplied
        SET status = 'Approved'
        WHERE loan_applied_id = ID;
        UPDATE Accounts
        SET balance = balance + amount
        WHERE account_number = CONCAT('ACC-',LPAD(account,12,'0'));
        INSERT INTO Loans(account_number,loan_amount,term,loan_date,due_date) 
        VALUES (CONCAT('ACC-',LPAD(account,12,'0')),amount,CONCAT(period,' ',period_type),CURRENT_DATE(),end_date);
	END IF;
END //


CREATE PROCEDURE InsertMerchant(
    IN name VARCHAR(100),
    IN email VARCHAR(50)
)
BEGIN
    DECLARE newMerchantID INT;

    SELECT id INTO newMerchantID
    FROM MerchantAccount
    ORDER BY merchant_id DESC
    LIMIT 1;
    
    SET newMerchantID = newMerchantID + 1;
    SET @formattedMerchantID = LPAD(newMerchantID, 11, '0');
    INSERT INTO MerchantAccount(merchant_id, merchant_name, email)
    VALUES (CONCAT('MACC-', @formattedMerchantID), name, email);
END //

CREATE PROCEDURE InsertTransactionOnly(
    IN account_id INT,
    IN transfer_to_account_id INT,
    IN transaction_amount DECIMAL(15,2),
    IN transaction_type INT,
    IN payment_method INT
)
BEGIN
    DECLARE balanceCheck DECIMAL(15,2);
    DECLARE acc VARCHAR(16);
    DECLARE tacc VARCHAR(16);
    
    
SELECT 
    account_number
FROM
    Accounts a
WHERE
    a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0')) INTO acc;
    IF(acc IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account Does Not Exist';
	END IF;
    -- Check if payment_method requires a debit card and if user has one
    IF payment_method = 2 THEN
        -- Check if user associated with account_id has a debit card
        SELECT a.debit_card_number INTO @debit_card_exists
        FROM Accounts a
        WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
        
        IF @debit_card_exists IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have a Debit Card';
        END IF;
    END IF;
    
    
    -- Handle different transaction types
    IF transaction_type = 1 THEN
        -- Deposit transaction
        UPDATE Accounts a
        SET balance = balance + transaction_amount
        WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
        
        INSERT INTO Transactions (account_number, transaction_amount, transaction_type, payment_method)
        VALUES (CONCAT('ACC-', LPAD(account_id, 12, '0')), transaction_amount, transaction_type, payment_method);
        
    ELSEIF transaction_type = 2 THEN
        -- Withdrawal transaction
        SELECT balance INTO balanceCheck
        FROM Accounts a
        WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
        
        IF balanceCheck >= transaction_amount THEN
            UPDATE Accounts a
            SET balance = balance - transaction_amount
            WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
            
            INSERT INTO Transactions (account_number, transaction_amount, transaction_type, payment_method)
            VALUES (CONCAT('ACC-', LPAD(account_id, 12, '0')), transaction_amount, transaction_type, payment_method);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;
        
    ELSEIF transaction_type = 3 THEN
        -- Fund transfer transaction
        SELECT balance INTO balanceCheck
        FROM Accounts a
        WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
        
        
SELECT 
    account_number
FROM
    Accounts a
WHERE
    a.account_number = CONCAT('ACC-', LPAD(transfer_to_account_id, 12, '0')) INTO tacc;
		IF(tacc IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer Account Does Not Exist';
		END IF;
        IF balanceCheck >= transaction_amount THEN
            UPDATE Accounts a
            SET balance = balance - transaction_amount
            WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
            
UPDATE Accounts 
SET 
    balance = balance + transaction_amount
WHERE
    account_number = CONCAT('ACC-', LPAD(transfer_to_account_id, 12, '0'));
            
            INSERT INTO Transactions (account_number, transfer_to_account_number, transaction_amount, transaction_type, payment_method)
            VALUES (CONCAT('ACC-', LPAD(account_id, 12, '0')),CONCAT('ACC-', LPAD(transfer_to_account_id, 12, '0')), transaction_amount, transaction_type, payment_method);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;
        
    ELSEIF transaction_type = 4 THEN
    
    SELECT merchant_id FROM MerchantAccount ma WHERE ma.merchant_id = CONCAT('MACC-', LPAD(transfer_to_account_id, 11, '0')) INTO tacc;
		IF(tacc IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Merchant Does Not Exist';
		END IF;
        -- Merchant transaction
SELECT 
    balance
INTO balanceCheck FROM
    Accounts a
WHERE
    a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
        
        IF balanceCheck >= transaction_amount THEN
            UPDATE Accounts a
            SET balance = balance - transaction_amount
            WHERE a.account_number = CONCAT('ACC-', LPAD(account_id, 12, '0'));
            
UPDATE MerchantAccount ma 
SET 
    ma.balance = ma.balance + transaction_amount
WHERE
    ma.merchant_id = CONCAT('MACC-', LPAD(transfer_to_account_id, 11, '0'));
            
            INSERT INTO Transactions (account_number, transfer_to_account_number, transaction_amount, transaction_type, payment_method)
            VALUES (CONCAT('ACC-', LPAD(account_id, 12, '0')), CONCAT('MACC-', LPAD(transfer_to_account_id, 11, '0')), transaction_amount, transaction_type, payment_method);
            
            INSERT INTO Invoices (account_number, merchant_id, transaction_type, payment_method, amount)
            VALUES (CONCAT('ACC-', LPAD(account_id, 12, '0')), CONCAT('MACC-', LPAD(transfer_to_account_id, 11, '0')), transaction_type, payment_method, transaction_amount);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;
        
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transaction type';
    END IF;
    
END //

CREATE PROCEDURE InsertUser(
	IN cnic VARCHAR(15),
    IN fName VARCHAR(50),
    IN lName VARCHAR(50),
    IN birthDate DATE,
    IN email VARCHAR(50),
    IN phone VARCHAR(50),
    IN getCard VARCHAR(1)
)
BEGIN
	IF getCard = 'Y' THEN
		INSERT INTO USERS(cnic,first_name,last_name,birth_date,email,phone_number)
        VALUES(cnic,fName,lName,birthDate,email,phone);
        SELECT user_id INTO @lastAdded FROM Users ORDER BY user_id DESC LIMIT 1;
        CALL GenerateAndAssignDebitCard(@lastAdded);
	ELSE
		INSERT INTO USERS(cnic,first_name,last_name,birth_date,email,phone_number)
        VALUES(cnic,fName,lName,birthDate,email,phone);
	END IF;
END //


CREATE PROCEDURE `payLoan`(
    IN account INT
)
BEGIN 
    DECLARE loanAppliedID VARCHAR(16); 
    DECLARE rate DECIMAL(15,2);
    DECLARE balanceCheck DECIMAL(15,2);
    DECLARE activeLoan DECIMAL(15,2);
    DECLARE activeLoanID INT;
    
    -- Get the loan applied ID for the account
    SELECT account_number INTO loanAppliedID 
    FROM Loans l 
    WHERE l.account_number = CONCAT('ACC-',LPAD(account,12,'0')) AND l.status = 'Active';
    
    IF loanAppliedID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account does not have a loan';
    END IF;
    
    -- Get the active loan ID
    SELECT loan_id INTO activeLoanID 
    FROM Loans l 
    WHERE l.account_number = loanAppliedID AND l.status = 'Active'
    LIMIT 1; -- Limit to one row to avoid multiple row error
    
    IF activeLoanID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active loan found for the account';
    END IF;
    
    -- Get the active loan amount
    SELECT loan_amount INTO activeLoan 
    FROM Loans 
    WHERE loan_id = activeLoanID;
    
    -- Get the interest rate for the loan
    SET rate = (SELECT interest_rate FROM Loans WHERE loan_id = activeLoanID LIMIT 1);
    
    -- Check if overdue and calculate interest
    IF CURRENT_DATE() > (SELECT due_date FROM Loans WHERE loan_id = activeLoanID) THEN 
        SET rate = rate * 2.0;
    END IF;
    
    -- Calculate total loan amount with interest
    SET activeLoan = activeLoan + (activeLoan * rate / 100.0);
    
    -- Get the balance for the account
    SELECT balance INTO balanceCheck
    FROM Accounts 
    WHERE account_number = loanAppliedID;
    
    -- Check if balance is sufficient for payment
    IF balanceCheck >= activeLoan THEN
        BEGIN
            -- Perform the updates
            UPDATE Accounts
            SET balance = balance - activeLoan
            WHERE account_number = loanAppliedID;
            
            UPDATE Loans 
            SET status = 'Inactive', repayment_date = CURRENT_DATE(),repayed_amount = activeLoan
            WHERE loan_id = activeLoanID;
        END;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You do not have sufficient balance';
    END IF;
    
END //

DELIMITER ;
