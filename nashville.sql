select SaleDateConverted, convert(date, SaleDate)
from proj1.dbo.Nashville

--standaradize date
select SaleDate, convert(date, SaleDate)
from proj1.dbo.Nashville

alter table Nashville
add SaleDateConverted date;

Update Nashville
set SaleDateConverted = convert(date, SaleDate)

--populate property address data
select*
from proj1.dbo.Nashville
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isNULL(a.PropertyAddress, b.PropertyAddress)
from proj1.dbo.Nashville a
join proj1.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isNULL(a.PropertyAddress, b.PropertyAddress)
from proj1.dbo.Nashville a
join proj1.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from proj1.dbo.Nashville

alter table Nashville
add PropertySplitAddress Nvarchar(255);

Update Nashville
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table Nashville
add PropertySplitCity Nvarchar(255);

Update Nashville
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from proj1.dbo.Nashville

select OwnerAddress
from proj1.dbo.Nashville

select
parsename(replace(OwnerAddress, ',','.'), 3)
,parsename(replace(OwnerAddress, ',','.'), 2)
,parsename(replace(OwnerAddress, ',','.'), 1)
from proj1.dbo.Nashville

alter table Nashville
add OwnerSplitAddress Nvarchar(255);

Update Nashville
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)

alter table Nashville
add OwnerSplitCity Nvarchar(255);

Update Nashville
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'), 2)

alter table Nashville
add OwnerSplitState Nvarchar(255);

Update Nashville
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)

select *
from proj1.dbo.Nashville

--change Y and N to yes and no
select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from proj1.dbo.Nashville

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--remove duplicates
with RowNumCTE as(
select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from proj1.dbo.Nashville
)
--delete
--from RowNumCTE
--where row_num > 1

select*
from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete unused column
select *
from proj1.dbo.Nashville

alter table proj1.dbo.Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table proj1.dbo.Nashville
drop column SaleDate