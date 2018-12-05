function [ sequence ] = unitgen(tmatrix, n, resample_limit, alphabet) % add alphabet later

% first characterize the desired sequence in terms of transition matrices,
% frequencies, and so forth

% count the number of rows with unique entries
ueCount = 0;
for i = 1:length(tmatrix)
    row = tmatrix(i,:); 
    if ~isempty(row(sum(bsxfun(@eq, row(:), row(:).'))==1))
        ueValue = row(sum(bsxfun(@eq, row(:), row(:).'))==1);
        if (ueValue ~= 0)
            ueCount = ueCount + 1;
        end
    end
end

% preallocate!
units = num2cell(1:length(tmatrix)+ueCount);
proportion = zeros(1, length(tmatrix)+ueCount);
not = zeros(1,length(tmatrix)+ueCount);

% now fill the units, proportion, and not vectors appropriately
addindex = length(tmatrix)+1;
for i = 1:length(tmatrix)
    % pull a row from tmatrix and find its unique entry if one exists
    % if one does, determine its index and value
    % from these, identify the correct units to add, their proportions, and
    % the units they cannot follow
    row = tmatrix(i,:); 
    if ~isempty(row(sum(bsxfun(@eq, row(:), row(:).'))==1))
        ueValue = row(sum(bsxfun(@eq, row(:), row(:).'))==1);
        ueIndex = find(row == ueValue, 1);
        if (ueValue == 0.0)
            proportion([i ueIndex]) = 1.0;
        else
            units{addindex} = [i ueIndex];
            proportion([i ueIndex]) = (1-ueValue);
            proportion(addindex) = ueValue;
            not(ueIndex) = i;
            addindex = addindex + 1;
        end
    end
end

proportion

% finish up by converting the proportion vector into a vector of desired
% unit frequencies
proportion = proportion/sum(proportion);
p = proportion;
proportion((length(tmatrix)+1):length(proportion)) = ....
    2* proportion((length(tmatrix)+1):length(proportion));
freqs = p.*n/sum(proportion);

freqs
fsum = sum(freqs) + sum(freqs((length(tmatrix)+1):length(freqs)))

% now we begin the master loop; start with a basic version and then expand
% the innermost while loop just continues until a sequence is finished
% the next loop 
seq = nan(1, n);
index = 1;
f = freqs; % a copy of freqs we modify until a proper seq is generated

%while ~all(all(abs(empprobs(1:length(tmatrix), seq)-t) < .01))    
while any(isnan(seq))
    resample = resample_limit; % reset the resample limit
    f(f<0)=0;
    u = randsample(1:length(units), 1, true, f); % sample from units based on frequency vector
    legal = 0;
    
    % until resample falls past 0 or the unit is legal at the current index,
    % resample, test for unit legality, and decrement resample.
    while resample >= 0 && legal == 0
        % resample
        u = randsample(1:length(units), 1, true, f);
        resample = resample - 1;
        
        % test if sample is legal
        % sample is illegal if f(u) < 0 or not(u) == seq(index-1) while the
        % index != 1 OR length(u) > nancount(seq)
        legal = 1;
        if f(u) <= 0
            legal = 0;
        end
        
        if index ~= 1
            if not(u) == seq(index-1)
                legal = 0;
            end
        end
        
        unit = units(u);
        if length(unit{:}) > sum(isnan(seq))
            legal = 0;
        end
    end

    % if loop stopped because a legal unit was found, fill the sequence
    % with the unit and proceed to the next index
    % otherwise, start everything over.
    if legal
        unit = units(u);
        seq(index:index+length(units(u))) = unit{:};
        f(u) = f(u) - 1;
        index = index + length(unit{:});
    else
        seq = nan(1, n);
        index = 1;
        f = freqs;
    end
end
%end

empprobs2(1:length(tmatrix), seq)
seq
% convert to letters
sequence = cell(1,n);
for i = 1:n
    sequence{i} = alphabet(seq(i),:);
end