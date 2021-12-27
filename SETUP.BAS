DEFINT A-Z
OPTION BASE 0

TYPE SettingsStr
 JoystickOn AS INTEGER
 Level AS INTEGER
 LifeCount AS INTEGER
 Sensitivity AS INTEGER
 ShipColor AS INTEGER
 ShipType AS INTEGER
 SoundOn AS INTEGER
END TYPE

DECLARE FUNCTION FileExists (File$)
DECLARE FUNCTION ProgramActive (Program$)
DECLARE SUB Center (x, Text$)
DECLARE SUB DrawBox (x, y, w, h, f, b, Shadow)
DECLARE SUB DrawMenu (MenuHelp$(), Option$(), State$(), CursorX, Pressed)
DECLARE SUB Initialize ()
DECLARE SUB LoadSettings (Settings AS SettingsStr)
DECLARE SUB LoadShips (Ship$())
DECLARE SUB MakeButton (x, y, Text$, Selected)
DECLARE SUB Menu ()
DECLARE SUB PressButton (x, y, Text$)
DECLARE SUB Quit ()
DECLARE SUB SaveSettings (Settings AS SettingsStr)
DECLARE SUB SelectShip (Settings AS SettingsStr)
DECLARE SUB SetLevel (Settings AS SettingsStr)
DECLARE SUB SetLifeCount (Settings AS SettingsStr)
DECLARE SUB SetProgramActive (Program$, NewActive)
DECLARE SUB SetSensitivity (Settings AS SettingsStr)
DECLARE SUB TestJoystick (MenuHelp$(), Option$(), State$(), Settings AS SettingsStr)
ON ERROR GOTO ErrorTrap
DIM SHARED FileName$

Initialize
CALL Menu

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
 PRINT Text$;
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

SUB DrawMenu (MenuHelp$(), Option$(), State$(), CursorX, Pressed)
DIM Button
DIM Column
DIM Highlight
DIM Row

 Row = 4
 Column = 3

 COLOR 15, 2
 LOCATE 44
 PRINT " Use "; CHR$(24); "/"; CHR$(25); " to move the cursor and press Enter to select."; SPACE$(26)
 COLOR , 1
 LOCATE 1, 1
 PRINT " Setup for Space, by: Peter Swinkels, ***1999*** "; SPACE$(30);
 COLOR 3, 0
 PRINT "Ü"
 PRINT " "; STRING$(79, "ß")
 COLOR 10
 LOCATE 45
 PRINT STRING$(80, "Ä"); SPACE$(80)
 COLOR 11
 Center 46, MenuHelp$(CursorX)
 COLOR 10
 PRINT STRING$(80, "Ä")
 FOR Button = LBOUND(Option$) TO UBOUND(Option$)
  Highlight = (Button = CursorX)
  IF Button = Pressed THEN
   PressButton Row, Column, " " + Option$(Button) + SPACE$(27 - LEN(Option$(Button)))
  ELSE
   MakeButton Row, Column, " " + Option$(Button) + SPACE$(27 - LEN(Option$(Button))), Highlight
  END IF
  IF Row = 36 THEN
   Row = 4
   Column = Column + 30
  ELSE
   Row = Row + 4
  END IF
 NEXT Button
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

SUB Initialize
 SCREEN 0
 WIDTH 80, 50
 COLOR 7, 0
 CLS
 PALETTE 5, &H38
END SUB

SUB LoadSettings (Settings AS SettingsStr)
DIM FileH

 SetProgramActive "Setup", -1
 IF FileExists("Space.set") THEN
  FileH = FREEFILE
  FileName$ = "Space.set"
  OPEN FileName$ FOR BINARY LOCK READ WRITE AS FileH
   Settings.JoystickOn = (ASC(INPUT$(1, 1)) = 1)
   Settings.LifeCount = ASC(INPUT$(1, 1))
   Settings.Level = ASC(INPUT$(1, 1))
   Settings.Sensitivity = 20 - ASC(INPUT$(1, 1))
   Settings.ShipColor = ASC(INPUT$(1, 1))
   Settings.ShipType = ASC(INPUT$(1, 1))
   Settings.SoundOn = (ASC(INPUT$(1, 1)) = 1)
  CLOSE FileH
 ELSE
  Settings.JoystickOn = 0
  Settings.Level = 0
  Settings.LifeCount = 5
  Settings.Sensitivity = 0
  Settings.ShipColor = 15
  Settings.ShipType = 0
  Settings.SoundOn = -1
 END IF
END SUB

