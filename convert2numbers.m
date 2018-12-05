function [ output ] = convert2numbers( alphabet, sequence )
output = zeros(1, length(sequence));
for i = 1:length(sequence)
    for j = 1:length(alphabet)
        if sequence{i} == alphabet(j,:)
            break
        end
    end
    output(i) = j;
end
end