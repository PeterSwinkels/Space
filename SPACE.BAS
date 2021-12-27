DEFINT A-Z
OPTION BASE 0

TYPE EnemyStr
 Active AS INTEGER
 ColorV AS INTEGER
 Destroyed AS INTEGER
 ShipType AS INTEGER
 TorpedoActive AS INTEGER
 TorpedoX AS INTEGER
 TorpedoY AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE PalettesStr
 Enemy AS INTEGER
 Explosion AS INTEGER
 Star AS INTEGER
END TYPE

TYPE PlayerStr
 Destroyed AS INTEGER
 DirectionX AS INTEGER
 DirectionY AS INTEGER
 KillCount AS INTEGER
 NameV AS STRING * 25
 Score AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE SettingsStr
 JoystickOn AS INTEGER
 Level AS INTEGER
 LifeCount AS INTEGER
 Sensitivity AS INTEGER
 ShipColor AS INTEGER
 ShipType AS INTEGER
 SoundOn AS INTEGER
 StickCenterX AS INTEGER
 StickCenterY AS INTEGER
END TYPE

TYPE ScoreStr
 DateV AS STRING * 10
 EndLevel AS INTEGER
 NameV AS STRING * 25
 Score AS INTEGER
 StartLevel AS INTEGER
END TYPE

TYPE StarStr
 ColorV AS INTEGER
 x AS INTEGER
 y AS INTEGER
 z AS INTEGER
END TYPE

TYPE StatusStr
 EnemyCount AS INTEGER
 EnemiesLeft AS INTEGER
 NextLevelEntered AS INTEGER
 TorpedoCount AS INTEGER
 TorpedoesLeft AS INTEGER
END TYPE

TYPE TorpedoStr
 Active AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

