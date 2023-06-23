show databases;
use orders;

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

select CUSTOMER_ID,
	case
    when CUSTOMER_GENDER ='F' THEN 'Ms'
    when CUSTOMER_GENDER = 'M' THEN 'Mr'
    end as TITLE,
    CONCAT(upper(CUSTOMER_FNAME)," ", upper(CUSTOMER_LNAME)) AS CUSTOMER_NAME,CUSTOMER_EMAIL, date_format(CUSTOMER_CREATION_DATE,"%Y") AS CUSTOMER_CREATION_YEAR,
    case
    when CUSTOMER_CREATION_DATE<'2005-01-01' then 'Category A'
    when CUSTOMER_CREATION_DATE>='2005-01-01' AND CUSTOMER_CREATION_DATE<'2011-01-01' then 'Category B'
    when CUSTOMER_CREATION_DATE>='2011-01-01' then 'Category C'
    end as CUSTOMER_CATEGORY
FROM online_customer;


/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/

SELECT p.PRODUCT_ID, p.PRODUCT_DESC, p.PRODUCT_QUANTITY_AVAIL, p.PRODUCT_PRICE, 
p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE as INVENTORY_VALUES,
	CASE
    when p.Product_Price > 20000 then p.Product_Price*0.20
    when p.Product_Price > 10000 then p.Product_Price*0.15
	when p.Product_Price <= 10000 then p.Product_Price*0.10
    end as NEW_PRICE
FROM PRODUCT AS p
LEFT JOIN ORDER_ITEMS AS o
ON p.PRODUCT_ID = o.PRODUCT_ID 
where o.PRODUCT_ID IS NULL
order by INVENTORY_VALUES DESC;

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

select pr.PRODUCT_CLASS_CODE, pcc.PRODUCT_CLASS_DESC, count(pcc.PRODUCT_CLASS_CODE) as PRODUCT_COUNT,
sum(pr.PRODUCT_QUANTITY_AVAIL * pr.PRODUCT_PRICE) as INVENTORY_VALUE
from product as pr
LEFT JOIN PRODUCT_CLASS as pcc ON  pr.PRODUCT_CLASS_CODE =  pcc.PRODUCT_CLASS_CODE
group by pr.PRODUCT_CLASS_CODE having INVENTORY_VALUE > 100000
order by INVENTORY_VALUE DESC;

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY */

select orh.CUSTOMER_ID, concat(upper(onc.CUSTOMER_FNAME),' ',upper(onc.CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME , onc.CUSTOMER_EMAIL, onc.CUSTOMER_PHONE,a.COUNTRY
from order_header as orh
LEFT JOIN online_customer as onc on orh.CUSTOMER_ID = onc.CUSTOMER_ID
LEFT JOIN address as a on onc.ADDRESS_ID = a.ADDRESS_ID
where orh.customer_id in  (select customer_id from order_header where order_status='Cancelled')
group by orh.CUSTOMER_ID having count(distinct orh.ORDER_STATUS) = 1;

/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

SELECT s.SHIPPER_NAME,a.CITY, count(a.CITY) AS CUSTOMER_CATERED, count(distinct oc.customer_id) AS CUSTOMERS_IN_CITY
FROM SHIPPER as s
LEFT JOIN ORDER_HEADER AS oh on s.SHIPPER_ID=oh.SHIPPER_ID
LEFT JOIN online_customer as oc on oh.CUSTOMER_ID = oc.CUSTOMER_ID
LEFT JOIN address as a on oc.ADDRESS_ID = a.ADDRESS_ID
where oh.SHIPPER_ID in (select s.SHIPPER_ID where SHIPPER_NAME='DHL')
group by a.CITY,s.SHIPPER_NAME
order by a.CITY;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

select i.*, case when i.product_class_desc = 'Electronics' or i.product_class_desc = 'Computer' then
					  case when i.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
						   when i.product_quantity_avail < i.Quantity_sold*0.10 then 'Low inventory, need to add inventory'
                           when i.Quantity_sold*0.10 >= i.product_quantity_avail < i.Quantity_sold*0.50 then 'Medium inventory, need to add some inventory'
                           when i.product_quantity_avail >= i.Quantity_sold*0.50 then 'Sufficient inventory'  end
                 when i.product_class_desc = 'Mobiles' or i.product_class_desc = 'Watches' then
					  case when i.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
                           when i.product_quantity_avail < i.Quantity_sold*0.20 then 'Low inventory, need to add inventory'
                           when i.Quantity_sold*0.20 >= i.product_quantity_avail < i.Quantity_sold*0.60 then 'Medium inventory, need to add some inventory'
                           when i.product_quantity_avail >= i.Quantity_sold*0.60 then 'Sufficient inventory' end
				 else 
					  case when i.Quantity_sold = 0 then 'No Sales in past, give discount to reduce inventory'
                           when i.product_quantity_avail < i.Quantity_sold*0.30 then 'Low inventory, need to add inventory'
                           when i.Quantity_sold*0.30 >= i.product_quantity_avail < i.Quantity_sold*0.70 then 'Medium inventory, need to add some inventory'
                           when i.product_quantity_avail >= i.Quantity_sold*0.70 then 'Sufficient inventory' end
				end as Inventory_Status
from
(select pr.product_id,pr.product_desc,pr.product_quantity_avail,pc.product_class_desc,sum(ifnull(oi.product_quantity,0)) as Quantity_Sold,
 pr.product_quantity_avail as Quantity_Available from product pr
left join order_items oi on pr.product_id = oi.product_id
join  product_class pc on pr.product_class_code = pc.product_class_code
group by pr.product_id, pr.product_desc,pr.product_quantity_avail,pc.product_class_desc ) i
order by i.product_id;



/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

select oi.ORDER_ID, sum(oi.PRODUCT_QUANTITY*p.LEN*p.WIDTH*p.HEIGHT) as PRODUCT_VOLUME
FROM ORDER_ITEMS as oi
LEFT JOIN PRODUCT as p on oi.PRODUCT_ID = p.PRODUCT_ID
group by oi.ORDER_ID having PRODUCT_VOLUME < (select (c.LEN*c.WIDTH*c.HEIGHT) as CARTON_VOLUME from CARTON as c where CARTON_ID=10)
order by PRODUCT_VOLUME desc
limit 1;

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

SELECT onc.CUSTOMER_ID,concat(upper(onc.CUSTOMER_FNAME)," ",upper(onc.CUSTOMER_LNAME)) as CUSTOMER_NAME,
sum(ori.PRODUCT_QUANTITY) as TOTAL_QUANTITY, sum(ori.PRODUCT_QUANTITY*pr.PRODUCT_PRICE) as TOTAL_PRICE
FROM ORDER_HEADER as orh
LEFT JOIN ONLINE_CUSTOMER as onc on orh.CUSTOMER_ID=onc.CUSTOMER_ID
LEFT JOIN ORDER_ITEMS as ori on orh.ORDER_ID=ori.ORDER_ID
LEFT JOIN PRODUCT as pr on ori.PRODUCT_ID=pr.PRODUCT_ID
where orh.payment_mode = 'Cash' and onc.customer_lname LIKE 'G%'
group by CUSTOMER_NAME, onc.CUSTOMER_ID; 

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */
 
select c.product_id as Product_ID,p.PRODUCT_DESC,sum(c.product_quantity) as Total_Quantity
from 
(select b.*,a.product_id as actual_product_id, b.product_id as bought_together
from order_items a
inner join order_items b
on a.order_id = b.order_id and  a.product_id != b.product_id
where a.product_id = 201) c
inner join product p on p.product_id = c.product_id
inner join order_header oh on oh.order_id = c.order_id
inner join online_customer oc on oc.customer_id = oh.customer_id
inner join address ad on ad.address_id = oc.address_id
where city not in ('Bangalore','New Delhi')
group by c.product_id
order by Total_Quantity desc;

/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */
 
select orh.ORDER_ID, onc.CUSTOMER_ID, concat(onc.customer_fname,' ',onc.customer_lname) as CUSTOMER_NAME, sum(ori.product_quantity) as TOTAL_QUANTITY
from online_customer as onc
left join order_header as orh on onc.customer_id = orh.customer_id
left join order_items as ori on orh.order_id = ori.order_id
left join address as a on onc.address_id = a.address_id
where orh.order_id % 2 = 0 and a.pincode not like '5%' and ori.product_quantity is not null
group by onc.customer_id,orh.order_id
limit 15;
 