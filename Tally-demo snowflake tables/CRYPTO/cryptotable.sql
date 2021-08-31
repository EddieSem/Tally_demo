COPY INTO "MYDB"."MYSCHEMA"."CRYPTOTABLE"
    FROM (select t.$1,t.$2,t.$3,t.$4,t.$5,t.$6,t.$7,t.$8,t.$9 from @tally_s3_stage t)
    file_format = (type = csv field_delimiter = ',' skip_header = 2)
    PATTERN='.*coinbase.*.csv';


SELECT * FROM "MYDB"."MYSCHEMA"."CRYPTOTABLE"