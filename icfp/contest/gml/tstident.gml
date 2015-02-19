% GML Test script 
% for testing the scanning of identifiers

% From the spec:
% Identifiers must start with an letter and can contain letters, digits, 
% dashes (`-'), and underscores (`_')

%foo
 foo
%foo-bar
 foo-bar
%foo-
 foo-
%foo--
 foo--
%foo_bar
%foo_bar
 foo_bar
%foo_
 foo_
%foo__
 foo__
%foo123
 foo123
%foo-123
 foo-123
%foo_123
 foo_123
