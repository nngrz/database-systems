-- 1. Create a view listing all locations (Loc) 
-- along with the number of departments in that location 
-- and the number of employees employed in those departments.

CREATE VIEW loc_summary AS
SELECT d.loc,
       COUNT(DISTINCT d.deptno) AS dept_count,
       COUNT(e.empno) AS emp_count
FROM DEPT d
LEFT JOIN EMP e
  ON d.deptno = e.deptno
GROUP BY d.loc;

-- support
DROP VIEW loc_summary;
-- test
SELECT *
FROM loc_summary;
