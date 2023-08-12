select *
from Nashville_Housing

---To Standardize Sale Date---

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------ Populate Property Address data---
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)--
select PropertyAddress
from Nashville_Housing

Select 
substring (propertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1) as Address,
substring (propertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from Nashville_Housing

ALTER TABLE Nashville_Housing
Add New_Property_Address nvarchar (255);

Update Nashville_Housing
SET New_Property_Address = substring (propertyAddress, 1, CHARINDEX( ',', PropertyAddress) - 1)

ALTER TABLE Nashville_Housing
Add New_Property_City nvarchar (255);

Update Nashville_Housing
SET New_Property_City = substring (propertyAddress, CHARINDEX( ',', PropertyAddress) + 1, LEN(PropertyAddress))


select * from Nashville_Housing

select OwnerAddress
from Nashville_Housing

select
PARSENAME (REPLACE (OwnerAddress, ',','.'), 3) AS ADDRESS,
PARSENAME (REPLACE (OwnerAddress, ',','.'), 2) AS CITY,
PARSENAME (REPLACE (OwnerAddress, ',','.'), 1) AS STATE
from Nashville_Housing

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress nvarchar (255);

Update Nashville_Housing
SET OwnerSplitAddress  = PARSENAME (REPLACE (OwnerAddress, ',','.'), 3)

ALTER TABLE Nashville_Housing
Add OwnerSplitCity nvarchar (255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',','.'), 2)

ALTER TABLE Nashville_Housing
Add Owner_State nvarchar (255);

Update Nashville_Housing
SET Owner_State = PARSENAME (REPLACE (OwnerAddress, ',','.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field--

select distinct (SoldAsVacant), count (*) as SoldAsVacant_Count
from Nashville_Housing
Group by SoldAsVacant

select SoldAsVacant,
Case When SoldAsVacant = 0 THEN 'No'
	 when SoldAsVacant = 1 THEN 'Yes'
	 Else SoldAsVacant
	 End
from Nashville_Housing

Alter table Nashville_Housing
Alter column SoldAsVacant varchar(50);

Update Nashville_Housing
Set SoldAsVacant = Case 
				   When SoldAsVacant = 0 THEN 'No'
				   when SoldAsVacant = 1 THEN 'Yes'
				   Else SoldAsVacant
				   End

-- Remove Duplicates---
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing)
Delete
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns
Alter table Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table Nashville_Housing
drop column SaleDate



Select * from Nashville_Housing