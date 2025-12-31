--Part 2
-----------------------------------------------------------------------------------
--1. Library Book Inventory Report
select LName , count(B_Id) as TotalBooks ,sum(CASE WHEN B.Av_Status = 'True' THEN 1 ELSE 0 END) AS AvailableBooks,
sum(CASE WHEN B.Av_Status = 'Fulse' THEN 1 ELSE 0 END) AS NotAvailableBooks
from Libraries L, Book B
where L.Library_Id =B.FLibrary_Id
group by LName

--2. Active Borrowers Analysis 
select M.FName ,M.Email, BTitle ,Loan_Date, Due_Date,LStatus
from Loan L JOIN Members M ON L.FM_Id = M.M_Id
JOIN Book B ON L.FB_Id = B.B_Id
WHERE L.LStatus IN ('Issued', 'Overdue');

--3. Overdue Loans with Member Details 
select M.FName ,M.PhoneNo, B.BTitle , Lib.LName, DATEDIFF(DAY, L.Due_Date, GETDATE()) AS DaysOverdue
FROM Loan L
JOIN Members M ON L.FM_Id = M.M_Id
JOIN Book B ON L.FB_Id = B.B_Id
JOIN Libraries Lib ON B.FLibrary_Id = Lib.Library_Id
LEFT JOIN Payment P ON L.Loan_ID = P.FLoan_ID AND P.Method = 'Cash'
WHERE L.LStatus = 'Issued'
GROUP BY M.FName, M.PhoneNo, B.BTitle, Lib.LName, L.Due_Date;

--4. Staff Performance Overview 
SELECT 
    Lib.LName,
    S.FName,
    S.Position,
    COUNT(B.B_Id) AS BooksManaged
FROM Staff S
JOIN Libraries Lib ON S.FLibrary_Id = Lib.Library_Id
LEFT JOIN Book B ON Lib.Library_Id = B.FLibrary_Id
GROUP BY Lib.LName, S.FName, S.Position;

--5. Book Popularity Report
SELECT 
    B.BTitle,
    B.ISBN,
    B.Genre,
    COUNT(L.Loan_ID) AS TimesLoaned,
    AVG(CAST(R.Rating AS DECIMAL(3,2))) AS AvgRating
FROM Book B
JOIN Loan L ON B.B_Id = L.FB_Id
LEFT JOIN Reviews R ON B.B_Id = R.FB_Id
GROUP BY B.BTitle, B.ISBN, B.Genre
HAVING COUNT(L.Loan_ID) >= 3;

--6. Member Reading History 
SELECT 
    M.FName,
    B.BTitle,
    L.Loan_Date,
    L.Return_Date,
    R.Rating
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
JOIN Book B ON L.FB_Id = B.B_Id
LEFT JOIN Reviews R 
    ON R.FM_Id = M.M_Id AND R.FB_Id = B.B_Id
ORDER BY M.FName, L.Loan_Date;

--7. Revenue Analysis by Genre 
SELECT 
    B.Genre,
    COUNT(DISTINCT L.Loan_ID) AS TotalLoans,
    SUM(P.Amount) AS TotalRevenue,
    AVG(P.Amount) AS AvgFine
FROM Book B
JOIN Loan L ON B.B_Id = L.FB_Id
JOIN Payment P ON L.Loan_ID= P.FLoan_ID AND P.Method = 'Cash'
GROUP BY B.Genre;
 -----------------------------------------------------------------------------
 --Section 2: Aggregate Functions and Grouping

 --8. Monthly Loan Statistics 
 SELECT 
    DATENAME(MONTH, Loan_Date) AS MonthName,
    COUNT(*) AS TotalLoans,
    SUM(CASE WHEN LStatus = 'Returned' THEN 1 ELSE 0 END) AS Returned,
    SUM(CASE WHEN LStatus IN ('Issued','Overdue') THEN 1 ELSE 0 END) AS Active
FROM Loan
WHERE YEAR(Loan_Date) = YEAR(GETDATE())
GROUP BY DATENAME(MONTH, Loan_Date), MONTH(Loan_Date)
ORDER BY MONTH(Loan_Date);

 --9. Member Engagement Metrics
 SELECT 
    M.FName,
    COUNT(L.Loan_ID) AS TotalBorrowed,
    SUM(CASE WHEN L.LStatus IN ('Issued','Overdue') THEN 1 ELSE 0 END) AS CurrentLoans,
    SUM(P.Amount) AS TotalFines,
    AVG(R.Rating) AS AvgRating
FROM Members M
JOIN Loan L ON M.M_Id = L.FM_Id
LEFT JOIN Payment P ON L.Loan_ID = P.FLoan_ID AND P.Method='Cash'
LEFT JOIN Reviews R ON M.M_Id = R.FM_Id
GROUP BY M.FName;

 --10. Library Performance Comparison
 
 SELECT 
    Lib.LName,
    COUNT(DISTINCT B.B_Id) AS TotalBooks,
    COUNT(DISTINCT L.FM_Id) AS ActiveMembers,
    SUM(P.Amount) AS Revenue,
    CAST(COUNT(B.B_Id) AS FLOAT) / NULLIF(COUNT(DISTINCT L.FM_Id),0) AS AvgBooksPerMember
