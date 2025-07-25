//PAYWLREG JOB (ACCT),'PAYWALL REG',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID,REGION=0M
//*
//* COMPILE AND RUN CUSTOMER REGISTRATION PROGRAM
//*
//JOBLIB   DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//         DD DSN=PROD.LOADLIB,DISP=SHR
//*
//* STEP 1: DELETE OLD VERSIONS
//*
//DELETE   EXEC PGM=IEFBR14
//SYSPRINT DD SYSOUT=*
//DD1      DD DSN=PROD.PAYWALL.LOADLIB(CUSTREG),
//         DISP=(MOD,DELETE),SPACE=(TRK,0),
//         UNIT=SYSDA
//*
//* STEP 2: COMPILE COBOL PROGRAM
//*
//COMPILE  EXEC PGM=IGYCRCTL,
//         PARM='SQL,CICS,RENT,DATA(31),XREF,MAP,OFFSET,SSRANGE'
//STEPLIB  DD DSN=IGY.SIGYCOMP,DISP=SHR
//         DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSN=&&OBJECT,DISP=(NEW,PASS),
//         UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT2   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT3   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT4   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT5   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT6   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT7   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSIN    DD DSN=PROD.PAYWALL.SOURCE(CUSTREG),DISP=SHR
//SYSLIB   DD DSN=PROD.COPYLIB,DISP=SHR
//         DD DSN=SYS1.DB2.SDSNMACS,DISP=SHR
//*
//* STEP 3: DB2 PRECOMPILE
//*
//PC       EXEC PGM=DSNHPC,
//         PARM='HOST(COB),XREF,SOURCE,MAR(1,80)'
//STEPLIB  DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSCIN   DD DSN=&&DBRM,DISP=(NEW,PASS),
//         UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSLIB   DD DSN=PROD.COPYLIB,DISP=SHR
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT2   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSIN    DD DSN=&&OBJECT,DISP=(OLD,DELETE)
//*
//* STEP 4: BIND DB2 PACKAGE
//*
//BIND     EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=&&DBRM,DISP=(OLD,DELETE)
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DB2P)
  BIND PACKAGE(PAYWALL) -
       MEMBER(CUSTREG) -
       ACTION(REPLACE) -
       ISOLATION(CS) -
       VALIDATE(BIND) -
       RELEASE(COMMIT) -
       EXPLAIN(YES) -
       CURRENTDATA(YES) -
       DEGREE(1) -
       DYNAMICRULES(BIND) -
       OWNER(&SYSUID) -
       QUALIFIER(PAYWALL)
  END
/*
//*
//* STEP 5: LINK EDIT
//*
//LKED     EXEC PGM=IEWL,PARM='XREF,MAP,RENT,REUS,AMODE=31,RMODE=ANY'
//SYSPRINT DD SYSOUT=*
//SYSLIB   DD DSN=CEE.SCEELKED,DISP=SHR
//         DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//         DD DSN=PROD.LOADLIB,DISP=SHR
//SYSLMOD  DD DSN=PROD.PAYWALL.LOADLIB(CUSTREG),DISP=SHR
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSLIN   DD DSN=&&OBJECT,DISP=(OLD,DELETE)
//         DD *
  INCLUDE SYSLIB(DSNELI)
  INCLUDE SYSLIB(DSNALI)
  INCLUDE SYSLIB(DSNTIAR)
  ENTRY CUSTREG
  NAME CUSTREG(R)
/*
//*
//* STEP 6: EXECUTE TEST RUN
//*
//RUN      EXEC PGM=CUSTREG,COND=(4,LT)
//STEPLIB  DD DSN=PROD.PAYWALL.LOADLIB,DISP=SHR
//         DD DSN=SYS1.DB2.SDSNLOAD,DISP=SHR
//         DD DSN=CEE.SCEERUN,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//AUDITLOG DD DSN=PROD.PAYWALL.AUDIT.D&LYYMMDD..T&LHHMMSS,
//         DISP=(NEW,CATLG,DELETE),
//         UNIT=SYSDA,SPACE=(TRK,(10,10),RLSE),
//         DCB=(RECFM=FB,LRECL=100,BLKSIZE=0)
//SYSIN    DD *
REGISTER
/*
//PARMCARD DD *
EMAIL=john.doe@example.com
PASSWORD=SecurePass123!
FIRSTNAME=John
LASTNAME=Doe
PHONE=555-123-4567
PLANCODE=BAS
PAYMETHOD=CC
CARDNUM=4111111111111111
EXPIRY=1225
CVV=123
ZIPCODE=10001
/*