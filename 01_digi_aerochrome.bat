@echo off

REM ===============================================================
REM  Aerochrome ImageMagick script
REM ===============================================================
REM  Varible setup
REM ===============================================================

REM Sets the subfolder for temp files
set "p_fldr=processing"

REM Sets the subfolder for output files
set "out_fldr=aero"
 
REM Set the amount to lower the brightness of the IR channel for the red input (green output) channel
set "blu_att=-50x0"

REM Set the amount to lower the brightness of the IR channel for the green (blue input) channel
set "gr_att=-50x0"

REM Set the amount to lower the brightness of the IR channel
set "ir_att=-10x0"

REM ===============================================================
REM  Loop over all tiff files
REM ===============================================================
for %%a in (*.tif) do (

REM =======================================================
REM  Cleanup old temp files
REM =======================================================
	echo Processing %%a
    echo Clearing old files
	rmdir /s /q %p_fldr%
	mkdir %p_fldr%
	mkdir %out_fldr%

	copy %%a %p_fldr%\01_temp.tif

REM =======================================================
REM  Seperate Image Channels
REM =======================================================
	echo Processing %%a
    magick -quiet %p_fldr%\01_temp.tif[0] -channel R -separate -colorspace gray %p_fldr%\02_channel_r_ir.tif
    magick -quiet %p_fldr%\01_temp.tif[0] -channel G -separate -colorspace gray %p_fldr%\02_channel_g_ir.tif
    magick -quiet %p_fldr%\01_temp.tif[0] -channel B -separate -colorspace gray %p_fldr%\02_channel_ir.tif

REM =======================================================
REM Process Channels
REM =======================================================
	magick -quiet %p_fldr%\02_channel_ir.tif -brightness-contrast %blu_att% +sigmoidal-contrast 4x50 %p_fldr%\02_channel_ir_sub_b.tif
	magick -quiet %p_fldr%\02_channel_ir.tif -brightness-contrast %gr_att% +sigmoidal-contrast 4x50 %p_fldr%\02_channel_ir_sub_g.tif

 	magick -quiet %p_fldr%\02_channel_ir_sub_b.tif %p_fldr%\02_channel_r_ir.tif -compose minus_dst -composite %p_fldr%\03_channel_final_g.tif
 	magick -quiet %p_fldr%\02_channel_ir_sub_g.tif %p_fldr%\02_channel_g_ir.tif -compose minus_dst -composite %p_fldr%\03_channel_final_b.tif

	magick -quiet %p_fldr%\02_channel_ir.tif -brightness-contrast %ir_att% %p_fldr%\03_channel_final_ir.tif

REM =======================================================
REM Recombine channels
REM =======================================================
	magick -quiet %p_fldr%\03_channel_final_ir.tif %p_fldr%\03_channel_final_g.tif %p_fldr%\03_channel_final_b.tif -combine %out_fldr%\%%a_areo.tif
)
echo "Press enter to exit"
set /p input=