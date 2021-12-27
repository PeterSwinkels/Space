DEFINT A-Z
OPTION BASE 0

DECLARE FUNCTION FileExists (File$)
DECLARE FUNCTION Initialize$ ()
DECLARE FUNCTION ProgramActive (Program$)
DECLARE FUNCTION ReadHelp (HelpFile$, HelpText$())
DECLARE FUNCTION Unescape$ (Text$)
DECLARE SUB Center (x, Text$)
DECLARE SUB DisplayHelp (HelpText$(), CursorX)
DECLARE SUB DrawBox (x, y, w, h, f, b, Shadow)
DECLARE SUB Main ()
DECLARE SUB Quit ()
ON ERROR GOTO ErrorTrap
DIM SHARED FileName$

CALL Main

ErrorTrap:
DIM ErrorCode
DIM Key$
DIM Selection

 PCOPY 0, 2
 Selection = 1
 ErrorCode = ERR
 DrawBox 10, 25, 26, 3, 12, 4, -1
 COLOR 14, 4
 LOCATE 11
 SELECT CASE ErrorCode
  CASE 7, 14
   Center 0, "Not enough memory."
  CASE 53
   Center 0, "Cannot find " + FileName$ + "."
  CASE 55
   Center 0, FileName$ + " already"
   Center 0, "opened."
  CASE 61
   Center 0, "The disk is full."
  CASE 62
   Center 0, "Error while reading"
   Center 0, FileName$ + "."
  CASE 70
   Center 0, "The disk or file is"
   Center 0, "write protected."
  CASE 71
   Center 0, "There is no disk in"
   Center 0, "the diskdrive."
  CASE 72
   Center 0, "The disk is damaged."
  CASE 75
   Center 0, "Cannot open file."
  CASE ELSE
   Center 0, "Unexpected error."
 END SELECT
 COLOR , 7
 DO
  IF Selection = 1 THEN COLOR 15 ELSE COLOR 0
  LOCATE 13, 28: PRINT " Retry ";
  IF Selection = 2 THEN COLOR 15 ELSE COLOR 0
  LOCATE , 36: PRINT " Ignore ";
  IF Selection = 3 THEN COLOR 15 ELSE COLOR 0
  LOCATE , 45: PRINT " Quit "
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  SELECT CASE Key$
   CASE CHR$(0) + "K"
    IF Selection > 1 THEN Selection = Selection - 1 ELSE Selection = 3
   CASE CHR$(0) + "M"
    IF Selection < 3 THEN Selection = Selection + 1 ELSE Selection = 1
   CASE CHR$(13)
    SELECT CASE Selection
     CASE 1
      PCOPY 2, 0
      RESUME
     CASE 2
      PCOPY 2, 0
      RESUME NEXT
     CASE 3
      Quit
    END SELECT
  END SELECT
 LOOP

SUB Center (x, Text$)
 IF x > 0 THEN LOCATE x
 LOCATE , 40 - (LEN(Text$) / 2)
 PRINT Text$
END SUB

SUB DisplayHelp (HelpText$(), CursorX)
DIM HelpLine
DIM Length
DIM Row

 Row = 2
 FOR HelpLine = CursorX TO CursorX + 42
  Length = LEN(HelpText$(HelpLine))
  LOCATE Row, 2
  SELECT CASE LEFT$(HelpText$(HelpLine), 1)
   CASE "-"
    PRINT STRING$(78, "Ä")
   CASE "="
    PRINT STRING$(78, "Í")
   CASE ">"
    PRINT SPACE$(78)
    Center Row, MID$(HelpText$(HelpLine), 2)
   CASE ELSE
    PRINT " "; Unescape$(HelpText$(HelpLine)); SPACE$(77 - Length)
  END SELECT
  Row = Row + 1
 NEXT HelpLine
END SUB

SUB DrawBox (x, y, w, h, f, b, Shadow)
DIM BoxX

 COLOR f, b
 LOCATE x, y
 PRINT "Ú"; STRING$(w, "Ä"); "¿"
 FOR BoxX = 1 TO h
  LOCATE , y: PRINT "³"; SPC(w); "³";
  IF Shadow THEN PRINT "°" ELSE PRINT
 NEXT BoxX
 LOCATE , y
 PRINT "À"; STRING$(w, "Ä"); "Ù";
 IF Shadow THEN
  PRINT "°"
  LOCATE , y + 1
  PRINT STRING$(w + 2, "°")
 END IF
END SUB

FUNCTION FileExists (File$)
DIM Exists
DIM FileH

 Exists = 0
 FileH = FREEFILE
 FileName$ = File$
 OPEN File$ FOR BINARY LOCK READ WRITE AS FileH
  Exists = (LOF(FileH) > 0)
 CLOSE FileH
 IF NOT Exists THEN KILL File$

