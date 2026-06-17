# Read Me

This code is structured to take .snp files and convert them to .csv files so they can be more easily processed by the MERIT toolbox.

When you extract from the VNA, you can save your data as a .snp files (eg. .s4p, .s6p, .s8p) which depends on the number of ports you are using.  For instance, .s8p is for a 8-port setup even if the ports used are not exactly 1 through 8.

One way the MERIT toolbox forms images uses the difference between a background (no tumour) and full (tumour) set of s-parameters.  

Prior to running this code, identify which .snp file you would like to use as your background.  

## Inputs
You will need to modify the following fields marked as %INPUT in the .m file:
 - Path --> to match where your particular .snp files are stored
 - '*.s8p' --> can keep if it is 8-port setup, otherwise use '\*.s4p' for 4-ports, '\*.s6p' for 6-ports, etc.
 - SnP_E --> make this the title of the .snp file you want to use as a background
 - threshold_dB --> default is -50 dB, but it is modifiable depending on your experiment

```
% INPUT
% Pick Folder and Files
% Load the S-parameters
cd('C:\Users\crowe\Documents\MATLAB\VNA_measurements')  % Replace with your actual path
Folder = 'June_11_2026';  % Replace with your actual folder name

% INPUT
% Takes all the .s8p files in the folder 
% Change this to .s4p, .s6p, etc. depending on your files or the number of
% antennas
filePattern = fullfile(Folder, '*.s8p');
fileList = dir(filePattern);

% INPUT
% Background .sNp file
SnP_E = '4Hour_Drift_06-11_10-05-05.s8p';

% INPUT
% Threshold for masking
threshold_dB = -50; 
```

## Outputs

After running this script, you will have the following files saved to your folder: 
- channels.csv
- frequencies.csv
- scan_E.csv (e for empty, background)
- scan_F_1.csv, scan_F_2.csv, scan_F_3.csv, etc. (f for full, from each of the .snp files in the folder)
- **scan_subtraction_1.csv, scan_subtraction_2.csv, scan_subtraction_3.csv (difference between scan_F_1 and scan_E, scan_F_2 and scan_E, scan_F_3 and scan_E, etc.)**

The **scan_subtraction_n.csv** files can be input into MERIT / Complete_Analysis.m script because they represent the difference between the empty (background) and full s-parameters.

## Files in this repository

| File | Description |
|------|-------------|
| [`SNP_CSV_iterative.m`](https://github.com/EMT-Lab/snp-to-csv-multiple-files/blob/main/SNP_CSV_iterative.m) | Converts .snp files to .csv files for easier processing in MERIT. |

---

## Debugging
It is helpful to check that the channels.csv and frequencies.csv match the parameters you set when you used the VNA.

Eg. For a 4-port setup using ports 1, 2, 3, 4 the channels.csv should look like this:
| 1    | 1   |
| ---- | --- |
| 1    | 2   |
| 1    | 3   |
| 1    | 4   |
| 2    | 1   |
| 2    | 2   |
| etc. |     |
| 4    | 4   |


