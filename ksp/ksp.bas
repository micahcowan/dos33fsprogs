' *********************************************
' *** KSP by Vince Weaver, vince@deater.net ***
' ***                                       ***
' ***       A VMW Software Production       ***
' *********************************************
' 
' http://www.deater.net/weave/vmwprod/ksp/
' https://github.com/deater/dos33fsprogs
'
' Note: you'll want to run this through my tokenize_asoft
'       routine to remove these comments and create a proper
'       Applesoft BASIC file
'       Why not use REM statements?  They take up valuable space
'       in RAM (we optimistically only have around 12kB to play with)
'       as well as slow down execution as BASIC is interpreted.
'
' Variable List: (Note, in Applesoft only first 2 chars matters)
'   A$   = keypressed
'   AN$  = astrounat name
'   C$   = contract name
'   D$   = ASCII(4) indicating we have a DOS command
'   AD() = astronaut dead
'   AN   = rocket angle
'   AX/AY= rocket x/y acceleration
'   BF   =
'   CQ   = current quadrant (i.e. background to display)
'   DT   = 
'   DV() = deltaV
'   EM() = per-stage empty mass
'   FM() = per-stage fuel mass
'   EN() = engines per stage
'   FF() = fuel flow
'   FT() = fuel tanks per stack
'   G    = gravity
'   GX/GY= gravity X/Y vector
'   H    = horizon
'   I    = loop iterator
'   J    = loop iterator
'   KE   = astronaut eyes
'   KR   = planet radius
'   LN   = launched
'   MX   = maximum altitude reached
'   OM   = orbit mode (view)
'   P    = number of parachutes
'   RA   = distance to center of planet
'   RR   = altitude
'   RX/RY= rocket x,y position
'   S    = Current Stage Number
'   SR   = Number of struts
'   SS   = Number of stages
'   TH() = stage thrust
'   TR   =
'   T    = time
'   SM() = per-stage stage mass
'   ST() = Stacks per stage
'   TM() = per-stage total mass
'   TW() = thrust/weight ratio
'   V    = velocity magnitude
'   VX/VY= velocity x/y vector
'   W    = Which astronaut
'
' Clear screen
  10  HOME:HGR:D$=CHR$(4)
' *** REM *** SQUAD LOADING SCREEN ***
  100 PRINT D$"BLOAD SQUAD.HGR,A$2000"
' *** REM *** Randmoize the start of the witty loading comments
  580 S=0:I=INT(RND(1)*8)+1
' *** REM *** Prepare for the status bar
  590 VTAB 21: PRINT "    ";:FOR I=1 TO 32: PRINT ".";: NEXT I
' *** REM *** LOADING SCREEN ***
  700 FOR J=1 TO 32
  708    IF J=16 THEN PRINT: PRINT D$"BLOAD LOADING.HGR,A$2000"
  710    HTAB J+4:VTAB 21
  720    INVERSE: PRINT " ";: NORMAL
  790    S=S+1: IF S=4 THEN S=0
  795    IF S<>1 GOTO 840
  800    I=I+1: IF I > 8 THEN I=1
  802    VTAB 22: HTAB 1:PRINT "                              ";
  805    ON I GOSUB 850,851,852,853,854,855,856,857
' *** REM *** Slow down so we don't load so fast
  840    FOR T=1 TO 250: NEXT T
  842 NEXT J
  845 GOTO 900
  850 HTAB 10:PRINT "Adding Extraneous Ks":RETURN
  851 HTAB 14:PRINT "Locating Jeb":RETURN
  852 HTAB 11:PRINT "Breaking Quicksaves":RETURN
  853 HTAB 12:PRINT "Patching Conics":RETURN
  854 HTAB 12:PRINT "Spinning up Duna":RETURN
  855 HTAB 11:PRINT "Warming up the 6502":RETURN
  856 HTAB 10:PRINT "Preparing Explosions":RETURN
  857 HTAB 10:PRINT "Unleashing the Kraken":RETURN