FileExists = Exists
END FUNCTION

FUNCTION Initialize$
DIM HelpFile$

 SCREEN 0
 WIDTH 80, 50
 COLOR 7, 0
 CLS

 SELECT CASE -1
  CASE ProgramActive("Setup")
   HelpFile$ = "Setup.hlp"
  CASE ProgramActive("Space")
   HelpFile$ = "Space.hlp"
  CASE ELSE
   COLOR 7, 0: CLS
   PRINT "This program cannot be executed outside Setup or Space."
   PRINT
   PRINT "Press Enter to continue."
   DO UNTIL INKEY$ = CHR$(13)
   LOOP
   Quit
 END SELECT

 Initialize$ = HelpFile$
END FUNCTION

SUB Main
DIM CursorX
DIM HelpFile$
DIM HelpText$(0 TO 249)
DIM Key$
DIM LineCount

 CursorX = 0
 HelpFile$ = Initialize$
 LineCount = ReadHelp(HelpFile$, HelpText$())
 COLOR , 0
 CLS

 COLOR 15, 2
 LOCATE 48
 PRINT " Use "; CHR$(24) + " and " + CHR$(25) + " to scroll.   Press Escape to go back."; SPACE$(30)
 DrawBox 1, 1, 78, 45, 0, 7, 0
 Center 1, "´ Help Ã"
 DO
  DisplayHelp HelpText$(), CursorX
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  SELECT CASE Key$
   CASE CHR$(0) + "H"
    IF CursorX > 0 THEN CursorX = CursorX - 1
   CASE CHR$(0) + "P"
    IF CursorX < LineCount - 42 THEN CursorX = CursorX + 1
   CASE CHR$(27)
    SELECT CASE -1
     CASE ProgramActive("Setup")
      RUN "Setup"
     CASE ProgramActive("Space")
      RUN "Space"
    END SELECT
  END SELECT
 LOOP
END SUB

FUNCTION ProgramActive (Program$)
DIM Active
DIM FileH

 Active = 0
 FileName$ = Program$ + ".sts"
 IF FileExists(FileName$) THEN
  FileH = FREEFILE
  OPEN Program$ + ".sts" FOR BINARY LOCK READ WRITE AS FileH
   Active = (ASC(INPUT$(1, FileH)) = 1)
  CLOSE FileH
 END IF
 ProgramActive = Active
END FUNCTION

SUB Quit
 SCREEN 0
 COLOR 7, 0
 CLS
 WIDTH 80, 25
 PALETTE
 SYSTEM
END SUB

FUNCTION ReadHelp (HelpFile$, HelpText$())
DIM FileH
DIM HelpLine
DIM LineCount

 FileH = FREEFILE
 FileName$ = HelpFile$
 OPEN HelpFile$ FOR INPUT LOCK READ WRITE AS FileH
  FOR HelpLine = LBOUND(HelpText$) TO UBOUND(HelpText$)
   IF EOF(FileH) THEN
    LineCount = HelpLine
    EXIT FOR
   ELSE
    LINE INPUT #FileH, HelpText$(HelpLine)
   END IF
  NEXT HelpLine
 CLOSE FileH

 ReadHelp = LineCount
END FUNCTION

FUNCTION Unescape$ (Text$)
DIM Character$
DIM Hexadecimals$
DIM Index
DIM NextCharacter$
DIM Unescaped$

 Index = 1
 Unescaped$ = ""
 DO UNTIL Index > LEN(Text$)
  Character$ = MID$(Text$, Index, 1)
  NextCharacter$ = MID$(Text$, Index + 1, 1)
  IF Character$ = "/" THEN
   IF NextCharacter$ = "/" THEN
    Unescaped$ = Unescaped$ + Character$
    Index = Index + 1
   ELSE
    Hexadecimals$ = UCASE$(MID$(Text$, Index + 1, 2))
    IF LEN(Hexadecimals$) = 2 THEN
     IF LEFT$(Hexadecimals$, 1) = "0" THEN Hexadecimals$ = RIGHT$(Hexadecimals$, 1)
     IF UCASE$(HEX$(VAL("&H" + Hexadecimals$))) = Hexadecimals$ THEN
      Unescaped$ = Unescaped$ + CHR$(VAL("&H" + Hexadecimals$))
      Index = Index + 2
     ELSE
      EXIT DO
     END IF
    ELSE
     EXIT DO
    END IF
   END IF
  ELSE
   Unescaped$ = Unescaped$ + Character$
  END IF
  Index = Index + 1
 LOOP
   
 Unescape$ = Unescaped$
END FUNCTION

