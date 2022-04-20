/*
building query up incrementally:

SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Johnny Depp');
SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Helena Bonham Carter');

SElECT id
  FROM movies
 WHERE id
    IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Johnny Depp'));

SElECT id
  FROM movies
 WHERE id
    IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = 'Helena Bonham Carter'));
*/

SElECT title
  FROM movies
 WHERE id
    IN (SElECT id
          FROM movies
         WHERE id
            IN (SELECT movie_id
                  FROM stars
                 WHERE person_id = (SELECT id
                                      FROM people
                                     WHERE name = 'Johnny Depp')))
            AND id
             IN (SElECT id
                   FROM movies
                  WHERE id
                     IN (SELECT movie_id
                           FROM stars
                          WHERE person_id = (SELECT id
                                               FROM people
                                              WHERE name = 'Helena Bonham Carter')));

