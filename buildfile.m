function plan = buildfile
import matlab.buildtool.tasks.*
import matlabtest.plugins.codecoverage.StandaloneReport
import matlab.unittest.plugins.codecoverage.CoberturaFormat

plan = buildplan(localfunctions);

plan("clean") = CleanTask;

plan("check") = CodeIssuesTask;

plan("test") = TestTask(SourceFiles="toolbox").addCodeCoverage([StandaloneReport("mystandalonereport.html") CoberturaFormat("cov.xml")]);

plan("test").Dependencies = ["setup" "mex" "pcode"];

% plan("mex") = MexTask.forEachFile("mex\*.c", "toolbox");

plan("mex") = MexTask("mex\convec.c", "toolbox");

plan("pcode") = PcodeTask("pcode", "toolbox");

% plan("toolbox") = ToolboxTask.fromToolboxProject("Mass-Spring-Damper.prj");
% plan("toolbox").Dependencies = ["check" "test"];

% plan.DefaultTasks = "toolbox";
plan.DefaultTasks = ["check" "test"];
end

function setupTask(~)
addpath("toolbox");
addpath(fullfile("toolbox", "doc"));
end
