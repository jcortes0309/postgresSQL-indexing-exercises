-- OPTIMIZE LOOKUP TIME
-- 1. Write a query to find the restaurant with the name 'Nienow, Kiehn and DuBuque'. Run the query and record the query run time.
select
	name as "Restaurant Name"
from
	restaurant
where
	name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 615ms


-- 2. Re-run query with explain, and record the explain plan
explain select
	name as "Restaurant Name"
from
	restaurant
where
	name = 'Nienow, Kiehn and DuBuque'
;
-- QUERY PLAN
-- Seq Scan on restaurant  (cost=0.00..57655.25 rows=46 width=19)
--  Filter: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

-- 3. Create an index for the restaurant's name column. This may take a few minutes to run.
create index on restaurant (name);
-- indexing time = 63.8s

-- 4. Re-run the query (in #1). Is performance improved? Record the new run time
select
	name as "Restaurant Name"
from
	restaurant
where
	name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 1ms

-- 5. Re-run query with explain. Record the query plan. Compare the query plan before vs after the index. You should no longer see "Seq Scan" in the query plan.
explain select
	name as "Restaurant Name"
from
	restaurant
where
	name = 'Nienow, Kiehn and DuBuque'
;
-- QUERY PLAN
-- Bitmap Heap Scan on restaurant  (cost=4.79..182.77 rows=46 width=19)
--   Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--   ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.77 rows=46 width=0)
--        Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)


-- OPTIMIZE SORT TIME
-- 1. Write a query to find the top 10 reviewers based on karma. Run it and record the query run time.
select
	name as "Reviewer Name",
	karma as "Karma"
from
	reviewer
order by
	karma DESC
limit
 	10
;
-- query time = 1.2ms

-- 2. Re-run query with explain, and record the explain plan
explain select
	name as "Reviewer Name",
	karma as "Karma"
from
	reviewer
order by
	karma DESC
limit
 	10
;
-- QUERY PLAN
-- Limit  (cost=114942.08..114942.11 rows=10 width=19)
--   ->  Sort  (cost=114942.08..122442.33 rows=3000100 width=19)
--         Sort Key: karma DESC
--         ->  Seq Scan on reviewer  (cost=0.00..50111.00 rows=3000100 width=19)

-- 3. Create an index on a column (which column? -- karma) to make the above query faster.
create index on reviewer (karma);
-- indexing time = 5.4s

-- 4. Re-run the query in step 1. Is performance improved? Record the new runtime.
select
	name as "Reviewer Name",
	karma as "Karma"
from
	reviewer
order by
	karma DESC
limit
 	10
;
-- query time = 1ms

-- 5. Re-run query with explain. Record the query plan. Compare the query plan before vs after the index. You should no longer see "Seq Scan" in the query plan.
explain select
	name as "Reviewer Name",
	karma as "Karma"
from
	reviewer
order by
	karma DESC
limit
 	10
;
-- QUERY PLAN
-- Limit  (cost=0.43..0.95 rows=10 width=19)
--   ->  Index Scan Backward using reviewer_karma_idx on reviewer  (cost=0.43..157165.44 rows=3000100 width=19)

-- OPTIMIZE JOIN TIME
-- 1. Write a query to list the restaurant reviews for 'Nienow, Kiehn and DuBuque'. Run and record the query run time.
select
	restaurant.name as "Restaurant Name",
	review.title "Review Title",
	review.content as "Review Content",
	review.stars as "Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 2.4s

-- Version 2
select
	restaurant.name as "Restaurant Name",
	review.title "Review Title",
	review.content as "Review Content",
	review.stars as "Review Stars"
from
	restaurant
inner join
	review
	on
	restaurant.id = review.restaurant_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;

-- 2. Re-run query with explain, and record the explain plan.
explain select
	restaurant.name as "Restaurant Name",
	review.title "Review Title",
	review.content as "Review Content",
	review.stars as "Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;
-- QUERY PLAN
-- Hash Join  (cost=183.34..287059.56 rows=92 width=249)
--   Hash Cond: (review.restaurant_id = restaurant.id)
--   ->  Seq Scan on review  (cost=0.00..264374.40 rows=6000240 width=234)
--   ->  Hash  (cost=182.77..182.77 rows=46 width=23)
--         ->  Bitmap Heap Scan on restaurant  (cost=4.79..182.77 rows=46 width=23)
--               Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--               ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.77 rows=46 width=0)
--                     Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

-- 3. Write a query to find the average star rating for 'Nienow, Kiehn and DuBuque'. Run and record the query run time.
-- Version 1
select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;
-- query time = 2.3s

-- Version 2
select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant
inner join
	review
	on restaurant.id = review.restaurant_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;

