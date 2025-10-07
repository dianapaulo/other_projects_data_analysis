/*
Cleaning Data in SQL Queries
*/

Select *
FROM SQLPortfolioProject.dbo.NashvilleHousing
-------------------------------------------------------------------

--Standardize Date Format--

Select SaleDate
FROM SQLPortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

/*
Alternative Solution

Select SaleDate, CONVERT(Date, SaleDate)
FROM SQLPortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

*/

----------------------------------------------

--Populate Property address data--

Select PropertyAddress
FROM SQLPortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null



Select *
FROM SQLPortfolioProject.dbo.NashvilleHousing
order by ParcelID -- related to Property Address

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  --when a.PropertyAddress is Null take the date from  b.PropertyAddress
FROM SQLPortfolioProject.dbo.NashvilleHousing a
Join SQLPortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID --make data shoulb be shown once, not multple
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null --when a.PropertyAddress is Null take the date from  b.PropertyAddress




Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM SQLPortfolioProject.dbo.

a
Join SQLPortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null


Select PropertyAddress
FROM SQLPortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is Null


----------------------------------------------------------------------------------

--Breaking out Address Into Individual Columns ( Address, City, State)--


Select PropertyAddress
FROM SQLPortfolioProject.dbo.NashvilleHousing

SELECT
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --looking for the comma and to get rid of it
,Substring(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) as Address
FROM SQLPortfolioProject.dbo.NashvilleHousing


SELECT
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --looking for the comma and to get rid of it
,Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM SQLPortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select *
FROM SQLPortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------

select OwnerAddress
FROM SQLPortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
FROM SQLPortfolioProject.dbo.NashvilleHousing

---alter table, add and update Owner Address---

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select *
FROM SQLPortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field--


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM SQLPortfolioProject.dbo.NashvilleHousing
GROUP by SoldAsVacant
ORDER by 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       Else SoldAsVacant
       END
FROM SQLPortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       Else SoldAsVacant
       END

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM SQLPortfolioProject.dbo.NashvilleHousing
GROUP by SoldAsVacant
ORDER by 2

---------------------------------------------------------------------

--Remove Duplicates--

SELECT *
FROM SQLPortfolioProject.dbo.NashvilleHousing



WITH RowNumCTE as (
SELECT *,
     ROW_NUMBER () OVER(
     PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
					UniqueID
					) row_num


FROM SQLPortfolioProject.dbo.NashvilleHousing
)

SELECT * ----- these are duplicates
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



 ----- DELETE THE duplicates
WITH RowNumCTE as (
SELECT *,
     ROW_NUMBER () OVER(
     PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
					UniqueID
					) row_num


FROM SQLPortfolioProject.dbo.NashvilleHousing
)

DELETE ----- DELETE THE duplicates
FROM RowNumCTE
WHERE row_num > 1



------RUN AGAIN TO SEE IF THE DUPLICATES ARE GONE


WITH RowNumCTE as (
SELECT *,
     ROW_NUMBER () OVER(
     PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
					UniqueID
					) row_num

FROM SQLPortfolioProject.dbo.NashvilleHousing
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


----------------------------------------------------------------------------------

------Delete unused columns------


select *
FROM SQLPortfolioProject.dbo.NashvilleHousing


ALTER TABLE SQLPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



ALTER TABLE SQLPortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

