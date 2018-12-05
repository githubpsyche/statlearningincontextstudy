function [ matrix ] = newmatrix( alphasize, ctrlcount, ctrlpwr, exppwr)
%TMATRIX Produces a matrix of transition probs given the parameters
%   They are: the size of the alphabet, the number of "control" pairings,
%   and the strength of the control and experimental pairings (ex .5, 1)

    % make sure the input is valid
    if alphasize <= ctrlcount*2
        print('!!!: ctrlcount is too large!')
    else if alphasize
        end
    end
    
    % construct the base vector for the matrix and make it the whole matrix
    matrix = zeros(alphasize);
    expcount = alphasize/2-ctrlcount;
    for i = 1:ctrlcount
       matrix(1,i) = 1;
       matrix(1,i+ctrlcount) = 1-ctrlpwr;
    end
    for i = (ctrlcount*2+1):(ctrlcount*2+expcount)
        matrix(1,i) = 1;
        matrix(1,i+expcount) = 1-exppwr;
    end
    for i = 2:alphasize
        matrix(i,:) = matrix(1,:);
    end
    
    % correct certain rows for pairings
    for i = 1:ctrlcount
        matrix(i,i+ctrlcount) = ctrlpwr;
    end
    for i = (ctrlcount*2+1):(ctrlcount*2+expcount)
        matrix(i,i+expcount) = exppwr;
    end
    
    % transform matrix into a transition matrix
    for i = 1:ctrlcount
        remainder = 1-matrix(i,i+ctrlcount);
        matrix(i,:) = (remainder/sum(matrix(i,:)))*matrix(i,:);
    end
    for i = (ctrlcount+1):(ctrlcount*2)
        remainder = 1;
        matrix(i,:) = (remainder/sum(matrix(i,:)))*matrix(i,:);
    end
    for i = (ctrlcount*2+1):(ctrlcount*2+expcount)
        remainder = 1-matrix(i,i+expcount);
        matrix(i,:) = (remainder/sum(matrix(i,:)))*matrix(i,:);
    end
    for i = (ctrlcount*2+expcount+1):alphasize
        remainder = 1;
        matrix(i,:) = (remainder/sum(matrix(i,:)))*matrix(i,:);
    end
    
    % correct certain rows for pairings
    for i = 1:ctrlcount
        matrix(i,i+ctrlcount) = ctrlpwr;
    end
    for i = (ctrlcount*2+1):(ctrlcount*2+expcount)
        matrix(i,i+expcount) = exppwr;
    end
end