FROM Libraries Lib
LEFT JOIN Book B ON Lib.Library_Id = B.FLibrary_Id
LEFT JOIN Loan L ON B.B_Id = L.FB_Id
LEFT JOIN Payment P ON L.Loan_ID = P.FLoan_ID AND P.Method='Cash'
GROUP BY Lib.LName;

 --11. High-Value Books Analysis 
 WITH GenreAvg AS (
    SELECT Genre, AVG(Price) AS AvgGenrePrice
    FROM Book
    GROUP BY Genre
)
SELECT 
    B.BTitle AS BookTitle,
    B.Genre,
    B.Price,
    G.AvgGenrePrice,
    B.Price - G.AvgGenrePrice AS DifferenceFromAvg
FROM Book B
JOIN GenreAvg G ON B.Genre = G.Genre
WHERE B.Price > G.AvgGenrePrice
ORDER BY B.Genre, DifferenceFromAvg DESC;


 --12. Payment Pattern Analysis 
WITH TotalRevenue AS (
    SELECT SUM(Amount) AS TotalAmount
    FROM Payment
    WHERE Method='Cash'
)
SELECT 
    P.Method,
    COUNT(*) AS NumTransactions,
    SUM(P.Amount) AS TotalCollected,
    AVG(P.Amount) AS AvgPayment,
    SUM(P.Amount) * 100.0 / T.TotalAmount AS PercentageOfTotalRevenue
FROM Payment P
CROSS JOIN TotalRevenue T
WHERE P.Method='Cash'
GROUP BY P.Method, T.TotalAmount;
----------------------------------------------------------------------
--Section 3: Views Creation 

--13. vw_CurrentLoans 
CREATE VIEW vw_CurrentLoans AS
SELECT 
    M.FName,
    B.BTitle,
    L.Loan_Date,
    L.Due_Date,
    L.LStatus,
    DATEDIFF(DAY, GETDATE(), L.Due_Date) AS DaysToDue
FROM Loan L
JOIN Members M ON L.FM_Id = M.M_Id
JOIN Book B ON L.FB_Id = B.B_Id
WHERE L.LStatus IN ('Issued','Overdue');

--14. vw_LibraryStatistics 
CREATE VIEW vw_LibraryStatistics AS
SELECT 
    Lib.LName,
    COUNT(DISTINCT B.B_Id) AS TotalBooks,
    SUM(CASE WHEN B.Av_Status='TRUE' THEN 1 ELSE 0 END) AS AvailableBooks,
    COUNT(DISTINCT M.M_Id) AS Members,
    COUNT(DISTINCT S.S_Id) AS Staff,
    SUM(P.Amount) AS Revenue
FROM Libraries Lib
LEFT JOIN Book B ON Lib.Library_Id = B.FLibrary_Id
LEFT JOIN Staff S ON Lib.Library_Id = S.FLibrary_Id
LEFT JOIN Loan L ON B.B_Id = L.FB_Id
LEFT JOIN Payment P ON L.Loan_ID = P.FLoan_ID AND P.Method='Cash'
LEFT JOIN Members M ON L.FM_Id = M.M_Id
GROUP BY Lib.LName;

--15. vw_BookDetailsWithReviews 
CREATE VIEW vw_BookDetailsWithReviews AS
SELECT 
    B.BTitle,
    B.Genre,
    B.Av_Status,
    AVG(R.Rating) AS AvgRating,
    COUNT(R.R_Id) AS TotalReviews,
    MAX(R.R_Date) AS LastReview
FROM Book B
LEFT JOIN Reviews R ON B.B_Id = R.FB_Id
GROUP BY B.BTitle, B.Genre, B.Av_Status;

-----------------------------------------------------------------
--Section 4: Stored Procedures 

--16. sp_IssueBook 
CREATE PROCEDURE sp_IssueBook
    @MemberID INT,
    @BookID INT,
    @DueDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookAvailable VARCHAR(50);
    DECLARE @OverdueCount INT;

    -- Check if the book is available
    SELECT @BookAvailable = Av_Status
    FROM Book
    WHERE B_Id = @BookID;

    IF @BookAvailable IS NULL
    BEGIN
        PRINT 'Error: Book not found.';
        RETURN;
    END

    IF @BookAvailable != 'TRUE'
    BEGIN
        PRINT 'Error: Book is currently not available.';
        RETURN;
    END

    -- Check if member has overdue loans
    SELECT @OverdueCount = COUNT(*)
    FROM Loan
    WHERE FM_Id = @MemberID
      AND LStatus = 'Overdue';

    IF @OverdueCount > 0
    BEGIN
        PRINT 'Error: Member has overdue loans.';
        RETURN;
    END

    -- Issue the book
    INSERT INTO Loan (Loan_Date, Due_Date, LStatus, FB_Id, FM_Id)
    VALUES (GETDATE(), @DueDate, 'Issued', @BookID, @MemberID);

    -- Update book availability
    UPDATE Book
    SET Av_Status = 'FALSE'
    WHERE B_Id = @BookID;

    PRINT 'Success: Book issued successfully.';
