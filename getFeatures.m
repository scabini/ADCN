function [ featureVector ] = getFeatures( img, li, lf, n)
%getFeatures takes an image of the shape contour and calculates the Angular
% Descriptor features (ADCN) to the given parameters, according to the
% work (Scabini, Leonardo FS, et al. "Angular Descriptors of Complex 
% Networks: a novel approach for boundary shape analysis." Expert Systems 
% with Applications (2017))
% 
% author: Leonardo Scabini
%
% WARNING: Before using this function, make sure you properly compiled the
% c++ source function CNangle_histogram.cpp using the MATLAB mex.
%
% Usage: "img" is a 2d matrix where pixel values 0 indicates background and
%   values 255 indicates a boundary pixel.
%
%   "li" and "lf" are, respectivelly, the initial and final thresholds
%   calculated by the function "automaticThresholds".
%
%   "n" is the number of desired thresholds.
%
%   Returns: "featureVector" with the Angular descriptors of complex
%   networks to the given shape ("img"). Size of |featureVector| = n*6.

    radiuset = [];
    radiuset(1) = li;
    radiuset(n) = lf;
    inc = (lf - li)/(n-1);
    for i=2:n-1
        radiuset(i) = radiuset(i-1) + inc;
    end

    img = im2uint8(img);
    if size(img,3) >= 3
        img = rgb2gray(img(:,:,1:3));  
    end 
    
    featureVector= [];               

    hist = CNangle_histogram(double(img'), double(radiuset));

    for p=1:n
        featureVector = [featureVector, getMeasures(hist(p,:))];  
    end 

end

