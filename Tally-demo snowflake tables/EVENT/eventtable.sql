COPY INTO "MYDB"."MYSCHEMA"."EVENTTABLE"
    FROM (select upper(t.$1) from @tallyevent_s3_stage t);
           

SELECT * FROM "MYDB"."MYSCHEMA"."EVENTTABLE"   