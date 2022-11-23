/* data cleaning SQL queries*/

select * from
PortfolioProject.dbo.NashvilleHousing$

/*formatting date*/ 
--select SaleDate from
--PortfolioProject.dbo.NashvilleHousing$
select SaleDate, convert(date,SaleDate) as DateOfSale
from PortfolioProject..NashvilleHousing$

alter table NashvilleHousing$
add ConvertedSaleDate Date;

update NashvilleHousing$
set ConvertedSaleDate= Convert(Date,SaleDate)

select ConvertedSaleDate, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing$

/* populate date of property address*/
select *
from PortfolioProject..NashvilleHousing$ 
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,
b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing$ a
join PortfolioProject..NashvilleHousing$ b
on a. ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing$ a
join PortfolioProject..NashvilleHousing$ b
on a. ParcelID= b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

/*breaking address to individual columns
(address, city, state)*/
select PropertyAddress
from PortfolioProject..NashvilleHousing$ 

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from PortfolioProject..NashvilleHousing$ 

alter table NashvilleHousing$
add PropertySplitAddress varchar(255);

update NashvilleHousing$
set PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing$
add PropertySplitCity varchar(255);

update NashvilleHousing$
set PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

select *
from
PortfolioProject..NashvilleHousing$

select OwnerAddress 
from PortfolioProject..NashvilleHousing$

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state
from PortfolioProject..NashvilleHousing$

alter table NashvilleHousing$
add OwnerSplitAddress varchar(255);

update NashvilleHousing$
set OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing$
add OwnerSplitCity varchar(255);

update NashvilleHousing$
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NashvilleHousing$
add OwnerSplitState varchar(255);

update NashvilleHousing$
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from
PortfolioProject..NashvilleHousing$

/*change Y and N to Yes and No in the field 'Sold as Vacant'*/

select distinct(SoldAsVacant), count(SoldAsVacant) 
from
PortfolioProject..NashvilleHousing$
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	else SoldAsVacant
	end

/*remove duplicates*/

with RowNumCTE as(
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					)row_num
from PortfolioProject..NashvilleHousing$
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete
--from RowNumCTE
--where row_num>1

/*deleting unused columns*/

select * from
PortfolioProject..NashvilleHousing$

alter table PortfolioProject..NashvilleHousing$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate