function resolved = removeDotsFromFilePath(filePath)
    resolved = regexprep(filePath, '(?<=^|[\\/])\.[\\/]', '');
    
    dotDotRegexp = '(?<=^|[\\/])(?!\.\.[\\/])[^\\/]+[\\/]\.\.[\\/]';
    while ~isempty(regexp(resolved, dotDotRegexp, 'once'))
        resolved = regexprep(resolved, dotDotRegexp, '');
    end
end

%   Copyright 2011 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2011/06/15 08:03:55 $