DECLARE FUNCTION Choose$ (x, y, Text$, Choices$)
DECLARE FUNCTION FileExists (File$)
DECLARE FUNCTION GetInput$ (x, y, Prompt$, MaxLength)
DECLARE FUNCTION ReadScores (Score() AS ScoreStr)
DECLARE FUNCTION Trim$ (Text$)
DECLARE SUB AddNewEnemy (Enemy() AS EnemyStr, Palettes() AS PalettesStr, Settings AS SettingsStr, Status AS StatusStr)
DECLARE SUB AddScore (Player AS PlayerStr, Settings AS SettingsStr)
DECLARE SUB Center (x, Text$)
DECLARE SUB DisplayGraphics (File$, l, t, f, b)
DECLARE SUB DisplayMenu ()
DECLARE SUB DisplayNextLevelEntered (Player AS PlayerStr, Status AS StatusStr)
DECLARE SUB DisplayScores ()
DECLARE SUB DisplayStatus (Player AS PlayerStr, Settings AS SettingsStr)
DECLARE SUB DisplayTitle ()
DECLARE SUB DrawBox (x, y, w, h, f, b, Shadow)
DECLARE SUB DrawMenu (Option$())
DECLARE SUB FireTorpedo (Player AS PlayerStr, Settings AS SettingsStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DECLARE SUB GameOver (Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr)
DECLARE SUB GetJoystickStatus (Player AS PlayerStr, Settings AS SettingsStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DECLARE SUB GoToNextLevel (Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr, Status AS StatusStr)
DECLARE SUB Initialize ()
DECLARE SUB LoadGraphicsData (EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Ship$())
DECLARE SUB LoadSettings (Settings AS SettingsStr)
DECLARE SUB Main ()
DECLARE SUB MakeStars (Palettes() AS PalettesStr, Star() AS StarStr)
DECLARE SUB MoveEnemies (Enemy() AS EnemyStr, EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Settings AS SettingsStr, Status AS StatusStr)
DECLARE SUB MoveEnemyTorpedoes (Enemy() AS EnemyStr, Player AS PlayerStr, Settings AS SettingsStr)
DECLARE SUB MoveShip (Enemy() AS EnemyStr, EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Ship$(), Star() AS StarStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DECLARE SUB MoveStars (Palettes() AS PalettesStr, Star() AS StarStr)
DECLARE SUB MoveTorpedoes (Enemy() AS EnemyStr, Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DECLARE SUB Pause ()
DECLARE SUB PlaySound (SoundNumber, Settings AS SettingsStr)
DECLARE SUB Quit ()
DECLARE SUB SetProgramActive (Program$, NewActive)
ON ERROR GOTO ErrorTrap
DIM SHARED FileName$

Initialize
DisplayMenu

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

SUB AddNewEnemy (Enemy() AS EnemyStr, Palettes() AS PalettesStr, Settings AS SettingsStr, Status AS StatusStr)
DIM NewColor

 IF Status.EnemyCount <= UBOUND(Enemy) THEN
  Status.EnemyCount = Status.EnemyCount + 1
  Status.EnemiesLeft = Status.EnemiesLeft + 1
 
  Enemy(Status.EnemyCount - 1).Active = -1
  Enemy(Status.EnemyCount - 1).Destroyed = 0
  Enemy(Status.EnemyCount - 1).ShipType = CINT(RND * 3)
  IF Settings.Level > 250 THEN
   NewColor = CINT(RND * 2)
  ELSEIF Settings.Level < 251 THEN
   NewColor = CINT(RND * 4) * (((500 - Settings.Level) \ 1000) + 1)
  END IF
  IF NewColor < 4 THEN
   Enemy(Status.EnemyCount - 1).ColorV = Palettes(NewColor).Enemy
  ELSE
   Enemy(Status.EnemyCount - 1).ColorV = 0
  END IF
  Enemy(Status.EnemyCount - 1).x = 1
  Enemy(Status.EnemyCount - 1).y = CINT(RND * 76) + 1
 END IF
END SUB

SUB AddScore (Player AS PlayerStr, Settings AS SettingsStr)
DIM FileH
DIM Score(0 TO 19) AS ScoreStr
DIM Score1
DIM Score2
DIM ScoreCount
DIM ScoreIndex

 Score(UBOUND(Score)).DateV = DATE$
 Score(UBOUND(Score)).EndLevel = (500 - Settings.Level) / 10
 Score(UBOUND(Score)).NameV = Player.NameV
 Score(UBOUND(Score)).Score = Player.Score
 Score(UBOUND(Score)).StartLevel = (500 - Settings.Level) / 10

 ScoreCount = ReadScores(Score())

 FOR Score1 = LBOUND(Score) TO UBOUND(Score)
  FOR Score2 = LBOUND(Score) TO UBOUND(Score)
   IF Score(Score2).Score < Score(Score1).Score THEN
    SWAP Score(Score1), Score(Score2)
   END IF
  NEXT Score2
 NEXT Score1

 FileH = FREEFILE
 FileName$ = "Scores.lst"
 OPEN "Scores.lst" FOR OUTPUT LOCK READ WRITE AS FileH
  FOR ScoreIndex = 0 TO ScoreCount
   PRINT #FileH, CHR$(LEN(Trim$(Score(ScoreIndex).NameV))); Trim$(Score(ScoreIndex).NameV);
   PRINT #FileH, CHR$(LEN(LTRIM$(STR$(Score(ScoreIndex).Score)))); LTRIM$(STR$(Score(ScoreIndex).Score));
   PRINT #FileH, CHR$(LEN(Score(ScoreIndex).DateV)); Score(ScoreIndex).DateV;
   PRINT #FileH, CHR$(Score(ScoreIndex).StartLevel);
   PRINT #FileH, CHR$(Score(ScoreIndex).EndLevel);
  NEXT ScoreIndex
 CLOSE FileH
END SUB

SUB Center (x, Text$)
 IF x > 0 THEN LOCATE x
 LOCATE , 40 - (LEN(Text$) / 2)
 PRINT Text$
END SUB

FUNCTION Choose$ (x, y, Text$, Choices$)
DIM Choice$

 LOCATE x, y
 PRINT Text$
 DO
  Choice$ = UCASE$(INPUT$(1))
  IF INSTR(Choices$, Choice$) THEN EXIT DO
 LOOP
 LOCATE x, y
 PRINT SPACE$(LEN(Text$))

 Choose$ = Choice$
END FUNCTION

SUB DisplayGraphics (File$, l, t, f, b)
DIM FileH
DIM x
DIM y

 IF FileExists("Scores.grp") THEN
  COLOR f, b

  FileH = FREEFILE
  FileName$ = File$
  OPEN File$ FOR BINARY LOCK READ WRITE AS FileH
   DO UNTIL LOC(FileH) = LOF(FileH)
    x = ASC(INPUT$(1, FileH))
    y = ASC(INPUT$(1, FileH))
    LOCATE l + x, t + y
    PRINT INPUT$(1, FileH)
   LOOP
  CLOSE FileH
 ELSE
  ERROR 53
 END IF
END SUB

SUB DisplayMenu
DIM CursorX
DIM Key$
DIM MenuHelp$(0 TO 4)
DIM Option$(0 TO 4)

 Option$(0) = "Play"
 Option$(1) = "Settings"
 Option$(2) = "Help"
 Option$(3) = "Scores"
 Option$(4) = "Quit"
 MenuHelp$(0) = "Begin with game."
 MenuHelp$(1) = "Run settings."
 MenuHelp$(2) = "View help."
 MenuHelp$(3) = "View the scores."
 MenuHelp$(4) = "Exit this game."
 CursorX = 0

 DrawMenu Option$()
 DisplayTitle

 DO
  COLOR 11, 0: Center 45, MenuHelp$(CursorX)
  COLOR 14, 1: LOCATE (CursorX * 4) + 15, 4
  PRINT " "; Option$(CursorX); SPACE$(10 - LEN(Option$(CursorX)))
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  COLOR 14, 0: LOCATE (CursorX * 4) + 15, 4
  PRINT " "; Option$(CursorX); SPACE$(10 - LEN(Option$(CursorX)))
  LOCATE 45: PRINT SPACE$(80)
  SELECT CASE Key$
   CASE CHR$(0) + "H"
    IF CursorX > 0 THEN CursorX = CursorX - 1 ELSE CursorX = 4
   CASE CHR$(0) + "P"
    IF CursorX < 4 THEN CursorX = CursorX + 1 ELSE CursorX = 0
   CASE CHR$(13)
    SELECT CASE CursorX
     CASE 0
      CALL Main
      DrawMenu Option$()
      DisplayTitle
     CASE 1
      FileName$ = "Setup.exe"
      RUN "Setup"
     CASE 2
      FileName$ = "Help.exe"
      RUN "Help"
     CASE 3
      DisplayScores
     CASE 4
      COLOR 15
      IF Choose(47, 3, "Exit this game y/n?", "YN") = "Y" THEN Quit
    END SELECT
  END SELECT
 LOOP
END SUB

SUB DisplayNextLevelEntered (Player AS PlayerStr, Status AS StatusStr)
STATIC DelayStart AS SINGLE

 IF DelayStart = 0 THEN
  DelayStart = TIMER
 ELSE
  IF TIMER > DelayStart + 3 OR Player.Destroyed THEN
   COLOR , 0
   Center 24, SPACE$(32)
   DelayStart = 0
   Status.NextLevelEntered = 0
  ELSE
   COLOR 15
   Center 24, "You have entered the next level."
  END IF
 END IF
END SUB

SUB DisplayScores
DIM Score(0 TO 18) AS ScoreStr
DIM ScoreCount
DIM ScoreIndex

 PCOPY 0, 1
 COLOR , 0: CLS
 DisplayGraphics "Scores.grp", 1, 1, 11, 0
 DisplayGraphics "Scores.grp", 0, 0, 9, 1
 COLOR 10, 0: LOCATE 9: PRINT STRING$(80, "Ä")
 COLOR 15, 1
 PRINT " Name:"; SPACE$(25); "Score:  Date:       Start:  End:"; SPACE$(17)
 COLOR , 0

 ScoreCount = ReadScores(Score())
 IF ScoreCount = 0 THEN
  LOCATE , 3: PRINT "There are no scores."
 ELSE
  FOR ScoreIndex = 0 TO ScoreCount - 1
   LOCATE ((ScoreIndex + 1) * 2) + 10, 3
   PRINT USING "\" + SPACE$(25) + "\   ####   \" + SPACE$(12) + "\ ##    ##"; Score(ScoreIndex).NameV$; Score(ScoreIndex).Score; Score(ScoreIndex).DateV$; Score(ScoreIndex).StartLevel; Score(ScoreIndex).EndLevel
  NEXT ScoreIndex
 END IF
 COLOR 15, 1: LOCATE 48, 1: PRINT " Press Escape to return to the menu."; SPACE$(44)
 DO UNTIL INKEY$ = CHR$(27): LOOP
 PCOPY 1, 0
END SUB

SUB DisplayStatus (Player AS PlayerStr, Settings AS SettingsStr)
DIM Key$

 PCOPY 0, 1
 COLOR 15, 1
 LOCATE 1, 1: PRINT SPACE$(480)
 LOCATE 2, 1
 PRINT USING "     Level:   ##"; (500 - Settings.Level) / 10
 PRINT USING "     Score: ####"; Player.Score
 PRINT USING " Destroyed: ####"; Player.KillCount
 PRINT USING "     Lives:   ##"; Settings.LifeCount
 COLOR , 0
 Key$ = INPUT$(1)
 PCOPY 1, 0
END SUB

SUB DisplayTitle
 DisplayGraphics "Space.grp", 1, 1, 11, 0
 DisplayGraphics "Space.grp", 0, 0, 9, 1

 COLOR 3, 0
 LOCATE 5, 52: PRINT "Space,"
 LOCATE , 50: PRINT "version 1.08"
 LOCATE , 46: PRINT "by: Peter Swinkels,"
 LOCATE , 48: PRINT "***1998-1999***"
END SUB

SUB DrawBox (x, y, w, h, f, b, Shadow)
DIM BoxX

 COLOR f, b
 LOCATE x, y
 PRINT "Ú"; STRING$(w, "Ä"); "¿"
 FOR BoxX = 1 TO h
  LOCATE , y: PRINT "³"; SPACE$(w); "³";
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

SUB DrawMenu (Option$())
DIM OptionIndex

 COLOR 10, 0: CLS
 LOCATE 11: PRINT STRING$(80, "Ä")
 LOCATE 44: PRINT STRING$(80, "Ä")
 LOCATE 46: PRINT STRING$(80, "Ä")

 COLOR 15, 2
 LOCATE 43: PRINT " Use "; CHR$(24); "/"; CHR$(25); " to move the cursor and press Enter to select."; SPACE$(26)
 COLOR 14, 0
 FOR OptionIndex = LBOUND(Option$) TO UBOUND(Option$)
  LOCATE (OptionIndex * 4) + 15, 5
  PRINT Option$(OptionIndex)
 NEXT OptionIndex
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

SUB FireTorpedo (Player AS PlayerStr, Settings AS SettingsStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
 IF Status.TorpedoCount <= UBOUND(Torpedo) THEN
  Status.TorpedoCount = Status.TorpedoCount + 1
  Status.TorpedoesLeft = Status.TorpedoesLeft + 1
  Torpedo(Status.TorpedoCount - 1).Active = -1
  Torpedo(Status.TorpedoCount - 1).x = Player.x - 1
  Torpedo(Status.TorpedoCount - 1).y = Player.y + 1
  PlaySound 0, Settings
 END IF
END SUB

SUB GameOver (Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr)
 COLOR , 0: CLS
 PlaySound 4, Settings
 DO UNTIL INKEY$ = CHR$(27)
  COLOR 4: Center 23, "ÜÜÜÜÜÜÜÜÜÜÜÜ"
  COLOR 28, 4: Center 0, " Game over! "
  COLOR 4, 0: Center 0, "ßßßßßßßßßßßß"
  COLOR 15: Center 0, "Press Escape to return to menu."
  MoveStars Palettes(), Star()
 LOOP
 AddScore Player, Settings
 RUN "Space"
END SUB

FUNCTION GetInput$ (x, y, Prompt$, MaxLength)
DIM Key$
DIM Length
DIM Text$

 DO
  COLOR 7, 0
  LOCATE x, y: PRINT Prompt$; Text$; : COLOR 23: PRINT "_ "
  DO
   Key$ = INKEY$
  LOOP WHILE Key$ = ""
  Length = LEN(Text$)
  SELECT CASE ASC(Key$)
   CASE 8
    IF Length > 0 THEN Text$ = LEFT$(Text$, Length - 1)
   CASE 13
    EXIT DO
   CASE 27
    Text$ = ""
    EXIT DO
   CASE IS > 31
    IF Length < MaxLength THEN Text$ = Text$ + Key$
  END SELECT
 LOOP
 COLOR 7
 LOCATE x, y: PRINT SPACE$(LEN(Prompt$) + Length + 2)

 GetInput$ = Text$
END FUNCTION

SUB GetJoystickStatus (Player AS PlayerStr, Settings AS SettingsStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
 IF STICK(0) < Settings.StickCenterX - Settings.Sensitivity THEN
  Player.DirectionY = 1
 ELSEIF STICK(0) > Settings.StickCenterX + Settings.Sensitivity THEN
  Player.DirectionY = 2
 ELSE
  Player.DirectionY = 0
 END IF
 IF STICK(1) < Settings.StickCenterY - Settings.Sensitivity THEN
  Player.DirectionX = 1
 ELSEIF STICK(1) > Settings.StickCenterY + Settings.Sensitivity THEN
  Player.DirectionX = 2
 ELSE
  Player.DirectionX = 0
 END IF
 IF STRIG(1) THEN FireTorpedo Player, Settings, Status, Torpedo()
END SUB

SUB GoToNextLevel (Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr, Status AS StatusStr)
 IF Settings.Level > 0 THEN
  Settings.Level = Settings.Level - 10
  Status.NextLevelEntered = -1
  PlaySound 2, Settings
  DisplayNextLevelEntered Player, Status
 ELSE
  COLOR , 0: CLS
  PlaySound 3, Settings
  DO UNTIL INKEY$ = CHR$(27)
   COLOR 2: Center 23, "ÜÜÜÜÜÜÜÜÜÜ"
   COLOR 26, 2: Center 0, " You won! "
   COLOR 2, 0: Center 0, "ßßßßßßßßßß"
   COLOR 15: Center 0, "Press Escape to return to menu."
   MoveStars Palettes(), Star()
  LOOP
  AddScore Player, Settings
  RUN "Space"
 END IF
END SUB

SUB Initialize
 SetProgramActive "Space", -1
 RANDOMIZE TIMER
 PLAY "MB ML"
 SCREEN 0
 WIDTH 80, 50
 COLOR 7, 0
 CLS
END SUB

SUB LoadGraphicsData (EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Ship$())
DIM ExplosionIndex
DIM FileH
DIM PaletteIndex
DIM Row
DIM ShipIndex

 IF FileExists("Graphics.dat") THEN
  FileH = FREEFILE
  FileName$ = "Graphics.dat"
  OPEN "Graphics.dat" FOR BINARY LOCK READ WRITE AS FileH
   FOR ShipIndex = LBOUND(Ship$, 2) TO UBOUND(Ship$, 2)
    FOR Row = LBOUND(Ship$, 1) TO UBOUND(Ship$, 1)
     Ship$(Row, ShipIndex) = INPUT$(3, FileH)
     EnemyShip$(Row, ShipIndex) = INPUT$(3, FileH)
    NEXT Row
   NEXT ShipIndex
   FOR ExplosionIndex = LBOUND(Explosion$) TO UBOUND(Explosion$)
    Explosion$(ExplosionIndex) = INPUT$(1, FileH)
   NEXT ExplosionIndex
   FOR PaletteIndex = LBOUND(Palettes) TO UBOUND(Palettes)
    Palettes(PaletteIndex).Enemy = ASC(INPUT$(1, FileH))
    Palettes(PaletteIndex).Explosion = ASC(INPUT$(1, FileH))
    Palettes(PaletteIndex).Star = ASC(INPUT$(1, FileH))
   NEXT PaletteIndex
  CLOSE FileH
 ELSE
  ERROR 53
 END IF
END SUB

SUB LoadSettings (Settings AS SettingsStr)
DIM FileH

 FileH = FREEFILE
 FileName$ = "Space.set"
 OPEN "Space.set" FOR BINARY LOCK READ WRITE AS FileH
  IF LOF(1) = 0 THEN
   CLOSE 1
   KILL "Space.set"
   Settings.JoystickOn = 0
   Settings.Level = 500
   Settings.LifeCount = 5
   Settings.Sensitivity = 20
   Settings.ShipColor = 15
   Settings.ShipType = 0
   Settings.SoundOn = -1
  ELSE
   Settings.JoystickOn = (ASC(INPUT$(1, FileH)) = 1)
   Settings.Level = 500 - (ASC(INPUT$(1, FileH)) * 10)
   Settings.LifeCount = ASC(INPUT$(1, FileH))
   Settings.Sensitivity = ASC(INPUT$(1, FileH))
   Settings.ShipColor = ASC(INPUT$(1, FileH))
   Settings.ShipType = ASC(INPUT$(1, FileH))
   Settings.SoundOn = (ASC(INPUT$(1, FileH)) = 1)
  END IF
 CLOSE FileH
END SUB

SUB Main
DIM Enemy(0 TO 4) AS EnemyStr
DIM EnemyShip$(0 TO 2, 0 TO 3)
DIM Explosion$(0 TO 3)
DIM Key$
DIM Palettes(0 TO 3) AS PalettesStr
DIM Player AS PlayerStr
DIM PlayerName$
DIM Settings AS SettingsStr
DIM Ship$(0 TO 2, 0 TO 3)
DIM Star(0 TO 49) AS StarStr
DIM Status AS StatusStr
DIM Torpedo(0 TO 4) AS TorpedoStr
STATIC DelayStart AS SINGLE

 LoadSettings Settings
 LoadGraphicsData EnemyShip$(), Explosion$(), Palettes(), Ship$()

 Player.Destroyed = 0
 Player.DirectionX = 0
 Player.DirectionY = 0
 Player.KillCount = 0
 Player.NameV = ""
 Player.Score = 0
 Player.x = 20
 Player.y = 38

 PlayerName$ = GetInput$(47, 3, "Enter your name: ", 25)
 IF PlayerName$ = "" THEN EXIT SUB
 Player.NameV = PlayerName$

 MakeStars Palettes(), Star()

 COLOR 7, 0: CLS

 IF Settings.JoystickOn THEN
  COLOR 15: LOCATE 3, 3: PRINT "Make sure the joystick's stick is centered."
  Key$ = INPUT$(1)
  Settings.StickCenterX = STICK(0)
  Settings.StickCenterY = STICK(1)
  CLS
 END IF

 DelayStart = TIMER

 DO
  DO
   IF Status.EnemyCount > 0 THEN MoveEnemies Enemy(), EnemyShip$(), Explosion$(), Palettes(), Settings, Status
   IF Settings.JoystickOn AND NOT Player.Destroyed THEN GetJoystickStatus Player, Settings, Status, Torpedo()
   IF Status.NextLevelEntered THEN DisplayNextLevelEntered Player, Status
   IF Status.TorpedoCount THEN MoveTorpedoes Enemy(), Palettes(), Player, Settings, Star(), Status, Torpedo()
   IF Enemy(0).TorpedoActive OR Enemy(1).TorpedoActive OR Enemy(2).TorpedoActive OR Enemy(3).TorpedoActive OR Enemy(4).TorpedoActive THEN MoveEnemyTorpedoes Enemy(), Player, Settings
   IF TIMER > DelayStart + (Settings.Level / 500) THEN
    DelayStart = TIMER
    AddNewEnemy Enemy(), Palettes(), Settings, Status
   ELSE
    IF TIMER < 3 THEN DelayStart = TIMER
   END IF
   MoveStars Palettes(), Star()
   MoveShip Enemy(), EnemyShip$(), Explosion$(), Palettes(), Player, Settings, Ship$(), Star(), Status, Torpedo()
   Key$ = UCASE$(INKEY$)
  LOOP WHILE Key$ = ""
  IF NOT Player.Destroyed THEN
   IF NOT Settings.JoystickOn THEN
    SELECT CASE Key$
     CASE CHR$(0) + "H"
      IF Player.DirectionX = 1 THEN Player.DirectionX = 0 ELSE Player.DirectionX = 1
     CASE CHR$(0) + "P"
      IF Player.DirectionX = 2 THEN Player.DirectionX = 0 ELSE Player.DirectionX = 2
     CASE CHR$(0) + "K"
      IF Player.DirectionY = 1 THEN Player.DirectionY = 0 ELSE Player.DirectionY = 1
     CASE CHR$(0) + "M"
      IF Player.DirectionY = 2 THEN Player.DirectionY = 0 ELSE Player.DirectionY = 2
     CASE " "
      FireTorpedo Player, Settings, Status, Torpedo()
    END SELECT
   END IF
   IF Key$ = CHR$(0) + "O" THEN
    Player.DirectionX = 0
    Player.DirectionY = 0
   END IF
  END IF
  SELECT CASE Key$
   CASE CHR$(27)
    EXIT DO
   CASE "P"
    Pause
   CASE "S"
    DisplayStatus Player, Settings
  END SELECT
 LOOP
END SUB

SUB MakeStars (Palettes() AS PalettesStr, Star() AS StarStr)
DIM StarIndex

 FOR StarIndex = LBOUND(Star) TO UBOUND(Star)
  Star(StarIndex).ColorV = Palettes(CINT(RND * 3)).Star
  Star(StarIndex).x = CINT(RND * 45) + 1
  Star(StarIndex).y = CINT(RND * 79) + 1
  Star(StarIndex).z = CINT(RND * 1) + 1
 NEXT StarIndex
END SUB

SUB MoveEnemies (Enemy() AS EnemyStr, EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Settings AS SettingsStr, Status AS StatusStr)
DIM EnemyIndex
DIM Frame
DIM Row
STATIC EnemyDelayStart AS SINGLE
STATIC FireDelayStart AS SINGLE

 IF TIMER > EnemyDelayStart + .01 THEN
  EnemyDelayStart = TIMER
  FOR EnemyIndex = LBOUND(Enemy) TO UBOUND(Enemy)
   IF Enemy(EnemyIndex).Active THEN
    LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y: PRINT "   "
    LOCATE , Enemy(EnemyIndex).y: PRINT "   "
    LOCATE , Enemy(EnemyIndex).y: PRINT "   "
    IF Enemy(EnemyIndex).x = 45 THEN
     Enemy(EnemyIndex).Active = 0
     Status.EnemiesLeft = Status.EnemiesLeft - 1
     IF Status.EnemiesLeft = 0 THEN Status.EnemyCount = 0
    ELSE
     Enemy(EnemyIndex).x = Enemy(EnemyIndex).x + 1
     COLOR 12
     LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y: PRINT EnemyShip$(0, Enemy(EnemyIndex).ShipType)
     COLOR Enemy(EnemyIndex).ColorV
     LOCATE , Enemy(EnemyIndex).y: PRINT EnemyShip$(1, Enemy(EnemyIndex).ShipType)
     LOCATE , Enemy(EnemyIndex).y: PRINT EnemyShip$(2, Enemy(EnemyIndex).ShipType)
     IF TIMER > FireDelayStart + (Settings.Level / 1000) THEN
      FireDelayStart = TIMER
      IF NOT Enemy(EnemyIndex).TorpedoActive AND Enemy(EnemyIndex).Active THEN
       Enemy(EnemyIndex).TorpedoActive = -1
       Enemy(EnemyIndex).TorpedoX = Enemy(EnemyIndex).x + 1
       Enemy(EnemyIndex).TorpedoY = Enemy(EnemyIndex).y + 1
      END IF
     ELSE
      IF TIMER < 3 THEN FireDelayStart = TIMER
     END IF
    END IF
   ELSEIF Enemy(EnemyIndex).Destroyed THEN
    IF Enemy(EnemyIndex).x = 45 THEN
     Enemy(EnemyIndex).Destroyed = 0
     FOR Row = -2 TO 2
      LOCATE Enemy(EnemyIndex).x + Row, Enemy(EnemyIndex).y: PRINT "     "
     NEXT Row
    ELSE
     LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y: PRINT "   "
     LOCATE , Enemy(EnemyIndex).y: PRINT "   "
     LOCATE , Enemy(EnemyIndex).y: PRINT "   "
     Enemy(EnemyIndex).x = Enemy(EnemyIndex).x + 1
     FOR Frame = 0 TO 3
      COLOR Palettes(CINT(RND * 3)).Explosion
      LOCATE Enemy(EnemyIndex).x + CINT(RND * -2) + 2, Enemy(EnemyIndex).y + CINT(RND * -2) + 2
      PRINT Explosion$(CINT(RND * 3));
     NEXT Frame
    END IF
   END IF
  NEXT EnemyIndex
 ELSE
  IF TIMER < 3 THEN EnemyDelayStart = TIMER
 END IF
END SUB

SUB MoveEnemyTorpedoes (Enemy() AS EnemyStr, Player AS PlayerStr, Settings AS SettingsStr)
DIM Torpedo
STATIC DelayStart AS SINGLE

 IF TIMER > DelayStart + .01 THEN
  DelayStart = TIMER
  FOR Torpedo = LBOUND(Enemy) TO UBOUND(Enemy)
   IF Enemy(Torpedo).TorpedoActive THEN
    IF Enemy(Torpedo).TorpedoX > Player.x - 3 AND Enemy(Torpedo).TorpedoX < Player.x + 3 AND Enemy(Torpedo).TorpedoY > Player.y - 4 AND Enemy(Torpedo).TorpedoY < Player.y + 4 THEN
     Enemy(Torpedo).TorpedoActive = 0
     LOCATE Enemy(Torpedo).TorpedoX, Enemy(Torpedo).TorpedoY: PRINT " ";
     IF NOT Player.Destroyed THEN
      PlaySound 1, Settings
      Player.Destroyed = -1
     END IF
    END IF
   END IF
   IF Enemy(Torpedo).TorpedoActive THEN
    IF SCREEN(Enemy(Torpedo).TorpedoX, Enemy(Torpedo).TorpedoY) = 111 THEN
     LOCATE Enemy(Torpedo).TorpedoX, Enemy(Torpedo).TorpedoY: PRINT " ";
    END IF
    IF Enemy(Torpedo).TorpedoX >= 45 THEN
     Enemy(Torpedo).TorpedoActive = 0
    ELSE
     Enemy(Torpedo).TorpedoX = Enemy(Torpedo).TorpedoX + 2
     IF SCREEN(Enemy(Torpedo).TorpedoX, Enemy(Torpedo).TorpedoY) = 32 THEN
      COLOR 12: LOCATE Enemy(Torpedo).TorpedoX, Enemy(Torpedo).TorpedoY: PRINT "o";
     END IF
    END IF
   END IF
  NEXT Torpedo
 ELSE
  IF TIMER < 3 THEN DelayStart = TIMER
 END IF
END SUB

SUB MoveShip (Enemy() AS EnemyStr, EnemyShip$(), Explosion$(), Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Ship$(), Star() AS StarStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DIM Frame
DIM Key$
DIM Row
STATIC MoveDelayStart AS SINGLE
STATIC StatusMoveDelayStart AS SINGLE

 IF TIMER > MoveDelayStart + .01 THEN
  MoveDelayStart = TIMER
  LOCATE Player.x, Player.y: PRINT "   "
  LOCATE , Player.y: PRINT "   "
  LOCATE , Player.y: PRINT "   "
  IF Player.DirectionX = 1 THEN
   IF Player.x > 1 THEN Player.x = Player.x - 1
  ELSEIF Player.DirectionX = 2 THEN
   IF Player.x < 46 THEN Player.x = Player.x + 1
  END IF
  IF Player.DirectionY = 1 THEN
   IF Player.y > 1 THEN Player.y = Player.y - 1
  ELSEIF Player.DirectionY = 2 THEN
   IF Player.y < 78 THEN Player.y = Player.y + 1
  END IF
  IF NOT Player.Destroyed THEN
   COLOR Settings.ShipColor
   LOCATE Player.x, Player.y: PRINT Ship$(0, Settings.ShipType)
   LOCATE , Player.y: PRINT Ship$(1, Settings.ShipType)
   COLOR 12: LOCATE , Player.y: PRINT Ship$(2, Settings.ShipType)
  ELSE
   IF Player.x = 1 OR Player.x = 46 OR Player.y = 1 OR Player.y = 78 THEN
    Player.DirectionX = 0
    Player.DirectionY = 0
   END IF
   IF Player.DirectionX = 0 AND Player.DirectionY = 0 THEN
    Settings.LifeCount = Settings.LifeCount - 1
    IF Settings.LifeCount = 0 THEN GameOver Palettes(), Player, Settings, Star()
    StatusMoveDelayStart = TIMER
    DO UNTIL TIMER > StatusMoveDelayStart + 3 OR TIMER < 3
     IF Status.EnemyCount THEN MoveEnemies Enemy(), EnemyShip$(), Explosion$(), Palettes(), Settings, Status
     IF Settings.JoystickOn AND NOT Player.Destroyed THEN GetJoystickStatus Player, Settings, Status, Torpedo()
     IF Status.NextLevelEntered THEN DisplayNextLevelEntered Player, Status
     IF Status.TorpedoCount THEN MoveTorpedoes Enemy(), Palettes(), Player, Settings, Star(), Status, Torpedo()
     IF Enemy(0).TorpedoActive OR Enemy(1).TorpedoActive OR Enemy(2).TorpedoActive OR Enemy(3).TorpedoActive OR Enemy(4).TorpedoActive THEN MoveEnemyTorpedoes Enemy(), Player, Settings
     MoveStars Palettes(), Star()
     COLOR 15, 0
     Center 24, "Your ship has been destroyed."
     IF Settings.LifeCount = 1 THEN
      Center 0, "There is" + STR$(Settings.LifeCount) + " life left."
     ELSE
      Center 0, "There are" + STR$(Settings.LifeCount) + " lives left."
     END IF
     Key$ = INKEY$
    LOOP
    Player.Destroyed = 0
    Center 24, SPACE$(40)
    Center 0, SPACE$(40)
    Player.x = 20
    Player.y = 38
   END IF
   IF Player.x = 46 AND Player.DirectionX = 0 AND Player.DirectionY = 0 THEN
    Player.Destroyed = 0
    FOR Row = -2 TO 2
     LOCATE Player.x + Row, Player.y: PRINT "     "
    NEXT Row
   ELSE
    FOR Frame = 0 TO 3
     COLOR Palettes(CINT(RND * 3)).Explosion
     LOCATE Player.x + CINT(RND * -2) + 2, Player.y + CINT(RND * -2) + 2
     PRINT Explosion$(CINT(RND * 3));
    NEXT Frame
   END IF
  END IF
 ELSE
  IF TIMER < 3 THEN MoveDelayStart = TIMER
 END IF
END SUB

SUB MoveStars (Palettes() AS PalettesStr, Star() AS StarStr)
DIM StarIndex
STATIC DelayStart AS SINGLE

 IF TIMER > DelayStart + .01 THEN
  DelayStart = TIMER
  FOR StarIndex = LBOUND(Star) TO UBOUND(Star)
   IF SCREEN(Star(StarIndex).x, Star(StarIndex).y) = 46 THEN
    LOCATE Star(StarIndex).x, Star(StarIndex).y: PRINT " ";
   END IF
   IF Star(StarIndex).x + Star(StarIndex).z > 46 THEN
    Star(StarIndex).ColorV = Palettes(CINT(RND * 3)).Star
    Star(StarIndex).x = 1
    Star(StarIndex).y = CINT(RND * 79) + 1
    Star(StarIndex).z = CINT(RND * 1) + 1
   ELSE
    Star(StarIndex).x = Star(StarIndex).x + Star(StarIndex).z
   END IF
   IF SCREEN(Star(StarIndex).x, Star(StarIndex).y) = 32 THEN
    COLOR Star(StarIndex).ColorV
    LOCATE Star(StarIndex).x, Star(StarIndex).y
    PRINT ".";
   END IF
  NEXT StarIndex
 ELSE
  IF TIMER < 3 THEN DelayStart = TIMER
 END IF
END SUB

SUB MoveTorpedoes (Enemy() AS EnemyStr, Palettes() AS PalettesStr, Player AS PlayerStr, Settings AS SettingsStr, Star() AS StarStr, Status AS StatusStr, Torpedo() AS TorpedoStr)
DIM EnemyIndex
DIM TorpedoIndex
STATIC DelayStart AS SINGLE

 IF TIMER > DelayStart + .01 THEN
  DelayStart = TIMER
  FOR TorpedoIndex = LBOUND(Torpedo) TO UBOUND(Torpedo)
   FOR EnemyIndex = LBOUND(Enemy) TO UBOUND(Enemy)
    IF Torpedo(TorpedoIndex).Active AND Enemy(EnemyIndex).Active THEN
     IF Torpedo(TorpedoIndex).x > Enemy(EnemyIndex).x - 2 AND Torpedo(TorpedoIndex).x < Enemy(EnemyIndex).x + 2 AND Torpedo(TorpedoIndex).y > Enemy(EnemyIndex).y - 3 AND Torpedo(TorpedoIndex).y < Enemy(EnemyIndex).y + 3 THEN
      LOCATE Torpedo(TorpedoIndex).x, Torpedo(TorpedoIndex).y: PRINT " ";
      Torpedo(TorpedoIndex).Active = 0
      Status.TorpedoesLeft = Status.TorpedoesLeft - 1
      IF Status.TorpedoesLeft = 0 THEN Status.TorpedoCount = 0
      Enemy(EnemyIndex).Active = 0
      Status.EnemiesLeft = Status.EnemiesLeft - 1
      IF Status.EnemiesLeft = 0 THEN Status.EnemyCount = 0
      LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y: PRINT "   "
      LOCATE , Enemy(EnemyIndex).y: PRINT "   "
      LOCATE , Enemy(EnemyIndex).y: PRINT "   "

      PlaySound 1, Settings
      Enemy(EnemyIndex).Destroyed = -1

      SELECT CASE Enemy(EnemyIndex).ColorV
       CASE 0
        Player.Score = Player.Score + 5
       CASE 1
        IF Player.Score > 0 THEN Player.Score = Player.Score - 1
       CASE 4
        Player.Score = Player.Score + 1
       CASE 12
        Player.Score = Player.Score + 2
       CASE 14
        Player.Score = Player.Score + 3
      END SELECT
     
      Player.KillCount = Player.KillCount + 1
      IF Player.KillCount MOD 25 = 0 THEN
       GoToNextLevel Palettes(), Player, Settings, Star(), Status
      END IF
     END IF
    END IF
   NEXT EnemyIndex
   IF Torpedo(TorpedoIndex).Active THEN
    IF SCREEN(Torpedo(TorpedoIndex).x, Torpedo(TorpedoIndex).y) = 111 THEN
     LOCATE Torpedo(TorpedoIndex).x, Torpedo(TorpedoIndex).y: PRINT " ";
    END IF
    IF Torpedo(TorpedoIndex).x = 1 THEN
     Torpedo(TorpedoIndex).Active = 0
     Status.TorpedoesLeft = Status.TorpedoesLeft - 1
     IF Status.TorpedoesLeft = 0 THEN Status.TorpedoCount = 0
    ELSE
     Torpedo(TorpedoIndex).x = Torpedo(TorpedoIndex).x - 1
     IF SCREEN(Torpedo(TorpedoIndex).x, Torpedo(TorpedoIndex).y) = 32 THEN
      COLOR 14: LOCATE Torpedo(TorpedoIndex).x, Torpedo(TorpedoIndex).y: PRINT "o";
     END IF
    END IF
   END IF
  NEXT TorpedoIndex
 ELSE
  IF TIMER < 3 THEN DelayStart = TIMER
 END IF
END SUB

SUB Pause
 COLOR 15
 Center 24, "Game is paused."
 DO
 LOOP WHILE INKEY$ = ""
 Center 24, SPACE$(15)
END SUB

SUB PlaySound (SoundNumber, Settings AS SettingsStr)
DIM Note
DIM Repeat

 IF Settings.SoundOn THEN
  SELECT CASE SoundNumber
   CASE 0
    PLAY "T120 L64"
    FOR Note = 6 TO 27 STEP (Note + 1) * 6
     PLAY "N" + STR$(Note)
    NEXT Note
   CASE 1
    PLAY "T120 L64"
    FOR Note = 0 TO CINT(RND * 5) + 5
     PLAY "N" + STR$(CINT(RND * 32))
    NEXT Note
   CASE 2
    PLAY "T255 L64"
    FOR Repeat = 0 TO 1
     FOR Note = 4 TO 64 STEP 4
      PLAY "N" + STR$(Note)
      PLAY "N" + STR$(Note - 4)
     NEXT Note
    NEXT Repeat
   CASE 3
    PLAY "T255 << L16 CDEFABCDEFA L4 B >>"
   CASE 4
    PLAY "L16 T255"
    FOR Note = 32 TO 16 STEP -1
     PLAY "N" + STR$(Note)
    NEXT Note
  END SELECT
 END IF
END SUB

SUB Quit
 SetProgramActive "Space", 0
 COLOR 7, 0
 CLS
 PALETTE
 WIDTH 80, 25
 SYSTEM
END SUB

FUNCTION ReadScores (Score() AS ScoreStr)
DIM FileH
DIM Length
DIM ScoreCount
DIM ScoreIndex

 FileH = FREEFILE
 FileName$ = "Scores.lst"
 OPEN "Scores.lst" FOR BINARY LOCK READ WRITE AS FileH
  FOR ScoreIndex = LBOUND(Score) TO UBOUND(Score) - 1
   IF LOC(FileH) = LOF(FileH) THEN
    ScoreCount = ScoreIndex
    EXIT FOR
   ELSE
    Length = ASC(INPUT$(1, FileH))
    Score(ScoreIndex).NameV = INPUT$(Length, FileH)
    Length = ASC(INPUT$(1, FileH))
    Score(ScoreIndex).Score = VAL(INPUT$(Length, FileH))
    Length = ASC(INPUT$(1, FileH))
    Score(ScoreIndex).DateV = INPUT$(Length, FileH)
    Score(ScoreIndex).StartLevel = ASC(INPUT$(1, FileH))
    Score(ScoreIndex).EndLevel = ASC(INPUT$(1, FileH))
   END IF
  NEXT ScoreIndex
 CLOSE FileH

 ReadScores = ScoreCount
END FUNCTION

SUB SetProgramActive (Program$, NewActive)
DIM FileH

 FileName$ = Program$ + ".sts"
 FileH = FREEFILE
 OPEN FileName$ FOR OUTPUT LOCK READ WRITE AS FileH
  PRINT #FileH, CHR$(ABS(NewActive));
 CLOSE FileH
END SUB

FUNCTION Trim$ (Text$)
DIM Position

 Position = INSTR(Text$, CHR$(0))
 IF Position > 0 THEN Text$ = LEFT$(Text$, Position - 1)
 Trim$ = LTRIM$(RTRIM$(Text$))
END FUNCTION

