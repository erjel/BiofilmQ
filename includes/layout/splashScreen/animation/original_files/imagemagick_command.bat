rem for /R %%X in (*.png) do (
rem C:\ImageMagick\magick convert -size 668x500+0+0 xc:skyblue %%X -geometry 668x500+0+0 -composite -background white ( description.png -resize 668x138 )  -geometry +30+370 -composite %X:-~4_merged.png
rem )
rem pause
@echo off
cls
for /R %%X in (*splash*.png) do C:\ImageMagick\magick convert -size 668x500+0+0 xc:skyblue %%X -geometry 668x500+0+0 -composite -background white ( description.png -resize 668x138 )  -geometry +30+370 -composite %%X_merged.png
rem pause
