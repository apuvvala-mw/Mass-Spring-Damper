%% If you build it, they will come
% 
% My people! Oh how I have missed you. It has been such a long time since
% we have talked about some developer workflow goodness here on the blog.
% The silver lining here is that while I have found it hard to sit down and
% write up some thoughts and musings a big reaso for that is we have been
% hard at work deleivering development infrastructure for MATLAB. 
%
% One of those things is the new build tool for MATLAB that is now part of
% R2022b! We are super excited for this, it's rookie release, but even
% more excited for all the more value that will come of it as you begin
% using it for your MATLAB projects and in subsequent releases as we
% continue to enhance it. 
%
% What is this thing anyway? Well in short it is a standard interface for
% you to build and collaborate on your MATLAB projects. "Build?", you say?
%
% Yes, "Build!", I say. Anyone developing serious, shareable, production
% grade MATLAB code knows that even this easy to leverage language that
% typically doesn't require an actual "compile" step still needs a
% development process that includes things like testing, other quality
% gates, and bumping a release. Also it turns out that there are many ways
% in which MATLAB does indeed _*build*_ something. Think mex files, p-code,
% code generation, toolbox packages, doc pages, or producing artifacts from
% MATLAB Compiler and Compiler SDK. These are all build steps.
%
% The issue though, has been that there was no standard API for MATLAB
% projects to organize these build steps. It usually ends up looking
% something like this:
%
% <<y2022AdHocScripts.png>>
% 
% Does this look familiar? It does to me. All of these scripts grow in a
% project or repo for doing these specific tasks. Each one looks  alittle
% different because one was written on Tuesday and the other the following
% Monday. If we are lucky, we remember how these all work when we need to
% interact with them. However, sometimes we are not lucky. Sometimes we go
% back to our code and haven't the foggiest idea how we built it, i what
% order and with which scripts. 
%
% Also, know who is never so lucky? A new contributor. Someone who wants to
% contribute to your code and hasn't learned the system you have put in
% place to develop the project. We see that some of the best projects do
% indeed have their own build framework put in place. This is great for
% them, but even in these cases a new developer on the project needs to
% learn this custom system, which is different than all the other systems
% to build MATLAB code. 
%
% Well, not anymore. Starting in R2022b we now have a standard interface
% and build framework that enables project owners to easily produce their
% build in a way that anyone else can consume, no matter how complicated
% the build pipeline is. We need to go from the ad-hoc scripts and custom
% build system to a known, structured, and standard framework.
%
% <<y2022AdHoc2BuildTool.png>>
%
% Let's take my favorite simple Mass-Spring-Damper example (looks like I am
% still a mechanical engineer at heart). This is a simple example "toolbox"
% that has 3 components, a design script *|springMassDamperDesign.m|* that
% defines stiffness and damping constants for the system, a function
% *|simulateSystem.m|* that simulates the system from an initial condition
% outside of equilibrium to show the impulse response, and a mex file
% *|convec.c|* that convolves two arrays, which might be a useful utility
% for a dynamic system such as this. It also has a couple tests to ensure
% all is well and good as the code changes.
%
% If I am the author of this code, hopefully I know all about these
% components and why they were written as they were. However, if I am a
% contributor for the first time to this code base I have no idea. My
% workflow might look something like this:
%
% # Get the code
% # Use the toolbox
% # See there is something I want to change about the toolbox, a feature to
% add or a tweak to the design
% # Make the change
% 
% Seems like I am setting myself up for a solid contribution, and I am very
% proud of myself.















