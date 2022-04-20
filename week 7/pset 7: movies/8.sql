SElECT name
  FROM people
 WHERE id
    /* Pull list of stars using the ID we get from the title sub-query*/
    IN (SELECT person_id
          FROM stars
        /* Pull id of movie using title */
         WHERE movie_id = (SElECT id
                             FROM movies
                            WHERE title = "Toy Story"));