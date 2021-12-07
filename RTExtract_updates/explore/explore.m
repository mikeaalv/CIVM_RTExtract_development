function explore(fname)
%EXPLORE           show file/function/directory in native file browser
%
%   EXPLORE opens the native file browser in the current directory
%   EXPLORE(DIR) or EXPLORE DIR opens a file browser in the
%      directory DIR
%   EXPLORE(FILENAME) or EXPLORE FILENAME opens a file browser in the
%   directory where the file FILENAME.m is located and selects the file.
%

% Copyright (c) georg ogris ::: spantec.at ::: fall 2004
% All rights reserved.
%
% videoIO, ffmpeg, and friends are licensed under GPL. That is why these
% sources/libraries are not included within videoioPlayer.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the author nor the names 
%       of its contributors may be used to endorse or promote products derived 
%       from this software without specific prior written permission.
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

if ~exist('fname','var')
    dir = '.' ;
elseif isdir(fname)
    dir = fname ;
else
    if ~ischar(fname), error('Input should be a string.') ; end
    file = which(fname);
    if isempty(file)
        if exist(fname,'file') == 2
            file = fname ;
        else
            error(['Neither file ''' fname '.m'' not nor build-in function found.']) ;
        end
    elseif strcmpi('b',file(1))
        try
            file = file(regexp(file,'\(')+1:regexp(file,'\)')-1) ;
        catch ME            
            error(['Thought it was a build-in function found, ' ...
                'but failed with error message: ' ME.message]) ;
        end
    end
end

if ispc
    if exist('file','var')
        dos(['explorer /e,/select,',file]);
    else
        dos(['explorer /e,',dir]);
    end
elseif ismac
    if exist('file','var')
        unix(['open -R ',file]);
    else
        unix(['open ',dir]);
    end    
elseif isunix
    %     try
    %         unix(['thunar ',dir]);
    %     catch
    %         error('Starting thunar faild.')
    %     end
    try
        if exist('file','var')
            unix(['konqueror --select ',file,' &']);
        else
            unix(['konqueror ',dir,' &']);
        end
    catch ME
        error(['Starting konqueror faild with error: ' ME.message])
    end
end



