0HGR2
1HCOLOR=1+RND(1)*7:A=40+RND(1)*200:B=40+RND(1)*100:X=RND(1)*40
3Y=0:P=1-X:GOTO7
4Y=Y+1:IFP<=0THENP=P+2*Y+1:GOTO6
5X=X-1:P=P+2*Y-2*X+1
6IFX<YTHEN1
7HPLOTA+X,B+Y:HPLOTA-X,B+Y:HPLOTA+X,B-Y:HPLOTA-X,B-Y
8HPLOTA+Y,B+X:HPLOTA-Y,B+X:HPLOTA+Y,B-X:HPLOTA-Y,B-X
9GOTO4
