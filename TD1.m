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

%% Retrieve all extracted features
[mean, variance, skewness, kurtosis] = features.getStatisticalFeatures();
[energy, rms] = features.getTemporalFeatures();
[power, meanPowerFrequency, skewnessCoefficient, kurtosisCoefficient] = features.getSpectralFeatures();

% psd = [];
% for i = 1:noOfMeasurements
%     fastFourierTransform = fft(emg(i,:));
%     realFastFourier = real(fastFourierTransform);
%     imaginaryFastFourier = imag(fastFourierTransform);
%     psd = [psd; sqrt(realFastFourier.^2 + imaginaryFastFourier.^2)];
% end
% 
% moment0 = features.getMoment(psd(1, :), 0);
% moment1 = features.getMoment(psd(1, :), 1);
% moment2 = features.getMoment(psd(1, :), 2);
% moment3 = features.getMoment(psd(1, :), 3);
% moment4 = features.getMoment(psd(1, :), 4);
% disp(moment0);
% disp(moment1);
% disp(moment2);
% disp(moment3);
% disp(moment4);

[psd, f] = pwelch(emg(1,:));
plot(psd);

tiledlayout(4,3);
nexttile;
plotClassified(power, "Power");
nexttile;
DiscriminativePower.buildROC(power, "Power ROC");
nexttile;
DiscriminativePower.buildBoxPlot(power, "Power");
% % nexttile;
% % plotClassified(meanPowerFrequency, "Mean Power Frequency");
% % nexttile;
% % DiscriminativePower.buildROC(meanPowerFrequency, "Mean Power Frequency ROC");
% % nexttile;
% % DiscriminativePower.buildBoxPlot(meanPowerFrequency, "Mean Power Frequency");
% nexttile;
% plotClassified(skewnessCoefficient, "Skewness Coefficient");
% nexttile;
% DiscriminativePower.buildROC(skewnessCoefficient, "Skewness Coefficient");
% nexttile;
% DiscriminativePower.buildBoxPlot(skewnessCoefficient, "Skewness Coefficient");
% nexttile;
% plotClassified(kurtosisCoefficient, "Kurtosis Coefficent");
% nexttile;
% DiscriminativePower.buildROC(kurtosisCoefficient, "Kurtosis Coefficent ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(kurtosisCoefficient, "Kurtosis Coefficent");


% 
% 
% tiledlayout(3, 6);
% nexttile;
% plotClassified(mean, "Mean");
% nexttile;
% DiscriminativePower.buildROC(mean, "Mean ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(mean, "Mean");
% nexttile;
% plotClassified(variance, "Variance");
% nexttile;
% DiscriminativePower.buildROC(variance, "Variance ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(variance, "Variance");
% nexttile;
% plotClassified(skewness, "Skweness");
% nexttile;
% DiscriminativePower.buildROC(skewness, "Skewness ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(skewness, "Skewnes");
% nexttile;
% plotClassified(kurtosis, "Kurtosis");
% nexttile;
% DiscriminativePower.buildROC(kurtosis, "Kurtosis ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(kurtosis, "Kurtosis");
% nexttile;
% plotClassified(energy, "Energy");
% nexttile;
% DiscriminativePower.buildROC(energy, "Energy ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(energy, "Energy");
% nexttile;
% plotClassified(rms, "Root Mean Square");
% nexttile;
% DiscriminativePower.buildROC(rms, "Root Mean Square ROC");
% nexttile;
% DiscriminativePower.buildBoxPlot(rms, "Root Mean Square");
% 
% 
% function frequencyDomain = homemadeFFT(newSignal)
% 
% end

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


