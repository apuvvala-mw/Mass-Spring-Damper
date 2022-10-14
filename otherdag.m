function plan = buildfile

plan = buildplan(localfunctions);

plan("test").Dependencies = ["mex", "pcode"];
plan("toolbox").Dependencies = ["mex", "pcode", "doc"];

plan("install").Dependencies = "package";
plan("integTest").Dependencies = "toolbox";

plan("lintAll") = matlab.buildtool.Task("Description","Find code issues in source and tests");
plan("lintAll").Dependencies = ["lint", "lintTests"];

plan("release") = matlab.buildtool.Task("Description","Full qualification and release of the toolbox");
plan("release").Dependencies = ["toolbox", "test","lint","integTest","docTest"]

plan.DefaultTasks = "integTest";
end