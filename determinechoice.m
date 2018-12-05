function [ choice ] = determinechoice( alphasize, x, y, xCenter, yCenter )
angle = atan2(y, x) * (180/pi)+90;
if angle < 0
    angle = 360+angle;
end
increment = 360.0/alphasize;
choice = ceil(angle/increment);
if sqrt(x^2 + y^2) < 550/2
    choice = NaN;
end
end

