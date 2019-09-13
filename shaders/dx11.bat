echo off
IF NOT EXIST ".\dx11\." (
mkdir ".\dx11"
) 
IF NOT EXIST ".\dx11\fragment\." (
mkdir ".\dx11\fragment"
)
IF NOT EXIST ".\dx11\vertex\." (
mkdir ".\dx11\vertex"
)
IF NOT EXIST ".\dx11\compute\." (
mkdir ".\dx11\compute"
)
echo on

shadercRelease.exe -f .\src\vs_fbo.sc -o .\dx11\vertex\vs_fbo.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type vertex --platform windows -p vs_5_0
shadercRelease.exe -f .\src\fs_fbo.sc -o .\dx11\fragment\fs_fbo.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type fragment --platform windows -p ps_5_0