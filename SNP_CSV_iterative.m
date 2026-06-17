clear

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

% Load s-parameters for the empty file (SnP_E)
SparamsE = sparameters([Folder '/' SnP_E]);

% Extract frequency (Hz) as a column vector (assuming both files have the same frequencies)
freq = SparamsE.Frequencies;
num_freq = length(freq);

% Extract S-parameter matrices
S_E = SparamsE.Parameters; % Complex S-parameters for file E

% signal filtered version of s-parameters
S_E_mag = 20 * log10(abs(S_E));
low_mag_mask_E = S_E_mag < threshold_dB;
S_E(low_mag_mask_E) = 0;

% Get the number of ports
num_ports = size(S_E, 1);
num_channels = num_ports^2; % Total channels (S11, S12, ..., Snn)

% Prepare channel names matrix (Nx2)
channels = zeros(num_channels, 2);
index = 1;
for row = 1:num_ports
    for col = 1:num_ports
        channels(index, 1) = row;
        channels(index, 2) = col;
        index = index + 1;
    end
end

% Prepare S-parameter data for E and F (real and imaginary combined)
S_combined_E = zeros(num_freq, num_channels);
S_combined_F = zeros(num_freq, num_channels);

% Extract s-parameters for E
index = 1;
for row = 1:num_ports
    for col = 1:num_ports
        S_ij_E = squeeze(S_E(row, col, :));  % Extract specific S-parameter for E
        S_combined_E(:, index) = S_ij_E;  % Store complex values for E
        index = index + 1;
    end
end

% define folder if it does not exist
if ~exist(Folder, 'dir')
    mkdir(Folder);
end

% Save frequencies as CSV
writematrix(freq, [Folder '/frequencies.csv']);

% Save channel names as CSV
writematrix(channels, [Folder '/channels.csv']);

% Save empty s-parameters as CSV
writematrix(S_combined_E, [Folder '/scan_E.csv']);

% Iterates through .sNp files for the full

for sNpFile = 1:numel(fileList)
    
    % Get the first .snp file in the folder
    SnP_F = fileList(sNpFile).name;

    % Load the S-parameters for full
    SparamsF = sparameters([Folder '/' SnP_F]);

    % Extract S-parameter matrices
    S_F = SparamsF.Parameters; % Complex S-parameters for file F

    % signal filtered version of s-parameters
    S_F_mag = 20 * log10(abs(S_F));
    low_mag_mask_F = S_F_mag < threshold_dB; 
    S_F(low_mag_mask_F) = 0;


    index = 1;
    for row = 1:num_ports
        for col = 1:num_ports
            S_ij_F = squeeze(S_F(row, col, :));  % Extract specific S-parameter for F
            S_combined_F(:, index) = S_ij_F;  % Store complex values for F
            index = index + 1;
        end
    end

    
    % Save S-parameter data for both files (real and imaginary combined)
    fileLongName = append(Folder, '/scan_subtraction_', string(sNpFile), '.csv');
    writematrix(S_combined_F - S_combined_E, fileLongName);
    
    fileFullName = append(Folder, '/scan_F_', string(sNpFile), '.csv');
    writematrix(S_combined_F, fileFullName);
end