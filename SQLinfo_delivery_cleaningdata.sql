---Standardize Date Format
SELECT SaleDate, Convert(date, SaleDate) as Updated_date
FROM PorfolioProject..NavilleHousing

ALTER TABLE NavilleHousing
ADD SaleDateConverted Date



--- Populate Property Address data -- Cach kiem tra Dia chi bi trong
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as Updated_Address
FROM PorfolioProject..NavilleHousing AS a
JOIN PorfolioProject..NavilleHousing As b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE b.PropertyAddress IS NULL 

UPDATE  a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as Updated_Address
FROM PorfolioProject..NavilleHousing AS a
JOIN PorfolioProject..NavilleHousing As b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 


--- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress, 
SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress) ) AS City
FROM PorfolioProject..NavilleHousing

SELECT  OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS A
		OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS B
		OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS C
FROM PorfolioProject..NavilleHousing


--- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PorfolioProject..NavilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant = 'N' THEN 'No'
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 ELSE SoldAsVacant
			 END AS SoldAsVacant_Updated
FROM PorfolioProject..NavilleHousing

UPDATE PorfolioProject..NavilleHousing
SET SoldAsVacant = 		CASE WHEN SoldAsVacant = 'N' THEN 'No'
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 ELSE SoldAsVacant
			 END

--- Remove Duplicates

--Step 1: Find Duplicate values
WITH CTE AS (SELECT *,
		ROW_NUMBER () OVER (
		PARTITION BY 
					ParcelID,
					SaleDate,
					LegalReference,
					SalePrice
					ORDER BY ParcelId) AS Duplicate_parcel
FROM PorfolioProject..NavilleHousing)

SELECT *
FROM CTE
WHERE Duplicate_parcel > 1

-- Step 2: Delete Duplicate
DELETE 
FROM CTE
WHERE Duplicate_parcel > 1

--- Delete unused columns 
/* We would Update new columns after cleaning process then delete the reductdant one
Ex: We have split PropertyAddress and OwnerAddress -> So we need to add columns for split ones then delete source column
*/

ALTER TABLE PorfolioProject..NavilleHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE PorfolioProject..NavilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PorfolioProject..NavilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress))

UPDATE PorfolioProject..NavilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE PorfolioProject..NavilleHousing
DROP COLUMN PropertyAddress

SELECT *
FROM PorfolioProject..NavilleHousing
--- 