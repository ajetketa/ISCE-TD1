classdef Features
    properties
        emg;
        noOfMeasurements;
        noOfSamples;
        frequency;
    end

    properties (Constant)
        noOfElementsPerWindow = 1028;
        overlapPercentage = 0.3;
    end

    methods
        function obj = Features(emg, frequency)
            datasetSize = size(emg);
            obj.emg = emg;
            obj.noOfMeasurements = datasetSize(1);
            obj.noOfSamples = datasetSize(2);
            obj.frequency = frequency;
        end

        %% Calculate Mean, Variance, Skewness and Kurtosis of the given Dataset
        function [mean, variance, skewness, kurtosis] = getStatisticalFeatures(obj)
            % Statistical Features
            mean = zeros(obj.noOfMeasurements, 1);
            variance = zeros(obj.noOfMeasurements, 1);
            skewness = zeros(obj.noOfMeasurements, 1);
            kurtosis = zeros(obj.noOfMeasurements, 1);

            % Important Helping parameters
            standardDeviation = zeros(obj.noOfMeasurements, 1);
            median = zeros(obj.noOfMeasurements, 1);

            for i = 1:obj.noOfMeasurements
                sum = 0;
                for j = 1:obj.noOfSamples
                    sum = sum + obj.emg(i,j);
                end
                mean(i) = sum / obj.noOfSamples;
                
                sumOfVariance = 0;
                sumOfMeanThird = 0;
                sumOfMeanFourth = 0;
                for j = 1:obj.noOfSamples
                    sumOfVariance = sumOfVariance + (obj.emg(i,j) - mean(i)).^2;
                    sumOfMeanThird = sumOfMeanThird + (obj.emg(i,j) - mean(i)).^3;
                    sumOfMeanFourth = sumOfMeanFourth + (obj.emg(i,j) - mean(i)).^4;
                end
                variance(i) = sumOfVariance / obj.noOfSamples;
                standardDeviation(i) = sqrt(variance(i));
                skewness(i) = sumOfMeanThird / (obj.noOfSamples * standardDeviation(i).^3);
                kurtosis(i) = (sumOfMeanFourth / (obj.noOfSamples * standardDeviation(i).^4)) - 3;
            
                currentSortedEmg = sort(obj.emg(i, :));
                median(i) = (currentSortedEmg(25000) + currentSortedEmg(25001))/2;
            end
        end

        %% Calculate Energy and Root Mean Square
        function [energy, rms] = getTemporalFeatures(obj)
            % Temporal Features
            energy = zeros(obj.noOfMeasurements, 1);
            rms = zeros(obj.noOfMeasurements, 1);

            for i = 1:obj.noOfMeasurements
                sumOfEnergy = 0;
                sumOfSquared = 0;
                for j = 1:obj.noOfSamples
                    sumOfEnergy = sumOfEnergy + abs(obj.emg(i, j)).^2;
                    sumOfSquared = sumOfSquared + obj.emg(i, j).^2;
                end
                energy(i) = sumOfEnergy;
                rms(i) = sqrt(sumOfSquared / obj.noOfSamples);
            end
        end

        %% Calculate Moments, Energy By Frequency Band, H/L ratio
        function [power, meanPowerFrequency, skewnessCoefficient, kurtosisCoefficient] = getSpectralFeatures(obj)
            power = zeros(obj.noOfMeasurements, 1);
            meanPowerFrequency = zeros(obj.noOfMeasurements, 1);
            skewnessCoefficient = zeros(obj.noOfMeasurements, 1);
            kurtosisCoefficient = zeros(obj.noOfMeasurements, 1);

            for i = 1:obj.noOfMeasurements
                fastFourierTransform = fft(obj.emg(i,:));
                realFastFourier = real(fastFourierTransform);
                imaginaryFastFourier = imag(fastFourierTransform);
                psd = sqrt(realFastFourier.^2 + imaginaryFastFourier.^2);

                power(i, 1) = obj.getMoment(psd, 0);
                meanPowerFrequency(i, 1) = obj.getMoment(psd, 2) / power(i, 1);
                skewnessCoefficient(i, 1) = obj.getMoment(psd, 3) / sqrt(obj.getMoment(psd, 2).^3);
                kurtosisCoefficient(i, 1) = obj.getMoment(psd, 4) / obj.getMoment(psd, 2).^2;
            end
        end

        %% Utils - For Features
        function moment = getMoment(obj, psd, power)
             moment = 0;
             for i = 1:(length(psd)/2)+1
                 moment = moment + i.^power .* psd(i); 
             end
             moment = moment * 2;
        end

        function window = getWindow(obj, rowIndex, noOfWindow)
            startingIndex = noOfWindow * obj.noOfElementsPerWindow;
            if noOfWindow ~= 0
                startingIndex = (1 - obj.overlapPercentage) * startingIndex;
            end
            endingIndex = startingIndex + obj.noOfElementsPerWindow;

            window = obj.emg(rowIndex, startingIndex:endingIndex);
        end
    end


end