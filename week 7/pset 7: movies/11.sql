/*
Has the same titles as check50 but in different order...

SELECT title
  FROM movies
 WHERE id
    IN (SELECT movie_id
          FROM ratings
         WHERE movie_id
            IN (SELECT movie_id
                  FROM stars
                 WHERE person_id = (SELECT id
                                      FROM people
                                     WHERE name = 'Chadwick Boseman'))
         ORDER BY rating DESC
         LIMIT 5);
*/

/* building up incrementally from scratch I had built it up incrementally originally but didn't save the steps as a comment
SELECT id, name FROM people WHERE name = "Chadwick Boseman";
      returns 1569276 | Chadwick Boseman, obviously I only need the ID, I had name there to verify that it was the name I was looking for

SELECT movie_id, person_id FROM stars WHERE person_id = 1569276;
      returns
            453562   | 1569276
            10514222 | 1569276
            1712192  | 1569276
            1727373  | 1569276
            1825683  | 1569276
            2223990  | 1569276
            2404233  | 1569276
            2473602  | 1569276
            5301662  | 1569276
            8688634  | 1569276

Combining both the above
SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman");
      | 453562   |
      | 10514222 |
      | 1712192  |
      | 1727373  |
      | 1825683  |
      | 2223990  |
      | 2404233  |
      | 2473602  |
      | 5301662  |
      | 8688634  |

Now we need to pull ratings for movies
SELECT movie_id, rating FROM ratings WHERE movie_id IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman"));
returns
      | 453562   | 7.5    |
      | 10514222 | 6.9    |
      | 1712192  | 6.4    |
      | 1727373  | 4.4    |
      | 1825683  | 7.3    |
      | 2223990  | 6.8    |
      | 2404233  | 5.4    |
      | 2473602  | 6.9    |
      | 5301662  | 7.3    |
      | 8688634  | 6.6    |
      List checks out, now to sort it
SELECT movie_id, rating FROM ratings WHERE movie_id IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman")) ORDER BY rating DESC;
returns
      | 453562   | 7.5    |
      | 1825683  | 7.3    |
      | 5301662  | 7.3    |
      | 10514222 | 6.9    |
      | 2473602  | 6.9    |
      | 2223990  | 6.8    |
      | 8688634  | 6.6    |
      | 1712192  | 6.4    |
      | 2404233  | 5.4    |
      | 1727373  | 4.4    |
      Still seems to be checking out, now to try to limit it to the top 5
SELECT movie_id, rating FROM ratings WHERE movie_id IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman")) ORDER BY rating DESC LIMIT 5;
returns
      | 453562   | 7.5    |
      | 1825683  | 7.3    |
      | 5301662  | 7.3    |
      | 10514222 | 6.9    |
      | 2473602  | 6.9    |
      Seems correct. Now we need to remove the rating column and translate the movie IDs to titles

SELECT id, title FROM movies WHERE id IN (SELECT movie_id FROM ratings WHERE movie_id IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman")) ORDER BY rating DESC LIMIT 5);
returns
      | 453562   | 42                       |
      | 1825683  | Black Panther            |
      | 2473602  | Get on Up                |
      | 5301662  | Marshall                 |
      | 10514222 | Ma Rainey's Black Bottom |
      So it's returning the same movie IDs but in different sort than the id's are provided to the IN.
      Seems we'll have to use a join so we can sort by rating on the same level as the IN

*/

/* example multiple join

*/

SELECT movies.title
  FROM movies
  JOIN ratings ON movies.id = ratings.movie_id
  WHERE movies.id
     IN (SELECT movie_id FROM stars WHERE person_id = (SELECT id FROM people WHERE name = "Chadwick Boseman"))
  ORDER BY ratings.rating DESC
  LIMIT 5;