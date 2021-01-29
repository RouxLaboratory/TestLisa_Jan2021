function [out, segmentLength] = suprathresh(V, thresh)
%function [out, segmentLength] = suprathresh(V, thresh)

if size(V, 1) < size(V, 2)
    V = V';
end

V = V >= thresh;
V = [0; V; 0];
d = diff(V);

out = [find(d == 1), find(d == -1) - 1];
segmentLength = diff(out, [], 2) + 1;
end
