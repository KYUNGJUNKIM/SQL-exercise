-- alter table tweets add column created_at timestamp default now(); 
-- INSERT INTO tweets(content, username) 
-- VALUES('this is my first tweet', 'coltscat'), 
-- 	  ('this is my second tweet', 'coltscats');
-- SELECT * FROM tweets;
-- alter table tweets drop primary key;
-- alter table tweets add column updated_at timestamp on update now();
-- update tweets set content='Welcome to my private blog' where content='this is my second tweet';

create table customers(
	customer_id int PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email varchar(50)
);

create table orders(
	order_id int PRIMARY KEY AUTO_INCREMENT,
    customer_id int,
    order_date date,
    amount decimal(8,2),
    foreign key(customer_id) references customers(customer_id) on delete cascade
);

INSERT INTO customers(first_name, last_name, email)
values ('Boy', 'George', 'george@gmail.com'),
	   ('George', 'Michael', 'gm@gmail.com'),
       ('David', 'Bowie', 'david@gamil.com'),
       ('Blue', 'Steele', 'blue@gmail.com'),
       ('Bette', 'Davis', 'bette@gamil.com');

INSERT INTO orders(customer_id, amount, order_date)
values (1, 99.99, '2016-02-10'),
	   (1, 35.50, '2017-11-11'),
       (2, 800.67, '2014-12-12'),
       (2, 12.50, '2015-01-03'),
       (5, 450.25, '1994-04-11');

select sum(amount) as total, first_name, last_name from orders
join customers
on orders.customer_id = customers.customer_id
group by first_name, last_name
order by sum(amount) desc;

SELECT 
    first_name, 
    last_name, 
    IFNULL(SUM(amount), 0) AS money_spent
FROM
    customers
        LEFT JOIN
    orders ON customers.customer_id = orders.customer_id
GROUP BY first_name , last_name;

create table students(
	student_id int PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50)
);

create table papers(
	title varchar(100),
    grade int,
    student_id int,
    foreign key(student_id) references students(student_id) on delete cascade
);

INSERT INTO students (first_name) VALUES 
('Caleb'), ('Samantha'), ('Raj'), ('Carlos'), ('Lisa');
 
INSERT INTO papers (student_id, title, grade ) VALUES
(1, 'My First Book Report', 60),
(1, 'My Second Book Report', 75),
(2, 'Russian Lit Through The Ages', 94),
(2, 'De Montaigne and The Art of The Essay', 98),
(4, 'Borges and Magical Realism', 89);

select first_name, title, grade from students
join papers
on students.student_id = papers.student_id
order by first_name desc, grade desc;

select first_name, ifnull(title, 'missing'), ifnull(grade, 0) from students
left join papers
on students.student_id = papers.student_id;	

select first_name, ifnull(avg(grade), 0) as average from students
left join papers
on students.student_id = papers.student_id
group by first_name
order by avg(grade) desc;

select first_name, ifnull(avg(grade), 0) as average,
case
	when ifnull(avg(grade), 0) >= 75 then 'PASSING'
    else 'FAILING'
end as passing_status
from students
left join papers
on students.student_id = papers.student_id
group by first_name
order by avg(grade) desc;

