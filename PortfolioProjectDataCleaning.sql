/*
Cleaning Data in SQL Queries
*/

Select *
FROM PortfolioProject..NashvilleHousing

-- ReFormat SaleDate
Select SaleDate2, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing 
set SaleDate2 = convert(Date,SaleDate)

-- Populate Property Address data
Select *
FROM PortfolioProject..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddy Nvarchar(255);

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddy = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddy Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddy = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group By SoldAsVacant
order by 2

Select SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates
WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	Partition BY ParcelID,
				PropertyAddress,
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
Delete
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

Select *
FROM PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate