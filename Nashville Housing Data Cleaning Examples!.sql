

Select * 
	From Nashvillehousing 
------------------------------------------------------------------------------------

-- Standardizing the date format 

Select Saledate--, Convert(date, Saledate) as Saledate
from Nashvillehousing

Alter table nashvillehousing 
Alter Column saledate date

-- if you want to keep the orginal column and make another column 
--* you can do this instead

Alter table Nashvillehousing 
add SaledateConverted date;
-- you us the update once you've added the column
 
update Nashvillehousing 
Set Saledateconverted = Convert(date, saledate)

------------------------------------------------------------------------------------

--Populate Property Address Data


Select * 
	From Nashvillehousing 
	 --Where Propertyaddress is null 
	 Order by ParcelID

-- On this data set the Property address has some null values 
-- I noticed that each property has a ParcelID That is unique and 
-- SO if the Propertyaddress is Null on some rows but the same property has a Value on anther row with the ParcelID 
-- We can use that to fill in the null Values of the PropertyAddress using thr ParcelID

Select a.parcelId, a.propertyaddress, B.ParcelID, b.Propertyaddress
	From Nashvillehousing A
	 Join Nashvillehousing B
		On a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	Where a.propertyaddress is null 

--Once its all set and you want the data to repalce all the nulls You use ISNULL FUNCTION 

Select a.parcelId, a.propertyaddress, B.ParcelID, b.Propertyaddress, ISNULL(a.propertyaddress, B.propertyaddress)
	From Nashvillehousing A
	 Join Nashvillehousing B
		On a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	Where a.propertyaddress is null 

--When your ready to change it on the table you use the Update 

Update A
Set Propertyaddress = Isnull(a.propertyaddress, b.propertyaddress)
	From Nashvillehousing A
	 Join Nashvillehousing B
		On a.ParcelID = b.ParcelID
		and a.[UniqueID ] <> b.[UniqueID ]
	Where a.propertyaddress is Null 

------------------------------------------------------------------------------------

-- Breaking/Splitting  Out Address Into Indvidual Columns (Address, City, State)

Select Propertyaddress 
	From Nashvillehousing 
	 --Where Propertyaddress is null 
	 Order by ParcelID

Select 
 Substring(PropertyAddress, 1,Charindex(',', Propertyaddress)-1) as Address

 From nashvillehousing

 -- So now that we have the first part broken out we're going to do other one

 Select 
 Substring(PropertyAddress, 1,Charindex(',', Propertyaddress)-1) as Address,
  Substring (PropertyAddress, Charindex(',', Propertyaddress)+1, Len(propertyaddress)) as City

 From nashvillehousing

 -- Keep inmind The you Cant seprate 2 values from 1 Column Without creating 2 Other Columns  

 
Alter table Nashvillehousing 
add SplitCity NVarchar(255);

-- TO insert all of the data into the new Columns You have to use UPDATE

Update Nashvillehousing
Set SplitAddress = Substring(PropertyAddress, 1,Charindex(',', Propertyaddress)-1) 


Update Nashvillehousing
Set SplitCity = Substring (PropertyAddress, Charindex(',', Propertyaddress)+1, Len(propertyaddress))


Select Splitaddress, Splitcity
	From Nashvillehousing 

------------------------------------------------------------------------------------

--Another way to Breaking/Splitting  Out Address Into Indvidual Columns (Address, City, State) 

Select Owneraddress 
	From Nashvillehousing 

-- PARSENAME looks for . "period Values" So inorder to use it the Delimiter must me changed 
-- Parsename does things backwards so use the numbers in the reverse order  
Select 
	Parsename(Replace(owneraddress,',','.'), 3 ),
	Parsename(Replace(owneraddress,',','.'), 2),
	Parsename(Replace(owneraddress,',','.'), 1)
	 from Nashvillehousing

--TO insert create add new Columns and then You have to use UPDATE


Alter table Nashvillehousing 
add OwnerSplitCity NVarchar(255);

Alter table Nashvillehousing 
add OwnerSplitState NVarchar(255);

Alter table Nashvillehousing 
add OwnerSplit NVarchar(255);

-- TO insert all of the data into the new Columns You have to use UPDATE

Update Nashvillehousing
Set OwnerSplitAddress = Parsename(Replace(owneraddress,',','.'), 3)

Update Nashvillehousing
Set OwnerSplitCity = Parsename(Replace(owneraddress,',','.'), 2)

Update Nashvillehousing
Set OwnerSplitState = Parsename(Replace(owneraddress,',','.'), 1)


Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
	From Nashvillehousing 


------------------------------------------------------------------------------------

-- Change Y and N to Yes and No In "SOLD As Vacant" Feild USING CASE STATMENT


Select distinct(Soldasvacant), Count(SoldasVacant)
	from nashvillehousing
	 Group by SoldasVacant 
	  order by 2


	
Select Soldasvacant, 
		case When Soldasvacant= 'Y' Then 'Yes' 
			 when Soldasvacant= 'N' Then 'No'
			 Else Soldasvacant
			 End 
	from nashvillehousing

-- TO Make Change on the Table we Must Update this On to the Table!!

	
 Update nashvillehousing
  Set Soldasvacant = case When Soldasvacant= 'Y' Then 'Yes' 
			 when Soldasvacant= 'N' Then 'No'
			 Else Soldasvacant
			 End 
	

------------------------------------------------------------------------------------

-- Removing Duplicates using CTE's 

-- PARTITION By Is all the Row column values we want to be uniqe and shouldn't repeat

With RowNumCTE as (
Select *, 
	Row_number() Over(
	Partition by parcelId, 
				 Propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
			Order by 
				UniqueID
				) Row_num
	From Nashvillehousing 
	--order by ParcelID
	 ) 
Select * From RowNumCTE
where Row_num > 1
--Order by Propertyaddress

	from Nashvillehousing


------------------------------------------------------------------------------------

-- Deleting unused Columns 

Alter Table nashvillehousing 
Drop Column Owneraddress, taxdistrict, propertyaddress


Alter Table nashvillehousing 
Drop Column saledate















