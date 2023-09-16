classdef Features
    properties
        emg;
        noOfMeasurements;
        noOfSamples;
        frequency;
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
                sumOfMeanDifference = 0;
                for j = 1:obj.noOfSamples
                    sumOfVariance = sumOfVariance + (obj.emg(i,j) - mean(i)).^2;
                    sumOfMeanDifference = sumOfMeanDifference - mean(i) + obj.emg(i, j);
                end
                variance(i) = sumOfVariance / obj.noOfSamples;
                standardDeviation(i) = sqrt(variance(i));
                skewness(i) = (sumOfMeanDifference / obj.noOfSamples).^3 / standardDeviation(i).^3;
                kurtosis(i) = ((sumOfMeanDifference / obj.noOfSamples).^4 / standardDeviation(i).^4) - 3;
            
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
        function getSpectralFeatures(obj)
        end
    end
end