#!/bin/bash
mysql -h mysql-rw-vip.prod.example1.com -u guest -pguest -e "SELECT table_name AS 'Table',  round(((data_length + index_length) / 1024 / 1024 / 1024), 2) as Size_GB FROM information_schema.TABLES  WHERE table_schema = 'C3MetricsDb' order by Size_GB DESC limit 8"
