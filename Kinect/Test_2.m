clc; clearvars; close all;

load('RGB_D_Image_Slice.mat') % Loading the image slices

[pointsRGB, boardSizeRGB, imagesRGBused] = ...
    detectCheckerboardPoints(C_image_slice);

