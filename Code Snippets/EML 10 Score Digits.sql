-- clean up
DROP TYPE "T_PARAMS";
DROP TYPE "T_DATA";
DROP TYPE "T_RESULTS";
DROP TABLE "SIGNATURE";
DROP TABLE "PARAMS";
DROP TABLE "RESULTS";
DROP VIEW "V_DATA";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP" ('EMLUSER', 'SCORE_DIGITS');

-- import MNIST table

-- create table types
CREATE TYPE "T_PARAMS" AS TABLE ("Parameter" VARCHAR(100), "Value" VARCHAR(100));
CREATE TYPE "T_DATA" AS TABLE ("x" BLOB);
CREATE TYPE "T_RESULTS" AS TABLE ("Classes" VARCHAR(100), "Scores" FLOAT);

-- create signature table then generate stored procedure
CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'EMLUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'EMLUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'EMLUSER', 'T_RESULTS', 'OUT');
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE" ('EML', 'PREDICT', 'EMLUSER', 'SCORE_DIGITS', "SIGNATURE");

-- create tables
CREATE TABLE "PARAMS" LIKE "T_PARAMS";
CREATE TABLE "RESULTS" LIKE "T_RESULTS";

-- run time

-- data to be scored
DROP VIEW "V_DATA";
CREATE VIEW "V_DATA" AS 
 SELECT "Image" AS "x" 
  FROM "MNIST" 
  WHERE "Label" = 7
 ;

-- params
TRUNCATE TABLE "PARAMS";
INSERT INTO "PARAMS" VALUES ('Model', 'mnist'); -- mandatory: model name (optional: signature name)
--INSERT INTO "PARAMS" VALUES ('Deadline', '1000'); -- optional: max milliseconds to wait

-- scoring : results inline
CALL "SCORE_DIGITS" ("PARAMS", "V_DATA", ?);

-- scoring : results in table
TRUNCATE TABLE "RESULTS";
CALL "SCORE_DIGITS" ("PARAMS", "V_DATA", "RESULTS") WITH OVERVIEW;
SELECT * FROM "RESULTS";
