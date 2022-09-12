
/*

Data Cleaning Housing Data

*/


Select * 
From PorfolioProject1.dbo.Housing


------Standardize Date Format 

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PorfolioProject1.dbo.Housing

Update Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Housing
Add SaleDateConverted date;

Update Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--------------Populate Property Address Data

Select * 
From PorfolioProject1.dbo.Housing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(b.PropertyAddress,a.PropertyAddress)
From PorfolioProject1.dbo.Housing a
JOIN PorfolioProject1.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where b.PropertyAddress is null


Update b
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PorfolioProject1.dbo.Housing a
JOIN PorfolioProject1.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where b.PropertyAddress is null


-------Breaking out Address into Individual Columns ( Address, City, State)

Select *
From PorfolioProject1.dbo.Housing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) as Address
From PorfolioProject1.dbo.Housing

Select 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PorfolioProject1.dbo.Housing

ALTER TABLE Housing
Add PropertySplitAddress nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE Housing
DROP COLUMN PropertySplitCity;

ALTER TABLE Housing
Add PropertySplitCity nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))




--------For Owner Address
--------Easier Method using PARSENAME

Select OwnerAddress
From PorfolioProject1.dbo.Housing
 

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PorfolioProject1.dbo.Housing
 

ALTER TABLE Housing
Add OwnerSplitAddress nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Housing
Add OwnerSplitCity nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housing
Add OwnerSplitState nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PorfolioProject1.dbo.Housing



---------Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PorfolioProject1.dbo.Housing
Group by SoldAsVacant
Order by 2

-----Lets Change Y and N as they are less populated

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PorfolioProject1.dbo.Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-----------Remove Duplicates

-------Lets assume if ParcelID, PropertyAdress, SalePrice, SaleDate, LegalReference is same then it is a duplicate.

-------Using CTE

WITH RowNUMCTE AS (
Select * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID) row_num

From PorfolioProject1.dbo.Housing
)

Select * 
From RowNUMCTE
Where row_num > 1
Order by PropertyAddress

-------Deleting


WITH RowNUMCTE AS (
Select * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID) row_num

From PorfolioProject1.dbo.Housing
)
DELETE
From RowNUMCTE
Where row_num > 1


------------Delete Unused Columns

Select *
From PorfolioProject1.dbo.Housing
 

ALTER TABLE PorfolioProject1.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



------Learnings 
------1. Converting Date to Date format using "CONVERT".
------2. Replacing null values by populating then with existing data using "ISNULL","JOIN","UPDATE".
------3. Spliting PropertyAddress and OwnerAddress using first method("SUBSTRING","CHARINDEX","ALTER TABLE","UPDATE") and second method ("PARSENAME","ALTER TABLE","UPDATE")
------4. Cleaning classes in SoldAsVacant using "CASE".
------5. Removing duplicated by identifying using "ROW_NUMBER","OVER","PARTITION BY" on few columns and deleting them.
------6. Removing used columns using "ALTER TABLE", "DROP COLUMN"