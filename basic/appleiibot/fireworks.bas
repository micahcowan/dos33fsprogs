0HGR2
5Q=25-RND(1)*10
6B=4*NOTB:V=Q+RND(1)*240:W=Q+RND(1)*100:HCOLOR=B+3:HPLOTV,W:FORI=1TO9:IFI<9THENN=I:HCOLOR=B+3:GOSUB9
7N=I-1:HCOLOR=B:GOSUB9:NEXT:GOTO5
9HPLOTV+N,W+N:HPLOTV-N,W-N:HPLOTV+N,W-N:HPLOTV-N,W+N:HPLOTV,W+N*1.5:HPLOTV+N*1.5,W:HPLOTV,W-N*1.5:HPLOTV-N*1.5,W:RETURN
' Based on Fireworks by FozzTexx, originally written in 1987
