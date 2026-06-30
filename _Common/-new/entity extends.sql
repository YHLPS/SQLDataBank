-- LIKE '%אבי%';
-- Wildcard

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

-- 5. כדי לקבל את האדם יחד עם כל השמות שלו
SELECT p.id, n.name_text, n.is_primary
FROM persons p
JOIN person_names n ON p.id = n.person_id
WHERE p.id = 1;


-- 6. קוד ה-SQL לחיפוש חכם
DECLARE @search_name varchar(100) = '%אבי%'
	
-- שאילתה לחיפוש חכם לפי שם או כינוי
SELECT 
    p.id AS person_id,
    main_name.name_text AS official_name, 
	search_name.name_text AS resemble_name
FROM persons p
-- 6.1. חיבור ראשון: מביא רק את השם הראשי לצורך תצוגה
JOIN person_names main_name 
    ON p.id = main_name.person_id AND main_name.is_primary = TRUE
-- 6.2. חיבור שני: בודק את כל השמות (כולל כינויים) לצורך סינון החיפוש
JOIN person_names search_name 
    ON p.id = search_name.person_id
-- 6.3. שלב הסינון: כאן אנחנו מגדירים מה אנחנו מחפשים
--WHERE search_name.name_text LIKE '%אבי%';
WHERE search_name.name_text LIKE @search_name;



