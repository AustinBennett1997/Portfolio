/*********************************

Cleaning Data in SQL Queries

*********************************/

SELECT *
FROM Data_Cleaning_Prac..NashvilleHousing

--------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Data_Cleaning_Prac..NashvilleHousing

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_Cleaning_Prac..NashvilleHousing a
JOIN Data_Cleaning_Prac..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_Cleaning_Prac..NashvilleHousing a
JOIN Data_Cleaning_Prac..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

	-- Property Address

SELECT PropertyAddress
FROM Data_Cleaning_Prac..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Data_Cleaning_Prac..NashvilleHousing

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

	-- Owner Address

SELECT OwnerAddress
FROM Data_Cleaning_Prac..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Data_Cleaning_Prac..NashvilleHousing

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Data_Cleaning_Prac..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Data_Cleaning_Prac..NashvilleHousing

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Data_Cleaning_Prac..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Data_Cleaning_Prac..NashvilleHousing

ALTER TABLE Data_Cleaning_Prac..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--------------------------------------------------------------------------------

-- Changing nulls for information on land properties without a house

SELECT *
FROM Data_Cleaning_Prac..NashvilleHousing

SELECT DISTINCT(PropertySplitAddress), COUNT(PropertySplitAddress)
FROM Data_Cleaning_Prac..NashvilleHousing
GROUP BY PropertySplitAddress
ORDER BY 2 desc

SELECT PropertySplitAddress, LandValue, SaleDateConverted, YearBuilt, Bedrooms, FullBath, HalfBath
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE YearBuilt is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET LandValue = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE LandValue is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET BuildingValue = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE BuildingValue is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET TotalValue = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE TotalValue is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET Bedrooms = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE Bedrooms is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET FullBath = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE FullBath is null

UPDATE Data_Cleaning_Prac..NashvilleHousing
SET HalfBath = 0
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE HalfBath is null

--------------------------------------------------------------------------------

/*********************************

Queries for Data Visualization

*********************************/

--------------------------------------------------------------------------------

-- Amount of sales over time per 
SELECT PropertySplitCity, COUNT(UniqueID)
FROM Data_Cleaning_Prac..NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY COUNT(UniqueID) DESC


-- Sale price compared to year built
SELECT AVG(BuildingValue) AS AvgBuildingVal, YearBuilt
FROM Data_Cleaning_Prac..NashvilleHousing
WHERE BuildingValue != '0'
AND YearBuilt is not null
--AND LandUse != 'CHURCH'
GROUP BY YearBuilt
ORDER BY AVG(BuildingValue) DESC
