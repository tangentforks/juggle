% GML Test script 
% for testing the scanning of comments

% This is a comment
	% This one is indented
% The next one will be an empty comment
%
% "A string in a comment"
% More special chars: /[]{}%"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The next two lines should produce an error, shouldn't they?
/%foo
bar

