/*
In 13.sql, write a SQL query to list the names of all people who starred in a movie in which Kevin Bacon also starred.
Your query should output a table with a single column for the name of each person.
There may be multiple people named Kevin Bacon in the database. Be sure to only select the Kevin Bacon born in 1958.
Kevin Bacon himself should not be included in the resulting list.
*/

/* Lets start with finding the correct Kevin Bacon 
SELECT id FROM people WHERE name = 'Kevin Bacon' AND birth = 1958;
*/
/* get movie_id of movies our mr Bacon starred in
SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Kevin Bacon' AND birth = 1958);
*/
/* Get stars from movies of our previous list
SELECT person_id FROM stars WHERE movie_id IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Kevin Bacon' AND birth = 1958));
*/
/* now to remove Kevin Bacon from the previous list
SELECT person_id
  FROM stars
 WHERE movie_id
    IN (SELECT movie_id
          FROM stars
         WHERE person_id = (SELECT id
                              FROM people
                             WHERE name = 'Kevin Bacon' AND birth = 1958))
           AND person_id <> (SELECT id
                               FROM people
                               WHERE name = 'Kevin Bacon' AND birth = 1958);
*/

/* now to convert the person_id to names from people */
SELECT distinct(name)
  FROM people
 WHERE id IN (SELECT person_id
               FROM stars
              WHERE movie_id
                 IN (SELECT movie_id
                       FROM stars
                      WHERE person_id = (SELECT id
                                           FROM people
                                          WHERE name = 'Kevin Bacon' AND birth = 1958))
                        AND person_id <> (SELECT id
                                            FROM people
                                           WHERE name = 'Kevin Bacon' AND birth = 1958));