' *** REM *** TITLE SCREEN ***
  900 HOME: PRINT: PRINT D$"BLOAD TITLE.HGR,A$2000"
  905 HTAB 25:VTAB 24: PRINT "VERSION 1.3.7.1";
' *** REM ****************
' *** REM  KSP THEME MUSIC
' *** REM  SEE http://eightbitsoundandfury.ld8.org/programming.html
' *** REM  This loads an assembly language routine that generates 
' *** REM  Square waves on the speaker output
' *** REM ****************
  910 FOR L = 770 TO 790: READ V: POKE L,V: NEXT L
  920 DATA  173,48,192,136,208,5,206,1,3,240,9
  930 DATA  202,208,245,174,0,3,76,2,3,96
' *** REM on qbasic this would be PLAY "L2ECGL4CEGL2B-AGL4CEGL2B-AGCD"
  940 FOR I=1 TO 17: READ F: READ D: POKE 768,F: POKE 769,D: CALL 770: NEXT I
  950 DATA 202,216,255,216,170,216
  955 DATA 255,108,202,108,170,108
  960 DATA 143,216,152,216,170,216
  965 DATA 255,108,202,108,170,108
  970 DATA 143,216,152,216,170,216,255,216,227,255
' *** REM *** DONE LOADING ***
' *** REM *** Wait for keypress
  990 VTAB 1: GET A$
' *******************
' ***     VAB     ***
' *******************
'**** REM *** Point to shape table location and load in VAB table 
 1000 POKE 232,0:POKE 233,16
 1015 PRINT:PRINT D$"BLOAD VAB.SHAPE,A$1000"
 1035 HGR : ROT= 0: SCALE= 2
 1037 PRINT D$"BLOAD VAB.HGR,A$2000"
 1150 X=132:Y=28
 1155 XDRAW 1 AT X,Y+2 
 1200 HOME: INVERSE : VTAB  21: HTAB 7: PRINT " VEHICLE ASSEMBLY BUILDING "
 1205 NORMAL:PRINT:PRINT "HOW MANY STAGES? (1-3)";:INPUT S
 1230 FOR I = 1 TO S
 1240    PRINT "HOW MANY STACKS, STAGE ";I;" (1-3)";:INPUT T:ST(I) = T
 1260    PRINT "HOW MANY FUEL TANKS PER STACK, STAGE ";I;" (1-2)";
 1265    INPUT F: FT(I) = F
 1268    FOR J = 1 TO F
 1270       XDRAW 2 AT X, Y+13*J
 1272       IF T >1 THEN XDRAW 2 AT X-14, Y+13*J
 1274       IF T >2 THEN XDRAW 2 AT X+14, Y+13*J
 1278    NEXT J
 1279    Y=Y+13*F
 1280    PRINT "HOW MANY ENGINES, STAGE ";I;" (1-";T;")";:INPUT E
 1285    EN(I) = E
 1290    XDRAW 1 AT X, Y+8
 1292    IF E >1 THEN XDRAW 1 AT X-14, Y+8
 1294    IF E >2 THEN XDRAW 1 AT X+14, Y+8
 1297    Y=Y+6
 1300 NEXT I
 1330 PRINT "HOW MANY PARACHUTES? (0-3)";:INPUT P
 1350 PRINT "HOW MANY STRUTS? (0-20000)";:INPUT SR
 1370 SS=S
' *********************************
' ***     ASTRONAUT COMPLEX     ***
' *********************************
 1500 TEXT: HOME: HTAB 11
 1515 INVERSE: PRINT "ASTRONAUT COMPLEX": NORMAL
 1520 PRINT:PRINT "CHOOSE ONE KERBAL FOR THIS MISSION:":PRINT
 1530 FOR I=1 TO 8
 1540    IF AD(I) GOTO 1600
 1550    ON I GOSUB 1641,1642,1643,1644,1645,1646,1647,1648
 1560    PRINT " ";I;". ";AN$,AJ$;" S: ";AS$;" C: ";AC$
 1600 NEXT I
 1605 PRINT: INPUT W
 1615 IF W<1 OR W>8 THEN PRINT "INVALID INPUT, PLEASE TRY AGAIN!": GOTO 1610
 1630 ON W GOSUB 1641,1642,1643,1644,1645,1646,1647,1648
 1630 GOTO 1776
 1641 AN$="JEBEDIAH" :AJ$="PILOT":AS$="****":AC$="****":RETURN
 1642 AN$="VALENTINA":AJ$="PILOT":AS$="****":AC$="****":RETURN
 1643 AN$="KAI"      :AJ$="SCI  ":AS$="*** ":AC$="***":RETURN
 1644 AN$="KUROSHIN" :AJ$="ENGR ":AS$="**  ":AC$="*":RETURN
 1645 AN$="DESKTOP"  :AJ$="ENGR ":AS$="*   ":AC$="***":RETURN
 1646 AN$="SLASHDOT" :AJ$="SCI  ":AS$="*** ":AC$="*":RETURN
 1647 AN$="ZURGTROYD":AJ$="PILOT":AS$="**  ":AC$="***":RETURN
 1648 AN$="DAPHTY"   :AJ$="ENGR ":AS$="*** ":AC$="***":RETURN
'*** REM DEBUG, Uncomment and Jump here to skip loading
'1700 REM TEXT:HOME
'1720 REM AN$="ZURGTROYD":SS=3
'1750 REM EN(1)=1:ST(1)=1:FT(1)=1
'1751 REM EN(2)=2:ST(2)=2:FT(2)=1
'1752 REM EN(3)=3:ST(3)=3:FT(3)=1
'************************
'*   Rocket Summary   ***
'************************
'*** REM Load Rocket Shape Table
 1776 POKE 232,0:POKE 233,16
 1783 PRINT D$"BLOAD ROCKET.SHAPE,A$1000"
 1800 HOME:PRINT "ROCKET SUMMARY:":PRINT
 1802 G=-9.8:LN=0:CQ=0:OM=0:S=SS:DT=1
 1805 FOR I=1 TO S
'*** REM EmptyMass=Engines*1.5T+(Stacks*FuelTanks)*0.5T
 1810    EM(I)=EN(I)*1.5+ST(I)*FT(I)*0.5
'*** REM First stage also has a 1T capsule
 1812    IF I=1 THEN EM(I)=EM(I)+1.0
'*** REM FuelMass=(Stacks*FuelTanks)*4T
 1814    FM(I)=ST(I)*FT(I)*4.0
'*** REM StageFuel=FuelMass (one gets decremented as we use it up)
 1815    SF(I)=FM(I)
'*** REM StageMass=EmptyMass+FuelMass
 1816    SM(I)=EM(I)+FM(I)
'*** REM Total mass of stage includes all higher stages
 1820    TM(I)=0
 1822    FOR J=1 TO I
 1825       TM(I)=TM(I)+SM(J)
 1830    NEXT J
'***    Thrust=NumberOfEngines*168kN
 1835    TH(I)=EN(I)*168
'***    DeltaV=ISP*gravity*ln(total_mass/empty_mass)
 1840    DV(I)=270*-G*LOG(TM(I)/(TM(I)-FM(I)))
'***    Thrust/Weight Ratio
 1850    TW(I)=TH(I)/(TM(I)*-G)
'***    Fuel Flow
 1855    FF(I)=TH(I)/(270*-G)
 1990    PRINT "STAGE: ";4-I
 1991    PRINT "  TANKS=";ST(I)*FT(I);" ENGINES=";EN(I)
 1992    PRINT "  STAGE MASS=";SM(I);" TOTAL MASS=";TM(I)
 1993    PRINT "  DELTAV=";DV(I)
 1995    PRINT "  TWR=";TW(I)
 2000 NEXT I
 2998 GET A$
 2999 HOME
'******************************
'***       Main Loop       ****
'******************************
 3000 AN=0:GX=0:GY=-9.8:GA=0:V=0:VX=0:VY=0:AX=0:AY=0:KR=600000
 3016 RX=0:RY=KR+10:RA=KR+10:TR=0:T=0:BF=0:MX=0
 3020 HGR:ROT=0:SCALE=2:H=0
'**** REM ** LAUNCHPAD **
 3035 PRINT:PRINT D$"BLOAD LAUNCHPAD.HGR,A$2000"
'**** REM DRAW HORIZON (GREEN)
 3038 HCOLOR=1:HPLOT 1,80 TO 132,80: HPLOT 148,80 TO 247,80
'**** REM DRAW GANTRY (WHITE)
 3039 HCOLOR=3:HPLOT 110,110 TO 110,60:HPLOT TO 130,60: HPLOT 110,70 TO 130,70
'**** DRAW SHIP
 3040 XDRAW 1+((S-1)*2)+TR AT 140,80
 4000 REM ** MAIN LOOP **
'**** REM ** if not launched yet then skip physics
 4002 IF LN=0 GOTO 5032
'**** Calculate altitude and set maximum if we are at new record
 4003 RR=RA-KR:IF RR>MX THEN MX=RR
'**** If orbit mode then skip drawing horizon, etc
 4004 IF OM=1 GOTO 4018
'**** If above 1.8km don't draw horizon
'**** FIXME: do we need to check OM again?
'**** FIXME: we draw the horizon one pixel too far to right
 4005 IF RR>1800 OR OM=1 THEN GOTO 4012
'**** Erase old horizon
 4007 HCOLOR=0:HPLOT 1,80+H TO 132,80+H:HPLOT 148,80+H TO 247,80+H
'**** Calculate and draw new horizon
 4010 H=RR/20:HCOLOR=1:HPLOT 1,80+H TO 132,80+H:HPLOT 148,80+H TO 247,80+H
4012 IF RR<40000 AND CQ<>0 THEN GOSUB 7600
4014 IF RR<40000 GOTO 4018
4016 IF RR>40000 AND CQ<>1 THEN GOSUB 7700
4018 FL=FM(S)*100/SF(S)
4020 IF TR<>1 THEN GOTO 4050
4025 IF FM(S)<0.1 THEN FM(S)=0:BF=1:AX=0:AY=0:GOTO 4050
4030 AX=(TH(S)/TM(S))*SIN(AN):AY=(TH(S)/TM(S))*COS(AN)
4040 FM(S)=FM(S)-FF(S):TM(S)=TM(S)-FF(S)
4047 GOTO 4060
4050 REM NOT THRUSTING
4055 AX=0:AY=0
4060 GA=ATN(RX/RY)
4065 IF RY<0 THEN GA=GA+3.14
4070 GY=COS(GA)*G:GX=SIN(GA)*G:AY=AY+GY:AX=AX+GX
4090 ZX=VX:ZY=VY:VY=ZY+AY*DT:VX=ZX+AX*DT:V=SQR(VX*VX+VY*VY)
5012 RY=RY+0.5*(ZY+VY)*DT:RX=RX+0.5*(ZX+VX)*DT:RA=SQR(RX*RX+RY*RY)
5020 IF RA<KR THEN GOTO 8000
5030 G=-9.8/((RA/KR)*(RA/KR))
5032 VTAB 21:PRINT "TIME: ";T,"STAGE: ";4-S;"      ";AN$
5045 PRINT "ALT: ";INT((RA-KR)/1000);"KM","ANGLE=";R*5.625;"   "
5060 PRINT "VEL: ";INT(V);"M/S","FUEL: ";INT(FL);"%  "
5100 IF BF=1 THEN BF=0:A$="X":GOTO 5555
5115 Q=PEEK(-16384):IF Q<128 THEN GOTO 6095
5222 A$=CHR$(Q-128):POKE 49168,0
5555 IF OM<>1 THEN XDRAW 1+((S-1)*2)+TR AT 140,80
6060 IF A$="Q" THEN GOTO 9000
6061 IF A$="A" THEN R=R-8:AN=AN-0.7853
6062 IF A$="D" THEN R=R+8:AN=AN+0.7853
6063 IF A$="C" THEN GOTO 8000
6064 IF A$="Z" THEN TR=1
6065 IF A$="X" THEN TR=0
6066 IF A$=">" THEN DT=DT+1
6067 IF A$="<" THEN DT=DT-1:IF DT<1 THEN DT=1
6068 IF A$="M" AND OM=1 THEN OM=0:CQ=-1:GOTO 4000
6069 IF A$="M" AND OM=0 THEN OM=1:HOME:PRINT:PRINT CHR$(4);"BLOAD GLOBE.HGR,A$2000":GOTO 6095
6070 IF A$=" " AND LN=1 THEN S=S-1:XX=PEEK(-16336):IF S<1 THEN S=1
6071 IF A$=" " AND LN=0 THEN GOSUB 7500
6072 IF A$="E" THEN GOSUB 8100
6073 IF R=64 THEN R=0:AN=0
6074 IF R=-8 THEN R=56
6075 IF OM<>1 THEN GOSUB 8200
6076 IF OM<>1 AND R>20 AND R<48 THEN GOSUB 8210:GOTO 6080
6076 IF OM<>1 AND VY>100 THEN GOSUB 8220
6080 ROT=R
6090 IF OM<>1 THEN XDRAW 1+((S-1)*2)+TR AT 140,80
6095 IF OM=1 THEN HX=INT(RX/25000)+140:HY=INT(-RY/25000)+85:HCOLOR=3:HPLOT HX,HY
6118 T=T+DT:EC=EC+DT
6150 IF OM<>1 AND EC>30 THEN EC=0:GOSUB 8100
6200 GOTO 4000
7500 REM *** LAUNCH ***
7510 HCOLOR=0:HPLOT 110,110 TO 110,60:HPLOT TO 130,60: HPLOT 110,70 TO 130,70
7520 XX=PEEK(-16336)
7530 TR=1:LN=1
7535 GOSUB 8220
7540 RETURN
7600 REM *** GROUND ***
7610 HOME:PRINT:PRINT CHR$(4);"BLOAD LAUNCHPAD.HGR,A$2000"
7615 XDRAW 1+((S-1)*2)+TR AT 140,80
7620 CQ=0
7650 RETURN
7700 REM *** SPACE_UP ***
7710 HOME:PRINT:PRINT CHR$(4);"BLOAD ORBIT_TOP.HGR,A$2000"
7715 XDRAW 1+((S-1)*2)+TR AT 140,80
7720 CQ=1
7750 RETURN
8000 REM *** CRASH ***
8010 SCALE=3
8015 GOSUB 8200
8020 FOR I=0 TO 64 STEP 8: ROT=I:XDRAW 1+((S-1)*2)+TR AT 140,80: XX=PEEK(-16336):NEXT I
8030 FOR I=1 TO 50
8040 X=INT(RND(1)*80)+1:Y=INT(RND(1)*80)+1
8050 C=INT(RND(1)*7)+1:HCOLOR=C
8060 HPLOT 140,80 TO 100+X,40+Y
8070 XX=PEEK(-16336)
8080 NEXT I
8085 AD(W)=1
8090 GOTO 9000
'**************************
'***   Astronaut Eyes   ***
'**************************
'*** Erase old ones
8100 HCOLOR=3:HPLOT 258,150 TO 263,150:HPLOT 265,150 TO 270,150
'*** Randomly pick new ones
8110 KE=INT(RND(1)*3)
'*** Draw new ones
8120 HCOLOR=0:HPLOT 258+(2*KE),150 TO 259+(2*KE),150
8125 HPLOT 265+(2*KE),150 TO 266+(2*KE),150
8130 RETURN
'**************************
'*** Astronaut Frown    ***
'**************************
'**** Erase old mouth
 8200 HCOLOR=1:HPLOT 259,155 TO 271,155:HPLOT 259,156 TO 271,156
