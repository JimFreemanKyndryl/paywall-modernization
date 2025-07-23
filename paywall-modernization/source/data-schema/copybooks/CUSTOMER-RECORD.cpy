      ******************************************************************
      * CUSTOMER MASTER RECORD LAYOUT                                  *
      ******************************************************************
       01  CUSTOMER-RECORD.
           05  CUST-KEY.
               10  CUST-ID            PIC 9(10).
           05  CUST-DATA.
               10  CUST-EMAIL         PIC X(50).
               10  CUST-PASSWORD-HASH PIC X(64).
               10  CUST-SALT          PIC X(16).
               10  CUST-NAME.
                   15  CUST-FIRST-NAME PIC X(30).
                   15  CUST-LAST-NAME  PIC X(30).
               10  CUST-PHONE         PIC X(15).
               10  CUST-ADDRESS.
                   15  CUST-ADDR-LINE1 PIC X(100).
                   15  CUST-ADDR-LINE2 PIC X(100).
                   15  CUST-CITY       PIC X(50).
                   15  CUST-STATE      PIC X(50).
                   15  CUST-ZIP        PIC X(10).
                   15  CUST-COUNTRY    PIC X(2).
           05  CUST-STATUS-INFO.
               10  CUST-STATUS        PIC X(1).
                   88  CUST-ACTIVE    VALUE 'A'.
                   88  CUST-INACTIVE  VALUE 'I'.
                   88  CUST-SUSPENDED VALUE 'S'.
               10  CUST-EMAIL-VERIFIED PIC X(1).
               10  CUST-CREATED-DATE  PIC X(26).
               10  CUST-LAST-LOGIN    PIC X(26).
               10  CUST-FAILED-LOGINS PIC S9(4) COMP.
