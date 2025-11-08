/*
Create Database and Schemas

ThiS Script creates a new databse "datawarehouse" after checking if it already exists.
If exists, it is dropped and recreated.
Three schemas are created within database:"bronze", "silver", "gold"
*/


USE master;
GO

--Drop and recreate the database 'DataWarehouse'
IF exists (select 1 from sys.database where name='DataWarehouse')
begin
   ALTER database DataWarehouse set single_user with rollback immediate;
   drop database DataWarehouse;
END;
GO
--Create Database 'DataWarehouse'

USE master;
create database DataWarehouse;
GO
  
USE DataWarehouse;
GO
--Create Schemas  
CREATE Schema Bronze;
GO
CREATE Schema Silver;
GO
CREATE Schema Gold;
GO
--Create 
