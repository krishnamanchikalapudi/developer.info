CREATE DATABASE TESTDB;
COMMIT;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'my-secret-pw';
GRANT ALL ON TESTDB.* TO 'testuser'@'localhost';

COMMIT;

use TESTDB;

CREATE  TABLE IF NOT EXISTS TESTTABLE
(
  id INT NOT NULL AUTO_INCREMENT ,
  modifiedOn TIMESTAMP,
  createdOn TIMESTAMP,
  testname VARCHAR (50),
  PRIMARY KEY (id)
);

INSERT INTO TESTTABLE (testname, createdOn, modifiedOn) VALUES 
("name-1", NOW(), NOW()),
("name-2", NOW(), NOW()),
("name-3", NOW(), NOW()),
("name-4", NOW(), NOW());