# Tally_demo


Assignment: Use snowflake or similar to receive the pipeline from any 2 sources - could be streaming data or ETL or DB updates. In any one of them showcase some transformation step. For example, you can create a pipeline from S3 into Snowflake and a GitHub API feed. Introduce a transformation in the S3 stream and capitalise all words in that stream. 

*Loading Data into Snowflake via Bulk Loading Using COPY from Amazon S3*

- https://docs.snowflake.com/en/user-guide-data-load.html
- https://docs.snowflake.com/en/user-guide/data-load-bulk.html
- https://docs.snowflake.com/en/user-guide/data-load-s3.html
- https://docs.snowflake.com/en/user-guide/data-load-s3-config.html
- https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration.html

*Log Amazon S3 Object-Level Operations Using CloudWatch Events*

- https://github.com/awsdocs/amazon-cloudwatch-events-user-guide/blob/master/doc_source/log-s3-data-events.md

*Tables in Snowflake*

- "MYDB"."MYSCHEMA"."CRYPTOMYTABLE" 
- "MYDB"."MYSCHEMA"."COVIDTABLE" 
- "MYDB"."MYSCHEMA"."EVENTTABLE"



![](C:\Users\esemugabi\Documents\tally-demo.png)

The links stated under: *Loading Data into Snowflake via Bulk Loading Using COPY from Amazon S3* utilise the code below:  

 

```sql



##Create stroage intergration. 
##Code used for 'tallycovidsnowflake' and 'tallysnowflake'
CREATE STORAGE INTEGRATION tallyeventsnowflake
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = '<obtained from AWS IAM Roles>'
STORAGE_ALLOWED_LOCATIONS = ('<obtained from the highest AWS S3 bucket folder path location>', '<obtained from AWS S3 bucket folder path location>')


DESC INTEGRATION tallyeventsnowflake;

            ##Used when needed
            DROP INTEGRATION tallyeventsnowflake;


##Create an External Stage and load data. 
##Code used for 'tallycovid_s3_stage' and 'tally_s3_stage'
CREATE OR REPLACE FILE FORMAT my_json_format
                      TYPE = JSON

USE SCHEMA mydb.myschema;
CREATE OR REPLACE STAGE tallyevent_s3_stage
  STORAGE_INTEGRATION = tallyeventsnowflake
  URL = '<obtained from the lowest AWS S3 bucket folder path location>'
  FILE_FORMAT = my_json_format;
  
            ##Used when needed
            DROP STAGE tallyevent_s3_stage
            GRANT CREATE STAGE ON SCHEMA public TO ROLE ACCOUNTADMIN;
			GRANT USAGE ON INTEGRATION tallyeventsnowflake TO ROLE ACCOUNTADMIN;


##Create Database, schema and table. 
##Code used for 'mydb.myschema.covidtable' and 'mydb.myschema.cryptotable'
CREATE DATABASE mydb
CREATE SHCEMA myschema

CREATE TABLE IF NOT EXISTS mydb.myschema.eventtable (
    RECORD_CONTENT VARIANT
);

            ##Used when needed
            DROP TABLE "MYDB"."MYSCHEMA"."EVENTTABLE"

## Copy loaded data into table
##  Introduce a transformation in the S3 stream and capitalise all words in that stream    
COPY INTO "MYDB"."MYSCHEMA"."EVENTTABLE"
    FROM (select upper(t.$1) from @tallyevent_s3_stage t);
   
##MISC
SELECT * FROM "MYDB"."MYSCHEMA"."EVENTTABLE"

select t.$1 from @tallyevent_s3_stage t;
upper(t.$1)

##mydb.myschema.covidtable
CREATE TABLE IF NOT EXISTS mydb.myschema.covidtable
COPY INTO COVIDTABLE(PEOPLE_POSITIVE_CASES_COUNT, COUNTY_NAME, PROVINCE_STATE_NAME, REPORT_DATE, CONTINENT_NAME, DATA_SOURCE_NAME, PEOPLE_DEATH_NEW_COUNT, COUNTY_FIPS_NUMBER, COUNTRY_ALPHA_3_CODE, COUNTRY_SHORT_NAME, COUNTRY_ALPHA_2_CODE, PEOPLE_POSITIVE_NEW_CASES_COUNT, PEOPLE_DEATH_COUNT)
    from (select 
      $1:PEOPLE_POSITIVE_CASES_COUNT VARCHAR,
      $2:COUNTY_NAME VARCHAR,$3:PROVINCE_STATE_NAME VARCHAR,
      $4:REPORT_DATE VARCHAR,$5:CONTINENT_NAME VARCHAR,
      $6:DATA_SOURCE_NAME VARCHAR,
      $7:PEOPLE_DEATH_NEW_COUNT VARCHAR,
      $8:COUNTY_FIPS_NUMBER VARCHAR,
      $9:COUNTRY_ALPHA_3_CODE VARCHAR,
      $10:COUNTRY_SHORT_NAME VARCHAR,
      $11:COUNTRY_ALPHA_2_CODE VARCHAR,
      $12:PEOPLE_POSITIVE_NEW_CASES_COUNT VARCHAR,
      $13:PEOPLE_DEATH_COUNT VARCHAR 
      from @tallycovid_s3_stage t);

COPY INTO "MYDB"."MYSCHEMA"."COVIDTABLE"
    FROM (select upper(t.$1),t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9,t.$10,t.$11,t.$12,t.$13 from @tallycovid_s3_stage t)
    file_format = (type = csv field_delimiter = ',' skip_header = 1)
    PATTERN='.*COVID-19.*.csv';
    

##mydb.myschema.cryptotable
CREATE TABLE IF NOT EXISTS mydb.myschema.cryptotable (
  unix VARCHAR,
  date VARCHAR,	
  symbol VARCHAR,	
  open VARCHAR,	
  high VARCHAR,	
  low VARCHAR,	
  close VARCHAR,
  Volume_BTC VARCHAR,
  Volume_USD VARCHAR
);

COPY INTO "MYDB"."MYSCHEMA"."CRYPTOTABLE"
    FROM (select t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9 from @tally_s3_stage t)
    file_format = (type = csv field_delimiter = ',' skip_header = 2)
    PATTERN='.*coinbase.*.csv';

```

