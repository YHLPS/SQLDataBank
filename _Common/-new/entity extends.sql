-- 1. יצירת טבלת האנשים הראשית
CREATE TABLE persons (
    id INT PRIMARY KEY AUTO_INCREMENT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    -- code name - דוגמה לערכים: 'ACTIVE', 'PENDING_APPROVAL', 'DELETED'
	  -- `PENDING_APPROVAL_DELETED_PENDING_APPROVAL_DELETED`.length = 49
	  -- `PENDING_APPROVAL_DELETED_PENDING_APPROVAL_DELETED_PENDING_APPROVAL_DELETED`.length = 74
	  --status_key VARCHAR(50) NOT NULL, 
);

-- 2. יצירת טבלת השמות הנרדפים
CREATE TABLE person_names (
    id INT PRIMARY KEY AUTO_INCREMENT,
    person_id INT, -- קישור לאדם מטבלת האנשים
    name_text VARCHAR(100) NOT NULL, -- הטקסט/השם עצמו
    is_primary BOOLEAN DEFAULT FALSE, -- סימון האם זה השם הראשי
    FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- 3. הכנסת אדם חדש למערכת
INSERT INTO persons () VALUES (); -- מייצר אדם עם מזהה מס' 1

-- 4. הכנסת ריבוי שמות עבור אותו אדם (מזהה 1)
INSERT INTO person_names (person_id, name_text, is_primary) VALUES 
(1, 'אברהם', TRUE),   -- שם ראשי
(1, 'אבי', FALSE),     -- כינוי
(1, 'אברמל''ה', FALSE); -- שם נרדף נוסף