'**** Draw frown
 8205 HCOLOR=0:HPLOT 261,155 TO 269,155:HPLOT 259,156 TO 271,156
 8207 RETURN
'**************************
'*** Astronaut Neutral  ***
'**************************
'**** Erase old mouth
 8210 HCOLOR=1:HPLOT 259,155 TO 271,155:HPLOT 259,156 TO 271,156
'**** Draw new mouth
 8215 HCOLOR=0:HPLOT 259,155 TO 271,155
 8217 RETURN
'**************************
'*** Astronaut Smile    ***
'**************************
'**** Erase old mouth
 8220 HCOLOR=1:HPLOT 259,155 TO 271,155:HPLOT 259,156 TO 271,156
'**** Draw new mouth
 8225 HCOLOR=0:HPLOT 259,155 TO 271,155:HPLOT 261,156 TO 269,156
 8227 RETURN
'*****************************
'***   CONTRACT COMPLETE   ***
'*****************************
 9000 IF MX<40000 THEN C$="CRASH SHIP":F$="0.30":E$="-1":GOTO 9010
 9007 C$="REACH SPACE":F$="200":E$="20"
 9010 TEXT:HOME
 9020 HTAB 10:VTAB 9
 9021 FOR I=1 TO 20: PRINT "*";: NEXT I: PRINT "*"
 9023 HTAB 10: PRINT "* ";:INVERSE: PRINT "CONTRACT COMPLETE";:NORMAL: PRINT " *"
 9024 HTAB 10: PRINT "* ";
 9026 L=10-(LEN(C$))/2
 9027 HTAB 10+L:PRINT C$;:HTAB 30: PRINT "*"
 9030 HTAB 10:PRINT "*      FUNDS ";F$;:HTAB 30: PRINT "*"
 9030 HTAB 10:PRINT "*   EXPERIENCE ";E$;:HTAB 30: PRINT "*"
 9040 HTAB 10
 9042 FOR I=1 TO 20: PRINT "*";: NEXT I:PRINT "*"
 9100 VTAB 16
 9110 PRINT "NOW WHAT?"
 9120 PRINT "  1. RETURN TO THE VAB"
 9130 PRINT "  2. RETURN TO ASTRO COMPLEX"
 9140 PRINT "  3. RETURN TO LAUNCH"
 9145 PRINT "  4. HELP"
 9150 PRINT "  5. QUIT GAME"
 9160 PRINT "---> ";
 9170 GET A$
 9171 IF A$="1" GOTO 1000
 9172 IF A$="2" GOTO 1500
 9173 IF A$="3" GOTO 1776
 9174 IF A$="4" OR A$="H" GOTO 9200
 9175 IF A$="5" OR A$="Q" THEN TEXT:HOME:END
 9176 GOTO 9160
'*******************
'*** HELP SCREEN ***
'*******************
 9200 HOME:PRINT "KSP-APPLE-II BY VINCE WEAVER"
 9230 PRINT "     APPLE II FOREVER"
 9240 PRINT " A,D   - STEER SHIP LEFT/RIGHT"
 9250 PRINT " Z     - START ENGINES"
 9260 PRINT " X     - CUT ENGINES"
 9270 PRINT " SPACE - LAUNCH,STAGE"
 9275 PRINT " M     - SWITCH TO ORBITAL VIEW"
 9277 PRINT " <,>   - FAST FORWARD"
 9280 PRINT " ESC   - QUIT" 
 9300 GET A$
 9320 GOTO 9010
