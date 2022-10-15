function plan = buildfile

plan = buildplan(localfunctions);

plan("mex").Inputs = files(plan, "mex/**/*.c");
plan("mex").Outputs = files(plan, "toolbox/**/*." + mexext);

plan("pcode").Inputs = files(plan, "pcode/**/*.m");
plan("pcode").Outputs = files(plan, "toolbox/**/*.p");

plan("pcodeHelp").Inputs = plan("pcode").Inputs;
%plan("pcodeHelp").Outputs = files(plan, "toolbox/**/*.m"]); % how to do this?

plan("lint").Inputs = files(plan, ["toolbox/**/*.m", "pcode/**/*.m"]);


plan("test").Dependencies = ["mex", "pcode"];

plan("toolbox").Dependencies = ["lint", "test", "doc", "pcodeHelp"];
plan("toolbox").Inputs = files(plan, "toolbox");
plan("toolbox").Outputs = files(plan, "release/*.mltbx");

plan("doc").Dependencies = "docTest";
plan("doc").Inputs = files(plan, "toolbox/doc/**/*.mlx");
plan("doc").Outputs = files(plan, "toolbox/doc/**/*.html");

plan("install").Dependencies = "integTest";
plan("integTest").Dependencies = "toolbox";

plan("lintAll") = matlab.buildtool.Task("Description","Find code issues in source and tests");
plan("lintAll").Dependencies = ["lint", "lintTests"];

plan.DefaultTasks = "integTest";
end


function lintTask(~)
% Find static code issues

issues = codeIssues(["toolbox", "pcode"]);
if ~isempty(issues.Issues)
    disp(formattedDisplayText(issues.Issues,"SuppressMarkup",feature("hotlinks")));
    disp("Detected code issues in source")
end
if ~isempty(issues.SuppressedIssues)
    disp(formattedDisplayText(issues.SuppressedIssues,"SuppressMarkup",feature("hotlinks")));
    disp("Detected suppressed issues in source")
end
end

function mexTask(context)
% Compile mex files

outputPaths = replace(context.Inputs.paths,textBoundary + wildcardPattern + filesep, "toolbox" + filesep);

for idx = 1:numel(context.Inputs.paths)
    thisFile = context.Inputs.paths{idx};
    disp("Building " + thisFile);
    mex(thisFile,"-outdir", fileparts(outputPaths(idx)));
end
end

function docTask(~, options)
% Generate the doc pages

arguments
    ~
    options.Env (1,:) string = "standard"
end

if options.Env == "ci"
    fprintf("Starting connector...");
    connector.internal.startConnectionProfile("loopbackHttps");
    com.mathworks.matlabserver.connector.api.Connector.ensureServiceOn();
    disp("Done");
end

export("toolbox/doc/GettingStarted.mlx","toolbox/doc/GettingStarted.html");
end

function docTestTask(~)
% Test the doc and examples

results = runtests("tests/doc");
disp(results);
assertSuccess(results);
end

function testTask(~)
% Run the unit tests

results = runtests("tests");
disp(results);
assertSuccess(results);
end

function lintTestsTask(~)
% Find code issues in test code

issues = codeIssues("tests");
if ~isempty(issues.Issues)
    disp(formattedDisplayText(issues.Issues,"SuppressMarkup",feature("hotlinks")));
    disp("Detected code issues in tests")
end
if ~isempty(issues.SuppressedIssues)
    disp(formattedDisplayText(issues.SuppressedIssues,"SuppressMarkup",feature("hotlinks")));
    disp("Detected suppressed issues in tests")
end
end

function toolboxTask(~)
% Create an mltbx toolbox package

matlab.addons.toolbox.packageToolbox("Mass-Spring-Damper.prj","release/Mass-Spring-Damper.mltbx");

end

function pcodeHelpTask(context)
% Extract help text for p-coded m-files

outputPaths = "toolbox" + filesep + reverse(fileparts(reverse(context.Inputs.paths)));

for idx = 1:numel(context.Inputs.paths)

    % Grab the help text for the pcoded function to generate a help-only m-file
    mfile = context.Inputs.paths{idx};

    helpText = deblank(string(help(mfile)));
    helpText = split(helpText,newline);
    if helpText == ""
        disp("No help text to extract for " + mfile);
    else
        disp("Extracting help for for " + mfile);
        helpText = replaceBetween(helpText, 1, 1, "%"); % Add comment symbols

        % Write the file
        fid = fopen(outputPaths(idx),"w");
        closer = onCleanup(@() fclose(fid));
        fprintf(fid, "%s\n", helpText);
    end
end
end

function pcodeTask(context)
% Obfuscate m-files

startDir = pwd;
cleaner = onCleanup(@() cd(startDir));
inputFolders = unique(fileparts(context.Inputs.paths));
outputFolders = "toolbox" + filesep + reverse(fileparts(reverse(inputFolders)));

for idx = 1:numel(inputFolders)
    disp("P-coding files in " + inputFolders(idx));
    % Now pcode the file
    thisOutputFolder = fullfile(context.Plan.RootFolder, outputFolders(idx));
    thisInputFolder = fullfile(context.Plan.RootFolder,inputFolders(idx));
    if ~exist(thisOutputFolder,"dir")
        mkdir(thisOutputFolder);
    end
    cd(thisOutputFolder);
    pcode(thisInputFolder);
end
end

function cleanTask(~)
% Clean all derived artifacts

derivedFiles = [...
    "toolbox/springMassDamperDesign.m"
    "toolbox/springMassDamperDesign.p"
    "toolbox/convec." + mexext
    "toolbox/sub/convec2." + mexext
    "toolbox/subp/simulateSystem2.m"
    "toolbox/subp/simulateSystem2.p"
    "toolbox/doc/GettingStarted.html"
    "release/Mass-Spring-Damper.mltbx"
    ];

arrayfun(@deleteFile, derivedFiles);
end

function integTestTask(~, options)
% Run integration tests
arguments
    ~
    options.SandboxType (1,:) string = "full"
end

sourceFile = which("simulateSystem");

if options.SandboxType == "full"

    % Remove source
    sourcePaths = cellstr(fullfile(pwd, ["toolbox", "toolbox" + filesep + "doc"]));
    origPath = rmpath(sourcePaths{:});
    pathCleaner = onCleanup(@() path(origPath));

    % Install Toolbox

    tbx = matlab.addons.toolbox.installToolbox("release/Mass-Spring-Damper.mltbx");
    tbxCleaner = onCleanup(@() matlab.addons.toolbox.uninstallToolbox(tbx));

    assert(~strcmp(sourceFile,which("simulateSystem")), ...
        "Did not setup integ environment toolbox correctly");
else
    disp("Falling back to unit tests without full environment")
end
results = runtests("tests","IncludeSubfolders",true);
disp(results);
assertSuccess(results);

clear pathCleaner tbxCleaner;
assert(strcmp(sourceFile,which("simulateSystem")), ...
    "Did not restore integ environment correctly");

end

function installTask(~)
% Install the toolbox locally

matlab.addons.toolbox.installToolbox("release/Mass-Spring-Damper.mltbx");
end


function deleteFile(file)
if exist(file,"file")
    delete(file);
end
end

