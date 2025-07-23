IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTREG.
       AUTHOR. LEGACY-SYSTEMS.
       DATE-WRITTEN. 2015-03-15.
       DATE-COMPILED.
      ******************************************************************
      * CUSTOMER REGISTRATION FOR PAYWALL SYSTEM                       *
      * REGISTERS NEW CUSTOMERS, VALIDATES PAYMENT, CREATES ACCOUNT    *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AUDIT-FILE ASSIGN TO AUDITLOG
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-AUDIT-STATUS.
               
       DATA DIVISION.
       FILE SECTION.
       FD  AUDIT-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS.
       01  AUDIT-RECORD.
           05  AUDIT-TIMESTAMP    PIC X(26).
           05  AUDIT-USER-ID      PIC X(10).
           05  AUDIT-ACTION       PIC X(20).
           05  AUDIT-STATUS       PIC X(10).
           05  FILLER             PIC X(34).
           
       WORKING-STORAGE SECTION.
       01  WS-PROGRAM-FIELDS.
           05  WS-PROGRAM-NAME    PIC X(8) VALUE 'CUSTREG'.
           05  WS-RETURN-CODE     PIC S9(4) COMP VALUE ZERO.
           05  WS-AUDIT-STATUS    PIC XX.
           05  WS-CURRENT-DATE    PIC X(21).
           05  WS-SQLCODE-DISP    PIC -ZZZ9.
           
       01  WS-CUSTOMER-INPUT.
           05  WS-EMAIL           PIC X(50).
           05  WS-PASSWORD        PIC X(20).
           05  WS-FIRST-NAME      PIC X(30).
           05  WS-LAST-NAME       PIC X(30).
           05  WS-PHONE           PIC X(15).
           05  WS-PAYMENT-METHOD  PIC X(2).
               88  CREDIT-CARD    VALUE 'CC'.
               88  PAYPAL         VALUE 'PP'.
               88  BANK-TRANSFER  VALUE 'BT'.
           05  WS-PLAN-CODE       PIC X(3).
               88  BASIC-PLAN     VALUE 'BAS'.
               88  PREMIUM-PLAN   VALUE 'PRE'.
               88  ENTERPRISE     VALUE 'ENT'.
               
       01  WS-PAYMENT-DETAILS.
           05  WS-CARD-NUMBER     PIC X(16).
           05  WS-CARD-EXPIRY     PIC X(4).
           05  WS-CARD-CVV        PIC X(3).
           05  WS-BILLING-ZIP     PIC X(10).
           
       01  WS-GENERATED-FIELDS.
           05  WS-CUSTOMER-ID     PIC 9(10).
           05  WS-SUBSCRIPTION-ID PIC 9(10).
           05  WS-ACTIVATION-KEY  PIC X(32).
           05  WS-SALT            PIC X(16).
           05  WS-HASHED-PASSWORD PIC X(64).
           
       01  WS-FLAGS.
           05  WS-VALID-EMAIL     PIC X VALUE 'N'.
           05  WS-PAYMENT-OK      PIC X VALUE 'N'.
           05  WS-DUPLICATE-CHECK PIC X VALUE 'N'.
           
       01  WS-COUNTERS.
           05  WS-RETRY-COUNT     PIC 9(2) VALUE ZERO.
           05  WS-MAX-RETRIES     PIC 9(2) VALUE 3.
           
      * DB2 COMMUNICATION AREA
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.
           
      * DB2 HOST VARIABLES
       01  HV-CUSTOMER.
           05  HV-CUST-ID         PIC S9(9) COMP.
           05  HV-EMAIL           PIC X(50).
           05  HV-PASSWORD-HASH   PIC X(64).
           05  HV-SALT            PIC X(16).
           05  HV-FIRST-NAME      PIC X(30).
           05  HV-LAST-NAME       PIC X(30).
           05  HV-PHONE           PIC X(15).
           05  HV-STATUS          PIC X(1).
           05  HV-CREATED-DATE    PIC X(26).
           05  HV-LAST-LOGIN      PIC X(26).
           
       01  HV-SUBSCRIPTION.
           05  HV-SUB-ID          PIC S9(9) COMP.
           05  HV-SUB-CUST-ID     PIC S9(9) COMP.
           05  HV-PLAN-CODE       PIC X(3).
           05  HV-START-DATE      PIC X(10).
           05  HV-END-DATE        PIC X(10).
           05  HV-AUTO-RENEW      PIC X(1).
           05  HV-PAYMENT-METHOD  PIC X(2).
           05  HV-SUB-STATUS      PIC X(1).
           
       01  HV-PAYMENT.
           05  HV-PAY-ID          PIC S9(9) COMP.
           05  HV-PAY-CUST-ID     PIC S9(9) COMP.
           05  HV-PAY-METHOD      PIC X(2).
           05  HV-PAY-TOKEN       PIC X(64).
           05  HV-PAY-LAST4       PIC X(4).
           05  HV-PAY-EXPIRY      PIC X(4).
           05  HV-PAY-STATUS      PIC X(1).
           
       01  HV-ACTIVATION.
           05  HV-ACT-KEY         PIC X(32).
           05  HV-ACT-CUST-ID     PIC S9(9) COMP.
           05  HV-ACT-CREATED     PIC X(26).
           05  HV-ACT-USED        PIC X(1).
           
       LINKAGE SECTION.
       01  LS-COMMAREA.
           05  LS-FUNCTION        PIC X(8).
           05  LS-RETURN-CODE     PIC S9(4) COMP.
           05  LS-ERROR-MSG       PIC X(80).
           05  LS-CUSTOMER-DATA.
               10  LS-EMAIL       PIC X(50).
               10  LS-PASSWORD    PIC X(20).
               10  LS-FIRST-NAME  PIC X(30).
               10  LS-LAST-NAME   PIC X(30).
               10  LS-PHONE       PIC X(15).
               10  LS-PLAN-CODE   PIC X(3).
               10  LS-PAYMENT-METHOD PIC X(2).
           05  LS-PAYMENT-DATA.
               10  LS-CARD-NUMBER PIC X(16).
               10  LS-CARD-EXPIRY PIC X(4).
               10  LS-CARD-CVV    PIC X(3).
               10  LS-BILLING-ZIP PIC X(10).
           05  LS-OUTPUT-DATA.
               10  LS-CUSTOMER-ID PIC 9(10).
               10  LS-ACTIVATION-KEY PIC X(32).
               
       PROCEDURE DIVISION USING LS-COMMAREA.
       
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           
           EVALUATE LS-FUNCTION
               WHEN 'REGISTER'
                   PERFORM 2000-REGISTER-CUSTOMER
               WHEN 'VALIDATE'
                   PERFORM 3000-VALIDATE-CUSTOMER
               WHEN 'ACTIVATE'
                   PERFORM 4000-ACTIVATE-ACCOUNT
               WHEN OTHER
                   MOVE -1 TO LS-RETURN-CODE
                   MOVE 'INVALID FUNCTION CODE' TO LS-ERROR-MSG
           END-EVALUATE
           
           PERFORM 9000-FINALIZE
           GOBACK.
           
       1000-INITIALIZE.
           MOVE ZERO TO LS-RETURN-CODE
           MOVE SPACES TO LS-ERROR-MSG
           MOVE FUNCTION CURRENT-DATE TO WS-CURRENT-DATE
           
           EXEC SQL
               CONNECT TO PAYWLDB USER :USERID USING :PASSWORD
           END-EXEC
           
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO WS-SQLCODE-DISP
               STRING 'DB2 CONNECTION FAILED: ' WS-SQLCODE-DISP
                   DELIMITED BY SIZE INTO LS-ERROR-MSG
               MOVE -100 TO LS-RETURN-CODE
               PERFORM 9999-ABORT
           END-IF.
           
       2000-REGISTER-CUSTOMER.
           MOVE LS-CUSTOMER-DATA TO WS-CUSTOMER-INPUT
           MOVE LS-PAYMENT-DATA TO WS-PAYMENT-DETAILS
           
           PERFORM 2100-VALIDATE-INPUT
           IF LS-RETURN-CODE NOT = ZERO
               GO TO 2000-EXIT
           END-IF
           
           PERFORM 2200-CHECK-DUPLICATE
           IF WS-DUPLICATE-CHECK = 'Y'
               MOVE -10 TO LS-RETURN-CODE
               MOVE 'EMAIL ALREADY REGISTERED' TO LS-ERROR-MSG
               GO TO 2000-EXIT
           END-IF
           
           PERFORM 2300-PROCESS-PAYMENT
           IF WS-PAYMENT-OK NOT = 'Y'
               MOVE -20 TO LS-RETURN-CODE
               MOVE 'PAYMENT VALIDATION FAILED' TO LS-ERROR-MSG
               GO TO 2000-EXIT
           END-IF
           
           PERFORM 2400-CREATE-CUSTOMER
           PERFORM 2500-CREATE-SUBSCRIPTION
           PERFORM 2600-GENERATE-ACTIVATION
           PERFORM 2700-SEND-WELCOME-EMAIL
           
           MOVE WS-CUSTOMER-ID TO LS-CUSTOMER-ID
           MOVE WS-ACTIVATION-KEY TO LS-ACTIVATION-KEY
           
       2000-EXIT.
           EXIT.
           
       2100-VALIDATE-INPUT.
           IF WS-EMAIL = SPACES OR WS-PASSWORD = SPACES
               MOVE -2 TO LS-RETURN-CODE
               MOVE 'EMAIL AND PASSWORD REQUIRED' TO LS-ERROR-MSG
               GO TO 2100-EXIT
           END-IF
           
           PERFORM 2110-VALIDATE-EMAIL
           IF WS-VALID-EMAIL NOT = 'Y'
               MOVE -3 TO LS-RETURN-CODE
               MOVE 'INVALID EMAIL FORMAT' TO LS-ERROR-MSG
               GO TO 2100-EXIT
           END-IF
           
           IF WS-FIRST-NAME = SPACES OR WS-LAST-NAME = SPACES
               MOVE -4 TO LS-RETURN-CODE
               MOVE 'NAME FIELDS REQUIRED' TO LS-ERROR-MSG
               GO TO 2100-EXIT
           END-IF
           
           IF NOT (CREDIT-CARD OR PAYPAL OR BANK-TRANSFER)
               MOVE -5 TO LS-RETURN-CODE
               MOVE 'INVALID PAYMENT METHOD' TO LS-ERROR-MSG
               GO TO 2100-EXIT
           END-IF
           
           IF NOT (BASIC-PLAN OR PREMIUM-PLAN OR ENTERPRISE)
               MOVE -6 TO LS-RETURN-CODE
               MOVE 'INVALID PLAN CODE' TO LS-ERROR-MSG
           END-IF
           
       2100-EXIT.
           EXIT.
           
       2110-VALIDATE-EMAIL.
           MOVE 'N' TO WS-VALID-EMAIL
           INSPECT WS-EMAIL TALLYING WS-RETRY-COUNT FOR ALL '@'
           IF WS-RETRY-COUNT = 1
               MOVE 'Y' TO WS-VALID-EMAIL
           END-IF
           MOVE ZERO TO WS-RETRY-COUNT.
           
       2200-CHECK-DUPLICATE.
           MOVE WS-EMAIL TO HV-EMAIL
           
           EXEC SQL
               SELECT CUSTOMER_ID
               INTO :HV-CUST-ID
               FROM CUSTOMERS
               WHERE EMAIL = :HV-EMAIL
               FETCH FIRST 1 ROW ONLY
           END-EXEC
           
           IF SQLCODE = 0
               MOVE 'Y' TO WS-DUPLICATE-CHECK
           ELSE IF SQLCODE = +100
               MOVE 'N' TO WS-DUPLICATE-CHECK
           ELSE
               MOVE SQLCODE TO WS-SQLCODE-DISP
               STRING 'DUPLICATE CHECK ERROR: ' WS-SQLCODE-DISP
                   DELIMITED BY SIZE INTO LS-ERROR-MSG
               MOVE -101 TO LS-RETURN-CODE
               PERFORM 9999-ABORT
           END-IF.
           
       2300-PROCESS-PAYMENT.
           MOVE 'N' TO WS-PAYMENT-OK
           
           EVALUATE TRUE
               WHEN CREDIT-CARD
                   PERFORM 2310-VALIDATE-CREDIT-CARD
               WHEN PAYPAL
                   PERFORM 2320-VALIDATE-PAYPAL
               WHEN BANK-TRANSFER
                   PERFORM 2330-VALIDATE-BANK-TRANSFER
           END-EVALUATE.
           
       2310-VALIDATE-CREDIT-CARD.
           IF WS-CARD-NUMBER = SPACES OR 
              WS-CARD-EXPIRY = SPACES OR
              WS-CARD-CVV = SPACES
               MOVE 'N' TO WS-PAYMENT-OK
           ELSE
               CALL 'CCVALID' USING WS-CARD-NUMBER
                                    WS-CARD-EXPIRY
                                    WS-CARD-CVV
                                    WS-PAYMENT-OK
           END-IF.
           
       2320-VALIDATE-PAYPAL.
           MOVE 'Y' TO WS-PAYMENT-OK.
           
       2330-VALIDATE-BANK-TRANSFER.
           MOVE 'Y' TO WS-PAYMENT-OK.
           
       2400-CREATE-CUSTOMER.
           PERFORM 2410-GENERATE-CUSTOMER-ID
           PERFORM 2420-HASH-PASSWORD
           
           MOVE WS-CUSTOMER-ID TO HV-CUST-ID
           MOVE WS-EMAIL TO HV-EMAIL
           MOVE WS-HASHED-PASSWORD TO HV-PASSWORD-HASH
           MOVE WS-SALT TO HV-SALT
           MOVE WS-FIRST-NAME TO HV-FIRST-NAME
           MOVE WS-LAST-NAME TO HV-LAST-NAME
           MOVE WS-PHONE TO HV-PHONE
           MOVE 'A' TO HV-STATUS
           MOVE WS-CURRENT-DATE TO HV-CREATED-DATE
           MOVE SPACES TO HV-LAST-LOGIN
           
           EXEC SQL
               INSERT INTO CUSTOMERS
               (CUSTOMER_ID, EMAIL, PASSWORD_HASH, SALT,
                FIRST_NAME, LAST_NAME, PHONE, STATUS,
                CREATED_DATE, LAST_LOGIN)
               VALUES
               (:HV-CUST-ID, :HV-EMAIL, :HV-PASSWORD-HASH, :HV-SALT,
                :HV-FIRST-NAME, :HV-LAST-NAME, :HV-PHONE, :HV-STATUS,
                :HV-CREATED-DATE, :HV-LAST-LOGIN)
           END-EXEC
           
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO WS-SQLCODE-DISP
               STRING 'CUSTOMER INSERT ERROR: ' WS-SQLCODE-DISP
                   DELIMITED BY SIZE INTO LS-ERROR-MSG
               MOVE -102 TO LS-RETURN-CODE
               PERFORM 9999-ABORT
           END-IF.
           
       2410-GENERATE-CUSTOMER-ID.
           EXEC SQL
               SELECT NEXTVAL FOR CUSTOMER_SEQ
               INTO :HV-CUST-ID
               FROM SYSIBM.SYSDUMMY1
           END-EXEC
           
           MOVE HV-CUST-ID TO WS-CUSTOMER-ID.
           
       2420-HASH-PASSWORD.
           CALL 'HASHUTIL' USING WS-PASSWORD
                                 WS-SALT
                                 WS-HASHED-PASSWORD.
                                 
       2500-CREATE-SUBSCRIPTION.
           PERFORM 2510-GENERATE-SUBSCRIPTION-ID
           
           MOVE WS-SUBSCRIPTION-ID TO HV-SUB-ID
           MOVE WS-CUSTOMER-ID TO HV-SUB-CUST-ID
           MOVE WS-PLAN-CODE TO HV-PLAN-CODE
           MOVE WS-CURRENT-DATE(1:10) TO HV-START-DATE
           
           EVALUATE TRUE
               WHEN BASIC-PLAN
                   PERFORM 2520-CALC-END-DATE USING 30
               WHEN PREMIUM-PLAN
                   PERFORM 2520-CALC-END-DATE USING 365
               WHEN ENTERPRISE
                   PERFORM 2520-CALC-END-DATE USING 365
           END-EVALUATE
           
           MOVE 'Y' TO HV-AUTO-RENEW
           MOVE WS-PAYMENT-METHOD TO HV-PAYMENT-METHOD
           MOVE 'A' TO HV-SUB-STATUS
           
           EXEC SQL
               INSERT INTO SUBSCRIPTIONS
               (SUBSCRIPTION_ID, CUSTOMER_ID, PLAN_CODE,
                START_DATE, END_DATE, AUTO_RENEW,
                PAYMENT_METHOD, STATUS)
               VALUES
               (:HV-SUB-ID, :HV-SUB-CUST-ID, :HV-PLAN-CODE,
                :HV-START-DATE, :HV-END-DATE, :HV-AUTO-RENEW,
                :HV-PAYMENT-METHOD, :HV-SUB-STATUS)
           END-EXEC
           
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO WS-SQLCODE-DISP
               STRING 'SUBSCRIPTION INSERT ERROR: ' WS-SQLCODE-DISP
                   DELIMITED BY SIZE INTO LS-ERROR-MSG
               MOVE -103 TO LS-RETURN-CODE
               PERFORM 9999-ABORT
           END-IF.
           
       2510-GENERATE-SUBSCRIPTION-ID.
           EXEC SQL
               SELECT NEXTVAL FOR SUBSCRIPTION_SEQ
               INTO :HV-SUB-ID
               FROM SYSIBM.SYSDUMMY1
           END-EXEC
           
           MOVE HV-SUB-ID TO WS-SUBSCRIPTION-ID.
           
       2520-CALC-END-DATE USING DAYS-TO-ADD.
           CALL 'DATEUTIL' USING WS-CURRENT-DATE
                                 DAYS-TO-ADD
                                 HV-END-DATE.
                                 
       2600-GENERATE-ACTIVATION.
           CALL 'KEYGEN' USING WS-CUSTOMER-ID
                              WS-ACTIVATION-KEY
                              
           MOVE WS-ACTIVATION-KEY TO HV-ACT-KEY
           MOVE WS-CUSTOMER-ID TO HV-ACT-CUST-ID
           MOVE WS-CURRENT-DATE TO HV-ACT-CREATED
           MOVE 'N' TO HV-ACT-USED
           
           EXEC SQL
               INSERT INTO ACTIVATION_KEYS
               (ACTIVATION_KEY, CUSTOMER_ID, CREATED_DATE, USED)
               VALUES
               (:HV-ACT-KEY, :HV-ACT-CUST-ID, :HV-ACT-CREATED, :HV-ACT-USED)
           END-EXEC
           
           IF SQLCODE NOT = 0
               MOVE SQLCODE TO WS-SQLCODE-DISP
               STRING 'ACTIVATION INSERT ERROR: ' WS-SQLCODE-DISP
                   DELIMITED BY SIZE INTO LS-ERROR-MSG
               MOVE -104 TO LS-RETURN-CODE
               PERFORM 9999-ABORT
           END-IF.
           
       2700-SEND-WELCOME-EMAIL.
           CALL 'EMAILSVC' USING WS-EMAIL
                                 WS-FIRST-NAME
                                 WS-ACTIVATION-KEY
                                 'WELCOME'.
                                 
       2800-STORE-PAYMENT-TOKEN.
           PERFORM 2810-GENERATE-PAYMENT-ID
           
           MOVE WS-CUSTOMER-ID TO HV-PAY-CUST-ID
           MOVE WS-PAYMENT-METHOD TO HV-PAY-METHOD
           
           IF CREDIT-CARD
               CALL 'TOKENIZE' USING WS-CARD-NUMBER
                                    HV-PAY-TOKEN
               MOVE WS-CARD-NUMBER(13:4) TO HV-PAY-LAST4
               MOVE WS-CARD-EXPIRY TO HV-PAY-EXPIRY
           ELSE
               MOVE 'N/A' TO HV-PAY-TOKEN
               MOVE 'N/A' TO HV-PAY-LAST4
               MOVE 'N/A' TO HV-PAY-EXPIRY
           END-IF
           
           MOVE 'A' TO HV-PAY-STATUS
           
           EXEC SQL
               INSERT INTO PAYMENT_METHODS
               (PAYMENT_ID, CUSTOMER_ID, PAYMENT_METHOD,
                PAYMENT_TOKEN, LAST_FOUR, EXPIRY_DATE, STATUS)
               VALUES
               (:HV-PAY-ID, :HV-PAY-CUST-ID, :HV-PAY-METHOD,
                :HV-PAY-TOKEN, :HV-PAY-LAST4, :HV-PAY-EXPIRY,
                :HV-PAY-STATUS)
           END-EXEC.
           
       2810-GENERATE-PAYMENT-ID.
           EXEC SQL
               SELECT NEXTVAL FOR PAYMENT_SEQ
               INTO :HV-PAY-ID
               FROM SYSIBM.SYSDUMMY1
           END-EXEC.
           
       3000-VALIDATE-CUSTOMER.
           EXIT.
           
       4000-ACTIVATE-ACCOUNT.
           EXIT.
           
       9000-FINALIZE.
           PERFORM 9100-WRITE-AUDIT
           
           EXEC SQL
               COMMIT
           END-EXEC
           
           EXEC SQL
               DISCONNECT CURRENT
           END-EXEC.
           
       9100-WRITE-AUDIT.
           OPEN OUTPUT AUDIT-FILE
           
           MOVE WS-CURRENT-DATE TO AUDIT-TIMESTAMP
           MOVE WS-EMAIL TO AUDIT-USER-ID
           MOVE LS-FUNCTION TO AUDIT-ACTION
           
           IF LS-RETURN-CODE = ZERO
               MOVE 'SUCCESS' TO AUDIT-STATUS
           ELSE
               MOVE 'FAILED' TO AUDIT-STATUS
           END-IF
           
           WRITE AUDIT-RECORD
           CLOSE AUDIT-FILE.
           
       9999-ABORT.
           EXEC SQL
               ROLLBACK
           END-EXEC
           
           GOBACK.