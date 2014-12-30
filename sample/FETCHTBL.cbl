      ******************************************************************
      *  Open Cobol ESQL (Ocesql) Sample Program
      *
      *  FETCHTBL --- demonstrates CONNECT, SELECT COUNT(*), 
      *               DECLARE cursor, FETCH cursor, COMMIT, 
      *               ROLLBACK, DISCONNECT
      *
      *  Copyright 2013 Tokyo System House Co., Ltd.
      ******************************************************************
       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 FETCHTBL.
       AUTHOR.                     TSH.
       DATE-WRITTEN.               2013-06-28.

      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01  D-EMP-REC.
           05  D-EMP-NO            PIC  9(04).
           05  FILLER              PIC  X.
           05  D-EMP-NAME          PIC  X(20).
           05  FILLER              PIC  X.
           05  D-EMP-SALARY        PIC  --,--9.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.
       01  EMP-REC-VARS.
           05  EMP-NO              PIC S9(04).
           05  EMP-NAME            PIC  X(20) .
           05  EMP-SALARY          PIC S9(04).
       01  EMP-CNT                 PIC  9(04).
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           DISPLAY "*** FETCHTBL STARTED ***".
           
      *    WHENEVER IS NOT YET SUPPORTED :(
      *      EXEC SQL WHENEVER SQLERROR PERFORM ERROR-RTN END-EXEC.
           
      *    CONNECT
           MOVE  "testdb"          TO   DBNAME.
           MOVE  "postgres"        TO   USERNAME.
           MOVE  SPACE             TO   PASSWD.
           EXEC SQL
               CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME 
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN STOP RUN.
           
      *    SELECT COUNT(*) INTO HOST-VARIABLE
           EXEC SQL 
               SELECT COUNT(*) INTO :EMP-CNT FROM EMP
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN.
           DISPLAY "TOTAL RECORD: " EMP-CNT.
           
      *    DECLARE CURSOR
           EXEC SQL 
               DECLARE C1 CURSOR FOR
               SELECT EMP_NO, EMP_NAME, EMP_SALARY 
                      FROM EMP
                      ORDER BY EMP_NO
           END-EXEC.
           EXEC SQL
               OPEN C1
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN STOP RUN.
           
      *    FETCH
           DISPLAY "---- -------------------- ------".
           DISPLAY "NO   NAME                 SALARY".
           DISPLAY "---- -------------------- ------".
           EXEC SQL 
               FETCH C1 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
           END-EXEC.
           PERFORM UNTIL SQLSTATE NOT = ZERO
              MOVE  EMP-NO        TO    D-EMP-NO
              MOVE  EMP-NAME      TO    D-EMP-NAME
              MOVE  EMP-SALARY    TO    D-EMP-SALARY
              DISPLAY D-EMP-REC
              EXEC SQL 
                  FETCH C1 INTO :EMP-NO, :EMP-NAME, :EMP-SALARY
              END-EXEC
           END-PERFORM.
           IF  SQLSTATE NOT = "02000" PERFORM ERROR-RTN STOP RUN.
           
      *    CLOSE CURSOR
           EXEC SQL 
               CLOSE C1 
           END-EXEC. 
           
      *    COMMIT
           EXEC SQL 
               COMMIT WORK
           END-EXEC.
           
      *    DISCONNECT
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.
           
      *    END
           DISPLAY "*** FETCHTBL FINISHED ***".
           STOP RUN.

      ******************************************************************
       ERROR-RTN.
      ******************************************************************
           DISPLAY "*** SQL ERROR ***".
           DISPLAY "SQLSTATE: " SQLSTATE.
           EVALUATE SQLSTATE
              WHEN  "02000"
                 DISPLAY "Record not found"
              WHEN  "08003"
              WHEN  "08001"
                 DISPLAY "Connection falied"
              WHEN  SPACE
                 DISPLAY "Undefined error"
              WHEN  OTHER
                 DISPLAY "SQLCODE: "   SQLCODE
                 DISPLAY "SQLERRMC: "  SQLERRMC
              *> TO RESTART TRANSACTION, DO ROLLBACK.
                 EXEC SQL
                     ROLLBACK
                 END-EXEC
           END-EVALUATE.
      ******************************************************************

