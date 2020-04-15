function [geo, ScanXML, ReconXML] = GeometryFromXML(datafolder)
% Dependence: xml2struct.m
% Date: 2020-03-28

%% Scan.xml
filestr = dir([datafolder filesep 'Scan.xml']);

ScanXML = getfield(xml2struct(fullfile(filestr.folder, filestr.name)),...
    'Scan');

%% Reconstruction.xml
filestr = dir([datafolder filesep '**' filesep 'Reconstruction.xml']);

ReconXML = getfield(xml2struct(fullfile(filestr.folder, filestr.name)),...
    'Reconstruction');

%% Generate Scan Parameters
% Cone-beam CT scenario
geo.mode = 'cone';

% in geo, only 14 predefined fields can allowed
% determine arc/fan in FDK
%{ 
% Circular Trajectory: Full/Half
% flag to decide whether to use Parker weighting in FDK
geo.arc = ScanXML.Acquisitions.Trajectory.Text;
% Full/Half Fan: Full/Half
% flag to decide whether to use Wang weighting in FDK
geo.fan = ScanXML.Acquisitions.Fan.Text;
% Rotation Direction: 1 for clockwise, -1 for counterclockwise
% as a limitation of current FDK function
geo.closewise = sign(...
    str2double(ScanXML.Acquisitions.StopAngle.Text)...
     - str2double(ScanXML.Acquisitions.StartAngle.Text));
%}

% Distances                    (mm)
geo.DSD = str2double(ScanXML.Acquisitions.SID.Text);
geo.DSO = str2double(ScanXML.Acquisitions.SAD.Text);

% number of pixels             (vx)
geo.nDetector = [...
    str2double(ScanXML.Acquisitions.ImagerSizeX.Text); ...
    str2double(ScanXML.Acquisitions.ImagerSizeY.Text)];
% pixel size                   (mm)
geo.dDetector = [...
    str2double(ScanXML.Acquisitions.ImagerResX.Text); ...
    str2double(ScanXML.Acquisitions.ImagerResY.Text)];
% total size of the detector   (mm)
geo.dDetector = geo.nDetector.*geo.dDetector;

% Offset of Detector           (mm)
offset = str2double(ScanXML.Acquisitions.ImagerLat.Text);
geo.offDetector = [offset; 0 ];
% Offset of image from origin  (mm) 
geo.offOrigin =[0;0;0];                                  

% Auxiliary 
% Variable to define accuracy of 'interpolated' projection
% It defines the amoutn of samples per voxel.
% Recommended <=0.5          (vx/sample) 
geo.accuracy=0.5;                           

%% Generate Image Parameters
% total size of the image       (mm)
geo.sVoxel=[str2double(ReconXML.VOISizeX.Text);...
    str2double(ReconXML.VOISizeY.Text);...
    str2double(ReconXML.VOISizeZ.Text)];
% number of voxels              (vx)
SliceNO = round(geo.sVoxel(3)/str2double(ReconXML.SliceThickness.Text));
geo.nVoxel=[str2double(ReconXML.MatrixSize.Text);
    str2double(ReconXML.MatrixSize.Text);
    SliceNO];
% size of each voxel            (mm)
geo.dVoxel=geo.sVoxel./geo.nVoxel;

end