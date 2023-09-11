
select *
from portfolioproject.dbo.NashvilleHousing
-- clean dateformat
Select SaleDateConverted, CONVERT(Date, Saledate)
From Portfolioproject.dbo.NashvilleHousing

UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, Saledate)
	
Alter Table portfolioproject.dbo.NashvilleHousing
add SaleDateConverted Date;

UPDATE portfolioproject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

-- Populate Property adress data

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISnull(a.propertyaddress, b.propertyaddress) 
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <>  b.UniqueID


UPDATE a
SET PropertyAddress = ISnull(a.propertyaddress, b.propertyaddress) 
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <>  b.UniqueID

-- Breaking out address into individual colums (address, city, state)

Select PropertyAddress 
From PortfolioProject.dbo.NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1, len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table portfolioproject.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1)

Alter Table portfolioproject.dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1, len(PropertyAddress))	

select OwnerAddress
from portfolioproject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3) as address2,  
PARSENAME(REPLACE(OwnerAddress,',', '.') ,2) as city2,
PARSENAME(REPLACE(OwnerAddress,',', '.') ,1) as state
from portfolioproject.dbo.NashvilleHousing

Alter Table portfolioproject.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

Alter Table portfolioproject.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

Alter Table portfolioproject.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

UPDATE portfolioproject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1) 

-- Change Y and N to Yes and No in "SoldasVacant"  Field


Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = 'Yes'
where SoldAsVacant like 'Y'

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = 'No'
where SoldAsVacant like 'N'

-- remove duplicates

With RowNumCTE as (
Select *,
	Row_Number() over(
	Partition By ParcelID,
				PropertyAddress,
				Saleprice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) Row_Num

From portfolioproject.dbo.nashvilleHousing

)
select *
From RowNumCTE
Where row_num > 1

--Delete unused columns



Alter Table portfolioproject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress 


Alter Table portfolioproject.dbo.NashvilleHousing
Drop Column SaleDate