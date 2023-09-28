classdef DiscriminativePower
    methods (Static)
        %% ROC AND AUC, Accuracy
        function [thresholds, rateOfTruePositive, rateOfFalsePositive, areaUnderTheCurve, accuracy] = buildROC(measurement, chartTitle)
             noOfThresholds = 100000;
             accuracy = 0;
             % Confusion matrix will keep log of whether a specific point is or not
             % on a specific class. RateOfTruePositive = Sensitivity,
             % RateOfFalsePositive = 1 - sensitivity
             rateOfTruePositive = zeros(noOfThresholds, 1);
             rateOfFalsePositive = zeros(noOfThresholds, 1);
        
             minValue = min(measurement);
             maxValue = max(measurement);
             % Find the necessary scale to modify the number just enough
             scale = floor(log10(abs(minValue)));
             minValue = minValue - 10 ^ (scale - 4);
             maxValue = maxValue + 10 ^ (scale - 4);
             thresholds = linspace(minValue, maxValue, noOfThresholds);
        
             for thresholdIndex = 1:length(thresholds)
                 truePositive = 0;
                 falsePositive = 0;
                 falseNegative = 0;
                 trueNegative = 0;
                 for measurementIndex = 1:length(measurement)
                     if measurement(measurementIndex) > thresholds(thresholdIndex)
                         if measurementIndex > 10
                             truePositive = truePositive + 1;
                         else
                             falsePositive = falsePositive + 1;
                         end
                     else
                         if measurementIndex > 10
                             falseNegative = falseNegative + 1;
                         else
                             trueNegative = trueNegative + 1;
                         end
                     end
                 end
        
                 rateOfTruePositive(thresholdIndex) = truePositive / (truePositive + falseNegative);
                 rateOfFalsePositive(thresholdIndex) = falsePositive / (falsePositive + trueNegative);

                 thresholdAccuracy = (truePositive + trueNegative) / (truePositive + trueNegative + falsePositive + falseNegative);
                 if thresholdAccuracy > accuracy
                     accuracy = thresholdAccuracy;
                 end
             end
             [rateOfTruePositive, rateOfFalsePositive] = DiscriminativePower.removeDuplicates(rateOfFalsePositive, rateOfTruePositive);
             areaUnderTheCurve = DiscriminativePower.getAreaUnderTheCurve(rateOfFalsePositive, rateOfTruePositive);
             plot(rateOfFalsePositive', rateOfTruePositive', "r.-");
             title(chartTitle)
             text(0, 0.9, "AUC: " + areaUnderTheCurve);
             text(0, 0.8, "Accuracy: " + accuracy);
             ylabel("Rate of True Positive(sensibility)");
             xlabel("Rate of False Positive(1 - sensitivity)");
        end
        
        % Calculate Area Under The Curve (AUC)
        function areaUnderTheCurve = getAreaUnderTheCurve(rateOfFalsePositive, rateOfTruePositive)
            areaUnderTheCurve = 0;
            for point = 1:length(rateOfFalsePositive) - 1
                % No displacement on X-Axis = no Area
                if rateOfFalsePositive(point) ~= rateOfFalsePositive(point + 1)
                    % Conditions for triangle
                    if rateOfTruePositive(point) == 0 && rateOfTruePositive(point + 1) ~= 0
                        areaUnderTheCurve = areaUnderTheCurve + DiscriminativePower.getTriangleArea(rateOfFalsePositive(point + 1) - rateOfFalsePositive(point), rateOfTruePositive(point + 1) - rateOfTruePositive(point));
                    % Conditions for Rectangle
                    elseif rateOfTruePositive(point + 1) == rateOfTruePositive(point)
                        areaUnderTheCurve = areaUnderTheCurve + DiscriminativePower.getRectangleArea(rateOfFalsePositive(point + 1) - rateOfFalsePositive(point), rateOfTruePositive(point));
                    % Conditions for Parallelogram
                    elseif rateOfTruePositive(point) ~= 0 && (rateOfTruePositive(point) ~= rateOfTruePositive(point + 1))
                        areaUnderTheCurve = areaUnderTheCurve + DiscriminativePower.getParallelogramArea(rateOfFalsePositive(point + 1) - rateOfFalsePositive(point), rateOfTruePositive(point), rateOfTruePositive(point + 1));
                    end
                end
            end
        end
        
        function triangleArea = getTriangleArea(deltaX, deltaY)
            c = sqrt(deltaX.^2 + deltaY.^2);
            halfPerimeter = (c + deltaX + deltaY) / 2;
            triangleArea = sqrt(halfPerimeter * (halfPerimeter - c) * (halfPerimeter - deltaY) * (halfPerimeter - deltaX));
        end
        
        function rectangleArea = getRectangleArea(deltaX, y)
            rectangleArea = deltaX * y;
        end
        
        function parallelogramArea = getParallelogramArea(deltaX, y1, y2)
            parallelogramArea = DiscriminativePower.getTriangleArea(deltaX, y2 - y1) + DiscriminativePower.getRectangleArea(deltaX, y1);
        end

        %% BoxPlot
        function buildBoxPlot(measurements, chartTitle)
            classes = ["Class1" "Class1" "Class1" "Class1" "Class1" "Class1" "Class1" "Class1" "Class1" "Class1" "Class2" "Class2" "Class2" "Class2" "Class2" "Class2" "Class2" "Class2" "Class2" "Class2"];
            boxplot(measurements, classes);
            title(chartTitle + " BoxPlot");
            ylabel(chartTitle);
        end
        
        %% Utils -- Remove duplicate values to simplify the solutions
        function [rateOfTruePositive, rateOfFalsePositive] = removeDuplicates(rateFalsePositive, rateTruePositive)
             rateOfFalsePositive = [];
             rateOfTruePositive = [];
             insertIndex = 0;
             for i = 1:length(rateFalsePositive)
                 if insertIndex == 0
                     insertIndex = insertIndex + 1;
                     rateOfTruePositive(insertIndex) = rateTruePositive(i);
                     rateOfFalsePositive(insertIndex) = rateFalsePositive(i);
                 elseif rateOfTruePositive(insertIndex) ~= rateTruePositive(i) || rateOfFalsePositive(insertIndex) ~= rateFalsePositive(i)
                     insertIndex = insertIndex + 1;
                     rateOfTruePositive(insertIndex) = rateTruePositive(i);
                     rateOfFalsePositive(insertIndex) = rateFalsePositive(i);
                 end
             end
             rateOfTruePositive = flip(rateOfTruePositive);
             rateOfFalsePositive = flip(rateOfFalsePositive); 
        end
    end
end
