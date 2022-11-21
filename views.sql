
-- Creating Views 
CREATE VIEW full_reviews AS
SELECT title, released_year, genre, rating, first_name, last_name FROM reviews
JOIN series ON series.series_id = reviews.series_id
JOIN reviewers ON reviewers.reviewer_id = reviews.reviewer_id;

-- Updatable Views
CREATE VIEW ordered_series AS
SELECT * FROM series ORDER BY released_year;
 
CREATE OR REPLACE VIEW ordered_series AS
SELECT * FROM series ORDER BY released_year DESC;
 
ALTER VIEW ordered_series AS
SELECT * FROM series ORDER BY released_year;
 
DROP VIEW ordered_series;

-- Using HAVING clause
select title, avg(rating), count(rating) from full_reviews
group by title
having count(rating) > 1;

-- Group by with rollup
select title, avg(rating) from full_reviews
group by title with rollup;

select title, count(rating) from full_reviews
group by title with rollup;

select released_year, avg(rating) from full_reviews
group by released_year with rollup
order by released_year;

select released_year, genre, avg(rating) from full_reviews
group by released_year, genre with rollup;