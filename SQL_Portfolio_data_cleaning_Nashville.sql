						---- -- -- --  DATA CLEANING PROJECT -- -- -- ----

-- ManishPraa24 aka Manish Prajapti 

-- The Dataset is taken from a data analyst course from freecodecamp.org
-- IDE used : Microsoft SQL Server Management Studio
-- Excel file name : 'NashvilleHousing.xsl'
-- File imported in the SSMS through Microsoft DB Driver, hence, it's ready to query





								-- -- -- START OF PROJECT -- -- --





-- 1. View all the data from NashvilleHousing$ table

SELECT *
FROM NashvilleHousing$




-- 2. Converting type of SaleDate from Date&Time to Date and adding a new column for the same

SELECT SaleDate, 
	   CONVERT(Date, SaleDate) AS FormattedSaleDate
FROM NashvilleHousing$


ALTER TABLE NashvilleHousing$
ADD SaleDateFormatted Date

UPDATE NashvilleHousing$ 
SET SaleDateFormatted = CONVERT(Date, SaleDate)

SELECT SaleDateFormatted
FROM NashvilleHousing$






-- 3. Checking for NULL values in PropertyAddress

SELECT PropertyAddress
FROM NashvilleHousing$
WHERE PropertyAddress IS NULL



SELECT NS1.ParcelID, 
	   NS1.PropertyAddress, 
	   NS2.ParcelID, NS2.PropertyAddress, 
	   ISNULL(NS1.PropertyAddress, NS2.PropertyAddress) AS EffectiveAddress
FROM NashvilleHousing$ AS NS1
	 JOIN NashvilleHousing$ AS NS2
		ON NS1.ParcelID = NS2.ParcelID
			AND NS1.[UniqueID ] <> NS2.[UniqueID ]
WHERE NS1.PropertyAddress IS NULL







-- 4. Updating NULL values in property address with actual address from owner's address 
		--(Here, the owner was actually living in the same house with no tenants, hence, for these cases, the property address was found NULL)


UPDATE NS1
SET PropertyAddress = ISNULL(NS1.PropertyAddress, NS2.PropertyAddress)
FROM
	NashvilleHousing$ NS1
		JOIN NashvilleHousing$ NS2
			ON NS1.ParcelID = NS2.ParcelID
			AND NS1.[UniqueID ] <> NS2.[UniqueID ]
WHERE NS1.PropertyAddress IS NULL


SELECT PropertyAddress
FROM NashvilleHousing$







--- 5. Splitting Property address into Split address (street address) and City name

SELECT  PropertyAddress
FROM NashvilleHousing$


--		Fetching CityName from PropertyAddress

SELECT PropertyAddress,
	   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PropertySplitAddress,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS PropertyCityName
FROM NashvilleHousing$


--		Creating attributes for the split address

ALTER TABLE NashvilleHousing$
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing$
ADD PropertyCityName NVARCHAR(255)


UPDATE NashvilleHousing$
SET PropertyCityName = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))



SELECT *
FROM NashvilleHousing$







-- 6. Splitting Owner Address

SELECT OwnerAddress
FROM NashvilleHousing$


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetName,  -- PARSES Backwards
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCityName,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerStateName
FROM NashvilleHousing$


ALTER TABLE NashvilleHousing$
ADD OwnerStreetName NVARCHAR(255),
	OwnerCityName NVARCHAR(255),
	OwnerStateName NVARCHAR(255)


UPDATE NashvilleHousing$
SET OwnerStreetName = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCityName = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerStateName = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing$






-- 7. Changing Y to Yes and N to No in "SoldAsVacant" column


SELECT SoldAsVacant, COUNT(SoldAsVacant) -- Checking for above cases
FROM NashvilleHousing$
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN  'Yes'
	 ELSE SoldAsVacant
END AS UpdatedVacancy
FROM NashvilleHousing$


UPDATE NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
					END







-- 8. Removing duplicates from the table

-- Using CTE 

WITH UniqueRowsCTE AS (
	SELECT *
	, ROW_NUMBER() OVER 
					(
						PARTITION BY ParcelID,
					    PropertyAddress,
					    SalePrice,
					    LegalReference
						ORDER BY
							UniqueID
					 ) AS row_num
	FROM NashvilleHousing$
	)
SELECT *
FROM UniqueRowsCTE
WHERE row_num>1
ORDER BY PropertyAddress   -- Here, all duplicates were eliminated or rather, after rearragement of the data, no duplicate tuples existed







-- 9. DELETING unused columns


ALTER TABLE NashvilleHousing$
DROP COLUMN OwnerAddress, 
		    TaxDistrict, 
			PropertyAddress, 
			SaleDate


SELECT * 
FROM NashvilleHousing$








								-- -- -- END OF PROJECT -- -- --



