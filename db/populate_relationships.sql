INSERT INTO Relationships ( Type, To_Member, Member )
VALUES
     -- King Arthur + Queen Margaret
    ("Married", 1, 2 ),
    ("is_Child", 2, 3 ), -- Bill
    ("is_Child", 2, 5 ), -- Charlie
    ("is_Child", 2, 6 ), -- Percy
    ("is_Child", 2, 8 ), -- Ronald
    ("is_Child", 2, 10 ), -- Ginerva

    -- Bill's + Flora's Lineage
    ("Married", 3, 4 ),
    ("is_Child", 4, 12 ), -- Victoire
    ("is_Child", 4, 14 ), -- Dominique
    ("is_Child", 4, 15 ), -- Louis
    -- Victoire + Ted
    ("Married", 12, 13 ),
    ("is_Child", 12, 26 ), -- Remus
    -- Percy + Audrey's Lineage
    ("Married", 6, 7 ), 
    ("is_Child", 7, 16 ), -- Molly
    ("is_Child", 7, 17 ), -- Lucy   
    
    -- Ronald + Helen's Lineage
    ("Married", 8, 9 ),
    ("is_Child", 9, 19 ), -- Rose
    ("is_Child", 9, 20 ), -- Hugo
    -- Rose + Malfoy
    ("Married", 19, 18 ),
    ("is_Child", 9, 27 ), -- Draco
    ("is_Child", 9, 28 ), -- Aster  
    
    -- Ginerva + Harry's Lineage
    ("Married", 10, 11 ),
    ("is_Child", 10, 22 ), -- James
    ("is_Child", 10, 24 ), -- Albus
    ("is_Child", 10, 25 ), -- Lily
    -- James + Darcy
    ("Married", 22, 21 ),
    ("is_Child", 21, 29 ), -- William
    -- Albus + Alice
    ("Married", 24, 23 ),
    ("is_Child", 23, 30 ), -- Ron
    ("is_Child", 23, 31 ); -- Ginny