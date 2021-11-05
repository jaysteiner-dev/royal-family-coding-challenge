CREATE DATABASE RoyalFamily;

Use RoyalFamily;

CREATE TABLE Members (
    MemberID INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (MemberID), 

    Name VARCHAR(255) NOT NULL,
    Gender ENUM('Male', 'Female', 'Nonbinary', 'Other') NOT NULL,
    DirectLineage BOOLEAN DEFAULT 1,
    DateAdded TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    LastUpdated TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE Relationships (
    RelationshipID INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (RelationshipID),

    Type ENUM('Married', 'is_Child') NOT NULL,
    To_Member INT NOT NULL,
    Member INT NOT NULL,
    CONSTRAINT FOREIGN KEY (To_Member) REFERENCES Members(MemberID),
    CONSTRAINT FOREIGN KEY (Member) REFERENCES Members(MemberID)
);