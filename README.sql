# Data-cleaning-of-Nashville-Hosuing
Data cleaning process using SQL queries
-- Cleaning Data in SQL queries
select * from Nashville..nashville

-- Standardize sale date
select SaleDate, convert(Date, saledate) 
from Nashville..nashville

update Nashville..nashville
set SaleDate =  convert(Date, saledate)

select SaleDate 
from Nashville..nashville

Alter Table Nashville..nashville
add saledateconverted date

update Nashville..nashville
set saledateconverted =  convert(Date, saledate)

select SaleDateconverted 
from Nashville..nashville

--Populate Property Address Data
select PropertyAddress 
from Nashville..nashville
where PropertyAddress is null

select *
from Nashville..nashville
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from Nashville..nashville a
join Nashville..nashville b
on a.parcelid = b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from Nashville..nashville a
join Nashville..nashville b
on a.parcelid = b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.PropertyAddress is null

--Breaking Out Address into individual Colums (Address, City, State)
select PropertyAddress
from Nashville..nashville
--where PropertyAddress is null

select
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from Nashville..nashville
--Minus 1 was to remove the ,
--Plus 1 was to remove the ,

Alter Table Nashville..nashville
add PropertySplitAddress nvarchar(255)

update Nashville..nashville
set PropertySplitAddress =  SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table Nashville..nashville
add PropertySplitCity nvarchar(255)

update Nashville..nashville
set PropertySplitCity =  SUBSTRING(propertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


select * from Nashville..nashville

--Populate Owner's Address
select OwnerAddress
from Nashville..nashville
where OwnerAddress is null

-- Parse name this time
select 
PARSENAME (replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME (replace(OwnerAddress, ',', '.'), 2)as City,
PARSENAME (replace(OwnerAddress, ',', '.'), 1) as State
from Nashville..nashville

Alter Table Nashville..nashville
add OwnerSplitAddress nvarchar(255)

update Nashville..nashville
set OwnerSplitAddress =  PARSENAME (replace(OwnerAddress, ',', '.'), 3)

Alter Table Nashville..nashville
add OwnerSplitCity nvarchar(255)

update Nashville..nashville
set OwnerSplitCity =  PARSENAME (replace(OwnerAddress, ',', '.'), 2)

Alter Table Nashville..nashville
add OwnerSplitState nvarchar(255)

update Nashville..nashville
set OwnerSplitState =  PARSENAME (replace(OwnerAddress, ',', '.'), 1)

Select * from Nashville..nashville

--Change Y and N to yes and No  in 'Sold as Vacant'
Select Distinct(SoldAsVacant), Count(soldasvacant)
from Nashville..nashville
group by SoldAsVacant
order by 2

--we will use a case statement

select soldasvacant,
Case when soldasvacant = 'y' then 'yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from Nashville..nashville

update Nashville..nashville
set SoldAsVacant = Case when soldasvacant = 'y' then 'yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

-- Remove Duplicates. we will use CTE temp table so we can select on the duplicates
with RowNumCTE as(
Select * ,
ROW_NUMBER() over(
partition by Parcelid,
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by
			 uniqueid
			 ) as duplicates
from Nashville..nashville
--order by duplicates, ParcelID
)
select * from RowNumCTE
where duplicates > 1
order by PropertyAddress

--deleting the duplicate
with RowNumCTE as(
Select * ,
ROW_NUMBER() over(
partition by Parcelid,
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by
			 uniqueid
			 ) as duplicates
from Nashville..nashville
--order by duplicates, ParcelID
)
delete  from RowNumCTE
where duplicates > 1
--order by PropertyAddress



-- Delete Unused Columns

Select *
from
Nashville..nashville

Alter Table Nashville..nashville
Drop Column Propertyaddress, OwnerAddress, TaxDistrict

Alter Table Nashville..nashville
Drop Column saledate
