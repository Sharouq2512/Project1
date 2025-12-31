create database Libraries
use Libraries


create table Members (
M_Id int primary key identity(1,1),
Email varchar(50) unique not null,
PhoneNo int ,
FName varchar(50) ,
S_Date date not null,
)
-----------------------------------
create table Libraries(
Library_Id int primary key identity(700,1),
LName varchar(50) unique not null,
L_Location varchar(50) not null, 
PhoneNo int not null ,
E_Year int,
)
------------------------------
create table Staff(
S_Id int primary key identity(10,1),
FName varchar(50),
Position varchar(50),
PhoneNo int,
FLibrary_Id int,
FOREIGN KEY (FLibrary_Id) REFERENCES Libraries(Library_Id)
ON DELETE CASCADE
ON UPDATE CASCADE
)
----------------------------------------------------
create table Book(
B_Id int primary key identity(500,1),
ISBN varchar(100) unique,
BTitle varchar(50) ,
Genre varchar(50) check(Genre in('Fiction', 'Non-fiction', 'Reference', 'Children' )),
Price decimal(5,2) check(Price>=0),
Av_Status varchar(50) default 'TRUE', 
Shelf_Loc varchar(50) ,
FLibrary_Id int,
FM_Id int,
FOREIGN KEY (FM_Id) REFERENCES Members(M_Id)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (FLibrary_Id) REFERENCES Libraries(Library_Id)
ON DELETE CASCADE
ON UPDATE CASCADE
)

------------------------------

create table Reviews(
R_Id int primary key identity(400,1),
R_Date date not null ,
Comments varchar(200) default 'No comments' ,
Rating int not null check(Rating between 1 and 5),
FB_Id int,
FM_Id int ,
FOREIGN KEY (FB_Id) REFERENCES Book(B_Id)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (FM_Id) REFERENCES Members(M_Id)

)

------------------------------