END

--17. sp_ReturnBook 
CREATE PROCEDURE sp_ReturnBook
    @LoanID INT,
    @ReturnDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DueDate DATE;
    DECLARE @BookID INT;
    DECLARE @FineAmount DECIMAL(5,2);

    -- Get loan details
    SELECT @DueDate = Due_Date, @BookID = FB_Id
    FROM Loan
    WHERE Loan_ID = @LoanID;

    IF @DueDate IS NULL
    BEGIN
        PRINT 'Error: Loan record not found.';
        RETURN;
    END

    -- Update loan status and return date
    UPDATE Loan
    SET Return_Date = @ReturnDate,
        LStatus = 'Returned'
    WHERE Loan_ID = @LoanID;

    -- Update book availability
    UPDATE Book
    SET Av_Status = 'TRUE'
    WHERE B_Id = @BookID;

    -- Calculate fine ($2 per overdue day)
    SET @FineAmount = CASE 
                        WHEN @ReturnDate > @DueDate THEN DATEDIFF(DAY, @DueDate, @ReturnDate) * 2
                        ELSE 0
                      END;

    -- Create payment record if fine exists
    IF @FineAmount > 0
    BEGIN
        INSERT INTO Payment (P_Date, Amount, Method, FLoan_ID)
        VALUES (GETDATE(), @FineAmount, 'Pending', @LoanID);
    END

    PRINT CONCAT('Return processed. Total fine: $', @FineAmount);
END

--18. sp_GetMemberReport 
CREATE PROCEDURE sp_GetMemberReport
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Member basic information
    SELECT M_Id, FName, Email, PhoneNo, S_Date
    FROM Members
    WHERE M_Id = @MemberID;

    -- 2. Current loans
    SELECT L.Loan_ID, B.BTitle, L.Loan_Date, L.Due_Date, L.LStatus
    FROM Loan L
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE L.FM_Id = @MemberID AND L.LStatus = 'Issued';

    -- 3. Loan history with return status
    SELECT L.Loan_ID, B.BTitle, L.Loan_Date, L.Due_Date, L.Return_Date, L.LStatus
    FROM Loan L
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE L.FM_Id = @MemberID;

    -- 4. Total fines paid and pending
    SELECT SUM(CASE WHEN Amount > 0 THEN Amount ELSE 0 END) AS TotalFines,
           SUM(CASE WHEN Method = 'Pending' THEN Amount ELSE 0 END) AS PendingFines
    FROM Payment P
    JOIN Loan L ON P.FLoan_ID = L.Loan_ID
    WHERE L.FM_Id = @MemberID;

    -- 5. Reviews written by member
    SELECT R.R_Id, B.BTitle, R.R_Date, R.Comments, R.Rating
    FROM Reviews R
    JOIN Book B ON R.FB_Id = B.B_Id
    WHERE R.FM_Id = @MemberID;
END

--19. sp_MonthlyLibraryReport 

CREATE PROCEDURE sp_MonthlyLibraryReport
    @LibraryID INT,
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Total loans issued
    SELECT COUNT(*) AS TotalLoansIssued
    FROM Loan L
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE B.FLibrary_Id = @LibraryID
      AND MONTH(L.Loan_Date) = @Month
      AND YEAR(L.Loan_Date) = @Year;

    -- Total books returned
    SELECT COUNT(*) AS TotalBooksReturned
    FROM Loan L
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE B.FLibrary_Id = @LibraryID
      AND L.LStatus = 'Returned'
      AND MONTH(L.Return_Date) = @Month
      AND YEAR(L.Return_Date) = @Year;

    -- Total revenue collected
    SELECT SUM(P.Amount) AS TotalRevenue
    FROM Payment P
    JOIN Loan L ON P.FLoan_ID = L.Loan_ID
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE B.FLibrary_Id = @LibraryID
      AND MONTH(P.P_Date) = @Month
      AND YEAR(P.P_Date) = @Year;

    -- Most borrowed genre
    SELECT TOP 1 B.Genre, COUNT(*) AS TimesBorrowed
    FROM Loan L
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE B.FLibrary_Id = @LibraryID
      AND MONTH(L.Loan_Date) = @Month
      AND YEAR(L.Loan_Date) = @Year
    GROUP BY B.Genre
    ORDER BY TimesBorrowed DESC;

    -- Top 3 most active members
    SELECT TOP 3 L.FM_Id, M.FName, COUNT(*) AS LoansCount
    FROM Loan L
    JOIN Members M ON L.FM_Id = M.M_Id
    JOIN Book B ON L.FB_Id = B.B_Id
    WHERE B.FLibrary_Id = @LibraryID
      AND MONTH(L.Loan_Date) = @Month
      AND YEAR(L.Loan_Date) = @Year
    GROUP BY L.FM_Id, M.FName
    ORDER BY LoansCount DESC;
END


Select * from Book
Select * from Members
Select * from Loan
Select * from Loan_Member_Book
Select * from Libraries
Select * from Payment
Select * from Reviews
Select * from Staff