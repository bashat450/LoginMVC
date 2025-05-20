Use College;

-- Table for Countries
CREATE TABLE Country (
    CountryId INT PRIMARY KEY IDENTITY(1,1),
    CountryName VARCHAR(100) NOT NULL
);

Insert into Country values ('India'),('ThaiLand');
-- Table for Register
CREATE TABLE Register (
    
    FullName VARCHAR(100) NOT NULL,
    EmailId VARCHAR(100) NOT NULL UNIQUE,
    [Password] VARCHAR(100) NOT NULL,
    [Date] DATE NOT NULL,
    CountryId INT,  -- Foreign key

    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);

Insert Into Register Values('Komal Chauhan','komal@gmail.com','komal123','2025-01-15',1),
('Rinkle Solanki','rinkle@gmail.com','rinkle123','2025-02-12',1);
Insert into Register Values ('Roshni Joshi','roshni@gmail.com','roshni123','2024-06-16',2),
('Pooja Jain','pooja@gmail.com','pooja123','2024-08-23',2);


-- -----------------
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
            R.FullName,
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


CREATE PROCEDURE SP_InsertRegisterDetails
    @FullName VARCHAR(100),
    @EmailId VARCHAR(100),
    @Password VARCHAR(100),
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
        INSERT INTO Register (FullName, EmailId, [Password], [Date], CountryId)
        VALUES (@FullName, @EmailId, @Password, @Date, @CountryId);

        SELECT 'Registration successful.' AS Message;
    END
END

EXEC SP_InsertRegisterDetails 
    @FullName = 'Deepak Jadiwal', 
    @EmailId = 'deepak@gmail.com', 
    @Password = 'deepak123', 
    @Date = '2025-06-19', 
    @CountryId = 2;

------------------------------

CREATE PROCEDURE SP_UpdateRegisterDetails
    @EmailId VARCHAR(100),
    @FullName VARCHAR(100),
    @Password VARCHAR(100),
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
            FullName = @FullName,
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


EXEC SP_UpdateRegisterDetails 
    @EmailId = 'deepak@gmail.com',
    @FullName = 'Deepak Jadiwal',
    @Password = 'deepak123',
    @Date = '2025-05-20',
    @CountryId = 2;



-- Drop Password column and recreate it as VARBINARY if not already
ALTER TABLE Register DROP COLUMN [Password];

ALTER TABLE Register ALTER COLUMN [Password] VARBINARY(64) NOT NULL;


ALTER TABLE Register ADD [Password] VARBINARY(64) NULL;

UPDATE Register 
SET Password = CONVERT(varbinary, 'komal123') 
WHERE EmailId = 'komal@gmail.com';

UPDATE Register 
SET Password = CONVERT(varbinary, 'rinkle123') 
WHERE EmailId = 'rinkle@gmail.com';

UPDATE Register 
SET Password = CONVERT(varbinary, 'roshni123') 
WHERE EmailId = 'roshni@gmail.com';

UPDATE Register 
SET Password = CONVERT(varbinary, 'Pooja123') 
WHERE EmailId = 'Pooja@gmail.com';

UPDATE Register 
SET Password = CONVERT(varbinary, 'deepak123') 
WHERE EmailId = 'deepak@gmail.com';



