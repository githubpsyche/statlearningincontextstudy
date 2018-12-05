function seq = testwhen(sequence, alphabet, pertest, width)

% sort every index in sequence by its letter
indices = {};
for i = 1:length(sequence)
    indices{sequence(i)} = [];
end
for i = 1:length(sequence)
    indices{sequence(i)} = [indices{sequence(i)} i];
end

stillInvalid = 1;
while stillInvalid
    % select a set number of indices per identified alphabet
    seq = [];
    for i = 1:length(alphabet)
        seq = [seq randsample(indices{i},pertest)];
    end

    % sort sample and test for excessive proximity
    seq = sort(seq);
    difference = seq - [0 seq(1:end-1)];
    if ~any(difference(2:end) < width)
        stillInvalid = 0;
    end
end
end