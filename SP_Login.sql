Use [COLLEGE];
-- Table for Countries
CREATE TABLE Country (
    CountryId INT PRIMARY KEY IDENTITY(1,1),
    CountryName VARCHAR(100) NOT NULL
);
Insert into Country values ('India'),('ThaiLand');
Insert into Country values ('China'),('Russia');
Insert into Country values ('USA'),('UAE');

-- Table for Register
CREATE TABLE Register (
    UserName VARCHAR(100) NOT NULL,
    EmailId VARCHAR(100) NOT NULL UNIQUE,
    [Password] VARBINARY(64) NOT NULL,
    [Date] DATE NOT NULL,
    CountryId INT,  -- Foreign key

    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);

Insert Into Register Values('Komal Chauhan','komal@gmail.com',CONVERT(varbinary, 'komal123'),'2025-01-15',1),
('Rinkle Solanki','rinkle@gmail.com',CONVERT(varbinary,'rinkle123'),'2025-02-12',1);
Insert into Register Values ('Roshni Joshi','roshni@gmail.com',CONVERT(varbinary,'roshni123'),'2024-06-16',2),
('Pooja Jain','pooja@gmail.com',CONVERT(varbinary,'pooja123'),'2024-08-23',2);

-- ------------------------------------------------
CREATE PROCEDURE SP_GetLoginDetails
    @EmailId VARCHAR(100),
    @Password VARCHAR(100)
AS
BEGIN
    -- Check if user with given EmailId and Password exists
    IF EXISTS (SELECT 1 FROM Register WHERE EmailId = @EmailId AND [Password] = @Password)
    BEGIN
        -- Return user details with country name
        SELECT 
            R.UserName,
            R.EmailId,
            R.[Date],
            C.CountryName
        FROM Register R
        LEFT JOIN Country C ON R.CountryId = C.CountryId
        WHERE R.EmailId = @EmailId AND R.[Password] = @Password;
    END
    ELSE
    BEGIN
        -- Invalid credentials
        SELECT 'Invalid EmailId or Password.' AS Message;
    END
END
-- Correct information
Execute SP_GetLoginDetails 'komal@gmail.com','komal123';
-- Incorrect Information
Execute SP_GetLoginDetails 'komal@gmail.com','komal1234';

----/////////////////////////////////////////////////
Alter PROCEDURE SP_InsertRegisterDetails
    @UserName VARCHAR(100),
    @EmailId VARCHAR(100),
    @Password VARBINARY(64),
    @Date DATE,
    @CountryId INT
AS
BEGIN
    -- Check if EmailId already exists
    IF EXISTS (SELECT 1 FROM Register WHERE EmailId = @EmailId)
    BEGIN
        SELECT 'EmailId already exists.' AS Message;
    END
    ELSE
    BEGIN
        -- Insert new user details
        INSERT INTO Register (UserName, EmailId, [Password], [Date], CountryId)
        VALUES (@userName, @EmailId, @Password, @Date, @CountryId);

        SELECT 'Registration successful.' AS Message;
    END
END
--------------Call Insert values

DECLARE @UserName VARCHAR(100) = 'Divya Agarwal';
DECLARE @EmailId VARCHAR(100) = 'divya@gmail.com';
DECLARE @Password VARBINARY(64) = CONVERT(VARBINARY(64), 'divyal123');
DECLARE @Date DATE = '2025-06-19';
DECLARE @CountryId INT = 4;

EXEC SP_InsertRegisterDetails 
    @UserName = @FullName, 
    @EmailId = @EmailId, 
    @Password = @Password, 
    @Date = @Date, 
    @CountryId = @CountryId;



------------------------------

CREATE PROCEDURE SP_UpdateRegisterDetails
    @EmailId VARCHAR(100),
    @UserName VARCHAR(100),
    @Password varbinary(100),
    @Date DATE,
    @CountryId INT
AS
BEGIN
    -- Check if user with given EmailId exists
    IF EXISTS (SELECT 1 FROM Register WHERE EmailId = @EmailId)
    BEGIN
        -- Perform the update
        UPDATE Register
        SET 
            UserName = @UserName,
            [Password] = @Password,
            [Date] = @Date,
            CountryId = @CountryId
        WHERE EmailId = @EmailId;

        SELECT 'User details updated successfully.' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No user found with the provided EmailId.' AS Message;
    END
END
--////////////// Call Update SP
DECLARE @Password VARBINARY(64) = HASHBYTES('SHA2_256', 'sheetal123');

EXEC SP_UpdateRegisterDetails 
    @EmailId = 'sheetal@gmail.com',
    @UserName = 'Sheetal Singh',
    @Password = @Password,
    @Date = '2025-05-20',
    @CountryId = 2;


	-- Re-hash all passwords using SHA-256 (only if you trust the plaintext for demo users)
UPDATE Register
SET [Password] = HASHBYTES('SHA2_256', 'komal123')
WHERE EmailId = 'komal@gmail.com';

-- Repeat for others
UPDATE Register
SET [Password] = HASHBYTES('SHA2_256', 'rinkle123')
WHERE EmailId = 'rinkle@gmail.com';

UPDATE Register
SET [Password] = HASHBYTES('SHA2_256', 'roshni123')
WHERE EmailId = 'roshni@gmail.com';

UPDATE Register
SET [Password] = HASHBYTES('SHA2_256', 'pooja123')
WHERE EmailId = 'pooja@gmail.com';



