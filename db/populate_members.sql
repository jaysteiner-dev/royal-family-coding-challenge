--Necessary fields for row creation:
--Name, Gender

--INSERT INTO Members ( Name, Gender )
--VALUES ( "Arthur", "Male", 1 );


INSERT INTO Members (MemberID, Name, Gender, DirectLineage )
VALUES
    -- Patriach + Matriach
    ( 1, "Arthur", "Male", 1 ),
    ( 2, "Margaret", "Female", 1 ),

    -- First Generation
    ( 3, "Bill", "Male", 1 ),
    ( 4, "Flora", "Female", 0 ),
    ( 5, "Charlie", "Male", 1 ),
    ( 6, "Percy", "Male", 1 ),
    ( 7, "Audrey", "Female", 0 ),
    ( 8, "Ronald", "Male", 1 ),
    ( 9, "Helen", "Female", 0 ),
    ( 10, "Ginerva", "Female", 1 ),
    ( 11, "Harry", "Male", 0 ),

    -- Second Generation
    ( 12, "Victoire", "Female", 1 ),
    ( 13, "Ted", "Male", 0 ),
    ( 14, "Dominique", "Female", 1 ),
    ( 15, "Louis", "Male", 1 ),
    ( 16, "Molly", "Female", 1 ),
    ( 17, "Lucy", "Female", 1),
    ( 18, "Malfoy", "Male", 0 ),
    ( 19, "Rose", "Female", 1),
    ( 20, "Hugo", "Male", 1 ),
    ( 21, "Darcy", "Female", 0 ),
    ( 22, "James", "Male", 1 ),
    ( 23, "Alice", "Female", 0 ),
    ( 24, "Albus", "Male", 1 ),
    ( 25, "Lily", "Female", 1 ),

    -- Third Generation
    ( 26, "Remus", "Male", 1 ),
    ( 27, "Draco", "Male", 1 ),
    ( 28, "Aster", "Female", 1 ),
    ( 29, "William", "Male", 1 ),
    ( 30, "Ron", "Male", 1 ),
    ( 31, "Ginny", "Female", 1 );
