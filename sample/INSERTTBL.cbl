      ******************************************************************
      *  Open Cobol ESQL (Ocesql) Sample Program
      *
      *  INSERTTBL -- demonstrates CONNECT, DROP TABLE, CREATE TABLE, 
      *               INSERT rows, COMMIT, ROLLBACK, DISCONNECT
      *
      *  Copyright 2013 Tokyo System House Co., Ltd.
      ******************************************************************
       IDENTIFICATION              DIVISION.
      ******************************************************************
       PROGRAM-ID.                 INSERTTBL.
       AUTHOR.                     TSH.
       DATE-WRITTEN.               2013-06-28.

      ******************************************************************
       DATA                        DIVISION.
      ******************************************************************
       WORKING-STORAGE             SECTION.
       01  TEST-DATA.
                                       *>"---+++++++++++++++++++++----"
      *   03 FILLER       PIC X(28) VALUE "0001HOKKAI TARO         0400".
      *   03 FILLER       PIC X(28) VALUE "0002AOMORI JIRO         0350".
      *   03 FILLER       PIC X(28) VALUE "0003AKITA SABURO        0300".
      *   03 FILLER       PIC X(28) VALUE "0004IWATE SHIRO         025p".
      *   03 FILLER       PIC X(28) VALUE "0005MIYAGI GORO         020p".
      *   03 FILLER       PIC X(28) VALUE "0006FUKUSHIMA RIKURO    0150".
      *   03 FILLER       PIC X(28) VALUE "0007TOCHIGI SHICHIRO    010p".
      *   03 FILLER       PIC X(28) VALUE "0008IBARAKI HACHIRO     0050".
      *   03 FILLER       PIC X(28) VALUE "0009GUMMA KURO          020p".
      *   03 FILLER       PIC X(28) VALUE "0010SAITAMA JURO        0350".
         03 FILLER       PIC X(28) VALUE "0001�k�C�@���Y          0400".
         03 FILLER       PIC X(28) VALUE "0002�X�@���Y          0350".
         03 FILLER       PIC X(28) VALUE "0003�H�c�@�O�Y          0300".
         03 FILLER       PIC X(28) VALUE "0004���@�l�Y          025p".
         03 FILLER       PIC X(28) VALUE "0005�{��@�ܘY          020p".
         03 FILLER       PIC X(28) VALUE "0006�����@�Z�Y          0150".
         03 FILLER       PIC X(28) VALUE "0007�Ȗ؁@���Y          010p".
         03 FILLER       PIC X(28) VALUE "0008���@���Y          0050".
         03 FILLER       PIC X(28) VALUE "0009�Q�n�@��Y          020p".
         03 FILLER       PIC X(28) VALUE "0010��ʁ@�\�Y          0350".
       01  TEST-DATA-R   REDEFINES TEST-DATA.
         03  TEST-TBL    OCCURS  10.
           05  TEST-NO             PIC S9(04).
           05  TEST-NAME           PIC  X(20) .
           05  TEST-SALARY         PIC S9(04).
       01  IDX                     PIC  9(02).
       01  SYS-TIME                PIC  9(08).
 
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01  DBNAME                  PIC  X(30) VALUE SPACE.
       01  USERNAME                PIC  X(30) VALUE SPACE.
       01  PASSWD                  PIC  X(10) VALUE SPACE.
       01  EMP-REC-VARS.
         03  EMP-NO                PIC S9(04) VALUE ZERO.
         03  EMP-NAME              PIC  X(20) .
         03  EMP-SALARY            PIC S9(04) VALUE ZERO.
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.
      ******************************************************************
       PROCEDURE                   DIVISION.
      ******************************************************************
       MAIN-RTN.
           DISPLAY "*** INSERTTBL STARTED ***".

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
           
      *    DROP TABLE
           EXEC SQL
               DROP TABLE EMP
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN.
           
      *    CREATE TABLE 
           EXEC SQL
                CREATE TABLE EMP
                (
                    EMP_NO     NUMERIC(4,0) NOT NULL,
                    EMP_NAME   CHAR(20),
                    EMP_SALARY NUMERIC(4,0),
                    CONSTRAINT IEMP_0 PRIMARY KEY (EMP_NO)
                )
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN STOP RUN.
           
      *    INSERT ROWS USING LITERAL
           EXEC SQL
      *         INSERT INTO EMP VALUES (46, 'KAGOSHIMA ROKURO', -320)
               INSERT INTO EMP VALUES (46, '�������@�Z�Y', -320)
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN.

           EXEC SQL
      *         INSERT INTO EMP VALUES (47, 'OKINAWA SHICHIRO', 480)
               INSERT INTO EMP VALUES (47, '����@���Y', 480)
           END-EXEC.
           IF  SQLSTATE NOT = ZERO PERFORM ERROR-RTN.

      *    INSERT ROWS USING HOST VARIABLE
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 10
              MOVE TEST-NO(IDX)     TO  EMP-NO
              MOVE TEST-NAME(IDX)   TO  EMP-NAME
              MOVE TEST-SALARY(IDX) TO  EMP-SALARY
              EXEC SQL
                 INSERT INTO EMP VALUES
                        (:EMP-NO,:EMP-NAME,:EMP-SALARY)
              END-EXEC
              IF  SQLSTATE NOT = ZERO
                  PERFORM ERROR-RTN
                  EXIT PERFORM
              END-IF
           END-PERFORM.

      *    COMMIT
           EXEC SQL COMMIT WORK END-EXEC.
           
      *    DISCONNECT
           EXEC SQL
               DISCONNECT ALL
           END-EXEC.
           
      *    END
           DISPLAY "*** INSERTTBL FINISHED ***".
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
