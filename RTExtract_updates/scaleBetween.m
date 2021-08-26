function scaledVals = scaleBetween(vals,interval)
%% Useful for scaling a matrix of values to distribute between two numbers
% vals: matrix
% interval: [a,b]
% 
% scaledVals: the values of 'vals' distributed between a and b

%% Correct order of interval

    if interval(1)>interval(2)
        interval = interval(end:1);
    end
    
    %% Compute
    
         scaledVals = (interval(1) - interval(2))  *  (vals-min(vals)) /...
                                                      (max(vals)-min(vals))     + interval(1);


end