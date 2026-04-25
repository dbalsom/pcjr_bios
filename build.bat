@echo off
rem Assemble and link the IBM PCjr BIOS source.

MASM.EXE pcjrbios.asm,pcjrbios.obj,pcjrbios.lst,pcjrbios.crf;
if errorlevel 1 goto asm_error

LINK.EXE pcjrbios.obj,pcjrbios.exe,pcjrbios.map,NUL;
if errorlevel 1 goto link_error

echo Build complete: pcjrbios.exe
goto done

:asm_error
echo MASM failed; pcjrbios.exe was not linked.
goto done

:link_error
echo LINK failed; pcjrbios.exe was not created.

:done
