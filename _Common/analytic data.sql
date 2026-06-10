/* analytic data - Window Functions: 
| שיטה | תחביר | מה קורה לטבלה | שימוש |
| --- | --- | --- | --- |
| ** Aggregate רגיל ** | ``SUM(col)`` | מצטמצמת לשורה אחת | חישוב כללי |
| ** Aggregate עם GROUP BY ** | ``SUM(col) ``GROUP ``BY ``x`` | שורה לכל קבוצה | ניתוח לפי קטגוריה |
| ** Window Aggregate ** | ``SUM(col) ``OVER()`` | כל השורות נשארות | להציג גם את הנתון וגם את האגרגציה |
*/

SELECT 
    employee_name,
    salary,
    SUM(salary) OVER () AS total_salary
FROM employees;


SELECT 
    order_id,
    amount,
    amount * 1.0 / SUM(amount) OVER () AS percent_of_total
FROM sales;
