DEM Processing Front-End (MATLAB App)

This repository provides a MATLAB App (App Designer) front-end for running a black-box DEM (Digital Elevation Model) generation pipeline.
The backend processing code (originally developed in MATLAB) is encapsulated so that end users only interact with a simple graphical interface.

Features
1. One-click workflow execution: Wraps multiple step scripts (Step1–Step9) into a sequential pipeline.
2. Interactive file/folder selection: Users can provide key inputs (interferogram file, CC/MLI/UNW folders, etc.) through dialog boxes.
3. Intermediate folder management: Automatically creates time-stamped working folders (ccWork, mliWork, unwWork, daWork, postWork, …).
4. Logging: Status and error messages are captured in a log window.
5. Final outputs: DEM results (e.g., HighDEM11.tif, HighlyDEM1.mat) are stored in the designated output folder.

Installation
1. Open MATLAB (tested on R2019b).
2. Go to Home → Add-Ons → Install from File….
3. Select the packaged file FrontEnd.mlappinstall.
4. After installation, the app will appear under the APPS tab in MATLAB.

Usage
1. Launch the app from the APPS tab.
2. Use the provided buttons to select input files/folders:
3. Interfere file
4. CC folder
5. MLI folder
6. UNW folder
7. Output directory
8. Press Start to run the full DEM pipeline.
9. Progress and messages will appear in the status window.
10. Final outputs will be saved into the output directory with automatically generated subfolders.

Folder Structure
OutputFolder/
  ├─ cc_work_YYYYMMDD_HHMMSS/
  ├─ mli_work_YYYYMMDD_HHMMSS/
  ├─ unw_work_YYYYMMDD_HHMMSS/
  ├─ da_work_YYYYMMDD_HHMMSS/
  ├─ post_work_YYYYMMDD_HHMMSS/
  └─ final_results/

Requirements
1. MATLAB R2019b or later
2. Image Processing Toolbox
3. Mapping Toolbox (for geotiffwrite and georefcells)
4. All backend scripts (Step1load_cc.m, Step6cal_Da.m, Step7.m, Step8.m, Step9.m, etc.) and helper functions must be present in the MATLAB path.

Notes
1. When running in interactive mode, the app will prompt file/folder dialogs.
2. When running in batch/auto mode, preselected queues will silently provide inputs without opening dialogs.
3. Ensure that input files (e.g., interferogram lists, CC/MLI/UNW data) follow the expected naming convention (cc1.mat, mli1.mat, unw1.mat, …).
