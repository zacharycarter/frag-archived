echo off
IF NOT EXIST ".\dx11\." (
mkdir ".\dx11"
)
echo on

shadercRelease.exe -f .\src\vs_fbo.sc -o .\dx11\vs_fbo.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type vertex --platform windows -p vs_5_0
shadercRelease.exe -f .\src\fs_fbo.sc -o .\dx11\fs_fbo.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type fragment --platform windows -p ps_5_0
shadercRelease.exe -f .\src\vs_forward.sc -o .\dx11\vs_forward.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type vertex --platform windows -p vs_5_0
shadercRelease.exe -f .\src\fs_forward.sc -o .\dx11\fs_forward.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i ..\..\bgfx\examples\common -i .\src --type fragment --platform windows -p ps_5_0