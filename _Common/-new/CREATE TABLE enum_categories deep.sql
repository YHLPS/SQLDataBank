-- =========================================================
-- 1. יצירת טיפוס הטבלה הג'נרי (התבנית של 2 הטורים)
-- =========================================================
IF TYPE_ID('dbo.GenericHierarchyType') IS NOT NULL
    DROP TYPE dbo.GenericHierarchyType;
GO

CREATE TYPE dbo.GenericHierarchyType AS TABLE (
    node_id INT NOT NULL,
    parent_node_id INT NULL
);
GO

-- =========================================================
-- 2. יצירת הפונקציה הג'נרית לבדיקת מעגליות
-- =========================================================
CREATE OR ALTER FUNCTION dbo.fn_CheckCircularGeneric (
    @current_id INT, 
    @target_parent_id INT,
    @HierarchyTable dbo.GenericHierarchyType READONLY
)
RETURNS BIT
AS
BEGIN
    -- הגנה בסיסית: קטגוריה לא יכולה להצביע על עצמה
    IF @current_id = @target_parent_id
        RETURN 0;

    -- אם אין אב מיועד (קטגוריה ראשית), זה תמיד תקין
    IF @target_parent_id IS NULL
        RETURN 1;

    -- סריקה רקורסיבית למעלה בעץ המשפחה שקיבלנו בטבלה
    IF EXISTS (
        WITH CategoryHierarchy AS (
            -- נקודת התחלה: קטגוריית האב המיועדת
            SELECT node_id, parent_node_id
            FROM @HierarchyTable
            WHERE node_id = @target_parent_id
            
            UNION ALL
            
            -- שלב רקורסיבי: מטפסים לאב של האב
            SELECT t.node_id, t.parent_node_id
            FROM @HierarchyTable t
            INNER JOIN CategoryHierarchy h ON t.node_id = h.parent_node_id
        )
        -- אם ה-ID הנוכחי מופיע איפשהו בשרשרת למעלה - יש מעגליות!
        SELECT 1 FROM CategoryHierarchy WHERE node_id = @current_id
    )
        RETURN 0; -- לא תקין, נוצרת לולאה

    RETURN 1; -- תקין, אין לולאה
END;
GO

-- =========================================================
-- 3. יצירת טבלת הקטגוריות
-- =========================================================
DROP TABLE IF EXISTS enum_categories;
GO

CREATE TABLE enum_categories (
    category_id INT IDENTITY (1, 1) PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    parent_category_id INT NULL,
    
    -- מפתח זר בסיסי לוודא שהאב קיים פיזית בטבלה
    CONSTRAINT FK_Category_Parent 
    FOREIGN KEY (parent_category_id) 
    REFERENCES enum_categories (category_id)
);
GO

-- =========================================================
-- 4. יצירת הטריגר שמפקח על ההוספה והעריכה בעזרת הפונקציה
-- =========================================================
CREATE TRIGGER trg_ValidateCategoryHierarchy
ON enum_categories
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- אופטימיזציה: אם זו פעולת עדכון ואף אחד לא שינה את ה-parent_category_id, אין צורך לבדוק
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    -- א. נגדיר משתנה מסוג הטבלה הג'נרית
    DECLARE @CurrentSnapshot dbo.GenericHierarchyType;

    -- ב. נשפוך לתוכו את המצב הנוכחי של *כל* הקטגוריות בטבלה
    -- בשילוב הנתונים החדשים שהמשתמש מנסה להכניס/לעדכן (מתוך טבלת inserted)
    INSERT INTO @CurrentSnapshot (node_id, parent_node_id)
    SELECT category_id, parent_category_id 
    FROM enum_categories;

    -- ג. נבדוק באמצעות לולאה או בדיקה ישירה האם אחת השורות החדשות/מעודכנות יוצרת מעגליות
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE dbo.fn_CheckCircularGeneric(i.category_id, i.parent_category_id, @CurrentSnapshot) = 0
    )
    BEGIN
        -- ד. אם הפונקציה החזירה 0 (מעגליות), נכשיל את הפעולה ונזרוק שגיאה
        RAISERROR ('שגיאה באבטחת הנתונים: עדכון/הוספה זו יוצרים קשר מעגלי (לולאה אינסופית) בהיררכיה.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
