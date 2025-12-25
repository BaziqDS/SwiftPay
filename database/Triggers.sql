DELIMITER //

CREATE TRIGGER AfterUserInsert
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO Accounts (user_id, account_number, balance, created_at)
    VALUES (NEW.user_id, CONCAT('ACC-', LPAD(NEW.user_id, 12, '0')), 0.00, NOW());
END //

DELIMITER ;