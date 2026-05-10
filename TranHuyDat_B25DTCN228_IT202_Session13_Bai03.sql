-- Bảng price change sẽ cần id, med_id , giá cũ, giá mỡi, difference và loại thay đỏi (giảm/tăng)
-- difference thì nên là luôn dương 
CREATE TABLE price_changes_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    med_id VARCHAR(20),
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_type VARCHAR(20), -- TĂNG GIÁ / GIẢM GIÁ
    difference DECIMAL(10,2),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- Sẽ cần phải sử dụng 2 trigger 1 cái là chặn BEFORE và 1 cái là chặn log rác thì để là AFTER

DELIMITER //

CREATE TRIGGER trg_validate_price
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    IF NEW.med_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_validate_log
AFTER UPDATE ON Medicines
FOR EACH ROW
BEGIN 
	DECLARE v_diff DECIMAL(10,2);
    
	IF NEW.med_price <> OLD.med_price
    THEN 
		IF NEW.med_price > OLD.med_price THEN
			SET v_diff = NEW.med_price - OLD.med_price;
            
			INSERT INTO price_changes_Log
            (med_id, old_price, new_prile, type, difference)
            VALUES (OLD.med_id, OLD.med_price, NEW.med_price, 'TĂNG GIÁ', v_diff);
            
		ELSE
			SET v_diff = OLD.med_price - NEW.med_price;
            
            INSERT INTO price_changes_log
            (med_id, old_price, new_price, type, difference)
            VALUES (OLD.med_id, OLD.med_price, NEW.med_price, 'GIẢM GIÁ', v_diff);

        END IF;

    END IF;
END //

DELIMITER ;