SUB LoadShips (Ship$())
DIM FileH
DIM Row
DIM Ship

 IF FileExists("Graphics.dat") THEN
  FileH = FREEFILE
  FileName$ = "Graphics.dat"
  OPEN "Graphics.dat" FOR BINARY LOCK READ WRITE AS FileH
   FOR Ship = LBOUND(Ship$, 2) TO UBOUND(Ship$, 2)
    FOR Row = LBOUND(Ship$, 1) TO UBOUND(Ship$, 1)
     Ship$(Row, Ship) = INPUT$(3, FileH)
     SEEK #FileH, SEEK(FileH) + 3
    NEXT Row
   NEXT Ship
  CLOSE FileH
 ELSE
  ERROR 53
 END IF
END SUB

SUB MakeButton (x, y, Text$, Selected)
DIM Length

 Length = LEN(Text$)
 COLOR 7, 0: LOCATE x, y: PRINT STRING$(Length, "Ü")
 IF Selected THEN COLOR 15 ELSE COLOR 0
 COLOR , 7: LOCATE , y: PRINT Text$;
 COLOR 8: PRINT "Û"
 COLOR 7, 0: LOCATE , y: PRINT "ß";
 COLOR , 5: PRINT STRING$(Length - 1, "ß");
 COLOR 8: PRINT "Û";
END SUB

SUB Menu
DIM CursorX
DIM Key$
DIM MenuHelp$(0 TO 9)
DIM Option$(0 TO 9)
DIM Pressed
DIM Settings AS SettingsStr
DIM State$(-1 TO 0)

 LoadSettings Settings

 CursorX = 0
 Pressed = -1

 MenuHelp$(0) = "Turn the sound on or off."
 MenuHelp$(1) = "Turn the joystick on or off."
 MenuHelp$(2) = "Test the joystick."
 MenuHelp$(3) = "Set the joystick's sensitivity."
 MenuHelp$(4) = "Set the level."
 MenuHelp$(5) = "Set the number of lives."
 MenuHelp$(6) = "Select a ship."
 MenuHelp$(7) = "Save the settings."
 MenuHelp$(8) = "Help."
 MenuHelp$(9) = "Exit this program."

 State$(-1) = " on"
 State$(0) = " off"

 Option$(0) = "The sound is" + State$(Settings.SoundOn)
 Option$(1) = "The joystick is" + State$(Settings.JoystickOn)
 Option$(2) = "Test the joystick"
 Option$(3) = "Joystick sensitivity"
 Option$(4) = "Level"
 Option$(5) = "Number of lives"
 Option$(6) = "Select a ship"
 Option$(7) = "Save the settings"
 Option$(8) = "Help"
 Option$(9) = "Quit"

 DO
  DrawMenu MenuHelp$(), Option$(), State$(), CursorX, Pressed
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  SELECT CASE Key$
   CASE CHR$(0) + "H"
    IF CursorX = 0 THEN CursorX = 9 ELSE CursorX = CursorX - 1
   CASE CHR$(0) + "P"
    IF CursorX = 9 THEN CursorX = 0 ELSE CursorX = CursorX + 1
   CASE CHR$(13)
    Pressed = CursorX
    DrawMenu MenuHelp$(), Option$(), State$(), CursorX, Pressed
    Pressed = -1
    PCOPY 0, 1
    SELECT CASE CursorX
     CASE 0
      Settings.SoundOn = NOT Settings.SoundOn
      Option$(0) = "The sound is" + State$(Settings.SoundOn)
     CASE 1
      Settings.JoystickOn = NOT Settings.JoystickOn
      Option$(1) = "The joystick is" + State$(Settings.JoystickOn)
     CASE 2
      TestJoystick MenuHelp$(), Option$(), State$(), Settings
     CASE 3
      SetSensitivity Settings
     CASE 4
      SetLevel Settings
     CASE 5
      SetLifeCount Settings
     CASE 6
      SelectShip Settings
     CASE 7
      SaveSettings Settings
     CASE 8
      FileName$ = "Help.exe"
      RUN "Help"
     CASE 9
      SetProgramActive "Setup", 0
      IF ProgramActive("Space") THEN RUN "Space" ELSE Quit
    END SELECT
    PCOPY 1, 0
  END SELECT
 LOOP
END SUB

SUB PressButton (x, y, Text$)
DIM Key$
DIM Length
DIM StartTime AS SINGLE

 Length = LEN(Text$)
 COLOR , 0

 LOCATE x, y: PRINT SPACE$(Length + 1)
 LOCATE , y: PRINT SPACE$(Length + 1)
 LOCATE , y: PRINT SPACE$(Length + 1)

 COLOR 7: LOCATE x + 1, y + 1: PRINT STRING$(Length, "Ü")
 COLOR 0, 7: LOCATE , y + 1: PRINT Text$
 COLOR 7, 0: LOCATE , y + 1: PRINT STRING$(Length, "ß")
 StartTime = TIMER
 DO UNTIL TIMER > StartTime + .1 OR TIMER < 3
  Key$ = INKEY$
 LOOP

 LOCATE x + 1, y + 1: PRINT SPACE$(Length)
 LOCATE , y + 1: PRINT SPACE$(Length)
 LOCATE , y + 1: PRINT SPACE$(Length)

 MakeButton x, y, Text$, -1
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

