@echo off
doskey pbidev=cd /d "C:\Users\jaharmon\powerbi-development"
doskey cxnd=codex --no-daemon

doskey ga=git add $*
doskey gaa=git add . $*
doskey gcm=git commit -m $*
doskey gfo=git fetch origin $*
doskey gp=git push $*

doskey ll=eza -l
doskey tree2=eza -T -L 2
doskey tree3=eza -T -L 3

doskey lockin=ffplay -hide_banner -loglevel error -nodisp -f lavfi "anoisesrc=color=brown:amplitude=0.354,lowpass=f=550:poles=1,bass=g=12:f=60,afade=t=in:d=3"