function [ probs ] = empprobs( alphabet, sequence )
sequence = convert2numbers(alphabet, sequence);
probs = zeros(length(alphabet));

for i = 1:length(probs)
    % first find every occurence of the letter i 
    occurs = find(sequence == i);
    
    % then for each transitioned letter j increment its cell in the probs array
    for j = 1:length(occurs)
        if occurs(j) ~= length(sequence)
            probs(i, sequence(occurs(j)+1)) = probs(i, sequence(occurs(j)+1)) + 1.0;
        end
    end
    
    % finally divide the letter's row by the total number of occurances
    probs(i, :) = probs(i, :)/length(occurs);
end