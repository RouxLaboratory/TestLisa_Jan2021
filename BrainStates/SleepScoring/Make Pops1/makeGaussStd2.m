function out = makeGaussWin(Width, stdV)
%function out = makeGaussWin(halfWidth - 1, stdV)

alpha = Width/(2*stdV);
out = gausswin(Width, alpha);

% 
% x = (-1*halfWidth):halfWidth;
% 
% out = exp(-(0 - x).^2/(stdV^2));
