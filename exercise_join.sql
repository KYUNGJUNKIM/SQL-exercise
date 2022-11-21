create table reviewers(
	reviewer_id int PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) not null,
    last_nae VARCHAR(50) not null
    );


create table series(
	series_id int PRIMARY KEY AUTO_INCREMENT,
    title varchar(100),
    released_year year,
    genre varchar(100)
);
    

create table reviews(
	review_id int PRIMARY KEY AUTO_INCREMENT,
    rating decimal(2,1),
    reviewer_id int,
    series_id int,
    foreign key(reviewer_id) REFERENCES reviewers(reviewer_id) on delete cascade,
    foreign key(series_id) REFERENCES series(series_id) on delete cascade
);
    
    
    
INSERT INTO series (title, released_year, genre) VALUES
    ('Archer', 2009, 'Animation'),
    ('Arrested Development', 2003, 'Comedy'),
    ("Bob's Burgers", 2011, 'Animation'),
    ('Bojack Horseman', 2014, 'Animation'),
    ("Breaking Bad", 2008, 'Drama'),
    ('Curb Your Enthusiasm', 2000, 'Comedy'),
    ("Fargo", 2014, 'Drama'),
    ('Freaks and Geeks', 1999, 'Comedy'),
    ('General Hospital', 1963, 'Drama'),
    ('Halt and Catch Fire', 2014, 'Drama'),
    ('Malcolm In The Middle', 2000, 'Comedy'),
    ('Pushing Daisies', 2007, 'Comedy'),
    ('Seinfeld', 1989, 'Comedy'),
    ('Stranger Things', 2016, 'Drama');
    
    
INSERT INTO reviewers (first_name, last_name) VALUES
    ('Thomas', 'Stoneman'),
    ('Wyatt', 'Skaggs'),
    ('Kimbra', 'Masters'),
    ('Domingo', 'Cortes'),
    ('Colt', 'Steele'),
    ('Pinkie', 'Petit'),
    ('Marlon', 'Crafford');

INSERT INTO reviews(series_id, reviewer_id, rating) VALUES
    (1,1,8.0),(1,2,7.5),(1,3,8.5),(1,4,7.7),(1,5,8.9),
    (2,1,8.1),(2,4,6.0),(2,3,8.0),(2,6,8.4),(2,5,9.9),
    (3,1,7.0),(3,6,7.5),(3,4,8.0),(3,3,7.1),(3,5,8.0),
    (4,1,7.5),(4,3,7.8),(4,4,8.3),(4,2,7.6),(4,5,8.5),
    (5,1,9.5),(5,3,9.0),(5,4,9.1),(5,2,9.3),(5,5,9.9),
    (6,2,6.5),(6,3,7.8),(6,4,8.8),(6,2,8.4),(6,5,9.1),
    (7,2,9.1),(7,5,9.7),
    (8,4,8.5),(8,2,7.8),(8,6,8.8),(8,5,9.3),
    (9,2,5.5),(9,3,6.8),(9,4,5.8),(9,6,4.3),(9,5,4.5),
    (10,5,9.9),
    (13,3,8.0),(13,4,7.2),
    (14,2,8.5),(14,3,8.9),(14,4,8.9);

-- #1
select title, rating from series
join reviews
on series.series_id = reviews.series_id
limit 15;

-- #2
select title, round(avg(rating),2) as avg_rating from series
join reviews
on series.series_id = reviews.series_id
group by title
order by avg(rating);

-- #3
select first_name, last_name, rating from reviewers
join reviews
on reviewers.reviewer_id = reviews.reviewer_id;

-- #4
select title as unreviewed_series from series
left join reviews
on series.series_id = reviews.series_id
where rating is null;

-- #5
select genre, ifnull(round(avg(rating), 3), 0) as avg_rating from series
left join reviews
on series.series_id = reviews.series_id
group by genre;

-- #6
SELECT 
    first_name,
    last_name,
    COUNT(rating) AS count,
    IFNULL(MIN(rating), 0) AS min,
    IFNULL(MAX(rating), 0) AS max,
    ROUND(IFNULL(AVG(rating), 0), 2) AS avg,
    CASE
        WHEN COUNT(rating) >= 10 THEN 'POWERUSER'
        WHEN COUNT(rating) > 0 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS STATUS
FROM
    reviews
        RIGHT JOIN
    reviewers ON reviewers.reviewer_id = reviews.reviewer_id
GROUP BY first_name , last_name;

-- #7
select title, rating, concat(first_name, ' ', last_name) as reviewer from reviews
join reviewers
ON reviewers.reviewer_id = reviews.reviewer_id
join series
on series.series_id = reviews.series_id
order by title;