create table Loan (
Loan_ID int primary key identity(30,1),
Loan_Date date not null,
Due_Date date not null,
Return_Date date ,
check (Return_Date IS NULL OR Return_Date >= Loan_Date),
LStatus varchar(50) not null check(LStatus in('Issued', 'Returned', 'Overdue' )) default 'Issued',
FB_Id int,
FM_Id int,
FOREIGN KEY (FM_Id) REFERENCES Members(M_Id)
ON DELETE CASCADE
ON UPDATE CASCADE,
FOREIGN KEY (FB_Id) REFERENCES Book(B_Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION,

)

--------------------------------------------------------

create table Payment (
P_Id int primary key identity(20,1),
P_Date date not null,
Amount decimal(5,2) not null check(Amount>=0) ,
Method varchar(50) ,
FLoan_ID int,
FOREIGN KEY (FLoan_ID) REFERENCES Loan(Loan_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,
)

--------------------------------------

create table Loan_Member_Book(
FLoan_ID int,
FOREIGN KEY (FLoan_ID) REFERENCES Loan(Loan_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,
FM_Id int ,
FOREIGN KEY (FM_Id) REFERENCES Members(M_Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
FP_Id int,
FOREIGN KEY (FP_Id) REFERENCES Payment(P_Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
primary key (FLoan_ID,FM_Id, FP_Id)
)
-----------------------------------------------------------------------------------------------------



INSERT INTO Members (Email, PhoneNo, FName, S_Date)
VALUES
('ahmed@gmail.com', 91234561, 'Ahmed Ali', '2024-01-10'),
('fatima@gmail.com', 91234562, 'Fatima Hassan', '2024-01-12'),
('mohamed@gmail.com', 91234563, 'Mohamed Said', '2024-01-15'),
('aisha@gmail.com', 91234564, 'Aisha Omar', '2024-01-18'),
('khalid@gmail.com', 91234565, 'Khalid Salem', '2024-01-20'),
('noor@gmail.com', 91234566, 'Noor Ahmed', '2024-01-22'),
('yousef@gmail.com', 91234567, 'Yousef Ibrahim', '2024-01-25'),
('sara@gmail.com', 91234568, 'Sara Mahmood', '2024-01-27'),
('layla@gmail.com', 91234569, 'Layla Abdallah', '2024-02-01'),
('omar@gmail.com', 91234570, 'Omar Nasser', '2024-02-03');

-------------------------------------------------------------

INSERT INTO Libraries (LName, L_Location, PhoneNo, E_Year)
VALUES
('Al Noor Library', 'Muscat', 24123456, 2005),
('Al Amal Library', 'Salalah', 23214567, 2010),
('Al Hikma Library', 'Sohar', 26891234, 1998);
---------------------------------------------------------

INSERT INTO Staff (FName, Position, PhoneNo, FLibrary_Id)
VALUES
('Hassan Ali', 'Manager', 91111111, 705),
('Mona Said', 'Librarian', 91111112, 705),
('Salim Omar', 'Assistant', 91111113, 706),
('Rania Ahmed', 'Librarian', 91111114, 706),
('Fahad Khalid', 'Manager', 91111115, 707),
('Huda Salem', 'Assistant', 91111116, 707);


------------------------------------------------------------------

INSERT INTO Book (ISBN, BTitle, Genre, Price, Av_Status, Shelf_Loc, FLibrary_Id, FM_Id)
VALUES
('978-C001','Arab History','Non-fiction',20.00,'TRUE','A1',705,26),
('978-C002','Desert Stories','Fiction',15.00,'TRUE','A2',705,27),
('978-C003','Science Basics','Reference',30.00,'TRUE','B1',705,28),
('978-C004','Kids Tales','Children',12.00,'TRUE','C1',705,29),
('978-C005','Islamic Culture','Non-fiction',25.00,'TRUE','A3',705,30),

('978-C006','World Atlas','Reference',40.00,'TRUE','B2',706,31),
('978-C007','Ocean Life','Non-fiction',18.00,'TRUE','A1',706,32),
('978-C008','Funny Animals','Children',10.00,'TRUE','C1',706,33),
('978-C009','Arabic Poetry','Fiction',22.00,'TRUE','A2',706,34),
('978-C010','Math Essentials','Reference',35.00,'TRUE','B3',706,35),

('978-C011','Modern Physics','Reference',45.00,'TRUE','B1',707,26),
('978-C012','AI Basics','Non-fiction',38.00,'TRUE','A1',707,27),
('978-C013','Short Stories','Fiction',16.00,'TRUE','A2',707,28),
('978-C014','Learning English','Non-fiction',28.00,'TRUE','A3',707,29),
('978-C015','Coloring Book','Children',9.00,'TRUE','C1',707,30),

('978-C016','Space Journey','Fiction',19.00,'TRUE','A4',705,31),
('978-C017','Healthy Living','Non-fiction',21.00,'TRUE','A5',705,32),
('978-C018','Programming SQL','Reference',42.00,'TRUE','B4',706,33),
('978-C019','Arabic Grammar','Reference',33.00,'TRUE','B2',707,34),
('978-C020','Bedtime Stories','Children',11.00,'TRUE','C2',705,35);

------------------------------------------------------------

INSERT INTO Reviews (R_Date, Comments, Rating, FB_Id, FM_Id)
VALUES
('2025-12-01', 'Excellent and informative book', 5, 513, 26),
('2025-12-03', 'Interesting but a bit long', 4, 514, 27),
('2025-12-05', 'Very useful for students', 5, 515, 28),
('2025-12-06', 'Kids will love it', 5, 516, 29),
('2025-12-08', 'Good reference for geography', 4, 517,30);


---------------------------------------------------------------

INSERT INTO Loan (Loan_Date, Due_Date, Return_Date, LStatus, FB_Id, FM_Id)
VALUES
('2025-12-10', '2025-12-20', '2025-12-25', 'Issued', 513, 26),
('2025-12-11', '2025-12-21', NULL, 'Issued', 514, 27),
('2025-12-12', '2025-12-22', NULL, 'Issued', 515, 28),
('2025-12-13', '2025-12-23', '2025-12-28', 'Issued', 516, 29),
('2025-12-14', '2025-12-24', '2025-12-29', 'Issued', 517, 30);

------------------------------------------------------------------
INSERT INTO Payment (P_Date, Amount, Method, FLoan_ID)
VALUES
('2025-12-12', 5.00, 'Cash', 36),
('2025-12-13', 7.50, 'Card', 37),
('2025-12-14', 6.00, 'Cash', 38),
('2025-12-15', 4.50, 'Card', 39),
('2025-12-16', 8.00, 'Cash', 40);

---------------------------------------------------------
INSERT INTO Loan_Member_Book (FLoan_ID, FM_Id, FP_Id)
VALUES
(36, 26, 28),
(37, 27, 29),
(38, 28, 30),
(39, 29, 31),
(40, 30, 32);
----------------------------------------------------------------------------------------------------------

--Display all book records. 
select * from Book

--Display each book’s title, genre, and availability.
select BTitle, Genre, Av_Status from Book

--Display all member names, email, and membership start date. 
select Email, FName, S_Date from Members

--Display each book’s title and price as BookPrice.
SELECT BTitle + ' ' + CAST(Price AS VARCHAR(10)) AS BookPrice
FROM Book;

--List books priced above 20 OMR. 
select BTitle,price from Book where (Price>20)

--List members who joined before 2023.
SELECT *
FROM Members
WHERE S_Date < '2023-01-01';

--Display books published after 2018. 
 
--Display books ordered by price descending. 
select * from Book
order by price desc;

--Display the maximum, minimum, and average book price.
select min(price), max(price), avg(Price) from Book

--Display total number of books. 
select count(B_Id) from Book

--Display members with NULL email. 
select * from Members where (Email is null)

--Display books whose title contains 'Data'. 
SELECT *
FROM Book
WHERE BTitle LIKE '%Data%';
--DML 

--Insert another member with NULL email and phone. 
--Update the return date of your loan to today. 
UPDATE Loan
SET Return_Date = GETDATE()
WHERE FM_Id = 405;
--Increase book prices by 5% for books priced under 200. 
UPDATE Book
SET Price = Price * 1.05
WHERE Price < 200;
--Update member status to 'Active' for recently joined members. 
UPDATE Members
SET Status = 'Active'
WHERE S_Date >= DATEADD(DAY, -30, GETDATE());

--Delete members who never borrowed a book.
DELETE FROM Members
WHERE M_Id NOT IN (
    SELECT DISTINCT M_Id
    FROM Loan
);

--JOIN Queries
--1. Display library ID, name, and the name of the manager.
SELECT L.Library_Id, L.LName, S.FName AS ManagerName ,S.Position
FROM Libraries L
JOIN Staff S ON L.Library_Id = S.FLibrary_Id
WHERE S.Position = 'Manager';

--2. Display library names and the books available in each one.
SELECT L.LName, B.BTitle
FROM Libraries L
JOIN Book B ON L.Library_Id = B.FLibrary_Id
WHERE B.Av_Status = 'TRUE';

--3. Display all member data along with their loan history.
SELECT M.*, L.Loan_ID, L.Loan_Date, L.Due_Date, L.Return_Date, L.LStatus
FROM Members M
LEFT JOIN Loan L ON M.M_Id = L.FM_Id;

--4. Display all books located in 'Zamalek' or 'Downtown'.
SELECT B.*
FROM Book B
JOIN Libraries L ON B.FLibrary_Id = L.Library_Id
WHERE L.L_Location IN ('Sur', 'Sohar');

Select * from Book
Select * from Libraries
Select * from Loan
Select * from Loan_Member_Book
Select * from Members
Select * from Payment
Select * from Reviews
Select * from Staff

--5. Display all books whose titles start with 'T'.
SELECT *
FROM Book
WHERE BTitle LIKE 'S%';

--6. List members who borrowed books priced between 100 and 300 LE.
SELECT DISTINCT M.M_Id, M.FName
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
JOIN Book B ON L.FB_Id = B.B_Id
WHERE B.Price BETWEEN 16 AND 26;

--7. Retrieve members who borrowed and returned books titled 'The Alchemist'.
SELECT DISTINCT M.M_Id, M.FName
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
JOIN Book B ON L.FB_Id = B.B_Id
WHERE B.BTitle = 'History of Oman'
  AND L.Return_Date IS NOT NULL;


--8. Find all members assisted by librarian "Sarah Fathy".
SELECT DISTINCT M.M_Id, M.FName
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
JOIN Book B ON L.FB_Id = B.B_Id
JOIN Staff S ON B.FLibrary_Id = S.FLibrary_Id
WHERE S.FName = 'Sarah Fathy';

--9. Display each member’s name and the books they borrowed, ordered by book title.
SELECT M.FName, B.BTitle
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
JOIN Book B ON L.FB_Id = B.B_Id
ORDER BY B.BTitle;

--10. For each book located in 'Cairo Branch', show title, library name, manager, and shelf info.
SELECT B.BTitle, L.LName, S.FName AS ManagerName, B.Shelf_Loc
FROM Book B
JOIN Libraries L ON B.FLibrary_Id = L.Library_Id
JOIN Staff S ON L.Library_Id = S.FLibrary_Id
WHERE L.LName = 'Cairo Branch'
  AND S.Position = 'Manager';

--11. Display all staff members who manage libraries.
SELECT S.*
FROM Staff S
WHERE S.Position = 'Manager';

--12. Display all members and their reviews, even if some didn’t submit any review yet
SELECT M.M_Id, M.FName, R.R_Date, R.Comments, R.Rating
FROM Members M
LEFT JOIN Reviews R ON M.M_Id = R.FM_Id;

----------------------------------------------------------------------------------