-- 4. Re-run query with explain, and save the explain plan.
explain select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;
-- QUERY PLAN
-- GroupAggregate  (cost=183.34..287060.60 rows=46 width=51)
--   Group Key: restaurant.name
--   ->  Hash Join  (cost=183.34..287059.56 rows=92 width=23)
--         Hash Cond: (review.restaurant_id = restaurant.id)
--         ->  Seq Scan on review  (cost=0.00..264374.40 rows=6000240 width=8)
--         ->  Hash  (cost=182.77..182.77 rows=46 width=23)
--               ->  Bitmap Heap Scan on restaurant  (cost=4.79..182.77 rows=46 width=23)
--                     Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--                     ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.77 rows=46 width=0)
--                           Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)

-- 5. Create an index for the foreign key used in the join to make the above queries faster.
create index on review (restaurant_id);
-- indexing time = 10s

-- 6. Re-run the query you ran in step 1. Is performance improved? Record the query run time.
-- Version 1
select
	restaurant.name as "Restaurant Name",
	review.title "Review Title",
	review.content as "Review Content",
	review.stars as "Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 2ms

-- Version 2
select
	restaurant.name as "Restaurant Name",
	review.title "Review Title",
	review.content as "Review Content",
	review.stars as "Review Stars"
from
	restaurant
inner join
	review
	on
	restaurant.id = review.restaurant_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 1ms

-- 7. Re-run the query you ran in step 3. Is performance improved? Record the query run time.
-- Version 1
select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;
-- query time = 2ms
-- Version 2
select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant
inner join
	review
	on restaurant.id = review.restaurant_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;

-- 8. With explain, compare the before and after query plan of both queries.
explain select
	restaurant.name as "Restaurant Name",
	avg(review.stars) as "Avg Review Stars"
from
	restaurant,
	review
where
	restaurant.id = review.restaurant_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	restaurant.name
;
-- QUERY PLAN
-- GroupAggregate  (cost=5.22..943.49 rows=46 width=51)
--   Group Key: restaurant.name
--   ->  Nested Loop  (cost=5.22..942.46 rows=92 width=23)
--         ->  Bitmap Heap Scan on restaurant  (cost=4.79..182.77 rows=46 width=23)
--               Recheck Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--               ->  Bitmap Index Scan on restaurant_name_idx  (cost=0.00..4.77 rows=46 width=0)
--                     Index Cond: ((name)::text = 'Nienow, Kiehn and DuBuque'::text)
--         ->  Index Scan using review_restaurant_id_idx on review  (cost=0.43..16.48 rows=3 width=8)
--               Index Cond: (restaurant_id = restaurant.id)

-- BONUS: OPTIMIZE JOIN TIME 2
-- 1. Write a query to list the names of the reviewers who have reviewed 'Nienow, Kiehn and DuBuque'. Note the query run time and save the query plan.
-- Version 1
select
	restaurant.name as "Restaurant Name",
	reviewer.name "Reviewer",
	review.title as "Review Title",
	review.content "Review Content"
from
	restaurant,
	review,
	reviewer
where
	restaurant.id = review.restaurant_id and
	reviewer.id = review.reviewer_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;
-- query time = 2ms
-- Version 2
select
	restaurant.name as "Restaurant Name",
	reviewer.name "Reviewer",
	review.title as "Review Title",
	review.content "Review Content"
from
	restaurant
inner join
	review
	on
	restaurant.id = review.restaurant_id
inner join
	reviewer
	on reviewer.id = review.reviewer_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
;

-- 2. Write a query to find the average karma of the reviewers who have reviewed 'Nienow, Kiehn and DuBuque'. Note the query run time and save the query plan.
-- Version 1
select
	restaurant.name as "Restaurant Name",
	avg(reviewer.karma) as "Avg Reviewer Karma"
from
	restaurant,
	review,
	reviewer
where
	restaurant.id = review.restaurant_id and
	reviewer.id = review.reviewer_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	"Restaurant Name"
;
-- query time = 2ms
-- Version 2
select
	restaurant.name as "Restaurant Name",
	avg(reviewer.karma) as "Avg Reviewer Karma"
from
	restaurant
inner join
	review
	on restaurant.id = review.restaurant_id
inner join
	reviewer
	on reviewer.id = review.reviewer_id
where
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	"Restaurant Name"
;

-- 3. Is this slow? Does it use a "Seq Scan"? If it is, create an index to make the above queries faster.
explain select
	restaurant.name as "Restaurant Name",
	avg(reviewer.karma) as "Avg Reviewer Karma"
from
	restaurant,
	review,
	reviewer
where
	restaurant.id = review.restaurant_id and
	reviewer.id = review.reviewer_id and
	restaurant.name = 'Nienow, Kiehn and DuBuque'
group by
	"Restaurant Name"
;
-- No it's not slow.  It doesn't use a Seq Scan.  It uses the restaurant name index to run this query.
