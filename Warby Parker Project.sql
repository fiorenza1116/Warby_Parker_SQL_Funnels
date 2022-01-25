-- Warby Parker Project 
--	Objective: Analyze different Warby Parker's marketing funnels in order to calculate conversion rates


-- Part 1
--	Users will "give up" at different points in the survey. Analyze how many users move from Question 1 to Question 2, etc. What is the number of responses for each question?

SELECT question, COUNT(DISTINCT user_id) AS 'num_responses'
FROM survey
GROUP BY question
ORDER BY question;



--Part 2
-- Warby Parker's purchase funnel is: Take the Style Quiz -> Home Try On -> Purchase the perfect pair of glasses
-- Combine all three tables, starting with the top of the funnel (quiz) and ending with the bottom of the funnel (purchase). Select only the first 10 rows
-- Each Row of the Table will represent a single user from the browse table:
--		- If the user has any entries in home_try_on, then is_home_try_on will be TRUE
--		- Number_of_pairs comes from home_try_on table
--		- If the user has any entries in purchase, then is_purchase will be TRUE


SELECT DISTINCT TOP 10 q.user_id,
	CASE 
		WHEN h.user_id IS NOT NULL
		THEN 1
		ELSE 0
	END AS is_home_try_on,
	h.number_of_pairs,
	CASE 
		WHEN p.user_id IS NOT NULL 
		THEN 1
		ELSE 0
	END AS is_purchase
FROM quiz q
LEFT JOIN home_try_on h
 ON q.user_id = h.user_id
LEFT JOIN purchase p
 ON p.user_id = q.user_id;



--Part 3
-- Using the table created in Part 2, calculate the number of users that completed each step of the funnel.


WITH funnel
AS(
	SELECT DISTINCT q.user_id,
		CASE 
			WHEN h.user_id IS NOT NULL
			THEN 1
			ELSE 0
		END AS is_home_try_on,
		h.number_of_pairs,
		CASE 
			WHEN p.user_id IS NOT NULL 
			THEN 1
			ELSE 0
		END AS is_purchase
	FROM quiz q
	LEFT JOIN home_try_on h
	 ON q.user_id = h.user_id
	LEFT JOIN purchase p
	 ON p.user_id = q.user_id)

SELECT DISTINCT COUNT(user_id) users_quiz,
 SUM(is_home_try_on) users_home_try_on,
 SUM(is_purchase) users_purchase
FROM funnel;



--Part 4:
-- Using the table created in Part 2, compare the conversion rates from quiz -> home_try_on and home_try_on -> purchase


WITH funnel
AS(
	SELECT DISTINCT q.user_id,
		CASE 
			WHEN h.user_id IS NOT NULL
			THEN 1
			ELSE 0
		END AS is_home_try_on,
		h.number_of_pairs,
		CASE 
			WHEN p.user_id IS NOT NULL 
			THEN 1
			ELSE 0
		END AS is_purchase
	FROM quiz q
	LEFT JOIN home_try_on h
	 ON q.user_id = h.user_id
	LEFT JOIN purchase p
	 ON p.user_id = q.user_id)

SELECT 1.0 * SUM(is_home_try_on)/ COUNT(*) quiz_to_home_try_on,
 1.0 * SUM(is_purchase) / SUM(is_home_try_on) home_try_on_to_purchase
FROM funnel;



--Part 5 
-- Using the table created in Part 2, compare the conversion rates from quiz -> home_try_on and home_try_on -> purchase for each A/B test group


WITH funnel
AS(
	SELECT DISTINCT q.user_id,
		CASE 
			WHEN h.user_id IS NOT NULL
			THEN 1
			ELSE 0
		END AS is_home_try_on,
		h.number_of_pairs,
		CASE 
			WHEN p.user_id IS NOT NULL 
			THEN 1
			ELSE 0
		END AS is_purchase
	FROM quiz q
	LEFT JOIN home_try_on h
	 ON q.user_id = h.user_id
	LEFT JOIN purchase p
	 ON p.user_id = q.user_id)

SELECT number_of_pairs,
 1.0 * SUM(is_purchase) / SUM(is_home_try_on) purchase_rate
FROM funnel
WHERE number_of_pairs = '3 pairs' OR number_of_pairs = '5 pairs'
GROUP BY number_of_pairs;



--Part 6
-- What are the most common results of the style quiz?


WITH 
style_results AS(
	SELECT TOP 1 style
	FROM quiz
	GROUP BY style
	ORDER BY COUNT(*) DESC),
fit_results AS(
	SELECT TOP 1 fit
	FROM quiz
	GROUP BY fit
	ORDER BY COUNT(*) DESC),
shape_results AS(
	SELECT TOP 1 shape
	FROM quiz
	GROUP BY shape
	ORDER BY COUNT(*) DESC),
color_results AS(
	SELECT TOP 1 color
	FROM quiz
	GROUP BY color
	ORDER BY COUNT(*) DESC)

SELECT style, 
	fit, 
	shape, 
	color
FROM style_results, fit_results, shape_results, color_results;



--Part 7
-- What is the most common purchase made?


SELECT DISTINCT product_id,
 style,
 model_name,
 color,
 price
FROM purchase
WHERE product_id IN
	(SELECT TOP 1 product_id
	FROM purchase
	GROUP BY product_id
	ORDER BY COUNT(*) DESC);
