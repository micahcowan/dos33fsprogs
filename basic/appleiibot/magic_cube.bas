5 HGR:HGR2
6 C=0
40 FOR W=3 TO 64 STEP 0.5
50 A=4/W+T/4
60 K=145/W
70 X=64+COS(A)*K
80 Y=64+SIN(A)*K
100 HCOLOR=C
110 HPLOT X-W,Y-W TO X+W,Y-W TO X+W,Y+W TO X-W,Y+W TO X-W,Y-W
115 C=C+1:IF C>7 THEN C=0
120 NEXT
130 T=T+1:POKE230,32+32*P:P=NOTP:POKE49236+P,0:GOTO 6

'5 GR
'40 FOR W=3 TO 68 STEP 0.1
'50 A=4/W+T/4
'60 K=60/W
'70 X=20+COS(A)*K
'80 Y=20+SIN(A)*K
'90 I=35/W+2+T*3
'100 COLOR=C/4
'110 HLIN X-W,X+W AT Y-W
'111 HLIN X-W,X+W AT Y+W
'112 VLIN Y-W,Y+W AT X-W
'113 VLIN Y-W,Y+W AT X+W
'115 C=C+1
'120 NEXT


'c={0,1,2,8,14,15,7}
'fillp(0xa5a5)
'function _draw()
'for w=3,68,.1 do
'  a=4/w+t()/4
'  k=145/w
'  x=64+cos(a)*k
'  y=64+sin(a)*k
'  i=35/w+2+t()*3
'  rect(x-w,y-w,x+w,y+w,f(i)*16+f(i+.5))
'end
'end
'function f(i)
'return c[flr(1.5+abs(6-i%12))]
'end

