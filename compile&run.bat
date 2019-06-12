tasm proj1.asm /t /jJUMPS
tasm z22.asm /t /jJUMPS
tlink /v proj1.obj z22.obj
del *.obj
del *.map
proj1.exe