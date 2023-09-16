%% Defining Constants
frequency = 10000;
noOfMeasurements = 20;

%% Import all the EMG files

emg = [];
for index = 1:noOfMeasurements
    temporaryEMG = load(sprintf('../DatasetTD1/EMG%d.mat',index));
    emg = [emg; temporaryEMG.EMG];
end

features = Features(emg, frequency);

[mean, variance, skewness, kurtosis] = features.getStatisticalFeatures();
[energy, rms] = features.getTemporalFeatures();
 
% Define your stochastic, non-stationary signal
 signal = emg(1,:); % Replace with your signal data

% Parameters
segmentLength = 1024; % Length of each segment
overlapPercent = 50; % Overlap percentage
window = hamming(segmentLength); % Choose an appropriate window function

% Calculate the overlap length based on the percentage
overlapLength = round(segmentLength * overlapPercent / 100);

% Initialize variables to store the FFT results
fftResults = [];

% Iterate through the signal with overlapping segments
startIdx = 1;
while (startIdx + segmentLength - 1) <= length(signal)
    segment = signal(startIdx : startIdx + segmentLength - 1);
    
    % Apply the window to the segment
    windowedSegment = segment .* window;
    
    % Compute the FFT of the windowed segment
    fftSegment = fft(windowedSegment);
    
    % Store the FFT result for this segment
    fftResults = [fftResults; fftSegment];
    
    % Move to the next segment with overlap
    startIdx = startIdx + segmentLength - overlapLength;
end

% Plot the magnitude of the FFT results
fs = 1; % Sample rate (modify as needed)
frequencies = (0:(segmentLength/2)) * fs / segmentLength;
magnitude = abs(fftResults(:, 1:segmentLength/2 + 1));

plot(fftResults(1, :));
% Plot the magnitude spectrum
% figure;
% imagesc(frequencies, 1:size(magnitude, 1), 20*log10(magnitude));
% colormap('jet');
% colorbar;
% xlabel('Frequency (Hz)');
% ylabel('Segment Number');
% title('Spectrogram of Stochastic Non-Stationary Signal');

% tiledlayout(3, 4);
% nexttile;
% plotClassified(mean, "Mean");
% nexttile;
% DiscriminativePower.buildROC(mean, "Mean ROC");
% nexttile;
% plotClassified(variance, "Variance");
% nexttile;
% DiscriminativePower.buildROC(variance, "Variance ROC");
% nexttile;
% plotClassified(skewness, "Skweness");
% nexttile;
% DiscriminativePower.buildROC(skewness, "Skewness ROC");
% nexttile;
% plotClassified(kurtosis, "Kurtosis");
% nexttile;
% DiscriminativePower.buildROC(kurtosis, "Kurtosis ROC");
% nexttile;
% plotClassified(energy, "Energy");
% nexttile;
% DiscriminativePower.buildROC(energy, "Energy ROC");
% nexttile;
% plotClassified(rms, "Root Mean Square");
% nexttile;
% DiscriminativePower.buildROC(rms, "Root Mean Square ROC");



%% Plot the Points given in a classified manner for better readibility
function plotClassified(measurement, plotTitle)
    for index = 1:length(measurement)
         if index <= 10
             plot(index ,measurement(index), "b.")
         else
             plot(index, measurement(index), "r*")
         end
         hold on
    end
    title(plotTitle)
    hold off
end


