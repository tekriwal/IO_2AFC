function [percent_L, y_fit] = pMetric_v3(InputFile, InputData, rawFile, rawData)
% PMETRIC_V3 generates a sensory discrimiation plot modeled on the
% logisitic regression which wil provide an assessment of an individual's
% performance on the auditory task
%
%
% The function will require the input_matrix used to generate the session
% in addition to the output struct.
%
% INPUTS:
% 'fName' - string/character of the file name used for the output .mat file
% generated by the paradigm code. Example: 'JD_Oct20.mat'
%
% Example usage: pMetric_v2('inputshorten_PT2.mat','inputshorten_PT2','rData_PT2.mat','rData_PT2')
% pMetric_v2('inputshorten_PT1.mat','inputshorten','rData_PT1.mat','rData_PT1')
% pMetric_v2('input_matrix_rndm_matonly.mat', 'input_matrix_rndm','NB_Oct20.mat','NB_Oct20')

load(InputFile, InputData)
load(rawFile, rawData)
inputMat = eval(InputData);
rData = eval(rawData);

for i = 1:length(inputMat)
    if rData(i).Response == 'f'
        rData(i).actual = 0;
    end
end

for i = 1:length(inputMat)
    if rData(i).Response == 'f'
        inputMat(i) = NaN;
    end
end

rTEST = {rData.Stimbeepduration};
if iscell(rTEST)
    isEM = cellfun(@(x) ~isempty(x), rTEST);
    actual = {rData.actual};
    actual = actual(isEM);
    response = {rData.Response};
    response = response(isEM);
    inputMat = inputMat(isEM);
end

trialNum = ceil(length(response)/9)*9;
inputTemp = nan(trialNum,1);
inputTemp(1:length(inputMat)) = inputMat;
inputMat = inputTemp;
if iscell(rTEST)
   
    actualU = num2cell(nan(trialNum,1));
    actualU(1:length(actual)) = actual;
    
    respU = num2cell(nan(trialNum,1));
    respU(1:length(response)) = response;
    
end



blockNum = ceil(length(response)/9);

numOblks = numel(1:2:blockNum);

siInd2 = [1:9;19:27;37:45;55:63;73:81;91:99;109:117;127:135];

siInd = [];
for i = 1:numOblks
    siInd = [siInd , siInd2(i,:)];
end

choice = respU;
% choiceSI = choice(siInd); 
actualN = actualU;
% actualSI = actual(siInd);
trialHist = inputMat;

% TEST taking off first half of first block
siInd = siInd(5:end);

trialHSI = trialHist(siInd);
correct = cellfun(@(x,y) isequal(x,y), choice, actualN);
correctSI = correct(siInd);

% 1 = easy left
% 2 = med left
% 3 = 50/50
% 4 = med right
% 5 = easy right

observationsL = zeros(1,5);
observationsL(1,1) = sum(trialHSI == 1 & correctSI);
observationsL(1,2) = sum(trialHSI == 2 & correctSI);
observationsL(1,3) = sum(trialHSI == 301 & correctSI) + sum(trialHSI == 302 & ~correctSI);
observationsL(1,4) = sum(trialHSI == 4 & ~correctSI);
observationsL(1,5) = sum(trialHSI == 5 & ~correctSI);

trialnum = zeros(1,5);
trialnum(1,1) = sum(trialHSI == 1);
trialnum(1,2) = sum(trialHSI == 2);
trialnum(1,3) = sum(trialHSI == 301) + sum(trialHSI == 302);
trialnum(1,4) = sum(trialHSI == 4);
trialnum(1,5) = sum(trialHSI == 5);

percent_L = zeros(1,5);
percent_L(1,1) = sum(trialHSI == 1 & correctSI) / sum(trialHSI == 1);
percent_L(1,2) = sum(trialHSI == 2 & correctSI) / sum(trialHSI == 2);

percent_L(1,3) = (sum(trialHSI == 301 & correctSI) + sum(trialHSI == 302 & ~correctSI)) /...
     (sum(trialHSI == 301) + sum(trialHSI == 302));

percent_L(1,4) = sum(trialHSI == 4 & ~correctSI) / sum(trialHSI == 4);
percent_L(1,5) = sum(trialHSI == 5 & ~correctSI) / sum(trialHSI == 5);


xAxisM = [1,2,3,4,5];
b = glmfit(xAxisM',[observationsL; trialnum]' , 'binomial');

x_axis = (1:0.1:5);
y_fit = glmval(b, x_axis, 'logit');

figure;
p = plot(xAxisM, percent_L, 'ko');
set(p, 'MarkerFaceColor', 'k', 'MarkerSize', 10);
hold on
% the fit
p = plot(x_axis, y_fit, 'k');
set(p, 'LineWidth', 2);
ylim([0 1])
yticks([0 0.5 1])
ylabel('Fraction of left choices');
xticks([1 2 3 4 5])
xlabel('Frequency of tone')

axis square


end
