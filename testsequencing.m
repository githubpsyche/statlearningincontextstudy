subjectID = 'eh';

%% reseed based on subjectID
if strcmp(version('-release'),'2010a')
    s = RandStream.create('mt19937ar','seed',pm_hash('crc',double(subjectID)));
    RandStream.setDefaultStream(s);
else
    rng(pm_hash('crc',double(subjectID)));
end

%% timing params (all times in sec)
% fixation | stim1 | isi ... fixation | teststim | rw | fb | isi ...
tic 
params.timing.fix = .5;            % fixation point
params.timing.stimDur = 1.0;       % stimulus duration
params.timing.isi = .5;            % interstimulus interval
params.timing.respRW = 5.0;        % afc response window timeout
params.timing.respFB = .25;         % response feedback
params.timing.postTrial = .15;     % small wait after trial

%% count info (how many trials divided between how many blocks??)
if ismember(subjectID,{'practice','debug'})
    params.count.numBlocks = 1;
    params.count.numSquares = params.count.numBlocks*320;
else
    params.count.numBlocks = 1;
    params.count.numSquares = params.count.numBlocks*320;
end

params.count.trialsPerBlock = params.count.numSquares./params.count.numBlocks;
params.count.block = [1:params.count.trialsPerBlock:params.count.numSquares params.count.numSquares];

%% letter sequence features
params.seq.alphasize = 8;
params.seq.ctrlcount = .25 * params.seq.alphasize;
params.seq.expcount = params.seq.alphasize - params.seq.ctrlcount;
params.seq.ctrlpwr = .5;
params.seq.exppwr = 0;

%% alphabet is a bit challenging
params.seq.alphabet = distinguishable_colors(params.seq.alphasize);
params.seq.alphabet = params.seq.alphabet(randperm(params.seq.alphasize), :);

% define the actual sequence by looping "something" until a valid one is produced
params.seq.resample = 100;

params.seq.colors = [];
for i = 1:params.count.numBlocks
    params.seq.colors = [params.seq.colors unitgen(tmatrix(params.seq.alphasize,params.seq.ctrlcount, params.seq.ctrlpwr, params.seq.exppwr), params.count.trialsPerBlock, params.seq.resample, params.seq.alphabet)];
end

% determine the seq's empirical transition probabilities and frequencies 
params.seq.empprobs = empprobs(params.seq.alphabet, params.seq.colors)
params.seq.empfreqs = empfreqs(params.seq.alphabet, params.seq.colors)
params.seq.numbers = convert2numbers(params.seq.alphabet, params.seq.colors);