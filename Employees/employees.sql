create table employees(
	id int PRIMARY KEY AUTO_INCREMENT,
    department VARCHAR(20),
    salary int
);

INSERT INTO employees (department, salary) VALUES
('engineering', 80000),
('engineering', 69000),
('engineering', 70000),
('engineering', 103000),
('engineering', 67000),
('engineering', 89000),
('engineering', 91000),
('sales', 59000),
('sales', 70000),
('sales', 159000),
('sales', 72000),
('sales', 60000),
('sales', 61000),
('sales', 61000),
('customer service', 38000),
('customer service', 45000),
('customer service', 61000),
('customer service', 40000),
('customer service', 31000),
('customer service', 56000),
('customer service', 55000);

select department, round(avg(salary),2) from employees
group by department;

select department, salary, avg(salary) over() from employees;

select id, department, salary, round(avg(salary) over(partition by department), 2) as avg_per_dept, round(avg(salary) over(), 2) as comapny_avg from employees;

select id, department, count(*) over(partition by department) from employees;

-- partition by
select author_lname, count(*) from books group by author_lname;

select author_lname, count(*) over() from books;

SELECT author_lname, COUNT(*) over(partition by author_lname) FROM books;

-- order by
select id, department, salary, sum(salary) over(partition by department) from employees;

select id, department, salary, sum(salary) over(partition by department order by salary), sum(salary) over(partition by department) from employees;

select id, department, salary, min(salary) over(partition by department order by salary desc) from employees;

-- rank
select id, department, salary, rank() over(partition by department order by salary desc), rank() over(order by salary desc) from employees;

select id, department, salary, rank() over(partition by department order by salary desc), rank() over(order by salary desc) from employees
order by department;

-- row number
select id, department, salary, row_number() over(partition by department order by salary desc), rank() over(partition by department order by salary desc), rank() over(order by salary desc) from employees;

-- ntile
select id, department, salary, ntile(4) over(order by salary desc) from employees;

select id, department, salary, ntile(4) over(partition by department order by salary desc) from employees
order by department;

-- first value
select id, department, salary, first_value(id) over(partition by department order by salary desc) as highest_paid_in_dept from employees;

-- lead and lag
select id, department, salary, salary - lag(salary) over(order by salary desc) as sal_diff from employees;

select id, department, salary, salary - lag(salary) over(partition by department order by salary desc) as diff from employees;
