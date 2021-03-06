/* This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * Gradeup Block.
 *
 * @package   block_gradeup
 * @author    Chris Strothman	<cstrothman@southern.edu>
 * @license   http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
 
 /*
THIS IS A DEV RESOURCE FILE ONLY
This file is not used by gradeup - but the sql commands used within gradeup are contained in this file. 
use MySQL Workbench or any other database software to play around with moodle's tables and use the below to understand what is going on
*/

USE mysql;
SHOW tables; 
SELECT * FROM mdl_grade_grades;
SELECT * FROM mdl_grade_items;
SELECT * FROM mdl_assign;
SELECT * FROM mdl_assign_grades;
SELECT * FROM mdl_grade_items;
SELECT * FROM mdl_grade_grades_history;
SELECT * FROM mdl_course;

/** get courses that a user is enrolled in*/
SELECT c.id, c.fullname, c.startdate,c.enddate FROM mdl_course c INNER JOIN mdl_enrol e ON c.id=e.courseid INNER JOIN mdl_user_enrolments ue ON e.id=ue.enrolid WHERE userid=5 ORDER BY c.fullname;

/**get course startdate*/
SELECT c.startdate FROM mdl_course c INNER JOIN mdl_enrol e ON c.id=e.courseid INNER JOIN mdl_user_enrolments ue ON e.id=ue.enrolid WHERE userid=5 AND courseid=2;

/* returns the total points available in a course for use in computing assignment weight */
SELECT SUM(grade) as totalPoints FROM mdl_assign a WHERE a.course=2; 


/*get grades for a user given a specific class and user id*/
SELECT gi.courseid,g.userid,gi.itemname, g.finalgrade, gi.grademax, a.duedate 
	FROM mdl_grade_grades g 
    INNER JOIN mdl_grade_items gi ON gi.id = g.itemid 
    INNER JOIN mdl_assign a ON a.name=gi.itemname 
    WHERE g.userid = 5 AND gi.courseid = 2 AND gi.itemname IS NOT NULL 
    ORDER BY a.duedate;

/*
, q1.grademax / SUM(q1.grademax) AS weight 
*/

/*get grades for a user given a specific class and user id, also gets average grade for an assignment*/
SELECT q1.itemname as name, q1.finalgrade as score, q1.grademax, q1.duedate,q2.averageGrade FROM (
	SELECT gi.itemname, g.finalgrade, gi.grademax, a.duedate 
		FROM mdl_grade_grades g 
		INNER JOIN mdl_grade_items gi ON gi.id = g.itemid 
		INNER JOIN mdl_assign a ON a.name=gi.itemname 
		WHERE g.userid = 5 AND gi.courseid = 2 AND gi.itemname IS NOT NULL 
		ORDER BY a.duedate
	) q1 INNER JOIN (
		SELECT gi.itemname, AVG(finalgrade) as averageGrade
		FROM mdl_grade_grades g 
		INNER JOIN mdl_grade_items gi ON gi.id = g.itemid 
		INNER JOIN mdl_assign a ON a.name=gi.itemname 
		WHERE gi.courseid = 2 AND gi.itemname IS NOT NULL 
		GROUP BY itemname
		ORDER BY gi.itemname
	) q2 ON q1.itemname=q2.itemname ORDER BY q1.duedate
