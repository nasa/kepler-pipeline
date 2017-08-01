function draw(transitingOrbitObject, figureNum)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
theta = 0:2*pi/(100-1):2*pi;
r0 = transitingOrbitObject.periCenterR;
e = transitingOrbitObject.eccentricity;
thetaLOS = transitingOrbitObject.lineOfSightAngle; 

r = r0*(1+e)./(1+e*cos(theta));
x = r.*cos(theta);
y = r.*sin(theta);
z = zeros(size(x));

rLos = r0*(1+e)/(1+e*cos(thetaLOS));
xLos(1) = 0;
xLos(2) = rLos*cos(thetaLOS);
yLos(1) = 0;
yLos(2) = rLos*sin(thetaLOS);
zLos = zeros(size(xLos));

primaryRadius = transitingOrbitObject.primaryRadiusMks;
xPrimary2d = primaryRadius*cos(theta);
yPrimary2d = primaryRadius*sin(theta);
[xPrimary, yPrimary, zPrimary] = sphere(10);

secondaryRadius = transitingOrbitObject.secondaryRadiusMks;
xSecondary2d = r0 + secondaryRadius*cos(theta);
ySecondary2d = secondaryRadius*sin(theta);
[xSecondary, ySecondary, zSecondary] = sphere(10);
xSecondary = r0 + secondaryRadius*xSecondary;
ySecondary = secondaryRadius*ySecondary;
zSecondary = secondaryRadius*zSecondary;

if ~isempty(transitingOrbitObject.rotatedExposureStartPosition)
    xExp = transitingOrbitObject.exposureStartPosition(:,1);
    yExp = transitingOrbitObject.exposureStartPosition(:,2);
    zExp = transitingOrbitObject.exposureStartPosition(:,3);
    xExpRot = transitingOrbitObject.rotatedExposureStartPosition(:,1);
    yExpRot = transitingOrbitObject.rotatedExposureStartPosition(:,2);
    zExpRot = transitingOrbitObject.rotatedExposureStartPosition(:,3);
    
    negInd = find(transitingOrbitObject.exposureStartTransitSign < 0);
    xNegExp = transitingOrbitObject.exposureStartPosition(negInd,1);
    yNegExp = transitingOrbitObject.exposureStartPosition(negInd,2);
    zNegExp = transitingOrbitObject.exposureStartPosition(negInd,3);
    
    
else
    xExp = 0;
    yExp = 0;
    zExp = 0;
    xExpRot = 0;
    yExpRot = 0;
    zExpRot = 0;
    xNegExp = 0;
    yNegExp = 0;
    zNegExp = 0;
end

if nargin > 1
    figure(figureNum);
else
    figure;
end

subplot(1,2,1)
plot(x, y, xLos, yLos, xExp, yExp, '+', xExpRot, yExpRot, '.', ...
    xNegExp, yNegExp, 'o', 0, 0, 'x', xPrimary2d, yPrimary2d, xSecondary2d, ySecondary2d);
axis equal
subplot(1,2,2)
mesh(primaryRadius*xPrimary, primaryRadius*yPrimary, primaryRadius*zPrimary, 'EdgeColor', [1 1 0]);
hold on;
mesh(xSecondary, ySecondary, zSecondary, 'EdgeColor', [1 1 0]);
plot3(x, y, z, xLos, yLos, zLos, xExp, yExp, zExp, '+', xExpRot, yExpRot, zExpRot, '.', ...
    xNegExp, yNegExp, zNegExp, 'o', 0, 0, 0, 'x');
hold off;
axis equal
    