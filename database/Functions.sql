DELIMITER //

CREATE FUNCTION generate_cvc() RETURNS varchar(3) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE cvc VARCHAR(3);
    
    -- Generate a random 3-digit number for CVC
    SET cvc = LPAD(FLOOR(RAND() * 1000), 3, '0');
    
    RETURN cvc;
END //

CREATE FUNCTION generate_debit_card_number() RETURNS varchar(19) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE card_number VARCHAR(19);
    
    -- Generate 16 random digits
    SET card_number = CONCAT(
        LPAD(FLOOR(RAND() * 10000), 4, '0'), '-', 
        LPAD(FLOOR(RAND() * 10000), 4, '0'), '-', 
        LPAD(FLOOR(RAND() * 10000), 4, '0'), '-', 
        LPAD(FLOOR(RAND() * 10000), 4, '0')
    );
    
    RETURN card_number;
END //

DELIMITER ;