function [ frequencies ] = empfreqs( alphabet, sequence )
sequence = convert2numbers(alphabet, sequence);
frequencies = 1:length(alphabet);
for i = 1:length(alphabet)
    frequencies(i) = nnz(sequence == i);
end