-- Data Cleaning:

-- Check your raw data to know what needed to be done:

Select * 
from [Portfolio Porject # 2].dbo.Sheet1$

-------------------------------------------------------------------------------------------------------------------

-- Changing the SaleDate format:

Select SaleDate, cast(SaleDate as Date)
from [Portfolio Porject # 2].dbo.Sheet1$

-- Another way is by using Convert instead of cast:

Select SaleDate, convert(Date, SaleDate)
from [Portfolio Porject # 2].dbo.Sheet1$

-- Alter our table:

-- Update ... Set didn't work so had to Alter the Table and a new column then update:

Alter Table Sheet1$
Add SaleDateConverted Date

Update Sheet1$
Set SaleDateConverted = convert(Date, SaleDate)

-- Just to Check it is update:
Select SaleDateConverted, convert(Date, SaleDate)
from [Portfolio Porject # 2].dbo.Sheet1$



------------------------------------------------------------------------------------------------------------------------------------------------

-- Property Address Update:
-- Removing Null Values:
-- To check for the Null values:

Select *
from [Portfolio Porject # 2].dbo.Sheet1$
order by ParcelID

-- it is found that there are some same ParcelID values that are repeated and at least once is associated with a Null PrpertyAddress
-- So we will populate these Null Address using the Address associated with same ParcelID using ISNULL():

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Porject # 2].dbo.Sheet1$ a
Join [Portfolio Porject # 2].dbo.Sheet1$ b
 on a.ParcelID=b.ParcelID
 And a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is Null

 -- Now update the table, don't forget to used the aliases introduced before:

 Update a
 Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from [Portfolio Porject # 2].dbo.Sheet1$ a
Join [Portfolio Porject # 2].dbo.Sheet1$ b
 on a.ParcelID=b.ParcelID
 And a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is Null


 -- Reformat the PropertyAddress by breaking it into ( Address, City):

 Select PropertyAddress
from [Portfolio Porject # 2].dbo.Sheet1$

Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) ,
   SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) 
-- Use the following to check the position of delimiter:
--Charindex(',', PropertyAddress)
-- then add -1 to avoid including the (,) in the Address, same with +1
-- Len(PropertyAddress) to tell it where to stop
from [Portfolio Porject # 2].dbo.Sheet1$


-- Add our new Address columns:

Alter Table Sheet1$
Add PropertySplitAddress varchar(255), PropertyCity varchar(255)

Update Sheet1$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1),
    PropertyCity =  SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))



	

------------------------------------------------------------------------------------------------------------------------------------------------

-- Reformat the OwnerAddress by breaking it into ( Address, City, State):
--Do the same as PropertyAddress but in a different way using parsename() & replace():

select 
	Parsename(Replace(OwnerAddress, ',', '.'), 3),
	Parsename(Replace(OwnerAddress, ',', '.'), 2),
	Parsename(Replace(OwnerAddress, ',', '.'), 1)
from [Portfolio Porject # 2].dbo.Sheet1$

-- Add our new Address columns:

Alter Table Sheet1$
Add OwnerSplitAddress varchar(255), OwnerCity varchar(255), OwnerState varchar(255)

Update Sheet1$
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3),
    OwnerCity =  Parsename(Replace(OwnerAddress, ',', '.'), 2),
	OwnerState = Parsename(Replace(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------------------------------------------------------------------------------------------------


--Reformat the OwnerName by breaking it into ( OwnerFirstName, OwnerSurname):
--Do the same as OwnerAddress:

select 
	Parsename(Replace(OwnerName, ',', '.'), 2),
	Parsename(Replace(OwnerName, ',', '.'), 1)
	
from [Portfolio Porject # 2].dbo.Sheet1$

-- Add our new Address columns:

Alter Table [Portfolio Porject # 2].dbo.Sheet1$
Add OwnerSurname varchar(255), OwnerFirstName varchar(255)

Update [Portfolio Porject # 2].dbo.Sheet1$
Set OwnerSurname = Parsename(Replace(OwnerName, ',', '.'), 2),
	OwnerFirstName = Parsename(Replace(OwnerName, ',', '.'), 1)



-----------------------------------------------------------------------------------------------------------------------------

-- Modify SaleAsVacant Values:
-- Yes and No, Y and N:
-- Quick Check:

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from [Portfolio Porject # 2].dbo.Sheet1$
Group by SoldAsVacant
order by 2

--Four Values for SoldAsVacant Yes & Y and No & N (must be two values only, either Yes & No OR Y & N)

select SoldAsVacant,
  Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  End
from [Portfolio Porject # 2].dbo.Sheet1$

-- Now Update the table:


Update [Portfolio Porject # 2].dbo.Sheet1$
  Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  End
 
 


 --------------------------------------------------------------------------------------------------------------------------------------------------

 -- Remove Duplicates:

 -- We can use the SQL PARTITION BY clause with the OVER clause to specify the column on which we need to perform aggregation.

 With RowNumCTE AS (
   select *,
      ROW_NUMBER() Over (
	               Partition By ParcelID,
				                PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								Order By
								    UniqueID 
									) row_num
   from [Portfolio Porject # 2].dbo.Sheet1$
   )

-- To Idebtify the Duplicates:
 Select *
 from RowNumCTE
 Where row_num > 1
 Order By PropertyAddress

 -- To Delete the Duplicates:
--Delete
-- from RowNumCTE
-- Where row_num > 1





---------------------------------------------------------------------------------------------------------------------------------------------

--Remove the Unused/Unwanted Columns:

Alter Table [Portfolio Porject # 2].dbo.Sheet1$
  Drop Column  PropertyAddress, OwnerAddress, SaleDate, OwnerName



  -----------------------------------------------------------------------------------------------------------------------------------------------


-- The Final Form of Our Data after Cleaning:

select *

from [Portfolio Porject # 2].dbo.Sheet1$

