--select  * from [Project 2 SQL Data Cleaning].dbo.data1

----------------------------------------------------------------------------------------------------

select SaleDate,CONVERT(date,SaleDate),DateFormatted from data1

---- add a new column "DateFormatted" of data type "Date"
---- update column "DateFormatted" to CONVERT(date,SaleDate)
----- then delete the original date column

--alter table data1
--add DateFormatted Date

--update data1
--set DateFormatted = CONVERT(date,SaleDate)

select SaleDate,DateFormatted from data1

----------------------------------------------------------------------------------------------------
---- Populating empty property addresses:

---- some property addresses are empty (showing NULL) :
select PropertyAddress from data1
where PropertyAddress is null


---- each parcelID has a unique Property address corresponding to it.
---- hence where ever [PropertyAddress] is null, we can repopulate it by 
---- searching another order with the same parcelID and then coping the addresses corresponding to that
---- since same parcelIDs have same address.

---- a 'self' join as performed below for the same:
----ISNULL(a.PropertyAddress,b.PropertyAddress) >> "if a.PropertyAddress is null, replace it by value in b.PropertyAddress"

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from data1 a INNER JOIN data1 b
ON a.ParcelID  = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is null


---- Updating:
--UPDATE a 
--Set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
--FROM data1 a INNER JOIN data1 b
--ON a.ParcelID  = b.ParcelID
--AND a.[UniqueID ] <> b.[UniqueID ] 
--WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------
----seperating Property Address wrt the delimiter : ','

select 
PropertyAddress,
----address to the LEFT of delimter (',') :
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress ,1)- 1 ),
----address to the RIGHT of delimter (',') :
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress ,1) +1 ,LEN(PropertyAddress))

from data1

---- adding columns for the above:
--ALTER TABLE data1
--ADD PropertyAddressAdd nvarchar(255)

--UPDATE data1
--SET PropertyAddressAdd = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress ,1)- 1 )

--ALTER TABLE data1
--ADD PropertyAddressCity nvarchar(255)

--UPDATE data1
--SET PropertyAddressCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress ,1) +1 ,LEN(PropertyAddress))

SELECT PropertyAddressCity,PropertyAddressAdd from data1


----------------------------------------------------------------------------------------------------
----seperating Property Address wrt the delimiter : ','

select OwnerAddress from data1 

----parsename only works with the delimiter '.' thus replacing ',' by '.' using REPLACE() :
select 
PARSENAME(Replace(OwnerAddress,',','.'),3) as [Local Address],
PARSENAME(Replace(OwnerAddress,',','.'),2) as [City],
PARSENAME(Replace(OwnerAddress,',','.'),1) as [State]
from data1 


---- adding columns for the above:
ALTER TABLE data1
ADD OwnerSplitLocalAddress nvarchar(255)
UPDATE data1
SET OwnerSplitLocalAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE data1
ADD OwnerSplitCity nvarchar(255)
UPDATE data1
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE data1
ADD OwnerSplitState nvarchar(255)
UPDATE data1
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select * from data1

----------------------------------------------------------------------------------------------------
----Replacing 'Y' and 'N' to 'Yes' and 'No'

select Distinct(SoldAsVacant),COUNT(SoldAsVacant) 
from data1
GROUP BY SoldAsVacant
order by 2

select SoldAsVacant, 
CASE 
	WHEN SoldAsVacant ='Y' then 'Yes'
	WHEN SoldAsVacant ='N' then 'No'
	ELSE SoldAsVacant
	END
from data1
 
 

 ----UPDATING TABLE:

 --UPDATE data1
 --SET SoldAsVacant = CASE 
	--WHEN SoldAsVacant ='Y' then 'Yes'
	--WHEN SoldAsVacant ='N' then 'No'
	--ELSE SoldAsVacant
	--END


----------------------------------------------------------------------------------------------------
---- deleting duplicate data
---- SELECT *,ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SaleDate,LegalReference ORDER BY UniqueID) 
----- the above function first partitions by the given columns then within each partiton the windows function is applied to each row due to the order by funciton
----- rows with SAME ParcelID,PropertyAddress,SaleDate,LegalReference will be in same partion can have row numbers 1,2,3....so on
----- thus if a partiion has more than >1 rows, that means that data of rows 2,3,4.... is duplicate of row 1


with cte_rowNum as (
SELECT *,ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SaleDate,LegalReference ORDER BY UniqueID) r
FROM data1
)
SELECT * from cte_rowNum
--DELETE from cte_rowNum
where r>1


----------------------------------------------------------------------------------------------------
----deleting unwanted columns

SELECT * FROM data1

ALTER TABLE data1
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress