function tests = docTest
tests = functiontests(localfunctions);
end

function docRunsWithoutWarningTest(testCase)

fig = figure;
testCase.addTeardown(@close, fig);

testCase.verifyWarningFree(@runDocExample);
end

function runDocExample
BUILD_ROOT = "../.."; %#ok<NASGU> 
GettingStarted;
end
