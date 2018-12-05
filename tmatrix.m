function [ matrix ] = tmatrix( alphasize, ctrlcount, ctrlpwr, exppwr)
%TMATRIX Produces a matrix of transition probs given the parameters
%   They are: the size of the alphabet, the number of "control" pairings,
%   and the strength of the control and experimental pairings (ex .5, 1)
    
    % make sure the input is valid
    if alphasize <= ctrlcount*2
        print('!!!: ctrlcount is too large!')
    else if alphasize
        end
    end

    matrix = zeros(alphasize);  % construct the matrix
    for i = 1:ctrlcount         % fill the first rows with control pairings
        for j = 1:alphasize
            if j == i+ctrlcount
                matrix(i,j) = ctrlpwr;
            else
                matrix(i,j) = (1-ctrlpwr)/(alphasize-1);
            end
        end
    end
    
    % the latter part of control pairings have equiprobable successors
    for i = (ctrlcount+1):(ctrlcount*2)
        for j = 1:alphasize
            matrix(i,j) = 1/alphasize;
        end
    end
    
    % now the first part of the experimental pairings...
    expcount = alphasize/2-ctrlcount;
    for i = (ctrlcount*2+1):(ctrlcount*2+expcount)
        for j = 1:alphasize
            if j == i + (ctrlcount*2+expcount)-ctrlcount*2
                matrix(i,j) = exppwr;
            else
                matrix(i,j) = (1-exppwr)/(alphasize-1);
            end
        end
    end

    % almost done; the last part of the experimental pairings
    for i = (ctrlcount*2+expcount+1):alphasize
        for j = 1:alphasize
            matrix(i,j) = 1/alphasize;
        end
    end
end

