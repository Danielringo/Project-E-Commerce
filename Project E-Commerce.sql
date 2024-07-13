

select * from orders;
/*
manghilangkan nilai null di tabel orders

delete from orders 
where delivery_at = 'NA';
*/

/*
mengubah tanggal di tabel orders
update orders 
set created_at = STR_TO_DATE(created_at, '%d/%m/%Y');


update orders 
set delivery_at = STR_TO_DATE(delivery_at, '%d/%m/%Y');
*/
ALTER TABLE orders
MODIFY delivery_at DATE;
DESC order_details;
DESC orders;
DESC products;
DESC users;
-- 10 Transaksi terbesar user 12476
select 
	seller_id,
	buyer_id,
	total as nilai_transaksi,
	CAST(created_at as DATE) as Tanggal
from orders o 
where buyer_id = 12476
order by 3 desc
limit 10;



-- Transaksi per Bulan
select 
	DATE_FORMAT(created_at, '%Y-%m') as tahun_bulan,
	COUNT(1) as jumlah_transaksi,
	SUM(total) as total_nilai_transaksi
from orders 
where created_at >= '2020-01-01'
group by 1
order by 1;

-- Mencari Total Maximum Pembeli
SELECT * FROM orders
where total = (SELECT MAX(total) as max_total FROM orders);


-- pengguna dengan rata-rata transaksi terbesar di januari 2020
select 
	buyer_id,
	COUNT(1) as jumlah_transaksi,
	AVG(total) as avg_nilai_transaksi
from orders 
where EXTRACT(year from created_at) = 2020
	and EXTRACT(month from created_at) = 01
group by 1
having COUNT(1) >= 2
order by 3 desc 
limit 10;


-- Transaksi besar di bulan Desember 2019
select 	
	users.nama_user as nama_pembeli,
	total as nilai_transaksi,
	created_at as tanggal_transaksi
from orders 
inner join users on buyer_id = user_id
where EXTRACT(year from created_at) = 2019
	and EXTRACT(month from created_at) = 12
	and total >= 2000000
order by 2 desc;


-- Kategori Produk Terlaris di Tahun 2020
select 	
	category,
	SUM(quantity) as total_quantity,
	SUM(price) as total_price
from orders 
inner join order_details od USING(order_id)
inner join products p USING(product_id)
where EXTRACT(year from created_at) = 2020
	and delivery_at is not null
group by 1
order by 2 desc 
limit 5;


-- Mencari Pembeli High Value
select 
	nama_user as nama_pembeli, 
    count(1) as jumlah_transaksi, 
    sum(total) as total_nilai_transaksi, 
    min(total) as min_nilai_transaksi
from orders
inner join users on buyer_id = user_id
group by user_id, nama_user
having count(1) > 5 and min(total)>2000000
order by 3 desc;


-- Mencari Dropshipper
SELECT 
	u.nama_user as nama_pembeli, 
	COUNT(1) as jumlah_transaksi, 
	COUNT(DISTINCT o.kodepos) as distinct_kodepos, 
	SUM(total) as total_nilai_transaksi, 
	AVG(total) as AVG_nilai_transaksi
FROM orders o
INNER JOIN users u ON buyer_id = user_id	
GROUP BY u.nama_user
HAVING COUNT(1) >= 10 and COUNT(1) = COUNT(DISTINCT o.kodepos)
ORDER BY 4 desc;

-- Mencari Reseller Offline
select 	
	nama_user as nama_pembeli,
	COUNT(1) as jumlah_transaksi,
	SUM(total) as total_nilai_transaksi,
	AVG(total) as avg_nilai_transaksi,
	AVG(total_quantity) as avg_quantity_per_transaksi
from orders 
inner join users on buyer_id = user_id
inner join (select order_id , SUM(quantity) as total_quantity
			from order_details 
			group by 1) as summary_order 
	 USING(order_id)
where orders.kodepos = users.kodepos 
group by nama_user
having COUNT(1) = 8 and AVG(total_quantity) > 10
order by 3 desc;


-- Pembeli Sekaligus Penjual
select 	
	nama_user as nama_pembeli,
	buyer.jumlah_transaksi_beli,
	seller.jumlah_transaksi_jual
from users 
inner join( select buyer_id, COUNT(1) as jumlah_transaksi_beli
	from orders group by 1) as buyer on buyer_id = user_id 
inner join (select seller_id, COUNT(1) as jumlah_transaksi_jual
	from orders group by 1) as seller on seller_id = user_id 
where jumlah_transaksi_beli >= 7
order by 1 asc;

-- Lama Transaksi Di Bayar
select 
	DATE_FORMAT(created_at, '%Y-%m') as tahun_bulan,
	COUNT(order_id) as jumlah_transaksi,
	AVG(DATEDIFF(paid_at, created_at)) as lama_dibayar,
	CONCAT(MIN(DATEDIFF(paid_at, created_at)), ' Hari') as min_lama_dibayar,
	CONCAT(MAX(DATEDIFF(paid_at, created_at)), ' Hari') as max_lama_dibayar
from orders 
group by 1
order by 1;

