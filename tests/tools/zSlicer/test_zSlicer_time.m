function tests = test_zSlicer_time
    tests = functiontests(localfunctions);
end

function teardown(testCase)  % do not change function name
    close('all');
end

%% Test zSlicer 2D
function test2D_inputData(testCase)
    maxZ = 1;
    im = randi([0, 1], [4,4,maxZ]);
    maxZ = 1;
    handles.settings.lists.files_tif = {'dummy.tif'};
    timepoints = {datetime};
    workingDir = 'dummy';
    metadata.data.scaling.dxy = 1;
    metadata.data.scaling.dz = 1;
    file = 1;
    zSlicer_time(im, maxZ, handles.settings.lists.files_tif, timepoints, workingDir, metadata.data.scaling, file);
end

%% Test zSlicer 3D
function test3D_inputData(testCase)
    maxZ = 4;
    im = randi([0, 1], [4,4,maxZ]);
    handles.settings.lists.files_tif = {'dummy.tif'};
    timepoints = {datetime};
    workingDir = 'dummy';
    metadata.data.scaling.dxy = 1;
    metadata.data.scaling.dz = 1;
    file = 1;
    zSlicer_time(im, maxZ, handles.settings.lists.files_tif, timepoints, workingDir, metadata.data.scaling, file);
end