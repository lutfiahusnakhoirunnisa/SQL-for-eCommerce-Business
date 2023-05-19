-- Membuat tabel yang berisi informasi pendapatan/revenue (Price + Freight_value) perusahaan total untuk masing-masing tahun 
CREATE TABLE REVENUE_BY_YEAR AS (SELECT DATE_PART('YEAR', ORDER_PURCHASE_TIMESTAMP) ACTIVE_YEAR, SUM(I.PRICE + I.FREIGHT_VALUE) REVENUE
	FROM ORDERS_DATASET O JOIN ORDER_ITEMS_DATASET I ON O.ORDER_ID = I.ORDER_ID
	WHERE O.ORDER_STATUS = 'delivered' GROUP BY ACTIVE_YEAR);
	
-- Membuat tabel yang berisi informasi jumlah cancel order total untuk masing-masing tahun 
CREATE TABLE CALCELED_ORDER AS (SELECT DATE_PART('YEAR', ORDER_PURCHASE_TIMESTAMP) ACTIVE_YEAR, COUNT(O.ORDER_ID)
	FROM ORDERS_DATASET O JOIN ORDER_ITEMS_DATASET I ON O.ORDER_ID = I.ORDER_ID
	WHERE O.ORDER_STATUS = 'canceled' GROUP BY ACTIVE_YEAR);
	
-- Membuat tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi untuk masing-masing tahun
CREATE TABLE TOP_CAT_PRODUCT AS (WITH AGG AS (SELECT DATE_PART('YEAR', O.ORDER_PURCHASE_TIMESTAMP) ACTIVE_YEAR, P.PRODUCT_CATEGORY_NAME, 
	SUM(I.PRICE + I.FREIGHT_VALUE) TOTAL_REVENUE, ROW_NUMBER() OVER(PARTITION BY DATE_PART('YEAR', O.ORDER_PURCHASE_TIMESTAMP) ORDER BY SUM(I.PRICE + I.FREIGHT_VALUE) DESC) AS PROD_NUM
	FROM ORDERS_DATASET O 
	JOIN ORDER_ITEMS_DATASET I ON O.ORDER_ID = I.ORDER_ID 
	JOIN PRODUCT_DATASET P ON I.PRODUCT_ID = P.PRODUCT_ID
	WHERE O.ORDER_STATUS = 'delivered' GROUP BY 1,2)
SELECT ACTIVE_YEAR, PRODUCT_CATEGORY_NAME, TOTAL_REVENUE 
FROM AGG WHERE PROD_NUM = 1);

-- Membuat tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak untuk masing-masing tahun
CREATE TABLE TOP_CANCELED_PRODUCT AS (WITH AGG AS (SELECT DATE_PART('YEAR', O.ORDER_PURCHASE_TIMESTAMP) ACTIVE_YEAR, P.PRODUCT_CATEGORY_NAME, 
	COUNT(DISTINCT O.ORDER_ID) TOTAL_ORDER, ROW_NUMBER() OVER(PARTITION BY DATE_PART('YEAR', O.ORDER_PURCHASE_TIMESTAMP) ORDER BY COUNT(DISTINCT O.ORDER_ID) DESC) AS PROD_NUM
	FROM ORDERS_DATASET O 
	JOIN ORDER_ITEMS_DATASET I ON O.ORDER_ID = I.ORDER_ID 
	JOIN PRODUCT_DATASET P ON I.PRODUCT_ID = P.PRODUCT_ID
	WHERE O.ORDER_STATUS = 'canceled' GROUP BY 1,2)
SELECT ACTIVE_YEAR, PRODUCT_CATEGORY_NAME, TOTAL_ORDER 
FROM AGG WHERE PROD_NUM = 1);

-- Menggabungkan informasi-informasi yang telah didapatkan ke dalam satu tampilan tabel
SELECT A.ACTIVE_YEAR, A.REVENUE TOTAL_REVENUE, B.COUNT TOTAL_CANCELED_ORDER,
	C.PRODUCT_CATEGORY_NAME TOP_PRODUCT_CATEGORY, D.PRODUCT_CATEGORY_NAME TOP_CANCELED_PRODUCT
	FROM REVENUE_BY_YEAR A JOIN CALCELED_ORDER B ON A.ACTIVE_YEAR = B.ACTIVE_YEAR
	JOIN TOP_CAT_PRODUCT C ON A.ACTIVE_YEAR = C.ACTIVE_YEAR
	JOIN TOP_CANCELED_PRODUCT D ON A.ACTIVE_YEAR = D.ACTIVE_YEAR;