SUB SaveSettings (Settings AS SettingsStr)
DIM FileH

 FileH = FREEFILE
 FileName$ = "Space.set"
 OPEN "Space.set" FOR OUTPUT LOCK READ WRITE AS FileH
  PRINT #FileH, CHR$(ABS(Settings.JoystickOn));
  PRINT #FileH, CHR$(Settings.Level);
  PRINT #FileH, CHR$(Settings.LifeCount);
  PRINT #FileH, CHR$(20 - Settings.Sensitivity);
  PRINT #FileH, CHR$(Settings.ShipColor);
  PRINT #FileH, CHR$(Settings.ShipType);
  PRINT #FileH, CHR$(ABS(Settings.SoundOn));
 CLOSE FileH
END SUB

SUB SelectShip (Settings AS SettingsStr)
DIM Key$
DIM Ship$(0 TO 2, 0 TO 3)

 LoadShips Ship$()

 COLOR 15, 0
 Center 46, "Use " + CHR$(24) + "/" + CHR$(25) + " to select a ship. Use " + CHR$(27) + "/" + CHR$(26) + " to change the color."
 DO
  COLOR Settings.ShipColor
  LOCATE 9, 35: PRINT Ship$(0, Settings.ShipType)
  LOCATE , 35: PRINT Ship$(1, Settings.ShipType)
  COLOR 12
  LOCATE , 35: PRINT Ship$(2, Settings.ShipType)
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  SELECT CASE Key$
   CASE CHR$(0) + "H"
    IF Settings.ShipType = 0 THEN Settings.ShipType = 3 ELSE Settings.ShipType = Settings.ShipType - 1
   CASE CHR$(0) + "P"
    IF Settings.ShipType = 3 THEN Settings.ShipType = 0 ELSE Settings.ShipType = Settings.ShipType + 1
   CASE CHR$(0) + "K"
    IF Settings.ShipColor = 1 THEN Settings.ShipColor = 15 ELSE Settings.ShipColor = Settings.ShipColor - 1
   CASE CHR$(0) + "M"
    IF Settings.ShipColor = 15 THEN Settings.ShipColor = 1 ELSE Settings.ShipColor = Settings.ShipColor + 1
   CASE CHR$(27)
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB SetLevel (Settings AS SettingsStr)
DIM Key$

 COLOR 15, 0
 Center 46, "Use the  + and - keys to set the level."
 LOCATE 41, 6: PRINT "Level:"
 COLOR 3, 1: LOCATE , 4: PRINT STRING$(51, "°")
 COLOR 15, 0: LOCATE , 3: PRINT "-";
 COLOR 3, 1: PRINT STRING$(51, "°");
 COLOR 15, 0: PRINT "+"

 DO
  COLOR 1, 15
  LOCATE 42, Settings.Level + 4: PRINT "±"
  LOCATE , Settings.Level + 4: PRINT "±"
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  COLOR 3, 1
  LOCATE 42, Settings.Level + 4: PRINT "°"
  LOCATE , Settings.Level + 4: PRINT "°"
  SELECT CASE Key$
   CASE "+"
    IF Settings.Level = 50 THEN Settings.Level = 0 ELSE Settings.Level = Settings.Level + 1
   CASE "-"
    IF Settings.Level = 0 THEN Settings.Level = 50 ELSE Settings.Level = Settings.Level - 1
   CASE CHR$(27)
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB SetLifeCount (Settings AS SettingsStr)
DIM Key$

 COLOR 15, 0
 Center 46, "Use the + and - keys to set the number of lives."
 LOCATE 41, 4: PRINT "Number of lives:  0"
 COLOR 3, 1: LOCATE , 4: PRINT STRING$(50, "°")
 COLOR 15, 0: LOCATE , 3: PRINT "-";
 COLOR 3, 1: PRINT STRING$(50, "°");
 COLOR 15, 0: PRINT "+"

 DO
  COLOR 15, 0: LOCATE 41, 4: PRINT USING "Number of lives: ##"; Settings.LifeCount
  COLOR 1, 15
  LOCATE 42, (Settings.LifeCount * 2) + 2: PRINT "±±"
  LOCATE , (Settings.LifeCount * 2) + 2: PRINT "±±"
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  COLOR 3, 1
  LOCATE 42, (Settings.LifeCount * 2) + 2: PRINT "°°"
  LOCATE , (Settings.LifeCount * 2) + 2: PRINT "°°"
  SELECT CASE Key$
   CASE "+"
    IF Settings.LifeCount = 25 THEN Settings.LifeCount = 1 ELSE Settings.LifeCount = Settings.LifeCount + 1
   CASE "-"
    IF Settings.LifeCount = 1 THEN Settings.LifeCount = 25 ELSE Settings.LifeCount = Settings.LifeCount - 1
   CASE CHR$(27)
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB SetProgramActive (Program$, NewActive)
DIM FileH

 FileName$ = Program$ + ".sts"
 FileH = FREEFILE
 OPEN FileName$ FOR OUTPUT LOCK READ WRITE AS FileH
  PRINT #FileH, CHR$(ABS(NewActive));
 CLOSE FileH
