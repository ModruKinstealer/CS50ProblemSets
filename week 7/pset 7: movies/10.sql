SELECT distinct(name)
  FROM people
 WHERE id
    IN (SELECT directors.person_id
          FROM directors
          JOIN ratings
            ON directors.movie_id = ratings.movie_id
        WHERE ratings.rating >= 9.0);
