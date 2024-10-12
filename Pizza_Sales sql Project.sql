create database pizzahut;
drop database pizza;
select* from pizzahut.pizzas;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

select * from orders;

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id int not null,
quantity int not null,
primary key(order_details_id));

alter table order_details modify pizza_id text;
describe order_details;
select pizza_id from order_details;

select * from order_details;

show databases;
use pizzahut;

select * from pizzas;
select * from order_details;
select * from orders;

-- Retrieve the total number of orders placed.

select * from orders;
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;	

-- Calculate the total revenue generated from pizza sales.

select * from pizzas;
select* from order_details;

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
select * from pizzas;

select * from pizza_types;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
select * from pizza_types;
select * from order_details;
select * from pizzas;


SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Identify the most common pizza size ordered.
select * from order_details;
select * from pizzas;

SELECT 
    pizzas.size, SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY quantity DESC
LIMIT 1;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, sum(order_details.quantity) as Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    group by pizza_types.category
    order by Total_Quantity desc;
    
-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS total_order
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC; 



SELECT 
    pizza_types.name,
    HOUR(orders.order_time),
    SUM(order_details.quantity) AS quantity, count(orders.order_id)
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY pizza_types.name,HOUR(orders.order_time)
ORDER BY quantity DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category, COUNT(category) as Total_pizzas
FROM
    pizza_types
GROUP BY category
ORDER BY COUNT(category) DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Total_quantity), 0) AS Avg_pizzas_order
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM((pizzas.price) * (order_details.quantity)) as Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name order by Revenue desc limit 3;


-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category AS Category,
    ROUND(SUM((order_details.quantity) * (pizzas.price)) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sale
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            0) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;


-- Analyze the cumulative revenue generated over time.



select order_date,
sum(Revenue) over(order by order_date) as cum_revenue from
(SELECT 
    orders.order_date,
    round(sum(pizzas.price * order_details.quantity),0) AS Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,category,Revenue from
(select name,category,Revenue,
rank() over(partition by category order by Revenue desc) as rn from
(SELECT 
    pizza_types.name AS name,
    pizza_types.category AS category,
    SUM(pizzas.price * order_details.quantity) AS Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name , category) as a) as b
where rn<=3;
















































