/* movies from 2004
SELECT id FROM movies WHERE year = 2004;
*/
/* list of all stars from movies in 2004, no duplicate person_id's
SElECT distinct(person_id)
  FROM stars
 WHERE movie_id
    IN (SELECT id
          FROM movies
         WHERE year = 2004);
*/

/* now we need to convert to name and order by birth year*/
SELECT name
  FROM people
 WHERE id
    IN (SElECT distinct(person_id)
          FROM stars
         WHERE movie_id
            IN (SELECT id
                  FROM movies
                 WHERE year = 2004))
 ORDER BY birth;