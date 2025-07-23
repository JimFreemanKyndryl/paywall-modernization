IDENTIFICATION DIVISION.
       PROGRAM-ID. PWREGCIC.
       AUTHOR. LEGACY-SYSTEMS.
      ******************************************************************
      * CICS ONLINE CUSTOMER REGISTRATION PROGRAM                      *
      * TRANSACTION: PWRG                                              *
      ******************************************************************
       
       ENVIRONMENT DIVISION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
       01  WS-PROGRAM-FIELDS.
           05  WS-PROGRAM-NAME    PIC X(8) VALUE 'PWREGCIC'.
           05  WS-TRANS-ID        PIC X(4) VALUE 'PWRG'.
           05  WS-MAP-NAME        PIC X(7) VALUE 'PWREG01'.
           05  WS-MAPSET-NAME     PIC X(8) VALUE 'PWREGMAP'.
           05  WS-RESP            PIC S9(8) COMP.
           05  WS-RESP2           PIC S9(8) COMP.
           05  WS-COMMAREA-LEN    PIC S9(4) COMP VALUE 300.
           
       01  WS-COMMAREA.
           05  WS-FIRST-TIME      PIC X VALUE 'Y'.
           05  WS-ERROR-FLAG      PIC X VALUE 'N'.
           05  WS-PROCESS-FLAG    PIC X VALUE 'N'.
           05  WS-CUSTOMER-ID     PIC 9(10).
           05  WS-ACTIVATION-KEY  PIC X(32).
           
       01  WS-AID-FIELDS.
           05  WS-AID             PIC X.
               88  PF1-PRESSED    VALUE X'F1'.
               88  PF3-PRESSED    VALUE X'F3'.
               88  PF5-PRESSED    VALUE X'F5'.
               88  PF12-PRESSED   VALUE X'FC'.
               88  ENTER-PRESSED  VALUE X'7D'.
               88  CLEAR-PRESSED  VALUE X'6D'.
               
       01  WS-MESSAGES.
           05  WS-MSG-WELCOME     PIC X(79) VALUE
               'Welcome to Paywall Registration. Please fill all fields'.
           05  WS-MSG-SUCCESS     PIC X(79) VALUE
               'Registration successful! Your activation key is: '.
           05  WS-MSG-ERROR       PIC X(79) VALUE
               'Error occurred during registration. Please try again.'.
           05  WS-MSG-INVALID     PIC X(79) VALUE
               'Please correct highlighted fields and try again.'.
           05  WS-MSG-EXIT        PIC X(79) VALUE
               'Thank you for using Paywall Registration System.'.
           05  WS-MSG-DUP-EMAIL   PIC X(79) VALUE
               'Email already registered. Please use different email.'.
           05  WS-MSG-PAY-FAIL    PIC X(79) VALUE
               'Payment validation failed. Please check card details.'.
               
       01  WS-TIME-FIELDS.
           05  WS-ABSTIME         PIC S9(15) COMP-3.
           05  WS-TIME            PIC X(8).
           05  WS-DATE            PIC X(10).
           
       01  WS-ATTRIBUTE-FIELDS.
           05  WS-UNPROT-NORM     PIC X VALUE X'40'.
           05  WS-UNPROT-BRT      PIC X VALUE X'C8'.
           05  WS-UNPROT-DARK     PIC X VALUE X'4C'.
           05  WS-PROT-NORM       PIC X VALUE X'20'.
           05  WS-PROT-BRT        PIC X VALUE X'28'.
           05  WS-ERROR-ATTR      PIC X VALUE X'CA'.
           
      * COPY MAP DSECT
       COPY PWREGMAP.
       
      * LINKAGE TO BATCH REGISTRATION PROGRAM
       01  LS-CUSTREG-COMMAREA.
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
               
       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  LINK-AREA          PIC X(300).
           
       PROCEDURE DIVISION.
       
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           
           EVALUATE TRUE
               WHEN WS-FIRST-TIME = 'Y'
                   PERFORM 2000-SEND-MAP
               WHEN PF3-PRESSED OR PF12-PRESSED
                   PERFORM 9000-EXIT-PROGRAM
               WHEN PF5-PRESSED
                   PERFORM 2100-CLEAR-SCREEN
               WHEN PF1-PRESSED
                   PERFORM 2200-SHOW-HELP
               WHEN ENTER-PRESSED
                   PERFORM 3000-PROCESS-INPUT
               WHEN OTHER
                   MOVE 'Invalid key pressed. Use ENTER to submit.'
                       TO MSGO OF PWREG01O
                   PERFORM 2000-SEND-MAP
           END-EVALUATE
           
           PERFORM 8000-RETURN-CONTROL
           .
           
       1000-INITIALIZE.
           MOVE DFHCOMMAREA TO WS-COMMAREA
           
           IF EIBCALEN = 0
               MOVE 'Y' TO WS-FIRST-TIME
           ELSE
               MOVE 'N' TO WS-FIRST-TIME
           END-IF
           
           MOVE EIBTRNID TO WS-TRANS-ID
           MOVE EIBAID TO WS-AID
           .
           
       2000-SEND-MAP.
           IF WS-FIRST-TIME = 'Y'
               MOVE LOW-VALUES TO PWREG01O
               MOVE WS-MSG-WELCOME TO MSGO OF PWREG01O
           END-IF
           
           PERFORM 2010-GET-CURRENT-TIME
           
           EXEC CICS SEND
               MAP(WS-MAP-NAME)
               MAPSET(WS-MAPSET-NAME)
               FROM(PWREG01O)
               ERASE
               CURSOR
               RESP(WS-RESP)
           END-EXEC
           
           IF WS-RESP NOT = DFHRESP(NORMAL)
               PERFORM 9100-ABEND
           END-IF
           .
           
       2010-GET-CURRENT-TIME.
           EXEC CICS ASKTIME
               ABSTIME(WS-ABSTIME)
           END-EXEC
           
           EXEC CICS FORMATTIME
               ABSTIME(WS-ABSTIME)
               TIME(WS-TIME)
               DATESEP('/')
               TIMESEP(':')
               DATE(WS-DATE)
           END-EXEC
           .
           
       2100-CLEAR-SCREEN.
           MOVE LOW-VALUES TO PWREG01O
           MOVE SPACES TO EMAILO OF PWREG01O
                          PASSWDO OF PWREG01O
                          CONFPWO OF PWREG01O
                          FNAMEO OF PWREG01O
                          LNAMEO OF PWREG01O
                          PHONEO OF PWREG01O
                          PLANO OF PWREG01O
                          PAYMTO OF PWREG01O
                          CARDNOO OF PWREG01O
                          EXPIRYO OF PWREG01O
                          CVVO OF PWREG01O
           
           MOVE 'Screen cleared. Enter new registration data.'
               TO MSGO OF PWREG01O
           
           PERFORM 2000-SEND-MAP
           .
           
       2200-SHOW-HELP.
           EXEC CICS SEND TEXT
               FROM('HELP: Fill all fields. CC payment requires card info.')
               LENGTH(50)
               ERASE
           END-EXEC
           
           EXEC CICS SEND TEXT
               FROM('Plans: BAS=$9.99/mo PRE=$19.99/mo ENT=$49.99/mo')
               LENGTH(48)
           END-EXEC
           
           EXEC CICS SEND TEXT
               FROM('Press any key to return to registration screen...')
               LENGTH(49)
           END-EXEC
           
           EXEC CICS RECEIVE
           END-EXEC
           
           PERFORM 2000-SEND-MAP
           .
           
       3000-PROCESS-INPUT.
           EXEC CICS RECEIVE
               MAP(WS-MAP-NAME)
               MAPSET(WS-MAPSET-NAME)
               INTO(PWREG01I)
               RESP(WS-RESP)
           END-EXEC
           
           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE 'Error receiving data. Please try again.'
                   TO MSGO OF PWREG01O
               PERFORM 2000-SEND-MAP
               GO TO 3000-EXIT
           END-IF
           
           PERFORM 3100-VALIDATE-INPUT
           
           IF WS-ERROR-FLAG = 'Y'
               PERFORM 2000-SEND-MAP
               GO TO 3000-EXIT
           END-IF
           
           PERFORM 3200-CALL-REGISTRATION
           
           IF LS-RETURN-CODE = ZERO
               PERFORM 3300-DISPLAY-SUCCESS
           ELSE
               PERFORM 3400-DISPLAY-ERROR
           END-IF
           
       3000-EXIT.
           EXIT.
           
       3100-VALIDATE-INPUT.
           MOVE 'N' TO WS-ERROR-FLAG
           
      * Validate email
           IF EMAILL OF PWREG01I = 0 OR EMAILI OF PWREG01I = SPACES
               MOVE WS-ERROR-ATTR TO EMAILA OF PWREG01O
               MOVE 'Y' TO WS-ERROR-FLAG
               MOVE 'Email address is required.' TO MSGO OF PWREG01O
           END-IF
           
      * Validate password match
           IF PASSWDI OF PWREG01I NOT = CONFPWI OF PWREG01I
               MOVE WS-ERROR-ATTR TO PASSWDA OF PWREG01O
               MOVE WS-ERROR-ATTR TO CONFPWA OF PWREG01O
               MOVE 'Y' TO WS-ERROR-FLAG
               MOVE 'Passwords do not match.' TO MSGO OF PWREG01O
           END-IF
           
      * Validate names
           IF FNAMEL OF PWREG01I = 0 OR LNAMEL OF PWREG01I = 0
               MOVE WS-ERROR-ATTR TO FNAMEA OF PWREG01O
               MOVE WS-ERROR-ATTR TO LNAMEA OF PWREG01O
               MOVE 'Y' TO WS-ERROR-FLAG
               MOVE 'First and Last names are required.'
                   TO MSGO OF PWREG01O
           END-IF
           
      * Validate plan
           IF PLANI OF PWREG01I NOT = 'BAS' AND
              PLANI OF PWREG01I NOT = 'PRE' AND
              PLANI OF PWREG01I NOT = 'ENT'
               MOVE WS-ERROR-ATTR TO PLANA OF PWREG01O
               MOVE 'Y' TO WS-ERROR-FLAG
               MOVE 'Invalid plan code. Use BAS, PRE, or ENT.'
                   TO MSGO OF PWREG01O
           END-IF
           
      * Validate payment method
           IF PAYMTI OF PWREG01I NOT = 'CC' AND
              PAYMTI OF PWREG01I NOT = 'PP' AND
              PAYMTI OF PWREG01I NOT = 'BT'
               MOVE WS-ERROR-ATTR TO PAYMTA OF PWREG01O
               MOVE 'Y' TO WS-ERROR-FLAG
               MOVE 'Invalid payment method. Use CC, PP, or BT.'
                   TO MSGO OF PWREG01O
           END-IF
           
      * If credit card, validate card fields
           IF PAYMTI OF PWREG01I = 'CC'
               IF CARDNOL OF PWREG01I = 0 OR
                  EXPIRYL OF PWREG01I = 0 OR
                  CVVL OF PWREG01I = 0
                   MOVE WS-ERROR-ATTR TO CARDNOA OF PWREG01O
                   MOVE WS-ERROR-ATTR TO EXPIRYA OF PWREG01O
                   MOVE WS-ERROR-ATTR TO CVVA OF PWREG01O
                   MOVE 'Y' TO WS-ERROR-FLAG
                   MOVE 'Credit card details required for CC payment.'
                       TO MSGO OF PWREG01O
               END-IF
           END-IF
           .
           
       3200-CALL-REGISTRATION.
           INITIALIZE LS-CUSTREG-COMMAREA
           
           MOVE 'REGISTER' TO LS-FUNCTION
           MOVE EMAILI OF PWREG01I TO LS-EMAIL
           MOVE PASSWDI OF PWREG01I TO LS-PASSWORD
           MOVE FNAMEI OF PWREG01I TO LS-FIRST-NAME
           MOVE LNAMEI OF PWREG01I TO LS-LAST-NAME
           MOVE PHONEI OF PWREG01I TO LS-PHONE
           MOVE PLANI OF PWREG01I TO LS-PLAN-CODE
           MOVE PAYMTI OF PWREG01I TO LS-PAYMENT-METHOD
           
           IF PAYMTI OF PWREG01I = 'CC'
               MOVE CARDNOI OF PWREG01I TO LS-CARD-NUMBER
               MOVE EXPIRYI OF PWREG01I TO LS-CARD-EXPIRY
               MOVE CVVI OF PWREG01I TO LS-CARD-CVV
               MOVE '10001' TO LS-BILLING-ZIP
           END-IF
           
           EXEC CICS LINK
               PROGRAM('CUSTREG')
               COMMAREA(LS-CUSTREG-COMMAREA)
               LENGTH(LENGTH OF LS-CUSTREG-COMMAREA)
               RESP(WS-RESP)
           END-EXEC
           
           IF WS-RESP NOT = DFHRESP(NORMAL)
               MOVE -999 TO LS-RETURN-CODE
               MOVE 'Unable to process registration at this time.'
                   TO LS-ERROR-MSG
           END-IF
           .
           
       3300-DISPLAY-SUCCESS.
           MOVE LS-CUSTOMER-ID TO WS-CUSTOMER-ID
           MOVE LS-ACTIVATION-KEY TO WS-ACTIVATION-KEY
           
           STRING WS-MSG-SUCCESS DELIMITED BY SIZE
                  WS-ACTIVATION-KEY DELIMITED BY SIZE
                  INTO MSGO OF PWREG01O
           END-STRING
           
           MOVE SPACES TO PASSWDO OF PWREG01O
                          CONFPWO OF PWREG01O
                          CARDNOO OF PWREG01O
                          CVVO OF PWREG01O
           
           PERFORM 2000-SEND-MAP
           .
           
       3400-DISPLAY-ERROR.
           EVALUATE LS-RETURN-CODE
               WHEN -10
                   MOVE WS-MSG-DUP-EMAIL TO MSGO OF PWREG01O
                   MOVE WS-ERROR-ATTR TO EMAILA OF PWREG01O
               WHEN -20
                   MOVE WS-MSG-PAY-FAIL TO MSGO OF PWREG01O
                   MOVE WS-ERROR-ATTR TO CARDNOA OF PWREG01O
               WHEN OTHER
                   MOVE LS-ERROR-MSG TO MSGO OF PWREG01O
           END-EVALUATE
           
           PERFORM 2000-SEND-MAP
           .
           
       8000-RETURN-CONTROL.
           MOVE WS-COMMAREA TO DFHCOMMAREA
           
           EXEC CICS RETURN
               TRANSID(WS-TRANS-ID)
               COMMAREA(WS-COMMAREA)
               LENGTH(WS-COMMAREA-LEN)
           END-EXEC
           .
           
       9000-EXIT-PROGRAM.
           MOVE WS-MSG-EXIT TO MSGO OF PWREG01O
           PERFORM 2000-SEND-MAP
           
           EXEC CICS SEND
               CONTROL
               FREEKB
           END-EXEC
           
           EXEC CICS RETURN
           END-EXEC
           .
           
       9100-ABEND.
           EXEC CICS ABEND
               ABCODE('PWRG')
           END-EXEC
           .