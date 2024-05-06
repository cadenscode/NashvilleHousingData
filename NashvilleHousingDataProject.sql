DROP TABLE  if exists NashvilleHousingData;
CREATE TABLE NashvilleHousingData (
	UniqueID int,
	ParcelID varchar(30),
	LandUse varchar(50),
	PropertyAddress Varchar(100),
	SaleDate date,
	SalePrice varchar(50), 
	Legalreference varchar(100),
	SoldAsVacant varchar(100),
	OwnerName varchar (100),
	OwnerAddress varchar(100),
	Acreage numeric,
	TaxDistrcit varchar(50),
	LandValue int, 
	BuildingValue int, 
	TotalValue int, 
	YearBuilt int, 
	Bedrooms int,
	FullBath int,
	HalfBath int
);

COPY NashvilleHousingData FROM '/private/tmp/Nashville Housing Data for Data Cleaning.csv' WITH CSV HEADER

-----


Select * 
From NashvilleHousingData
Order by parcelid

-- Populate property address with the right information

Select nash1.parcelid, nash1.propertyaddress, nash2.parcelid, nash2.propertyaddress, COALESCE(nash1.propertyaddress,nash2.propertyaddress) as propertyaddressfixed
From NashvilleHousingData Nash1
Join NashvilleHousingData Nash2
 on nash1.parcelid = nash2.parcelid
 and nash1.uniqueid <> nash2.uniqueid
Where nash1.propertyaddress is null 

UPDATE NashvilleHousingData as nh
SET PropertyAddress = COALESCE(nash1.propertyaddress,nash2.propertyaddress)
	From NashvilleHousingData Nash1
	Join NashvilleHousingData Nash2
	 on nash1.parcelid = nash2.parcelid
	 and nash1.uniqueid <> nash2.uniqueid
Where nh.propertyaddress is null 



-- Breaking Address into individual columns for address and city

Select * 
From NashvilleHousingData


Select 
Substring(Propertyaddress, 1, Position(',' in PropertyAddress) -1) as address,
Substring(Propertyaddress, Position(',' in PropertyAddress) +1) as address2
From NashvilleHousingData


Alter Table NashvilleHousingData
Add PropertySplitAddress varchar(250);

Update NashvilleHousingData
SET PropertySplitAddress = Substring(Propertyaddress, 1, Position(',' in PropertyAddress) -1);


Alter Table NashvilleHousingData
Add PropertySplitCity varchar(250);

Update NashvilleHousingData
SET PropertySplitCity = Substring(Propertyaddress, Position(',' in PropertyAddress) +1);


Select *
From Nashvillehousingdata


-- ------ Splitting up the owner address column by delimiters

Select OwnerAddress
From NashvilleHousingData


SELECT
    SPLIT_PART(owneraddress, ',', 1) AS firstpart
	, SPLIT_PART(owneraddress, ',', 2) AS secondpart
	, SPLIT_PART(owneraddress, ',', 3) AS thirdpart
FROM
    NashvilleHousingData;
	
	
	

Alter Table NashvilleHousingData
Add OwnerSplitAddress varchar(250);

Update NashvilleHousingData
SET OwnerSplitAddress = SPLIT_PART(owneraddress, ',', 1);


Alter Table NashvilleHousingData
Add OwnerSplitCity varchar(250);

Update NashvilleHousingData
SET OwnerSplitCity = SPLIT_PART(owneraddress, ',', 2);



Alter Table NashvilleHousingData
Add Ownersplitstate varchar(250);

Update NashvilleHousingData
SET Ownersplitstate = SPLIT_PART(owneraddress, ',', 3);



Select *
From Nashvillehousingdata



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldasvacant), count(soldasvacant)
From Nashvillehousingdata
Group by soldasvacant

Select
	Case When Soldasvacant = 'Y' Then 'Yes'
	When Soldasvacant = 'N' Then 'No'
	Else soldasvacant
	END
From Nashvillehousingdata

Update NashvilleHousingData
SET Soldasvacant =
	Case When Soldasvacant = 'Y' Then 'Yes'
	When Soldasvacant = 'N' Then 'No'
	Else soldasvacant
	END


Select count(Soldasvacant), soldasvacant
From NashvilleHousingdata
Group by soldasvacant



--- Using a CTE to remove duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Parcelid,
                         Propertyaddress,
                         Saleprice,
                         SaleDate,
                         Legalreference
            ORDER BY uniqueid
        ) AS rownum
    FROM Nashvillehousingdata
)
Select * 
FROM Nashvillehousingdata
WHERE (Parcelid, Propertyaddress, Saleprice, SaleDate, Legalreference) IN (
    SELECT Parcelid, Propertyaddress, Saleprice, SaleDate, Legalreference
    FROM RowNumCTE
    WHERE rownum > 1
);
		
		

Select *
From Nashvillehousingdata


--- Delete unused columns

Alter Table NashvilleHousingData
Drop Column Owneraddress, 
Drop Column taxdistrcit, 
Drop Column propertyaddress


Select *
From Nashvillehousingdata