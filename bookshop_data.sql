USE Bookshop;
CREATE TABLE books(
	book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    author_fname VARCHAR(100),
    author_lname VARCHAR(100),
    released_year INT,
    stock_quantity INT,
    pages INT
    );
    
INSERT INTO books (title, author_fname, author_lname, released_year, stock_quantity, pages)
VALUES
('The Namesake', 'Jhumpa', 'Lahiri', 2003, 32, 291),
('Norse Mythology', 'Neil', 'Gaiman',2016, 43, 304),
('American Gods', 'Neil', 'Gaiman', 2001, 12, 465),
('Interpreter of Maladies', 'Jhumpa', 'Lahiri', 1996, 97, 198),
('A Hologram for the King: A Novel', 'Dave', 'Eggers', 2012, 154, 352),
('The Circle', 'Dave', 'Eggers', 2013, 26, 504),
('The Amazing Adventures of Kavalier & Clay', 'Michael', 'Chabon', 2000, 68, 634),
('Just Kids', 'Patti', 'Smith', 2010, 55, 304),
('A Heartbreaking Work of Staggering Genius', 'Dave', 'Eggers', 2001, 104, 437),
('Coraline', 'Neil', 'Gaiman', 2003, 100, 208),
('What We Talk About When We Talk About Love: Stories', 'Raymond', 'Carver', 1981, 23, 176),
("Where I'm Calling From: Selected Stories", 'Raymond', 'Carver', 1989, 12, 526),
('White Noise', 'Don', 'DeLillo', 1985, 49, 320),
('Cannery Row', 'John', 'Steinbeck', 1945, 95, 181),
('Oblivion: Stories', 'David', 'Foster Wallace', 2004, 172, 329),
('Consider the Lobster', 'David', 'Foster Wallace', 2005, 92, 343);

DESC books;

-- concatenation 
SELECT CONCAT(author_fname, ' ', author_lname) AS author_full_name FROM books;
-- concatenation with seperator 
SELECT CONCAT_WS('-', author_fname, author_lname) AS author_name FROM books;

-- substring
SELECT title FROM books;
SELECT SUBSTR(title, 1, 15) FROM books;
SELECT SUBSTR(author_lname, 1, 1) AS Initial FROM books; 

SELECT CONCAT(SUBSTR(title, 1, 10), '...') AS short_title FROM books;
SELECT 
    CONCAT(SUBSTR(author_fname, 1, 1),
            '.',
            SUBSTR(author_lname, 1, 1),
            '.') AS author_shorten
FROM
    books;
    
SELECT REPLACE(title, ' ', '-') FROM books;    

SELECT 
    CHAR_LENGTH(title)
FROM
    books;

SELECT 
    UPPER(CONCAT('I ', 'love ', title, ' !!'))
FROM
    books; 

-- exercise
select upper(reverse("why does my cat look at me such hatred?"));
select replace(title, " ", "->") from books;
select author_lname as forwards, reverse(author_lname) as backwards from books;
select upper(concat(author_fname, ' ', author_lname)) as full_name_in_caps from books;
select concat(title, ' was released in ', released_year) as blurb from books;
select title, char_length(title) as character_count from books;
SELECT 
    CONCAT(SUBSTRING(title, 1, 10), '...') AS short_title,
    CONCAT(author_fname, ',', author_lname) AS author,
    CONCAT(stock_quantity, ' in stock') AS quantity
FROM
    books
WHERE
    LEFT(title, 1) = 'A'
        AND stock_quantity != 154; 

