function [] = blockCompare_ind_v2(InputFile, InputData, rawFile, rawData)
% BLOCKCOMPARE_IND_V1 generates a sensory discrimiation plot modeled on the
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
% blockCompare_ind_v2('inputshorten_PT2.mat','inputshorten_PT2','rData_PT2.mat','rData_PT2')
% blockCompare_ind_v2('inputshorten_PT1.mat','inputshorten','rData_PT1.mat','rData_PT1')
% blockCompare_ind_v2('input_matrix_rndm_matonly.mat', 'input_matrix_rndm','NB_Oct20.mat','NB_Oct20')

load(InputFile, InputData)
load(rawFile, rawData)
inputMat = eval(InputData);
rData = eval(rawData);
rTEST = {rData.Stimbeepduration};
if iscell(rTEST)
    isEM = cellfun(@(x) ~isempty(x), rTEST);
    actual = {rData.actual};
    actual = actual(isEM);
    response = {rData.Response};
    response = response(isEM);
    rTime = {rData.rtime};
    rTime = rTime(isEM);
    inputMat = inputMat(isEM);
end

trialNum = ceil(length(inputMat)/9)*9;
blockNum = ceil(length(inputMat)/9);
inputTemp = nan(trialNum,1);
inputTemp(1:length(inputMat)) = inputMat;
inputMat = inputTemp;

if iscell(rTEST)
   
    actualU = num2cell(nan(trialNum,1));
    actualU(1:length(actual)) = actual;
    
    respU = num2cell(nan(trialNum,1));
    respU(1:length(response)) = response;
    
    rTimeU = num2cell(nan(trialNum,1));
    rTimeU(1:length(rTime)) = rTime;
    
end

analysismatrix = zeros(trialNum,10);
analysismatrix(:,1) = inputMat; %1st column is trial type



corT = cellfun(@(x,y) isequal(x,y), respU, actualU);
analysismatrix(:,2) = corT;
analysismatrix(:,3) = cell2mat(rTimeU);
% Z score = (value - mean/SD)
mean_analysismat = nanmean(analysismatrix(:,3));
stdev = nanstd(analysismatrix(:,3));
analysismatrix(:,4) = (analysismatrix(:,3) - mean_analysismat)/stdev; %Z score;

%% Generates bar graph for reaction times
%in column 3 are raw reaction times
blocklength = 9;
matrixoutput = reshape(analysismatrix(:,3),blocklength,blockNum);

meanperblock = nanmean(matrixoutput); %now you have the average rxn time for each block
%
odds_meanperblock = meanperblock(1:2:blockNum);
evens_meanperblock = meanperblock(2:2:blockNum);

oddSBy = reshape(matrixoutput(:,1:2:blockNum),numel(matrixoutput(:,1:2:blockNum)),1);
oddSBx = reshape(repmat(1:2:blockNum,9,1),numel(matrixoutput(:,1:2:blockNum)),1);

evenSBy = reshape(matrixoutput(:,2:2:blockNum),numel(matrixoutput(:,2:2:blockNum)),1);
evenSBx = reshape(repmat(2:2:blockNum,9,1),numel(matrixoutput(:,2:2:blockNum)),1);

figure(1)

hold on
scatter(oddSBx , oddSBy , 15 , [.5 0 .5])
scatter(evenSBx , evenSBy , 15 , [0 0 .5])

line([(1:2:blockNum)-0.4 ; (1:2:blockNum)+0.4] , [odds_meanperblock ; odds_meanperblock],...
    'Color' , [.5 0 .5] , 'LineWidth' , 2)

line([(2:2:blockNum)-0.4 ; (2:2:blockNum)+0.4] , [evens_meanperblock ; evens_meanperblock],...
    'Color' , [0 0 .5] , 'LineWidth' , 2)
xlim([0 blockNum+1])
xticks(1:1:blockNum)
axis square
% b = bar(meanperblock);
% b.FaceColor = 'flat';
% b.CData(1:2:16,:) = repmat([.5 0 .5],8,1);

title('Reaction time by block')
ylabel('Reaction time (seconds)')
xlabel('Block #')
mean_odds_meanperblock = mean(odds_meanperblock);
mean_evens_meanperblock = mean(evens_meanperblock);
std_odds1 = std(odds_meanperblock);
std_evens1 = std(evens_meanperblock);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
c = bar([mean_odds_meanperblock;mean_evens_meanperblock]);
hold on
errorbar([mean_odds_meanperblock;mean_evens_meanperblock],...
         [std_odds1;std_evens1])
c.FaceColor = 'flat';
c.CData(1,:) = [.5 0 .5];%makes the odds average purple
title('Reaction time by block type')
ylabel('Reaction time (seconds)')
xticks([1 2])
xticklabels({'SG','IS'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis square

%% Generates bar graph for NORMALIZED reaction times

matrixoutputN = reshape(analysismatrix(:,4),blocklength,blockNum);
sumperblockN = sum(matrixoutputN);
meanperblockN = sumperblockN/blocklength;
odds_meanperblockN = meanperblockN(1:2:blockNum);
evens_meanperblockN = meanperblockN(2:2:blockNum);

title('Normalized reaction time by block')
ylabel('Normalized reaction time (Z-score)')
mean_odds_meanperblockN = mean(odds_meanperblockN);
mean_evens_meanperblockN = mean(evens_meanperblockN);
std_odds = std(odds_meanperblockN);
std_evens = std(evens_meanperblockN);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3)
c = bar([mean_odds_meanperblockN;mean_evens_meanperblockN]);
hold on
errorbar([mean_odds_meanperblockN;mean_evens_meanperblockN],...
         [std_odds;std_evens])
c.FaceColor = 'flat';
c.CData(1,:) = [.5 0 .5];%makes the odds average purple
title('Normalized reaction time by block type')
ylabel('Reaction time (Z-score)')
xticks([1 2])
xticklabels({'SG','IS'})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis square