END SUB

SUB SetSensitivity (Settings AS SettingsStr)
DIM Key$

 COLOR 15, 0
 Center 46, "Use the + and - keys to set the joystick's sensitivity."
 LOCATE 41, 6: PRINT "Sensitivity:"
 COLOR 3, 1: LOCATE , 4: PRINT STRING$(42, "°")
 COLOR 15, 0: LOCATE , 3: PRINT "-";
 COLOR 3, 1: PRINT STRING$(42, "°");
 COLOR 15, 0: PRINT "+"

 DO
  COLOR 1, 15
  LOCATE 42, (Settings.Sensitivity * 2) + 4: PRINT "±±"
  LOCATE , (Settings.Sensitivity * 2) + 4: PRINT "±±"
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  COLOR 3, 1
  LOCATE 42, (Settings.Sensitivity * 2) + 4: PRINT "°°"
  LOCATE , (Settings.Sensitivity * 2) + 4: PRINT "°°"
  SELECT CASE Key$
   CASE "+"
    IF Settings.Sensitivity = 20 THEN Settings.Sensitivity = 0 ELSE Settings.Sensitivity = Settings.Sensitivity + 1
   CASE "-"
    IF Settings.Sensitivity = 0 THEN Settings.Sensitivity = 20 ELSE Settings.Sensitivity = Settings.Sensitivity - 1
   CASE CHR$(27)
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB TestJoystick (MenuHelp$(), Option$(), State$(), Settings AS SettingsStr)
DIM CursorX
DIM CursorY
DIM DirectionX
DIM DirectionY
DIM Key$
DIM StartTime AS SINGLE
DIM StickCenterX
DIM StickCenterY

 CursorX = 4
 CursorY = 4
 DirectionX = 0
 DirectionY = 0
 StickCenterX = STICK(0)
 StickCenterY = STICK(1)

 PCOPY 0, 1
 DrawBox 19, 20, 36, 1, 15, 1, -1
 Center 20, "Make sure the joystick is centered."
 Key$ = INPUT$(1)
 PCOPY 1, 0
 
 DrawMenu MenuHelp$(), Option$(), State$(), 0, -1
 COLOR 11, 0: Center 46, "Move the joystick's stick to check if the cursor reacts properly."
 DO
  DrawBox 10, 34, 10, 10, 0, 7, 1
  LOCATE 24, 38: PRINT " Fire "
  COLOR 8: LOCATE CursorX + 11, CursorY + 35: PRINT "Û"
  IF STRIG(1) OR STRIG(5) THEN
   COLOR 15, 4
   IF STRIG(1) THEN LOCATE 24, 38: PRINT " Fire "
   StartTime = TIMER
   DO UNTIL TIMER > StartTime + .1 OR TIMER < 3
   LOOP
  END IF
  IF STICK(0) < StickCenterX - Settings.Sensitivity THEN
   DirectionY = 1
  ELSEIF STICK(0) > StickCenterX + Settings.Sensitivity THEN
   DirectionY = 2
  ELSE
   DirectionY = 0
  END IF
  IF STICK(1) < StickCenterY - Settings.Sensitivity THEN
   DirectionX = 1
  ELSEIF STICK(1) > StickCenterY + Settings.Sensitivity THEN
   DirectionX = 2
  ELSE
   DirectionX = 0
  END IF
  IF DirectionX = 1 THEN
   IF CursorX > 0 THEN CursorX = CursorX - 1
  ELSEIF DirectionX = 2 THEN
   IF CursorX < 9 THEN CursorX = CursorX + 1
  END IF
  IF DirectionY = 1 THEN
   IF CursorY > 0 THEN CursorY = CursorY - 1
  ELSEIF DirectionY = 2 THEN
   IF CursorY < 9 THEN CursorY = CursorY + 1
  END IF
 LOOP UNTIL INKEY$ = CHR$(27)
END SUB

