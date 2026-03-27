@echo off
REM Convert DenseNet121 Keras model to TFLite using conda environment

echo Activating conda environment...
call conda activate tf_env

if errorlevel 1 (
    echo ERROR: tf_env not found. Trying base environment...
    call conda activate base
)

echo.
echo Running conversion...
python convert_simple.py

echo.
echo Done! Press any key to exit...
pause
