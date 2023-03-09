-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
   SELECT MAX(era)
   FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
   FROM people
   WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE "% %"
  ORDER BY namefirst ASC, namelast ASC;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) AS count
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT *
  FROM q1iii
  WHERE avgheight > 70
  ORDER BY birthyear ASC;
;

-- Question 2i

CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p
  INNER JOIN halloffame h ON p.playerid = h.playerid
  WHERE inducted = "Y"
  ORDER BY yearid DESC, p.playerid ASC;
;



-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q.playerid, s.schoolid, q.yearid
  FROM collegeplaying c 
  INNER JOIN schools s on c.schoolid = s.schoolid 
  INNER JOIN q2i q ON q.playerid = c.playerid 
  WHERE schoolState = "CA" 
  ORDER BY q.yearid DESC, s.schoolid ASC, q.playerid ASC
  ;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  -- Find the playerid, namefirst, namelast and schoolid of all people who
  -- were successfully inducted into the Hall of Fame -- whether or not they 
  -- played in college. Return people in descending order of playerid. Break ties 
  -- on playerid by schoolid (ascending). (Note: schoolid should be NULL if they did not play in college.)
  SELECT q.playerid, namefirst, namelast, schoolid
  FROM q2i q
  LEFT JOIN collegeplaying c on c.playerid = q.playerid
  ORDER BY q.playerid DESC, schoolid ASC;
;

-- -- Question 3i

CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, namefirst, namelast, yearid, (H + H2B + (2 * H3B) + (3 * HR))/(AB * 1.0) as slg
  FROM batting b 
  INNER JOIN people p ON b.playerid = p.playerid
  WHERE ab > 50
  ORDER BY slg DESC, yearid ASC, p.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, namefirst, namelast, (SUM(H) + SUM(H2B) + (2 * SUM(H3B)) + (3 * SUM(HR)))/(SUM(AB) * 1.0) as lslg
  FROM batting b 
  INNER JOIN people p ON b.playerid = p.playerid
  GROUP BY p.playerid
  HAVING SUM(AB) > 50
  ORDER BY lslg DESC, p.playerid ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, lslg
  FROM (
    SELECT p.playerid, namefirst, namelast, (SUM(H) + SUM(H2B) + (2 * SUM(H3B)) + (3 * SUM(HR)))/(SUM(AB) * 1.0) as lslg
    FROM batting b 
    INNER JOIN people p ON b.playerid = p.playerid
    GROUP BY p.playerid
    HAVING SUM(AB) > 50
    ORDER BY lslg DESC, p.playerid ASC
    ) AS subq
  WHERE lslg > (
    SELECT (SUM(H) + SUM(H2B) + (2 * SUM(H3B)) + (3 * SUM(HR)))/(SUM(AB) * 1.0) as lslg
    FROM batting
    WHERE playerid = "mayswi01"
    );

;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
-- i. Find the yearid, min, max and average of all player salaries for each year recorded, ordered by yearid in ascending order.
  SELECT DISTINCT yearid, 
  MIN(salary) OVER (PARTITION BY yearid) AS minSalary,
  MAX(salary) OVER (PARTITION BY yearid) AS maxSalary,
  AVG(salary) OVER (PARTITION BY yearid) AS avgSalary
  FROM salaries
  ORDER BY yearid ASC
;

-- Question 4ii
-- 
CREATE VIEW q4ii(binid, low, high, count)
AS
-- Return the binid, low and high boundaries for each bin, as well as the number of salaries in each bin,
SELECT binid, lowBound, highBound, 
CASE WHEN
AS countSalaries
-- Divide the salary range into 10 equal bins from min to max, with binids 0 through 9, and count the salaries in each bin. 


FROM salaries
WHERE year = 2016
ORDER BY lowBound ASC
;

-- Question 4iii
-- Now let's compute the Year-over-Year change in min, max and average player salary. 
-- For each year with recorded salaries after the first, return the yearid, mindiff, maxdiff,
-- and avgdiff with respect to the previous year. Order the output by yearid in ascending order.
-- (You should omit the very first year of recorded salaries from the result.)
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s.yearid,
  -- window functions to get diff btwn previous row
    (minSal - LAG(minSal, 1) OVER ()) AS mindiff,
    (maxSal - LAG(maxSal, 1) OVER ()) AS maxdiff, 
    (avgSal - LAG(avgSal, 1) OVER ()) AS avgdiff
  FROM salaries s
  -- create subquery that gets the min/max/avg salaries for each year and join on salaries by year
  INNER JOIN (
    SELECT yearid, MAX(salary) AS maxSal, MIN(salary) AS minSal, AVG(salary) AS avgSal
    FROM salaries
    GROUP BY yearid) as subq 
    ON s.yearid = subq.yearid
  GROUP BY s.yearid
  ORDER BY s.yearid ASC 
  LIMIT 1000 OFFSET 1
;

-- Question 4iv
-- In 2001, the max salary went up by over $6 million. Write a query to 
-- find the players that had the max salary in 2000 and 2001. Return the playerid, 
-- namefirst, namelast, salary and yearid for those two years. If multiple players
-- tied for the max salary in a year, return all of them.
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT s.playerid, namefirst, namelast, MAX(salary), yearid
  FROM salaries s
  INNER JOIN people p ON s.playerid = p.playerid
  WHERE s.yearid = "2000" OR s.yearid = "2001"
  GROUP BY s.yearid
;


-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
-- Each team has at least 1 All Star and may have multiple. For each team in the year 2016, give the teamid and diffAvg (
-- the difference between the team's highest paid all-star's salary and the team's lowest paid all-star's salary).
-- Due to some discrepancies in the database, please draw your team names from the All-Star table 
-- (so use allstarfull.teamid in the SELECT statement 
  SELECT a.teamid, MAX(salary) - MIN(salary) AS diffAvg
  FROM salaries s
  INNER JOIN allstarfull a ON s.playerid = a.playerid 
  INNER JOIN allstarfull a2 ON s.yearid = a2.yearid
  INNER JOIN allstarfull a3 on s.teamid = a3.teamid
  WHERE s.yearid = 2016
  GROUP BY a.teamid
  ;
