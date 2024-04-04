SELECT * 
FROM NashvillePortfolioProject..NashvilleHousing

-- Cleaning Data using SQL Queries to make dataset more usable (Porfolio Project - via AlexTheAnalyst!) 

-----------------------------------------------------------------------------------------------------------------------------------------
-- Standardize date format: 
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvillePortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvillePortfolioProject..NashvilleHousing



-----------------------------------------------------------------------------------------------------------------------------------------
--- Populate Property Address Data 
SELECT 
	a.ParcelID ,  
	a.PropertyAddress, 
	b.ParcelID , 
	b.PropertyAddress, 
	ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM NashvillePortfolioProject..NashvilleHousing AS a    -- Self join to create two columns of each other
JOIN NashvillePortfolioProject..NashvilleHousing AS b    
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)    -- Fill in null values with the proper property address
FROM NashvillePortfolioProject..NashvilleHousing AS a
JOIN NashvillePortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress IS NULL 


-----------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvillePortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvillePortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing			-- Alter table to create the property address column
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing              -- Alter table to create the property city column
ADD PropertySplitCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress , PropertySplitCity
FROM NashvillePortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------
-- Another way to break down OwnerAddress
SELECT OwnerAddress
FROM NashvillePortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3) AS StreetName
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2) AS CityName
, PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1) AS StateName 
FROM NashvillePortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

SELECT OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
FROM NashvillePortfolioProject..NashvilleHousing



-----------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in Sold as Vacant field using a CASE statement

SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM NashvillePortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

SELECT 
	SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'		-- Use a CASE Statement to change Y to Yes
	WHEN SoldAsVacant = 'N' THEN 'No'			-- Use a CASE statement to change N to No
	ELSE SoldAsVacant 
	END
FROM NashvillePortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =								-- Updating table using CASE statement query
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant 
	END



-----------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS (
SELECT * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) AS row_num
FROM NashvillePortfolioProject..NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1 


-------------------------------------------------------------------------------------
--- DELETE unused columns

SELECT *
FROM NashvillePortfolioProject..NashvilleHousing

ALTER TABLE NashvillePortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvillePortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
